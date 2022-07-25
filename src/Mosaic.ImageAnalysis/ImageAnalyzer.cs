using Microsoft.Extensions.Logging;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;
using System.Diagnostics;
using System.Numerics;

namespace Mosaic.ImageAnalysis;

public class ImageAnalyzer
{
    private readonly ILogger<ImageAnalyzer> _logger;

    public ImageAnalyzer(ILogger<ImageAnalyzer> logger)
    {
        _logger = logger;
    }

    public Rgba32[,] CalculateAverageColorGrid(Image<Rgba32> image, int rows, int columns)
    {
        Rgba32[,] colorGrid = new Rgba32[rows, columns];

        for (int row = 0; row < rows; row++)
        {
            for (int col = 0; col < columns; col++)
            {
                (int top, int left, int height, int width) = GetGridCoordinates(row, col, image.Height, image.Width, rows, columns);

                var avg = CalculateAverageColor(image, top, left, height, width);
                colorGrid[row, col] = avg;
            }
        }

        return colorGrid;
    }

    static public (int top, int left, int height, int width) GetGridCoordinates(int row, int column, int imageHeight, int imageWidth, int rows, int columns)
    {
        float exactWidth = imageWidth / (float)columns;
        float exactHeight = imageHeight / (float)rows;

        float exactLeft = column * exactWidth;
        float exactTop = row * exactHeight;
        float exactRight = exactLeft + exactWidth;
        float exactBottom = exactTop + exactHeight;

        int top = (int)Math.Round(exactTop);
        int left = (int)Math.Round(exactLeft);
        int right = (int)Math.Round(exactRight);
        int bottom = (int)Math.Round(exactBottom);

        int width = right - left;
        int height = bottom - top;

        return (top, left, height, width);

    }

    public Rgba32 CalculateAverageColor(Image<Rgba32> image)
    {
        return CalculateAverageColor(image, 0, 0, image.Height, image.Width);
    }

    public Rgba32 CalculateAverageColor(Image<Rgba32> image, int top, int left, int height, int width)
    {
        (int red, int green, int blue) totals = (0, 0, 0);

        image.ProcessPixelRows(accessor =>
        {
            for (int y = top; y < top + height; y++)
            {
                Span<Rgba32> pixelRow = accessor.GetRowSpan(y);

                // pixelRow.Length has the same value as accessor.Width,
                // but using pixelRow.Length allows the JIT to optimize away bounds checks:
                for (int x = left; x < left + width; x++)
                {
                    // Get a reference to the pixel at position x
                    ref Rgba32 pixel = ref pixelRow[x];
                    if (pixel.A == 255)
                    {
                        // solid opacity => just add the values
                        totals.red += pixel.R;
                        totals.green += pixel.G;
                        totals.blue += pixel.B;
                    }
                    else
                    {
                        // partial opacity => add partial values
                        float opacity = (float)pixel.A / 255;
                        totals.red += (int)(pixel.R * opacity);
                        totals.green += (int)(pixel.G * opacity);
                        totals.blue += (int)(pixel.B * opacity);
                    }
                }
            }

            int pixelCount = width * height;
            totals.red /= pixelCount;
            totals.green /= pixelCount;
            totals.blue /= pixelCount;
        });

        return new Rgba32((byte)totals.red, (byte)totals.green, (byte)totals.blue);
    }

    public async Task GenerateMosaic(Image<Rgba32> newMosaic, int[,] mosaicTileIds, Func<int, Task<Image<Rgba32>>> tileFromId)
    {
        int rows = mosaicTileIds.GetLength(0);
        int columns = mosaicTileIds.GetLength(1);

        for (int row = 0; row < rows; row++)
        {
            for (int col = 0; col < columns; col++)
            {
                (int top, int left, int height, int width) = GetGridCoordinates(row, col, newMosaic.Height, newMosaic.Width, rows, columns);

                using var tile = await tileFromId(mosaicTileIds[row, col]);

                tile.Mutate(ctx => ctx.Resize(width, height));

                newMosaic.ProcessPixelRows(tile, (source, tile) => copyTile(source, tile, top, left, height, width));
            }
        }
    }

