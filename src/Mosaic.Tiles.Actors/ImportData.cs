namespace Mosaic.Tiles.Actors;

public record ImportData
{
    public required string FlickrKey { get; init; }
    public DateTime? FlickrLastImport { get; init; }
    public int FlickrTotalImportCount { get; init; }
    public int FlickrLastImportCount { get; init; }
}

