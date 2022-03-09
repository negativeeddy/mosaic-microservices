using Mosaic.TilesApi;
using Mosaic.TileSources.Flickr;
using System.Text.Json;

namespace Mosaic.TileProcessor.TileSources;


public class FlickrTileSource : ITileSource
{
    private readonly HttpClient _client;
    private readonly ILogger<FlickrTileSource> _logger;

    public FlickrTileSource(ILogger<FlickrTileSource> logger, HttpClient client)
    {
        _client = client;
        _logger = logger;
    }
    public string Source => "flickr";

    public async Task<Stream> GetTileAsync(string tileData, CancellationToken token)
    {
        var flickrData = JsonSerializer.Deserialize<FlickrTileData>(tileData);
        string url = $"https://live.staticflickr.com/{flickrData.Server}/{flickrData.Id}_{flickrData.Secret}.jpg";
        return await _client.GetStreamAsync(url);
    }
}