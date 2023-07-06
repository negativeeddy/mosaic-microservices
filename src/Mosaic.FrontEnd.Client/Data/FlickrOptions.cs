namespace Mosaic.FrontEnd.Data;

public class ImportOptions
{
    public string? FlickrApiKey { get; set; }
    public FlickrSearchOption[]? Searches{ get; set; }
    public bool ImportInteresting { get; set; }

}

public record FlickrSearchOption(string? SearchString, string[]? Tags);
