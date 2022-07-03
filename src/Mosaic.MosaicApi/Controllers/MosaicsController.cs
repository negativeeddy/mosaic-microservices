using Dapr.Client;
using Microsoft.AspNetCore.Mvc;
using Mosaic.MosaicApi.Data;
using System.Text;

namespace Mosaic.MosaicApi.Controllers;

[ApiController]
[Route("[controller]")]
public class MosaicsController : ControllerBase
{
    private const string PubsubName = "pubsub";
    private readonly DaprClient _daprClient;
    private readonly ILogger<MosaicsController> _logger;
    static Dictionary<int, MosaicEntity> mosaics = new Dictionary<int, MosaicEntity>();
    static int nextId = 1;


    public MosaicsController(DaprClient dapr, ILogger<MosaicsController> logger)
    {
        _daprClient = dapr;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<MosaicReadDto>>> GetAllMosaics([FromQuery] int page = 1, [FromQuery] int pageSize = 20, [FromQuery] bool details = false)
    {
        var result = mosaics.Values
                            .Skip((page - 1) * pageSize)
                            .Take(pageSize)
                            .Select(m => MosaicReadDtoFromMosaicEntity(m, details));
        return Ok(result);
    }

    private MosaicReadDto MosaicReadDtoFromMosaicEntity(MosaicEntity entity, bool details = false)
    {
        return new MosaicReadDto
        {
            Id = entity.Id,
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
    [HttpGet("{id}")]
    public IActionResult GetById(int id)
    {
        if (mosaics.ContainsKey(id))
        {
            return Ok(MosaicReadDtoFromMosaicEntity(mosaics[id], true));
        }

        return NotFound($"Mosaic {id} not found");
    }

    [HttpGet("{id}/image")]
    public async Task<IActionResult> GetImageById(int id)
    {
        if (mosaics.ContainsKey(id))
        {
            var mosaic = mosaics[id];
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
    public async Task<ActionResult> Post([FromBody] MosaicCreateDto options)
    {
        MosaicEntity newMosaic = MosaicEntityFromMosaicCreateDto(options);

        mosaics.Add(newMosaic.Id, newMosaic);

        await _daprClient.PublishEventAsync(
            PubsubName,
            nameof(MosaicCreatedEvent),
            new MosaicCreatedEvent(newMosaic.Id, options));

        return Created($"mosaics/{newMosaic.Id}", MosaicReadDtoFromMosaicEntity(newMosaic));
    }

    private static MosaicEntity MosaicEntityFromMosaicCreateDto(MosaicCreateDto options)
    {
        return new MosaicEntity
        {
            Id = nextId++,
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
    public IActionResult Delete(int id)
    {
        if (mosaics.Remove(id))
        {
            return Ok();
        }
        return NotFound();
    }

    [HttpGet("{id}/tiles")]
    public IActionResult GetMosaicTile(MosaicTileDto tileData, int id)
    {
        if (mosaics.ContainsKey(id))
        {
            var mosaic = mosaics[id];

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
    public IActionResult SetMosaicStatus(int id, [FromBody] MosaicStatus status)
    {
        if (mosaics.ContainsKey(id))
        {
            var mosaic = mosaics[id];
            mosaic.Status = status.ToString();

            return Ok(new MosaicStatusResponse(id, status));
        }
        else
        {
            return NotFound($"Mosaic {id} not found");
        }
    }

    [HttpGet("{id}/status")]
    public IActionResult GetMosaicStatus(int id)
    {
        if (mosaics.ContainsKey(id))
        {
            var mosaic = mosaics[id];
            return Ok(new MosaicStatusResponse(id, Enum.Parse<MosaicStatus>(mosaic.Status)));
        }
        else
        {
            return NotFound($"Mosaic {id} not found");
        }
    }

    [HttpPost("{id}/imageId")]
    public IActionResult SetMosaicImageId(int id, [FromBody] string imageId)
    {
        if (mosaics.ContainsKey(id))
        {
            var mosaic = mosaics[id];
            mosaic.ImageId = imageId;

            return Ok(new { Id = id, ImageId = imageId });
        }
        else
        {
            return NotFound($"Mosaic {id} not found");
        }
    }

    [HttpGet("{id}/imageId")]
    public IActionResult GetMosaicImageId(int id)
    {
        if (mosaics.ContainsKey(id))
        {
            var mosaic = mosaics[id];
            return Ok(new { Id = id, mosaic.ImageId });
        }
        else
        {
            return NotFound($"Mosaic {id} not found");
        }
    }


    [HttpPost("{id}/tiles")]
    public IActionResult SetMosaicTile(int id, [FromBody] MosaicTileDto tileData)
    {
        if (id != tileData.MosaicId)
        {
            return BadRequest("Ids do not match");
        }

        if (mosaics.ContainsKey(id))
        {
            var mosaic = mosaics[id];
            int idx = mosaic.GetTileIndex(tileData.Row, tileData.Column);

            if (mosaic.TileIds is null)
            {
                mosaic.TileIds = new int?[tileData.Row * tileData.Column];
            }

            mosaic.TileIds![idx] = tileData.TileId;

            return Ok(new MosaicTileDto { MosaicId = id, Row = tileData.Row, Column = tileData.Column, TileId = tileData.TileId });
        }
        else
        {
            return NotFound($"Mosaic {id} not found");
        }
    }
}
