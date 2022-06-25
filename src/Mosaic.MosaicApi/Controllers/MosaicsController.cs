using Dapr.Client;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.FileProviders;
using Mosaic.MosaicApi.Data;

namespace Mosaic.MosaicApi.Controllers;

[ApiController]
[Route("[controller]")]
public class MosaicsController : ControllerBase
{
    private const string PubsubName = "pubsub";
    private readonly DaprClient _daprClient;

    static Dictionary<int, MosaicEntity> mosaics = new Dictionary<int, MosaicEntity>();
    static int nextId = 1;


    public MosaicsController(DaprClient dapr)
    {
        _daprClient = dapr;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<MosaicReadDto>>> GetAllTiles([FromQuery] int page = 1, [FromQuery] int pageSize = 20, [FromQuery] bool details = false)
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
            Status = entity.Status,
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

        return NotFound();
    }

    [HttpGet("{id}/image")]
    public IActionResult GetImageById(int id)
    {
        if (mosaics.ContainsKey(id))
        {
            var mosaic = mosaics[id];
            if (mosaic.ImageId is null)
            {
                return this.NoContent();
            }

            var fileStream = System.IO.File.OpenRead(@"C:\src\Mosaic\src\Mosaic.MosaicApi\wwwroot\test.jpg");
            return File(fileStream, "image/jpg", "test.jpg",false);
        }

        return NotFound();
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
            Status = "created",
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

        return NotFound("Mosaic Id not found");
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
            return NotFound("Mosaic Id not found");
        }
    }
}
