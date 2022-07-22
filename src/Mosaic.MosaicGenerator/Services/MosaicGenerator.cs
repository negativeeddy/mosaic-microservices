using Dapr.Client;
using Mosaic.ImageAnalysis;
using Mosaic.MosaicApi;
using Mosaic.TilesApi;
using Mosaic.TileSources;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;
using Color = Mosaic.TilesApi.Color;

namespace Mosaic.MosaicGenerator.Services;

public class MosaicGenerator
{
    private const string PubsubName = "pubsub";
    private readonly MosaicService _mosaicSvc;
    private readonly Func<string, ITileSource> _tileSources;
    private readonly DaprClient _daprClient;
    private readonly ILogger<MosaicGenerator> _logger;
    private readonly ImageAnalyzer _analyzer;

    private string _mosaicName;
    private int _rows;
    private int _columns;
    private int _mosaicSourceTileId;
    private int _width;
    private int _height;

    private string _mosaicId;
    private string _userId;
    CancellationToken cancel;


    public MosaicGenerator(MosaicService mosaicService, ImageAnalyzer analyzer, Func<string, ITileSource> tileSources, DaprClient daprClient, ILogger<MosaicGenerator> logger)
    {
        _mosaicSvc = mosaicService;
        _tileSources = tileSources;
        _daprClient = daprClient;
        _logger = logger;
        _analyzer = analyzer;
    }

    public async Task CreateMosaic(MosaicCreatedEvent mosaicEvent, CancellationToken cancel)
    {
        var options = mosaicEvent.Options;

        this.cancel = cancel;
        _mosaicName = options.Name;
        _rows = options.VerticalTileCount;
        _columns = options.HorizontalTileCount;
        _mosaicSourceTileId = options.SourceTileId;
        _width = options.Width;
        _height = options.Height;
        _mosaicId = mosaicEvent.mosaicId;
        _userId = mosaicEvent.userId;

        try
        {
            Image<Rgba32> mosaicImage;
            switch (options.MatchStyle)
            {
                case 0: // solid color averages
                    mosaicImage = await CreateMosaicFromAverages();
                    break;
                case 1: // from tiles
                    var mosaicTileIds = await CalculateMosaicTiles();
                    mosaicImage = await CreateMosaicFromTiles(mosaicTileIds);
                    break;
                case 2: // self mosaic
                    mosaicImage = await CreateSelfMosaicFromAverages();
                    break;
                default:
                    throw new ArgumentOutOfRangeException(nameof(MosaicCreateDto.MatchStyle));
            };


#if DEBUG
            // drop the image in the file system so it can easily be viewed
            await mosaicImage.SaveAsJpegAsync(@"lastGenerated.jpg");
#endif
            MemoryStream stream = new MemoryStream();
            await mosaicImage.SaveAsJpegAsync(stream);
            await _mosaicSvc.SetMosaicImage(_mosaicId, stream.ToArray());

            await _mosaicSvc.SetMosaicStatus(_mosaicId, MosaicStatus.Complete);

            await _daprClient.PublishEventAsync(
                PubsubName,
                nameof(MosaicGeneratedEvent),
                new MosaicGeneratedEvent(_mosaicId, options.Name));

        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to generate mosaic {MosaicId}", _mosaicId);

            await _mosaicSvc.SetMosaicStatus(_mosaicId, MosaicStatus.Error);
        }
    }

    private async Task<Image<Rgba32>> CreateMosaicFromAverages()
    {
        await _mosaicSvc.SetMosaicStatus(_mosaicId, MosaicStatus.CalculatingTiles);

        // get the tile that is the source of the mosaic
        TileReadDto mosaicSourceTile = await _mosaicSvc.GetTile(_mosaicSourceTileId);

        // get the image stream from the tile source
        ITileSource mosaicTileSource = _tileSources(mosaicSourceTile.Source);
        var imageStream = await mosaicTileSource.GetTileAsync(mosaicSourceTile.SourceData, cancel);

        // calculate the image information
        var originalImage = await Image.LoadAsync<Rgba32>(imageStream);
        var averageColors = _analyzer.CalculateAverageColorGrid(originalImage, _rows, _columns);

        await _mosaicSvc.SetMosaicStatus(_mosaicId, MosaicStatus.CalculatedTiles);

        await _daprClient.PublishEventAsync(
            PubsubName,
            nameof(MosaicCalculatedEvent),
            new MosaicCalculatedEvent(_mosaicId, _mosaicName));

        await _mosaicSvc.SetMosaicStatus(_mosaicId, MosaicStatus.CreatingMosaic);

        var mosaicImage = _analyzer.GenerateMosaic(_width, _height, averageColors);
        return mosaicImage;
    }

