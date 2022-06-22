using Dapr.Client;
using Mosaic.TilesApi;
using Mosaic.TileSources.AzureBlobStorage;
using System.Text.Json;

namespace Mosaic.FrontEnd.Data;

public class TileService
{
    private readonly DaprClient _dapr;
    private readonly ILogger<TileService> _logger;

    public TileService(DaprClient dapr, ILogger<TileService> logger)
    {
        _dapr = dapr;
        _logger = logger;
    }

    public async Task<TileReadDto[]> GetTiles(int page = 0, int pageSize = 20)
    {
        var tiles = await _dapr.InvokeMethodAsync<TileReadDto[]>(HttpMethod.Get, "tilesapi", $"Tiles?page={page}&pageSize={pageSize}");
        return tiles;
    }

    public async Task<TileReadDto> AddNewTile(string name, byte[] bytes)
    {
        // store the tile in local storage
        var result = await _dapr.InvokeBindingAsync<byte[], BlobResponse>("tilestorage", "create", bytes);
        _logger.LogInformation($"Uploaded {name} to {result.blobURL}");

        // add the tile to the db
        string blobId = new Uri(result.blobURL).Segments.Last();
        var tile = await AddNewTile(new TileCreateDto
        {
            Source = "internal",
            SourceId = blobId,
            SourceData = JsonSerializer.Serialize(new BlobTileData(blobId, name))
        });

        return tile;
    }

    public async Task<TileReadDto> AddNewTile(TileCreateDto tile)
    {
        var newTile = await _dapr.InvokeMethodAsync<TileCreateDto, TileReadDto>("tilesapi", "Tiles", tile);
        return newTile;
    }
}
