using Mosaic.Tiles.Actors.Interfaces;

namespace Mosaic.Tiles.Actors;

public record ImportData
{
    public required string FlickrKey { get; init; }
    public FlickrSearchOption[]? FlickrSearchOptions{ get; init; }
    public DateTime? FlickrLastImport { get; init; }
    public int FlickrTotalImportCount { get; init; }
    public int FlickrLastImportCount { get; init; }
    public bool FlickrImportInteresting { get; init; }
}