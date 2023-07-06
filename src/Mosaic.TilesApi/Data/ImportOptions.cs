namespace Mosaic.TilesApi.Controllers;

public record ImportOptions
{
    public string? FlickrApiKey { get; init; }
    public FlickrSearchOptions[]? Searches { get; set; }
    public bool? ImportInteresting { get; set; }
}

public record FlickrSearchOptions
{
    /// <summary>
    /// The text to search the flickr API
    /// </summary>
    public string? SearchString { get; set; }
    /// <summary>
    /// Tags to set on the imported images
    /// </summary>
    public string[]? Tags { get; set; }
}