using Dapr.Actors;

namespace Mosaic.Tiles.Actors.Interfaces;

public interface ITileImportActor : IActor
{
    Task RegisterTimer(string apiKey);
    Task UnregisterTimer();
    Task<ImportStatus> GetImportStatus();
}

public record ImportStatus
{
    public DateTime FlickrLastImportDate { get; init; }
    public int FlickrLastImportCount { get; init; }
    public int FlickrTotalImportCount { get; init; }
}

