using Dapr.Client;
using Mosaic.MosaicApi;
using System.Reflection.Metadata.Ecma335;

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

    public async Task<MosaicReadDto[]> GetMosaics(int page = 1, int pageSize = 10)
    {
        return await _dapr.InvokeMethodAsync<MosaicReadDto[]>(HttpMethod.Get, "mosaicapi", $"mosaics?page={page}&pageSize={pageSize}");
    }

    public async Task<MosaicReadDto> GetMosaic(int id)
    {
        return await _dapr.InvokeMethodAsync<MosaicReadDto>(HttpMethod.Get, "mosaicapi", $"mosaics/{id}");
    }

    public async Task SetMosaicImage(string id, byte[] bytes)
    {
        await _dapr.InvokeMethodAsync<byte[]>("mosaicapi", $"mosaics/{id}", bytes);
    }

    public async Task<MosaicReadDto> AddNewMosaicAsync(string name, int sourceTileId, int horizontalTileCount, int VerticalTileCount)
    {
        var newTile = await _dapr.InvokeMethodAsync<MosaicCreateDto, MosaicReadDto>("mosaicapi", "mosaics", 
            new MosaicCreateDto (name, sourceTileId, horizontalTileCount, VerticalTileCount));
        return newTile;
    }
}
