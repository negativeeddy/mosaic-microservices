using Dapr.Client;
using Mosaic.ImageAnalysis;
using Mosaic.TilesApi;
using Mosaic.TilesApi.Models;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;
using System.Collections.Concurrent;

namespace Mosaic.TileProcessor;
public class TileProcessingService : BackgroundService
{
    public static BlockingCollection<TileCreatedEvent> TileQueue { get; set; } = new();

    private readonly ILogger<TileProcessingService> _logger;
    private readonly DaprClient _daprClient;
    private readonly ImageAnalyzer _analyzer;

    public TileProcessingService(ILogger<TileProcessingService> logger, DaprClient daprClient, ImageAnalyzer analyzer)
    {
        _logger = logger;
        _daprClient = daprClient;
        _analyzer = analyzer;
    }

    protected override Task ExecuteAsync(CancellationToken stoppingToken)
    {
        return Task.Run(async () =>
        {
            try
            {
                TileCreatedEvent tile;
                while (!stoppingToken.IsCancellationRequested)
                {
                    tile = TileQueue.Take(stoppingToken);

                    try
                    {
                            // generate tile details
                            TileUpdateDto data = await PopulateTileInfo(tile, stoppingToken);

                            // store tile details
                            await _daprClient.InvokeMethodAsync<TileUpdateDto>(
                                HttpMethod.Put,
                                "tilesapi",
                                $"tiles/{tile.TileId}",
                                data);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Failed to process tile {TileId}", tile.TileId);
                    }
                }
            }
            catch (OperationCanceledException)
            {
                return;
            }
        });
    }

    private async Task<TileUpdateDto> PopulateTileInfo(TileCreatedEvent tile, CancellationToken cancel)
    {

        var result = tile.Source switch
        {
            "internal" => await PopulateInternallyStoredTile(tile, cancel),
            _ => new TileUpdateDto
            {
                Id = tile.TileId
            }
        };

        return result;
    }

    private async Task<TileUpdateDto> PopulateInternallyStoredTile(TileCreatedEvent tile, CancellationToken cancel)
    {
        var bindingRequest = new BindingRequest("tilestorage", "get");
        bindingRequest.Metadata.Add("blobName", tile.SourceId);
        var response = await _daprClient.InvokeBindingAsync(bindingRequest, cancel);
        var byteArray = response.Data.ToArray();

        _logger.LogInformation("Processing tile {TileId} from internal storage. {byteCount} bytes", tile.TileId, byteArray.Length);

        var image = await Image.LoadAsync<Rgba32>(new MemoryStream(byteArray));

        var avgColor = _analyzer.CalculateAverageColor(image);

        return new TileUpdateDto
        {
            Id = tile.TileId,
            Aspect = ((float)image.Width) / image.Height,
            AverageColor = new TilesApi.Color(avgColor.R, avgColor.G, avgColor.B),
            Width = image.Width,
            Height = image.Height,
        };
    }
}
