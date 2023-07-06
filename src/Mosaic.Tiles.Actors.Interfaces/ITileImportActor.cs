using Dapr.Actors;
using Microsoft.Extensions.ObjectPool;
using System.Diagnostics.CodeAnalysis;

namespace Mosaic.Tiles.Actors.Interfaces;

public interface ITileImportActor : IActor
{
    Task StartImporting(ImportOptions options);
    Task StopImporting();
    Task<ImportStatus> GetImportStatus();
}

public record ImportStatus
{
    public required DateTime FlickrLastImportDate { get; init; }
    public required int FlickrLastImportCount { get; init; }
    public required int FlickrTotalImportCount { get; init; }
}

public record ImportOptions
{
    public required string FlickrApiKey { get; init; }
    public required FlickrSearchOption[] Searches { get; init; }
    public required bool ImportInteresting { get; init; }
}

public record FlickrSearchOption
{
    public string? SearchString { get; init; }
    public string[]? Tags { get; init; }
}

