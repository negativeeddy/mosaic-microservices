using Microsoft.Extensions.Logging;
using Mosaic.TileSources;
using System.Net.Http.Json;
using System.Text.Json;

namespace Mosaic.TileSources.Flickr;

public class FlickrTileSource : ITileSource
{
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

    private readonly HttpClient _client;
    private readonly string _apiKey;
    private readonly ILogger<FlickrTileSource> _logger;

    public FlickrTileSource(ILogger<FlickrTileSource> logger, HttpClient client, FlickrOptions options)
    {
        _client = client;
        _logger = logger;
        _apiKey = options.ApiKey;
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

    public async Task<FlickrTileData[]> GetTodaysInteresting()
    {
        int pageCount = 500;
        int pageNumber = 1;
        string interestingUrl = $"https://www.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key={_apiKey}&format=json&nojsoncallback=1&per_page={pageCount}&page={pageNumber}&extras=license";
        var response = await _client.GetFromJsonAsync<InterestingnessResponse>(interestingUrl);
        var usable = response!.photos.photo.Where(p => acceptableLicenses.Contains(p.license));
        return usable.Select(p => new FlickrTileData(p.id, p.secret, p.server)).ToArray();
    }
}

public record FlickrOptions()
{
    public string ApiKey { get; init; } = null!;
}