using Dapr.Actors;

namespace Mosaic.Tiles.Actors.Interfaces;

public interface ITileImportActor : IActor
{
    Task StartImporting(string apiKey);
    Task StopImporting();
    Task<ImportStatus> GetImportStatus();
}

public record ImportStatus
{
    public DateTime FlickrLastImportDate { get; init; }
    public int FlickrLastImportCount { get; init; }
    public int FlickrTotalImportCount { get; init; }
}

