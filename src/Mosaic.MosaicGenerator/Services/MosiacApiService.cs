using Dapr.Client;
using Mosaic.MosaicApi;
using Mosaic.TilesApi;

namespace Mosaic.MosaicGenerator.Services;

public class MosaicService
{
    private readonly DaprClient _dapr;
    private readonly ILogger<MosaicService> _logger;

    public MosaicService(DaprClient dapr, ILogger<MosaicService> logger)
    {
        _dapr = dapr;
        _logger = logger;
    }

    public async Task SetMosaicStatus(int id, MosaicStatus status)
    {
        await _dapr.InvokeMethodAsync<MosaicStatus, MosaicStatusResponse>(
            "mosaicapi", $"mosaics/{id}/status", status);
    }

    public async Task SetMosaicImageId(int id, string imageId)
    {
        var idResponse = await _dapr.InvokeMethodAsync<string, MosaicImageIdResponse>(
            "mosaicapi", $"mosaics/{id}/imageId", imageId);
    }

    public async Task<TileReadDto> GetTile(int id)
    {
        return await _dapr.InvokeMethodAsync<TileReadDto>(HttpMethod.Get, "tilesapi", $"Tiles/{id}");
    }

    public async Task SetMosaicImage(int id, byte[] imageBytes)
    {
        // store the tile in local storage
        var result = await _dapr.InvokeBindingAsync<byte[], BlobResponse>("mosaicstorage", "create", imageBytes);
        _logger.LogInformation($"Uploaded final mosaic image {id} to {result.blobURL}");

        string mosaicImageId = new Uri(result.blobURL).Segments.Last();

        await SetMosaicImageId(id, mosaicImageId);
    }

    public record BlobResponse(string blobURL);
}
