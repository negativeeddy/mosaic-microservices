using Dapr.Client;
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

    public async Task<TileReadDto[]> GetMosaicInfo()
    {
        var tiles = await _dapr.InvokeMethodAsync<TileReadDto[]>(HttpMethod.Get, "mosaicapi", "mosaics");
        return tiles;
    }

    public async Task SetMosaicImage(string id, byte[] bytes)
    {
        await _dapr.InvokeMethodAsync<byte[]>("mosaicapi", $"mosaics/{id}", bytes);
    }

    public async Task<MosaicReadDto> AddNewMosaic(MosaicCreateDto mosaic)
    {
        var newTile = await _dapr.InvokeMethodAsync<MosaicCreateDto, MosaicReadDto>("mosaicapi", "mosaics", mosaic);
        return newTile;
    }
}

public class MosaicReadDto
{
    public string Id { get; set; }
    public string Name { get; set; }
}

public class MosaicCreateDto
{
    public string Name { get; set; }
}