using Dapr.Client;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Identity.Web.Resource;
using Mosaic.MosaicApi.Data;
using System.Text;

namespace Mosaic.MosaicApi.Controllers;

[ApiController]
[Route("internal/mosaics")]
public class InternalMosaicsController : ControllerBase
{
    private const string PubsubName = "pubsub";
    private readonly ILogger<InternalMosaicsController> _logger;
    private readonly MosaicStore _mosaicStore;

    public InternalMosaicsController(ILogger<InternalMosaicsController> logger, MosaicStore mosaicStore)
    {
        _logger = logger;
        this._mosaicStore = mosaicStore;
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
    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(string id)
    {
        var mosaic = await _mosaicStore.GetMosaic(id);
        if (mosaic is not null)
        {
            return Ok(MosaicReadDtoFromMosaicEntity(mosaic, true));
        }

        return NotFound($"Mosaic '{id}' not found");
    }


    [HttpGet("{id}/tiles")]
    public async Task<IActionResult> GetMosaicTile(MosaicTileDto tileData, string id)
    {
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
