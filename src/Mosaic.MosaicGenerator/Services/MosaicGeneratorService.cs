using Dapr.Client;
using Mosaic.ImageAnalysis;
using Mosaic.MosaicApi;
using Mosaic.TilesApi;
using Mosaic.TileSources;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;
using System.Collections.Concurrent;
using Color = Mosaic.TilesApi.Color;

namespace Mosaic.MosaicGenerator.Services;
public class MosaicGeneratorService : BackgroundService
{
    public static BlockingCollection<MosaicCreatedEvent> MosaicQueue { get; set; } = new();

    private readonly ILogger<MosaicGeneratorService> _logger;
    private const string PubsubName = "pubsub";
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
                        await CreateMosaic(mosaic, stoppingToken);
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

    private async Task CreateMosaic(MosaicCreatedEvent mosaic, CancellationToken cancel)
    {
        using var scope = _serviceProvider.CreateScope();

        var mosaicSvc = scope.ServiceProvider.GetService<MosaicService>() ?? throw new InvalidOperationException();
        var tileSources = scope.ServiceProvider.GetRequiredService<Func<string, ITileSource>>();




        try
        {
            var options = mosaic.Options;
            switch (options.MatchStyle)
            {
                case 0:
                    await CreateMosaicFromAverages(mosaic.MosaicId,
                                                   options.Name,
                                                   options.VerticalTileCount,
                                                   options.HorizontalTileCount,
                                                   options.SourceTileId,
                                                   options.Width,
                                                   options.Height,
                                                   mosaicSvc,
                                                   tileSources,
                                                   cancel);
                    break;
                case 1:
                    var mosaicTileIds = await CalculateMosaicTiles(
                                                        mosaic.MosaicId,
                                                        options.Name,
                                                        options.VerticalTileCount,
                                                        options.HorizontalTileCount,
                                                        options.SourceTileId,
                                                        mosaicSvc,
                                                        tileSources,
                                                        cancel);

                    await CreateMosaicFromTiles(mosaic.MosaicId, options.Name, options.Width, options.Height, mosaicTileIds, mosaicSvc, tileSources);
                    break;
                default:
                    throw new ArgumentOutOfRangeException(nameof(MosaicCreateDto.MatchStyle));
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to generate mosaic {MosaicId}", mosaic.MosaicId);

            await mosaicSvc.SetMosaicStatus(mosaic.MosaicId, MosaicStatus.Error);
        }
    }

    private async Task CreateMosaicFromAverages(int mosaicId, string name, int rows, int columns, int mosaicSourceTileId, int width, int height, MosaicService mosaicSvc, Func<string, ITileSource> tileSources, CancellationToken cancel)
    {
        await mosaicSvc.SetMosaicStatus(mosaicId, MosaicStatus.CalculatingTiles);

        // get the tile that is the source of the mosaic
        TileReadDto mosaicSourceTile = await mosaicSvc.GetTile(mosaicSourceTileId);

        // get the image stream from the tile source
        ITileSource mosaicTileSource = tileSources(mosaicSourceTile.Source);
        var imageStream = await mosaicTileSource.GetTileAsync(mosaicSourceTile.SourceData, cancel);

        // calculate the image information
        var originalImage = await Image.LoadAsync<Rgba32>(imageStream);
        var averageColors = _analyzer.CalculateAverageColorGrid(originalImage, rows, columns);

        await mosaicSvc.SetMosaicStatus(mosaicId, MosaicStatus.CalculatedTiles);

        await _daprClient.PublishEventAsync(
            PubsubName,
            nameof(MosaicCalculatedEvent),
            new MosaicCalculatedEvent(mosaicId, name));

        await mosaicSvc.SetMosaicStatus(mosaicId, MosaicStatus.CreatingMosaic);

        var mosaicImage = _analyzer.GenerateMosaic(width, height, averageColors);

#if DEBUG
        // drop the image in the file system so it can easily be viewed
        await mosaicImage.SaveAsJpegAsync(@"lastGenerated.jpg");
#endif
        MemoryStream stream = new MemoryStream();
        await mosaicImage.SaveAsJpegAsync(stream);
        await mosaicSvc.SetMosaicImage(mosaicId, stream.ToArray());

        await mosaicSvc.SetMosaicStatus(mosaicId, MosaicStatus.Complete);

        await _daprClient.PublishEventAsync(
            PubsubName,
            nameof(MosaicGeneratedEvent),
            new MosaicGeneratedEvent(mosaicId, name));
    }

    private async Task<int[,]> CalculateMosaicTiles(int mosaicId, string name, int rows, int columns, int mosaicSourceTileId, MosaicService mosaicSvc, Func<string, ITileSource> tileSources, CancellationToken cancel)
    {
        await mosaicSvc.SetMosaicStatus(mosaicId, MosaicStatus.CalculatingTiles);

        // get the tile that is the source of the mosaic
        TileReadDto mosaicSourceTile = await mosaicSvc.GetTile(mosaicSourceTileId);

        // get the image stream from the tile source
        ITileSource mosaicTileSource = tileSources(mosaicSourceTile.Source);
        var imageStream = await mosaicTileSource.GetTileAsync(mosaicSourceTile.SourceData, cancel);

        // calculate the image information
        var originalImage = await Image.LoadAsync<Rgba32>(imageStream);
        var averageColors = _analyzer.CalculateAverageColorGrid(originalImage, rows, columns);
        var mosaicTileIds = new int[rows, columns];

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
                mosaicTileIds[row, col] = matches[0][0].Id;

                await _daprClient.InvokeMethodAsync<MosaicTileDto, MosaicTileDto>(
                    "mosaicapi",
                    $"mosaics/{mosaicId}/tiles",
                    new MosaicTileDto
                    {
                        MosaicId = mosaicId,
                        Row = row,
                        Column = col,
                        TileId = matches[0][0].Id,
                    });
            }
        }

