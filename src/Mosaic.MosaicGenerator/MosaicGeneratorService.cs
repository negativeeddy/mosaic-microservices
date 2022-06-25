﻿using Dapr.Client;
using Mosaic.ImageAnalysis;
using Mosaic.MosaicApi;
using Mosaic.TilesApi;
using Mosaic.TileSources;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;
using System.Collections.Concurrent;
using Color = Mosaic.TilesApi.Color;

namespace Mosaic.MosaicGenerator;
public class MosaicGeneratorService : BackgroundService
{
    public static BlockingCollection<MosaicCreatedEvent> MosaicQueue { get; set; } = new();

    private readonly ILogger<MosaicGeneratorService> _logger;
    private readonly DaprClient _daprClient;
    private readonly ImageAnalyzer _analyzer;
    private readonly IServiceProvider _serviceProvider;

    public MosaicGeneratorService(IServiceProvider serviceProvider, ILogger<MosaicGeneratorService> logger, DaprClient daprClient, ImageAnalyzer analyzer)
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
                MosaicCreatedEvent mosaic;
                while (!stoppingToken.IsCancellationRequested)
                {
                    mosaic = MosaicQueue.Take(stoppingToken);

                    try
                    {

                        // generate tile details
                        await PopulateTileInfo(mosaic, stoppingToken);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Failed to process tile {MosaicId}", mosaic.MosaicId);
                    }
                }
            }
            catch (OperationCanceledException)
            {
                return;
            }
        });
    }

    private async Task PopulateTileInfo(MosaicCreatedEvent mosaic, CancellationToken cancel)
    {
        // get the tile that is the source of the mosaic
        TileReadDto tile = await _daprClient.InvokeMethodAsync<TileReadDto>(HttpMethod.Get, "tilesapi", $"Tiles/{mosaic.Options.SourceTileId}");

        // get the image stream from the tile source
        using var scope = _serviceProvider.CreateScope();
        var tileSources = scope.ServiceProvider.GetRequiredService<Func<string, ITileSource>>();
        ITileSource source = tileSources(tile.Source);
        var imageStream = await source.GetTileAsync(tile.SourceData, cancel);

        // calculate the image information
        var image = await Image.LoadAsync<Rgba32>(imageStream);

        try
        {
            int columns = mosaic.Options.HorizontalTileCount;
            int rows = mosaic.Options.VerticalTileCount;
            var averageColors = _analyzer.CalculateAverageColorGrid(image, rows, columns);

            for (int row = 0; row < rows; row++)

            {
                for (int col = 0; col < columns; col++)
                {
                    var tmp = averageColors[row, col];
                    var avgColor = new Color(tmp.R, tmp.G, tmp.B);

                    // find the tile nearest to the color
                    var matches = await _daprClient.InvokeMethodAsync<MatchInfo[], List<TileReadDto[]>>(
                        "tilesapi",
                        $"tiles/nearesttiles",
                        new MatchInfo[] { new() { Single = avgColor } });


                    // store tile details
                    await _daprClient.InvokeMethodAsync<MosaicTileDto, MosaicTileDto>(
                        "mosaicapi",
                        $"mosaics/{mosaic.MosaicId}/tiles",
                        new MosaicTileDto
                        {
                            MosaicId = mosaic.MosaicId,
                            Row = row,
                            Column = col,
                            TileId = matches[0][0].Id,
                        });
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to generate mosaic {MosaicId}", mosaic.MosaicId);
        }
    }
}
