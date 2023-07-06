using System.Text.Json;

namespace Mosaic.TileSources.Flickr;

public class FlickrTileSource : ITileSource
{
    private readonly HttpClient _client;

    public FlickrTileSource(HttpClient client)
    {
        _client = client;
    }

    public static string Source => "flickr";

    string ITileSource.Source => FlickrTileSource.Source;

    public async Task<Stream> GetTileAsync(string tileData, CancellationToken token)
    {
        if (tileData == null) throw new ArgumentNullException(nameof(tileData));

        var flickrData = JsonSerializer.Deserialize<FlickrTileData>(tileData) ?? throw new ArgumentException("invalid tile data", nameof(tileData)); ;
        string url = $"https://live.staticflickr.com/{flickrData.Server}/{flickrData.Id}_{flickrData.Secret}.jpg";
        return await _client.GetStreamAsync(url);
    }

    public string GetTileInfoUrl(string tileData, CancellationToken token)
    {
        if (tileData == null) throw new ArgumentNullException(nameof(tileData));

        var flickrData = JsonSerializer.Deserialize<FlickrTileData>(tileData) ?? throw new ArgumentException("invalid tile data", nameof(tileData)); ;
        string url = $"https://www.flickr.com/photos/{flickrData.OwnerId}/{flickrData.Id}";
        return url;
    }
}