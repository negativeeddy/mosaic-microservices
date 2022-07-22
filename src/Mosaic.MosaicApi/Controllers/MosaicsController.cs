using Dapr.Client;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Identity.Web.Resource;
using Mosaic.MosaicApi.Data;
using System.Text;

namespace Mosaic.MosaicApi.Controllers;

//[Authorize]
[ApiController]
[Route("[controller]")]
//[RequiredScope(RequiredScopesConfigurationKey = "AzureAdB2C:Scopes")]
public class MosaicsController : ControllerBase
{
    private const string PubsubName = "pubsub";
    // fakeUser is a placeholder user ID until authentication is in place
    private readonly DaprClient _daprClient;
    private readonly ILogger<MosaicsController> _logger;
    private readonly MosaicStore _mosaicStore;

    public MosaicsController(DaprClient dapr, ILogger<MosaicsController> logger, MosaicStore mosaicStore)
    {
        _daprClient = dapr;
        _logger = logger;
        this._mosaicStore = mosaicStore;
    }

    // user ID is the Object ID of the user in AADB2C
    public string CurrentUserId => User.Claims.First(c => c.Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier").Value;
    
    [HttpGet]
    public async Task<ActionResult<IEnumerable<MosaicReadDto>>> GetAllMosaics([FromQuery] int page = 1, [FromQuery] int pageSize = 20, [FromQuery] bool details = false)
    {
        var result = (await _mosaicStore.GetAllMosaicsForUser(CurrentUserId))
                            .Select(m => MosaicReadDtoFromMosaicEntity(m, details));
        return Ok(result);
    }

    private MosaicReadDto MosaicReadDtoFromMosaicEntity(MosaicEntity entity, bool details = false)
    {
        return new MosaicReadDto
        {
            Name = entity.Name,
            SourceId = entity.TileSourceId,
            TileDetails = details ? entity.TileIds : null,
            HorizontalTileCount = entity.HorizontalTileCount,
            VerticalTileCount = entity.VerticalTileCount,
            Status = Enum.Parse<MosaicStatus>(entity.Status, true),
            Width = entity.Width,
            Height = entity.Height,
            MatchStyle = (int)entity.MatchStyle,
        };
    }


    // GET api/<MosaicController>/5
    [HttpGet("{name}")]
    public async Task<IActionResult> GetById(string name)
    {
        string id = GetMosaicId(name);
        var mosaic = await _mosaicStore.GetMosaic(id);
        if (mosaic is not null)
        {
            return Ok(MosaicReadDtoFromMosaicEntity(mosaic, true));
        }

        return NotFound($"Mosaic '{id}' not found");
    }

    [HttpGet("{name}/image")]
    public async Task<IActionResult> GetMosaicImage(string name)
    {
        string id = GetMosaicId(name);
        var mosaic = await _mosaicStore.GetMosaic(id);
        if (mosaic is not null)
        {
            if (mosaic.ImageId is null)
            {
                return this.NoContent();
            }

            Stream fileStream = await GetMosaicFromStorage(mosaic.ImageId);
            return File(fileStream, "image/jpg", "test.jpg", false);
        }

        return NotFound();
    }

    private async Task<Stream> GetMosaicFromStorage(string imageId)
    {
        // TODO de-duplicate this method - is copy of TileProcessor code
        var bindingRequest = new BindingRequest("mosaicstorage", "get");
        bindingRequest.Metadata.Add("blobName", imageId);
        var response = await _daprClient.InvokeBindingAsync(bindingRequest);
        var storageBytes = response.Data.ToArray();


        _logger.LogInformation("Retrieved mosaic {MosaicId} from internal storage. {byteCount} bytes, first 4 bytes are {B1}, {B2}, {B3}, {B4}",
            imageId, storageBytes.Length, storageBytes[0], storageBytes[1], storageBytes[2], storageBytes[3]);

        byte[] imageBytes;
        // check if is base64 encoded - can't currently deploy to Container Apps with dapr binding set to 
        // auto encode/decode. sometimes Dapr doesnt decode properly
        try
        {
            // TODO make this check better. Should not use exceptions as flow control
            _logger.LogInformation("Base64 decoding binary stream");
            var storageChars = Encoding.UTF8.GetChars(storageBytes);
            imageBytes = Convert.FromBase64CharArray(storageChars, 0, storageChars.Length);
            _logger.LogInformation("New stream is {Length} bytes", storageBytes.Length);
        }
        catch
        {
            _logger.LogInformation("Failed to Base64 decoding binary stream - using original stream");
            imageBytes = storageBytes;
        }
        MemoryStream imageStream = new MemoryStream(imageBytes);

        return imageStream;
    }

    // POST api/<MosaicController>
    [HttpPost]
    public async Task<ActionResult> CreateMosaic([FromBody] MosaicCreateDto options)
    {
        MosaicEntity newMosaic = MosaicEntityFromMosaicCreateDto(options);

        string mosaicId = GetMosaicId(options.Name);

        try
        {
            await _mosaicStore.SaveMosaic(CurrentUserId, mosaicId, newMosaic);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }

        await _daprClient.PublishEventAsync(
            PubsubName,
            nameof(MosaicCreatedEvent),
            new MosaicCreatedEvent(mosaicId, options));

        return Created($"mosaics/{newMosaic.Name}", MosaicReadDtoFromMosaicEntity(newMosaic));
    }

    private string GetMosaicId(string name)
    {
        return CurrentUserId + ":" + name;
    }

    private MosaicEntity MosaicEntityFromMosaicCreateDto(MosaicCreateDto options)
    {
        return new MosaicEntity
        {
            UserId = CurrentUserId,
            Name = options.Name,
            TileSourceId = options.SourceTileId,
            HorizontalTileCount = options.HorizontalTileCount,
            VerticalTileCount = options.VerticalTileCount,
            TileIds = new int?[options.HorizontalTileCount * options.VerticalTileCount],
            Status = MosaicStatus.Created.ToString(),
            Width = options.Width,
            Height = options.Height,
            MatchStyle = (TileMatchAlgorithm)options.MatchStyle,
        };
    }

    // PUT api/<MosaicController>/5
    [HttpPut("{id}")]
    public void Put(int id, [FromBody] string value)
    {
        throw new NotImplementedException();
    }

    // DELETE api/<MosaicController>/5
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(string name)
    {
        bool success = await _mosaicStore.DeleteMosaic(GetMosaicId(name));
        if (success)
        {
            return Ok();
        }
        return NotFound();
    }

    [HttpGet("{id}/tiles")]
    public async Task<IActionResult> GetMosaicTile(MosaicTileDto tileData, string name)
    {
        string id = GetMosaicId(name);
        var mosaic = await _mosaicStore.GetMosaic(id);
        if (mosaic is not null)
        {
            if (mosaic.TileIds is null)
            {
                return Ok(new MosaicTileDto { MosaicId = id, Row = tileData.Row, Column = tileData.Column, TileId = -1 });
            }
            else
            {
                int idx = mosaic.GetTileIndex(tileData.Row, tileData.Column);
                return Ok(new MosaicTileDto { MosaicId = id, Row = tileData.Row, Column = tileData.Column, TileId = mosaic.TileIds[idx] ?? -1 });
            }
        }

        return NotFound($"Mosaic {id} not found");
    }

    [HttpPost("{id}/status")]
    public async Task<IActionResult> SetMosaicStatus(string id, [FromBody] MosaicStatus status)
    {
        var mosaic = await _mosaicStore.GetMosaic(id);

        if (mosaic is not null)
        {
            mosaic.Status = status.ToString();

            await _mosaicStore.SaveMosaic(null, id, mosaic);
            return Ok(new MosaicStatusResponse(id, status));
        }
        else
        {
            return NotFound($"Mosaic {id} not found");
        }
    }

    [HttpGet("{id}/status")]
    public async Task<IActionResult> GetMosaicStatus(string id)
    {
        var mosaic = await _mosaicStore.GetMosaic(id);
        if (mosaic is not null)
        {
            return Ok(new MosaicStatusResponse(id, Enum.Parse<MosaicStatus>(mosaic.Status)));
        }
        else
        {
            return NotFound($"Mosaic {id} not found");
        }
    }

    [HttpPost("{id}/imageId")]
    public async Task<IActionResult> SetMosaicImageId(string id, [FromBody] string imageId)
    {
        var mosaic = await _mosaicStore.GetMosaic(id);
        if (mosaic is not null)
        {
            mosaic.ImageId = imageId;
            await _mosaicStore.SaveMosaic(null, id, mosaic);
            return Ok(new { Id = id, ImageId = imageId });
        }
        else
        {
            return NotFound($"Mosaic {id} not found");
        }
    }

    [HttpGet("{id}/imageId")]
    public async Task<IActionResult> GetMosaicImageId(string id)
    {
        var mosaic = await _mosaicStore.GetMosaic(id);
        if (mosaic is not null)
        {
            return Ok(new { Id = id, mosaic.ImageId });
        }
        else
        {
            return NotFound($"Mosaic {id} not found");
        }
    }


    [HttpPost("{id}/tiles")]
    public async Task<IActionResult> SetMosaicTile(string id, [FromBody] MosaicTileDto[] tileData)
    {
        foreach (var tile in tileData)
        {
            if (id != tile.MosaicId)
            {
                return BadRequest($"Id does not match mosaic id in tile {tile.TileId}");
            }
        }

        var mosaic = await _mosaicStore.GetMosaic(id);

        if (mosaic is null)
        {
            return NotFound($"Mosaic {id} not found");
        }

        foreach (var tile in tileData)
        {
            int idx = mosaic.GetTileIndex(tile.Row, tile.Column);

            if (mosaic.TileIds is null)
            {
                mosaic.TileIds = new int?[tile.Row * tile.Column];
            }

            mosaic.TileIds![idx] = tile.TileId;
        }

        await _mosaicStore.SaveMosaic(null, id, mosaic);

        return Ok(tileData);
    }
}
