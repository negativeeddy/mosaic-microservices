using Dapr.Client;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Identity.Web.Resource;
using Mosaic.TilesApi.Data;
using Mosaic.TileSources.Flickr;
using System.Text.Json;

namespace Mosaic.TilesApi.Controllers;

[Authorize]
[Route("external/tiles")]
[ApiController]
[RequiredScope(RequiredScopesConfigurationKey = "AzureAdB2C:Scopes")]
public partial class ExternalTilesController : ControllerBase
{
    private const string PubsubName = "pubsub";
    private readonly TilesDbContext _context;
    private readonly DaprClient _dapr;
    private readonly ILogger<ExternalTilesController> _logger;

    public ExternalTilesController(TilesDbContext context, DaprClient dapr, ILogger<ExternalTilesController> logger)
    {
        _logger = logger;
        _context = context;
        _dapr = dapr;
    }

    private string? currentUserID = null;
    public string CurrentUserId => currentUserID ??= User.Claims.First(c => c.Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier").Value;

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

    public record ImportStatus(string Id, string Status);

    [HttpPost("import/flickr")]
    public async Task<ActionResult<ImportStatus[]>> ImportFromFlickr([FromBody] FlickrOptions options)
    {
        // TODO this should be its own microservice
        HttpClient _client = new HttpClient();


        var data = await GetTodaysInteresting(options);

        List<ImportStatus> statuses = new List<ImportStatus>(data.Length);

        foreach (var item in data)
        {
            try
            {
                var newTile = new TileCreateDto()
                {
                    Source = "flickr",
                    SourceId = item.Id,
                    SourceData = JsonSerializer.Serialize(item),
                };

                ActionResult<TileReadDto> ar = await CreateTile(newTile);

                ImportStatus status = ar.Result switch
                {
                    UnprocessableEntityObjectResult => new(item.Id, "duplicate"),
                    CreatedAtActionResult => new(item.Id, "processing"),
                    _ => new(item.Id, "error"),

                };
                statuses.Add(status);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "failed to add flickr id {Id} to tiles", item.Id);
                statuses.Add(new(item.Id, "error"));
            }
        }

        return Ok(statuses.ToArray());

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
    public async Task<ActionResult<IEnumerable<TileReadDto>>> GetAllTiles([FromQuery] int page = 1, [FromQuery] int pageSize = 20, [FromQuery] string? source = null)
    {
        var query = _context.Tiles
                                  .OrderBy(t => t.Id)
                                  .Where(t => t.OwnerId == null || t.OwnerId == CurrentUserId);

        if (source is not null)
        {
            source = source.ToLowerInvariant();
            query = query.Where(t => t.Source == source);
        }

        var tiles = await query.Skip((page - 1) * pageSize)
                               .Take(pageSize)
                               .Select(entity => TileReadDtoFromTileEntity(entity))
                               .ToListAsync();

        return tiles;
    }

    private bool TileIsAllowed(TileEntity tile)
    {
        return tile.OwnerId == CurrentUserId || tile.OwnerId == null;
    }

    // GET: /Tiles/5
    [HttpGet("{id}")]
    public async Task<ActionResult<TileReadDto>> GetTile(int id)
    {
        var tile = await _context.Tiles.FindAsync(id);

        if (tile == null || !TileIsAllowed(tile))
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

        var entity = await _context.Tiles.AsTracking().SingleAsync(x => x.Id == id);
        if (entity == null || !TileIsAllowed(entity))
        {
            return NotFound();
        }

        entity.Aspect = tile.Aspect;
        if (tile.AverageColor is not null)
        {
            entity.Average = new(tile.AverageColor.Red, tile.AverageColor.Green, tile.AverageColor.Blue);
        }
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
                    AverageColor = tile.AverageColor is null ? null : new Color(tile.AverageColor.Red, tile.AverageColor.Green, tile.AverageColor.Blue),
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
            OwnerId = CurrentUserId,
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
        var tile = await _context.Tiles.AsTracking()
                                       .Where(t => t.Id == id && t.OwnerId == CurrentUserId)
                                       .FirstOrDefaultAsync();
        if (tile == null || !TileIsAllowed(tile))
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
