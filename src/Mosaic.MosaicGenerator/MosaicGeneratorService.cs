using Dapr.Client;
using Mosaic.ImageAnalysis;
using Mosaic.MosaicApi;
using Mosaic.TileSources;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;
using System.Collections.Concurrent;

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
        // get the image stream from the tile source
        //using var scope = _serviceProvider.CreateScope();
        //var tileSources = scope.ServiceProvider.GetRequiredService<Func<string, ITileSource>>();
        //ITileSource source = tileSources(mosaic.Options.Source.Source);
        //var imageStream = await source.GetTileAsync(mosaic.Options.Source.SourceData, cancel);

        //// calculate the image information
        //var image = await Image.LoadAsync<Rgba32>(imageStream);
        
        for(int row = 0; row < mosaic.Options.VerticalTileCount; row++)

        {
            for(int col=0; col < mosaic.Options.HorizontalTileCount; col++)
            {
                //var avgColor = _analyzer.CalculateAverageColor(image);

                //// store tile details
                await _daprClient.InvokeMethodAsync<TileId>(
                    HttpMethod.Post,
                    "mosaicapi",
                    $"mosaics/{mosaic.MosaicId}/tiles/{row}/{col}/",
                    new TileId("testSource", $"row {row}, col {col}"));

            }
        }
    }
}
