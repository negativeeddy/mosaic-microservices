﻿using Dapr.Client;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Mosaic.TilesApi.Data;
using Mosaic.TileSources.Flickr;
using NetTopologySuite.Geometries;
using System.Text.Json;

namespace Mosaic.TilesApi.Controllers;

[Route("internal/tiles")]
[ApiController]
public partial class InternalTilesController : ControllerBase
{
    private const string PubsubName = "pubsub";
    private readonly TilesDbContext _context;
    private readonly DaprClient _dapr;
    private readonly ILogger<InternalTilesController> _logger;
    private readonly IHttpClientFactory _httpClientFactory;

    public InternalTilesController(TilesDbContext context, DaprClient dapr, ILogger<InternalTilesController> logger, IHttpClientFactory httpClientFactory)
    {
        _logger = logger;
        _httpClientFactory = httpClientFactory;
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
    public async Task<ActionResult<ItemStatus[]>> ImportFromFlickr([FromBody] ImportOptions options, string? userId)
    {
        HttpClient client = _httpClientFactory.CreateClient();

        var data = new List<FlickrTileData>();
        List<ItemStatus> statuses = new List<ItemStatus>();

        if (options.FlickrApiKey is not null)
        {

            if (options.ImportInteresting ?? false)
            {

                var interestingTiles = await GetTodaysInteresting(options.FlickrApiKey);
                data.AddRange(interestingTiles);
            }

            if (options.Searches is not null)
            {
                foreach (var search in options.Searches)
                {
                    var searchTiles = await SearchFlickr(options.FlickrApiKey, options.Searches);
                    data.AddRange(searchTiles);
                }
            }


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

                    ActionResult<TileReadDto> ar = await CreateTile(newTile, userId);

                    ItemStatus status = ar.Result switch
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

            // log import results
            var groups = statuses.GroupBy(s => s.Status);
            foreach (var g in groups)
            {
                _logger.LogInformation("flicker import: {status} = {count}", g.Key, g.Count());
            }
        }

        return Ok(statuses.ToArray());

        async Task<FlickrTileData[]> GetTodaysInteresting(string flickrKey)
        {

            int pageCount = 500;
            int pageNumber = 1;
            string interestingUrl = $"https://www.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key={flickrKey}&format=json&nojsoncallback=1&per_page={pageCount}&page={pageNumber}&extras=license";
            var response = await client.GetFromJsonAsync<InterestingnessResponse>(interestingUrl);
            var usable = response!.photos.photo.Where(p => acceptableLicenses.Contains(p.license));
            return usable.Select(p => new FlickrTileData(p.id, p.secret, p.server, p.owner)).ToArray();
        }

        async Task<IList<FlickrTileData>> SearchFlickr(string flickrKey, FlickrSearchOptions[] searchOptions)
        {
            try
            {
                List<FlickrTileData> tiles = new List<FlickrTileData>();
                string licenses = string.Join(',', acceptableLicenses);
                foreach (var search in searchOptions)
                {
                    int pageCount = 500;
                    int pageNumber = 1;
                    
                    string url = $"https://www.flickr.com/services/rest/?method=flickr.photos.search" +
                    $"&api_key={flickrKey}&license={licenses}" +
                    $"&per_page={pageCount}&page={pageNumber}&format=json" +
                    $"&nojsoncallback=1&extras=license,url_m&content_type=1" +
                    $"&privacy_filter=1&safe_search=1";

                    string tags = null;
                    if (search.Tags is not null)
                    {
                        tags = string.Join(',', search.Tags);
                        url += "&tags=" + tags;
                    }
                    _logger.LogInformation("searching flickr for tags: {tags}", tags);

                    var response = await client.GetFromJsonAsync<InterestingnessResponse>(url);
                    tiles.AddRange(response.photos.photo.Select(p => new FlickrTileData(p.id, p.secret, p.server, p.owner)));
                }
                return tiles;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "failed to search flickr for tags {searchOptions}", searchOptions);
                return Array.Empty<FlickrTileData>();
            }
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
        },
                                          null);

        return tileResult;
    }


    // GET: /Tiles
    [HttpGet]
    public async Task<ActionResult<IEnumerable<TileReadDto>>> GetAllTiles([FromQuery] int page = 1, [FromQuery] int pageSize = 20, string? ownerId = null)
    {
        var tiles = await _context.Tiles
                                  .Where(t => t.OwnerId == ownerId)
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

        var entity = await _context.Tiles.AsTracking().FirstOrDefaultAsync(x => x.Id == id);
        if (entity == null)
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
                    AverageColor = tile.AverageColor is not null ?
                                   new Color(tile.AverageColor.Red, tile.AverageColor.Green, tile.AverageColor.Blue) :
                                   null,
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
    public async Task<ActionResult<TileReadDto>> CreateTile(TileCreateDto tile, [FromQuery] string? ownerId)
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
            OwnerId = ownerId,
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
                                       .FirstOrDefaultAsync(t => t.Id == id);
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
    public async Task<IActionResult> FindNearestMatchingTile(MatchInfo[] info, [FromQuery] string userId)
    {
        List<TileEntity[]> entities = new List<TileEntity[]>(info.Length);
        foreach (var i in info)
        {
            _logger.LogDebug("Calculating nearest tile to {MatchInfo} for {usedId}", i, userId);
            TileEntity[] nearest = await GetNearestMatchingTile(i, userId);
            entities.Add(nearest);
        }

        var result = entities.Select(e => e.Select(entity => TileReadDtoFromTileEntity(entity)).ToArray()).ToList();

        return base.Ok(result);
    }

    private async Task<TileEntity[]> GetNearestMatchingTile(MatchInfo info, string userId)
    {
        int maxTilesToFetch = info.Count ?? 1;

        const string sqlQuery =
        """
        SELECT *, ST_3DDistance(tiles."Average", {0}) AS dist
        FROM public."Tiles" tiles
        WHERE tiles."OwnerId" is null OR tiles."OwnerId" = {1}
        ORDER BY dist LIMIT {2}
        """;

        (byte x, byte y, byte z) = info.Single!;

        Point searchPoint = new Point(x, y, z);

        var nearest = await _context.Tiles
            .FromSqlRaw(sqlQuery, searchPoint, userId, maxTilesToFetch)
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