    public Image<Rgba32> GenerateMosaic(int width, int height, Rgba32[,] averageColors)
    {
        var newMosaic = new Image<Rgba32>(width, height);

        int rows = averageColors.GetLength(0);
        int columns = averageColors.GetLength(1);

        for (int row = 0; row < rows; row++)
        {
            for (int col = 0; col < columns; col++)
            {
                (int top, int left, int tileHeight, int tileWidth) = GetGridCoordinates(row, col, height, width, rows, columns);
                newMosaic.ProcessPixelRows((source) => Fill(source, averageColors[row, col], top, left, tileWidth, tileHeight));
            }
        }
        return newMosaic;
    }

    public Image<Rgba32> GenerateMosaicWithTintedTile(int width, int height, Rgba32[,] averageColors, Image<Rgba32> source)
    {
        var newMosaic = source.Clone(ctx => ctx.Resize(width, height));

        int rows = averageColors.GetLength(0);
        int columns = averageColors.GetLength(1);

        //prep the tile
        var sourceInfo = GetGridCoordinates(0, 0, height, width, rows, columns);
        source.Mutate(ctx => ctx.Resize(sourceInfo.width, sourceInfo.height));
        var sourceAvgColor = CalculateAverageColor(source);


        for (int row = 0; row < rows; row++)
        {
            for (int col = 0; col < columns; col++)
            {
                var tileAvgColor = averageColors[row, col];
                var delta = -sourceAvgColor.ToVector4() + tileAvgColor.ToVector4();
                using var tintedTile = CreateTintedImage(source, delta);

                (int top, int left, int tileHeight, int tileWidth) = GetGridCoordinates(row, col, height, width, rows, columns);

                newMosaic.ProcessPixelRows(tintedTile, (target, source) => copyTile(target, source, top, left, tileHeight, tileWidth));
            }
        }
        return newMosaic;
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="image">the source image to tint</param>
    /// <param name="rgba32">the amount to shift all the pixels</param>
    /// <returns></returns>
    public Image<Rgba32> CreateTintedImage(Image<Rgba32> image, Vector4 delta)
    {

        var newImage = image.Clone(ctx => TintTo(ctx, delta));
        return newImage;
    }

    private void TintTo(IImageProcessingContext ctx, Vector4 delta)
    {
        ctx.ProcessPixelRowsAsVector4(span =>
        {
            for (int i = 0; i < span.Length; i++)
            {
                span[i].X = Math.Clamp(span[i].X + delta.X, 0, 1);
                span[i].Y = Math.Clamp(span[i].Y + delta.Y, 0, 1);
                span[i].Z = Math.Clamp(span[i].Z + delta.Z, 0, 1);
            }
        });
    }

    private void Fill(PixelAccessor<Rgba32> pixelAccessor1, Rgba32 color, int top, int left, int width, int height)
    {
        Debug.Assert(top + height <= pixelAccessor1.Height);
        Debug.Assert(left + width <= pixelAccessor1.Width);

        int x = 0, y = 0;
        try
        {


            for (y = 0; y < height; y++)
            {
                var mosaicPixels = pixelAccessor1.GetRowSpan(y + top);

                for (x = 0; x < width; x++)
                {
                    mosaicPixels[x + left] = color;
                }
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"Failed to Fill pixels at x:{x} y:{y} for top:{top}, left:{left}, height:{height}, width:{width}\n{ex}");
        }
    }

    private void copyTile(PixelAccessor<Rgba32> target, PixelAccessor<Rgba32> source, int top, int left, int height, int width)
    {
        Debug.Assert(top + height <= target.Height);
        Debug.Assert(left + width <= target.Width);

        int x = 0, y = 0;
        try
        {

            for (y = 0; y < height; y++)
            {
                var targetPixels = target.GetRowSpan(y + top);
                var sourcePixels = source.GetRowSpan(y);

                for (x = 0; x < width; x++)
                {
                    targetPixels[x + left] = sourcePixels[x];
                }
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"Failed to copyTile pixels at x:{x} y:{y} for top:{top}, left:{left}, height:{height}, width:{width}\n{ex}");
        }
    }
}