        await mosaicSvc.SetMosaicStatus(mosaicId, MosaicStatus.CalculatedTiles);

        await _daprClient.PublishEventAsync(
            PubsubName,
            nameof(MosaicCalculatedEvent),
            new MosaicCalculatedEvent(mosaicId, name));

        return mosaicTileIds;
    }

    private async Task CreateMosaicFromTiles(int mosaicId, string name, int height, int width, int[,] mosaicTileIds, MosaicService mosaicSvc, Func<string, ITileSource> tileSources)
    {
        await mosaicSvc.SetMosaicStatus(mosaicId, MosaicStatus.CreatingMosaic);

        var mosaicImage = new Image<Rgba32>(height, width);

        await _analyzer.GenerateMosaic(mosaicImage, mosaicTileIds, async (id) =>
        {
            Image<Rgba32> result;
            TileReadDto? tile = null;
            try
            {
                tile = await _daprClient.InvokeMethodAsync<TileReadDto>(
                    HttpMethod.Get,
                    "tilesapi",
                    $"tiles/{id}");

                ITileSource tileSource = tileSources(tile.Source);
                Stream tileStream = await tileSource.GetTileAsync(tile.SourceData, CancellationToken.None);
                result = await Image.LoadAsync<Rgba32>(tileStream);
            }
            catch (Exception ex)
            {
                // continue if the tile is missing with default tile
                _logger.LogError(ex, "Failed to load tile {TileId}:{TileSource} for mosaic {MosaicId}", id, tile?.SourceData, mosaicId);
                result = new Image<Rgba32>(10, 10, new Rgba32(0, 0, 0));
            }
            return result;
        });

#if DEBUG
        // drop the image in the file system so it can easily be viewed
        await mosaicImage.SaveAsJpegAsync(@"lastGenerated.jpg");
#endif
        MemoryStream stream = new MemoryStream();
        await mosaicImage.SaveAsJpegAsync(stream);
        await mosaicSvc.SetMosaicImage(mosaicId, stream.ToArray());

        await mosaicSvc.SetMosaicStatus(mosaicId, MosaicStatus.Complete);

        await _daprClient.PublishEventAsync(
            PubsubName,
            nameof(MosaicGeneratedEvent),
            new MosaicGeneratedEvent(mosaicId, name));
    }
}

