using Dapr.Client;
using Microsoft.AspNetCore.Mvc.ModelBinding.Metadata;
using Mosaic.TilesApi.Models;

namespace Mosaic.FrontEnd.Data;

public class MosaicService
{
    private readonly DaprClient _dapr;
    private readonly ILogger<MosaicService> _logger;

    public MosaicService(DaprClient dapr, ILogger<MosaicService> logger)
    {
        _dapr = dapr;
        _logger = logger;
    }

    public async Task<TileReadDto[]> GetAllTiles()
    {
        var tiles = await _dapr.InvokeMethodAsync<TileReadDto[]>(HttpMethod.Get, "tilesapi", "Tiles");
        return tiles;
    }

    public async Task<TileReadDto> CreateMosaic(string name, byte[] bytes)
    {
        // store the tile in local storage
        var result = await _dapr.InvokeBindingAsync<byte[], BlobResponse>(
            "mosaicstorage", 
            "create",
            bytes,
            new Dictionary<string,string> () { { "blobName", name} }
            );

        _logger.LogInformation($"Uploaded {name} to {result.blobURL}");

        // add the tile to the db
        string blobId = new Uri(result.blobURL).Segments.Last();
        var tile = await AddNewTile(new TileCreateDto
        {
            Source = "internal",
            SourceId = blobId,
            SourceData = blobId,
        });

        return tile;
    }

    public async Task<TileReadDto> AddNewTile(TileCreateDto tile)
    {
        var newTile = await _dapr.InvokeMethodAsync<TileCreateDto, TileReadDto>("tilesapi", "Tiles", tile);
        return newTile;
    }
}
