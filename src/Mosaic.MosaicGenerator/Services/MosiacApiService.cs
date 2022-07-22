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

    public async Task SetMosaicStatus(string id, MosaicStatus status)
    {
        await _dapr.InvokeMethodAsync<MosaicStatus, MosaicStatusResponse>(
            "mosaicapi", $"/internal/mosaics/{id}/status", status);
    }

    public async Task SetMosaicTiles(string id, MosaicTileDto[] tiles)
    {
        await _dapr.InvokeMethodAsync<MosaicTileDto[], MosaicTileDto[]>(
            "mosaicapi",
            $"/internal/mosaics/{id}/tiles",
            tiles);
    }

    public async Task SetMosaicImageId(string id, string imageId)
    {
        var idResponse = await _dapr.InvokeMethodAsync<string, MosaicImageIdResponse>(
            "mosaicapi", $"/internal/mosaics/{id}/imageId", imageId);
    }

    public async Task<TileReadDto> GetTile(int id)
    {
        return await _dapr.InvokeMethodAsync<TileReadDto>(HttpMethod.Get, "tilesapi", $"/internal/Tiles/{id}");
    }

    public async Task<IList<TileReadDto[]>> GetNearestTileSingleAverage(Color avgColor, string userId)
    {
        var matches = await _dapr.InvokeMethodAsync<MatchInfo[], List<TileReadDto[]>>(
        "tilesapi",
        $"/internal/tiles/nearesttiles?userId={userId}",
        new MatchInfo[] { new() { Single = avgColor } });
        return matches;
    }

    public async Task SetMosaicImage(string id, byte[] imageBytes)
    {
        string blobname = $"{id}-mosaic.jpg";

        // store the tile in local storage
        var result = await _dapr.InvokeBindingAsync<byte[], BlobResponse>("mosaicstorage", "create", imageBytes,
            new Dictionary<string, string>
            {
                ["blobName"] = blobname,
            });
        _logger.LogInformation($"Uploaded final mosaic image {id} to {result.blobURL}");

        await SetMosaicImageId(id, blobname);
    }

    public record BlobResponse(string blobURL);
}
