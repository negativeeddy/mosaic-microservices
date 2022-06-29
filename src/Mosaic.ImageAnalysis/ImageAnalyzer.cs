﻿using Microsoft.Extensions.Logging;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;

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
        float exactHeight = imageHeight / (float)columns;

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

                var tile = await tileFromId(mosaicTileIds[row, col]);

                tile.Mutate(ctx => ctx.Resize(width, height));

                newMosaic.ProcessPixelRows(tile, (source, tile) => copyTile(source, tile, top, left, height, width));
            }
        }
    }
    private void copyTile(PixelAccessor<Rgba32> pixelAccessor1, PixelAccessor<Rgba32> pixelAccessor2, int top, int left, int height, int width)
    {
        for (int y = 0; y < height; y++)
        {
            var mosaicPixels = pixelAccessor1.GetRowSpan(y + top);
            var tilePixels = pixelAccessor2.GetRowSpan(y);

            for (int x = 0; x < width; x++)
            {
                mosaicPixels[x + left] = tilePixels[x];
            }
        }
    }
}

