using Microsoft.Extensions.Logging;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

namespace Mosaic.ImageAnalysis;

public class ImageAnalyzer
{
    private readonly ILogger<ImageAnalyzer> _logger;

    public ImageAnalyzer(ILogger<ImageAnalyzer> logger)
    {
        _logger = logger;
    }

    public Rgba32 CalculateAverageColor(Image<Rgba32> image)
    {
        return CalculateAverageColor(image, 0, image.Height, 0, image.Width);
    }

    public Rgba32 CalculateAverageColor(Image<Rgba32> image, int top, int height, int left, int width)
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
}

