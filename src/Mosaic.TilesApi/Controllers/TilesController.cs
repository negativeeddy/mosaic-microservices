#nullable disable
using Dapr.Client;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Mosaic.TilesApi.Data;
using Mosaic.TilesApi.Models;

namespace Mosaic.TilesApi.Controllers;

[Route("[controller]")]
[ApiController]
public class TilesController : ControllerBase
{
    private const string PubsubName = "pubsub";
    private readonly TilesDbContext _context;
    private readonly DaprClient _dapr;

    public TilesController(TilesDbContext context, DaprClient dapr)
    {
        _context = context;
        _dapr = dapr;
    }

    // GET: /Tiles
    [HttpGet]
    public async Task<ActionResult<IEnumerable<TileReadDto>>> GetAllTiles()
    {
        var tiles = await _context.Tiles.Select(entity =>
        new TileReadDto
        {
            Id = entity.Id,
            Aspect = entity.Aspect,
            Date = entity.Date,
            Height = entity.Height,
            Width = entity.Width,
            Source = entity.Source,
            SourceId = entity.SourceId,
            SourceData = entity.SourceData,
            AverageColor = entity.AverageR.HasValue ? new Color(entity.AverageR.Value, entity.AverageB.Value, entity.AverageG.Value) : null,
        }).ToListAsync();

        return tiles;
    }

    // GET: /Tiles/5
    [HttpGet("{id}")]
    public async Task<ActionResult<TileReadDto>> GetTile(string id)
    {
        var tile = await _context.Tiles.FindAsync(id);

        if (tile == null)
        {
            return NotFound();
        }

        return new TileReadDto
        {
            Id = tile.Id,
            Aspect = tile.Aspect,
            Date = tile.Date,
            Height = tile.Height,
            Width = tile.Width,
            Source = tile.Source,
            SourceId = tile.SourceId,
            SourceData = tile.SourceData,
            AverageColor = tile.AverageR.HasValue ? new Color(tile.AverageR.Value, tile.AverageB.Value, tile.AverageG.Value) : null,
        };
        }

    // PUT: /Tiles/5
    // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
    [HttpPut("{id}")]
    public async Task<IActionResult> PutTile(int id, TileUpdateDto tile)
    {
        if (id != tile.Id)
        {
            return BadRequest();
        }

        var entity = await _context.Tiles.FindAsync(id);
        if (entity == null)
        {
            return NotFound();
        }

        entity.Aspect = tile.Aspect;
        (entity.AverageR, entity.AverageG, entity.AverageB) = tile.AverageColor;
        entity.Height = tile.Height;
        entity.Width = tile.Width;

        try
        {
            await _context.SaveChangesAsync();

            await _dapr.PublishEventAsync(
                PubsubName,
                nameof(TileUpdatedEvent),
                new TileUpdatedEvent
                {
                    TileId = tile.Id,
                    Width = tile.Width,
                    Aspect = tile.Aspect,
                    Height = tile.Height,
                    AverageColor = new Color(tile.AverageColor.Red, tile.AverageColor.Green, tile.AverageColor.Blue),
                }) ;
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!TileExists(id))
            {
                return NotFound();
            }
            else
            {
                throw;
            }
        }

        return NoContent();
    }

    // POST: /Tiles
    // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
    [HttpPost]
    public async Task<ActionResult<TileReadDto>> PostTile(TileCreateDto tile)
    {
        if (!this.ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        if (TileExists(tile.Source, tile.SourceId))
        {
            return this.UnprocessableEntity($"Tile {tile.Source}:{tile.SourceId} already exists");
        }

        var entity = new TileEntity()
        {
            Source = tile.Source,
            SourceId = tile.SourceId,
            SourceData = tile.SourceData,
        };

        _context.Tiles.Add(entity);
        await _context.SaveChangesAsync();

        TileReadDto newTile = new TileReadDto
        {
            Id = entity.Id,
            Source = entity.Source,
            SourceId =  entity.SourceId,
            SourceData = entity.SourceData,
        };

        await _dapr.PublishEventAsync(
            PubsubName, 
            nameof(TileCreatedEvent), 
            new TileCreatedEvent
            {
                TileId = newTile.Id,
                Source = newTile.Source,
                SourceId = newTile.SourceId,
                SourceData = newTile.SourceData,
            });

        return CreatedAtAction("GetTile", new { id = newTile.Id }, newTile);
    }

    // DELETE: /Tiles/5
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteTile(int id)
    {
        var tile = await _context.Tiles.FindAsync(id);
        if (tile == null)
        {
            return NotFound();
        }

        _context.Tiles.Remove(tile);
        await _context.SaveChangesAsync();
        await _dapr.PublishEventAsync(
            PubsubName, 
            nameof(TileDeletedEvent),
            new TileDeletedEvent { TileId = tile.Id });

        return NoContent();
    }

    private bool TileExists(int id)
    {
        return _context.Tiles.Any(e => e.Id == id);
    }

    private bool TileExists(string source, string sourceId)
    {
        return _context.Tiles.Any(e => e.Source == source 
                                    && e.SourceId == sourceId);
    }
}