    private async Task<Image<Rgba32>> CreateSelfMosaicFromAverages()
    {
        await _mosaicSvc.SetMosaicStatus(_mosaicId, MosaicStatus.CalculatingTiles);

        // get the tile that is the source of the mosaic
        TileReadDto mosaicSourceTile = await _mosaicSvc.GetTile(_mosaicSourceTileId);

        // get the image stream from the tile source
        ITileSource mosaicTileSource = _tileSources(mosaicSourceTile.Source);
        var imageStream = await mosaicTileSource.GetTileAsync(mosaicSourceTile.SourceData, cancel);

        // calculate the image information
        var originalImage = await Image.LoadAsync<Rgba32>(imageStream);
        var averageColors = _analyzer.CalculateAverageColorGrid(originalImage, _rows, _columns);

        await _mosaicSvc.SetMosaicStatus(_mosaicId, MosaicStatus.CalculatedTiles);

        await _daprClient.PublishEventAsync(
            PubsubName,
            nameof(MosaicCalculatedEvent),
            new MosaicCalculatedEvent(_mosaicId, _mosaicName));

        await _mosaicSvc.SetMosaicStatus(_mosaicId, MosaicStatus.CreatingMosaic);

        var mosaicImage = _analyzer.GenerateMosaicWithTintedTile(_width, _height, averageColors, originalImage);
        return mosaicImage;
    }

    private async Task<int[,]> CalculateMosaicTiles()
    {
        await _mosaicSvc.SetMosaicStatus(_mosaicId, MosaicStatus.CalculatingTiles);

        // get the tile that is the source of the mosaic
        TileReadDto mosaicSourceTile = await _mosaicSvc.GetTile(_mosaicSourceTileId);

        // get the image stream from the tile source
        ITileSource mosaicTileSource = _tileSources(mosaicSourceTile.Source);
        var imageStream = await mosaicTileSource.GetTileAsync(mosaicSourceTile.SourceData, cancel);

        // calculate the image information
        var originalImage = await Image.LoadAsync<Rgba32>(imageStream);
        var averageColors = _analyzer.CalculateAverageColorGrid(originalImage, _rows, _columns);
        var mosaicTileIds = new int[_rows, _columns];

        for (int row = 0; row < _rows; row++)

        {
            for (int col = 0; col < _columns; col++)
            {
                var tmp = averageColors[row, col];
                var avgColor = new Color(tmp.R, tmp.G, tmp.B);

                // find the tile nearest to the color
                var matches = await _mosaicSvc.GetNearestTileSingleAverage(avgColor, _userId);

                // store tile details
                mosaicTileIds[row, col] = matches[0][0].Id;

                await _mosaicSvc.SetMosaicTiles(_mosaicId, new[] { new MosaicTileDto
                {
                    MosaicId = _mosaicId,
                    Row = row,
                    Column = col,
                    TileId = matches[0][0].Id,
                }});
            }
        }

        await _mosaicSvc.SetMosaicStatus(_mosaicId, MosaicStatus.CalculatedTiles);

        await _daprClient.PublishEventAsync(
            PubsubName,
            nameof(MosaicCalculatedEvent),
            new MosaicCalculatedEvent(_mosaicId, _mosaicName));

        return mosaicTileIds;
    }

    private async Task<Image<Rgba32>> CreateMosaicFromTiles(int[,] mosaicTileIds)
    {
        await _mosaicSvc.SetMosaicStatus(_mosaicId, MosaicStatus.CreatingMosaic);

        var mosaicImage = new Image<Rgba32>(_height, _width);

        await _analyzer.GenerateMosaic(mosaicImage, mosaicTileIds, async (id) =>
        {
            Image<Rgba32> result;
            TileReadDto? tile = null;
            try
            {
                tile = await _mosaicSvc.GetTile(id);
                ITileSource tileSource = _tileSources(tile.Source);
                Stream tileStream = await tileSource.GetTileAsync(tile.SourceData, CancellationToken.None);
                result = await Image.LoadAsync<Rgba32>(tileStream);
            }
            catch (Exception ex)
            {
                // continue if the tile is missing with default tile
                _logger.LogError(ex, "Failed to load tile {TileId}:{TileSource} for mosaic {MosaicId}", id, tile?.SourceData, _mosaicId);
                result = new Image<Rgba32>(10, 10, new Rgba32(0, 0, 0));
            }
            return result;
        });

        return mosaicImage;
    }
}

