using Microsoft.Extensions.Logging;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Microsoft.VisualStudio.TestTools.UnitTesting.Logging;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

namespace Mosaic.ImageAnalysis.Tests;

[TestClass]
public class SolidMosaicTests
{
    [Ignore]
    [TestMethod]
    public void GenerateSimpleQuad()
    {
        Rgba32[,] colors = new Rgba32[2, 2];
        colors[0, 0] = new Rgba32(0, 0, 0, 0);
        colors[0, 1] = new Rgba32(255, 0, 0, 0);
        colors[1, 0] = new Rgba32(0, 255, 0, 0);
        colors[1, 1] = new Rgba32(0, 0, 255, 0);
           
        ImageAnalyzer analyzer = new ImageAnalyzer(null!);

        var image = analyzer.GenerateMosaic(640, 480, colors);
        image.SaveAsBmp("SimpleQuadTest.bmp");
    }
}
