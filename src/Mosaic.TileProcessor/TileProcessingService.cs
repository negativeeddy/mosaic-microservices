﻿using Dapr.Client;
using Mosaic.ImageAnalysis;
using Mosaic.TilesApi;
using Mosaic.TileSources;
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
    private readonly IServiceProvider _serviceProvider;

    public TileProcessingService(IServiceProvider serviceProvider, ILogger<TileProcessingService> logger, DaprClient daprClient, ImageAnalyzer analyzer)
    {
        _logger = logger;
        _daprClient = daprClient;
        _analyzer = analyzer;
        _serviceProvider = serviceProvider;
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
                        _logger.LogInformation("Processing tile {TileId}", tile.TileId);
                        // generate tile details
                        TileUpdateDto data = await PopulateTileInfo(tile, stoppingToken);

                        // store tile details
                        await _daprClient.InvokeMethodAsync<TileUpdateDto>(
                            HttpMethod.Put,
                            "tilesapi",
                            $"internal/tiles/{tile.TileId}",
                            data);

                        _logger.LogInformation("Processed tile {TileId}", tile.TileId);
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
        // get the image stream from the tile source
        using var scope = _serviceProvider.CreateScope();
        var tileSources = scope.ServiceProvider.GetRequiredService<Func<string, ITileSource>>();
        ITileSource source = tileSources(tile.Source);
        using var imageStream = await source.GetTileAsync(tile.SourceData, cancel);

        // calculate the image information
        using var image = await Image.LoadAsync<Rgba32>(imageStream);
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