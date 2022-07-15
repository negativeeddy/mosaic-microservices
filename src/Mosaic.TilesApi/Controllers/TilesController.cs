using Dapr.Client;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Identity.Web.Resource;
using Mosaic.TilesApi.Data;
using Mosaic.TileSources.Flickr;
using NetTopologySuite.Geometries;
using System.Text.Json;

namespace Mosaic.TilesApi.Controllers;

[Authorize]
[Route("[controller]")]
[ApiController]
[RequiredScope(RequiredScopesConfigurationKey = "AzureAdB2C:Scopes")]
public partial class TilesController : ControllerBase
{
    private const string PubsubName = "pubsub";
    private readonly TilesDbContext _context;
    private readonly DaprClient _dapr;
    private readonly ILogger<TilesController> _logger;

    public TilesController(TilesDbContext context, DaprClient dapr, ILogger<TilesController> logger)
    {
        _logger = logger;
        _context = context;
        _dapr = dapr;
    }

    static readonly string[] acceptableLicenses = new string[] {
        //"0", // All Rights Reserved
        "1", // Attribution-NonCommercial-ShareAlike License
        "2", // Attribution-NonCommercial License
        //"3", // Attribution-NonCommercial-NoDerivs License
        "4", // Attribution License
        "5", // Attribution-ShareAlike License
        //"6", // Attribution-NoDerivs License
        "7", // No known copyright restrictions
        "8", // United States Government Work
        "9", // Public Domain Dedication (CC0)
        "10"  // Public Domain Mark
    };

    [HttpPost("import/flickr")]
    public async Task<ActionResult> ImportFromFlickr([FromBody] FlickrOptions options)
    {
        // TODO this should be its own microservice
        HttpClient _client = new HttpClient();


        var data = await GetTodaysInteresting(options);

        List<(string, string)> statuses = new List<(string, string)>(data.Length);

        foreach (var item in data)
        {
            var itemStatus = (id: item.Id, status: "waiting");
            try
            {
                var newTile = new TileCreateDto()
                {
                    Source = "flickr",
                    SourceId = item.Id,
                    SourceData = JsonSerializer.Serialize(item),
                };

                await CreateTile(newTile);
            }
            catch (Exception ex)
            {
                if (ex.InnerException is HttpRequestException httpEx &&
                    httpEx.StatusCode == System.Net.HttpStatusCode.UnprocessableEntity)
                {
                    _logger.LogWarning(ex, "failed to add flickr id {Id} to tiles because {Reason}", item.Id, httpEx.Message);
                    itemStatus.status = "duplicate";
                }
                else
                {
                    _logger.LogError(ex, "failed to add flickr id {Id} to tiles", item.Id);
                    itemStatus.status = "error";
                }
            }

            statuses.Add(itemStatus);
        }

        return Ok(statuses);

        async Task<FlickrTileData[]> GetTodaysInteresting(FlickrOptions options)
        {

            int pageCount = 500;
            int pageNumber = 1;
            string interestingUrl = $"https://www.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key={options.ApiKey}&format=json&nojsoncallback=1&per_page={pageCount}&page={pageNumber}&extras=license";
            var response = await _client.GetFromJsonAsync<InterestingnessResponse>(interestingUrl);
            var usable = response!.photos.photo.Where(p => acceptableLicenses.Contains(p.license));
            return usable.Select(p => new FlickrTileData(p.id, p.secret, p.server)).ToArray();
        }

    }

    [HttpPost("import/image")]
    public async Task<ActionResult<TileReadDto>> CreateTileFromImage(IFormFileCollection files, string? imageName = null)
    {
        // store the tile in local storage
        MemoryStream stream = new MemoryStream();
        var newTiles = new List<TileReadDto>(files.Count);

        var file = files.First();
        stream.Position = 0;
        await file.CopyToAsync(stream);
        byte[] imageBytes = stream.ToArray();
        var result = await _dapr.InvokeBindingAsync<byte[], BlobResponse>("tilestorage", "create", imageBytes);
        _logger.LogInformation($"Uploaded image to {result.blobURL}");

        // add the tile to the db
        string blobId = new Uri(result.blobURL).Segments.Last();
        var tileResult = await CreateTile(new TileCreateDto
        {
            Source = "internal",
            SourceId = blobId,
            SourceData = JsonSerializer.Serialize(new BlobTileData(blobId, file.FileName ?? string.Empty))
        });

        return tileResult;
    }


    // GET: /Tiles
    [HttpGet]
    public async Task<ActionResult<IEnumerable<TileReadDto>>> GetAllTiles([FromQuery] int page = 1, [FromQuery] int pageSize = 20)
    {
        var tiles = await _context.Tiles
                                  .Skip((page - 1) * pageSize)
                                  .Take(pageSize)
                                  .Select(entity => TileReadDtoFromTileEntity(entity))
                                  .ToListAsync();

        return tiles;
    }

    // GET: /Tiles/5
    [HttpGet("{id}")]
    public async Task<ActionResult<TileReadDto>> GetTile(int id)
    {
        var tile = await _context.Tiles.FindAsync(id);

        if (tile == null)
        {
            return NotFound();
        }

        return TileReadDtoFromTileEntity(tile);
    }

    private static TileReadDto TileReadDtoFromTileEntity(TileEntity tile)
    {
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
            AverageColor = tile.Average != null ? new Color((byte)tile.Average.X, (byte)tile.Average.Y, (byte)tile.Average.Z) : null,
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
        entity.Average = new(tile.AverageColor.Red, tile.AverageColor.Green, tile.AverageColor.Blue);
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
                });
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
    public async Task<ActionResult<TileReadDto>> CreateTile(TileCreateDto tile)
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

        _logger.LogInformation("Created tile {Source}:{SourceId}", entity.Source, entity.SourceId);

        TileReadDto newTile = new TileReadDto
        {
            Id = entity.Id,
            Source = entity.Source,
            SourceId = entity.SourceId,
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

    [HttpPost("nearesttiles")]
    public async Task<IActionResult> FindNearestMatchingTile(MatchInfo[] info)
    {
        List<TileEntity[]> entities = new List<TileEntity[]>(info.Length);
        foreach (var i in info)
        {
            TileEntity[] nearest = await GetNearestMatchingTile(i);
            entities.Add(nearest);
        }

        var result = entities.Select(e => e.Select(entity => TileReadDtoFromTileEntity(entity)).ToArray()).ToList();
        return base.Ok(result);
    }

    private async Task<TileEntity[]> GetNearestMatchingTile(MatchInfo info)
    {
        int maxTilesToFetch = info.Count ?? 1;

        const string sqlQuery =
 @"SELECT * ,
  ST_3DDistance(tiles.""Average"", {0}) AS dist
FROM public.""Tiles"" tiles
ORDER BY dist LIMIT {1}";

        (byte x, byte y, byte z) = info.Single;

        Point searchPoint = new Point(x, y, z);

        var nearest = await _context.Tiles
            .FromSqlRaw(sqlQuery, searchPoint, maxTilesToFetch)
            .AsNoTracking()
            .ToArrayAsync();
        return nearest;
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
