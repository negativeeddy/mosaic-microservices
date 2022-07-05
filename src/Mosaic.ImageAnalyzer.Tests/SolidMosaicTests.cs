using Microsoft.VisualStudio.TestTools.UnitTesting;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;

namespace Mosaic.ImageAnalysis.Tests;

[TestClass]
public class SolidMosaicTests
{
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
        image.SaveAsBmp("Output_SimpleQuadTest.bmp");
    }

    [TestMethod]
    public void GenerateTallLandscapeImage()
    {
        Rgba32[,] colors = new Rgba32[4, 2];
        colors[0, 0] = new Rgba32(0, 0, 0, 0);
        colors[0, 1] = new Rgba32(255, 0, 0, 0);
        colors[1, 0] = new Rgba32(0, 255, 0, 0);
        colors[1, 1] = new Rgba32(0, 0, 255, 0);
        colors[2, 0] = new Rgba32(255, 255, 255, 0);
        colors[2, 1] = new Rgba32(255, 0, 255, 0);
        colors[3, 0] = new Rgba32(255, 255, 0, 0);
        colors[3, 1] = new Rgba32(0, 255, 255, 0);

        ImageAnalyzer analyzer = new ImageAnalyzer(null!);

        var image = analyzer.GenerateMosaic(640, 480, colors);
        image.SaveAsBmp("Output_GenerateTallLandscapeImage.bmp");
    }

    [TestMethod]
    public void GenerateWideLandscapeImage()
    {
        Rgba32[,] colors = new Rgba32[2,4];
        colors[0, 0] = new Rgba32(0, 0, 0, 0);
        colors[0, 1] = new Rgba32(255, 0, 0, 0);
        colors[0, 2] = new Rgba32(0, 255, 0, 0);
        colors[0, 3] = new Rgba32(0, 0, 255, 0);
        colors[1, 0] = new Rgba32(255, 255, 255, 0);
        colors[1, 1] = new Rgba32(255, 0, 255, 0);
        colors[1, 2] = new Rgba32(255, 255, 0, 0);
        colors[1, 3] = new Rgba32(0, 255, 255, 0);

        ImageAnalyzer analyzer = new ImageAnalyzer(null!);

        var image = analyzer.GenerateMosaic(640, 480, colors);
        image.SaveAsBmp("Output_GeneratWideLandscapeImage.bmp");
    }

    [TestMethod]
    public void GenerateTallPortraitImage()
    {
        Rgba32[,] colors = new Rgba32[4, 2];
        colors[0, 0] = new Rgba32(0, 0, 0, 0);
        colors[0, 1] = new Rgba32(255, 0, 0, 0);
        colors[1, 0] = new Rgba32(0, 255, 0, 0);
        colors[1, 1] = new Rgba32(0, 0, 255, 0);
        colors[2, 0] = new Rgba32(255, 255, 255, 0);
        colors[2, 1] = new Rgba32(255, 0, 255, 0);
        colors[3, 0] = new Rgba32(255, 255, 0, 0);
        colors[3, 1] = new Rgba32(0, 255, 255, 0);

        ImageAnalyzer analyzer = new ImageAnalyzer(null!);

        var image = analyzer.GenerateMosaic(480, 640, colors);
        image.SaveAsBmp("Output_GenerateTallPortraitImage.bmp");
    }

    [TestMethod]
    public void GenerateWidePortraitImage()
    {
        Rgba32[,] colors = new Rgba32[2, 4];
        colors[0, 0] = new Rgba32(0, 0, 0, 0);
        colors[0, 1] = new Rgba32(255, 0, 0, 0);
        colors[0, 2] = new Rgba32(0, 255, 0, 0);
        colors[0, 3] = new Rgba32(0, 0, 255, 0);
        colors[1, 0] = new Rgba32(255, 255, 255, 0);
        colors[1, 1] = new Rgba32(255, 0, 255, 0);
        colors[1, 2] = new Rgba32(255, 255, 0, 0);
        colors[1, 3] = new Rgba32(0, 255, 255, 0);

        ImageAnalyzer analyzer = new ImageAnalyzer(null!);

        var image = analyzer.GenerateMosaic(480, 640, colors);
        image.SaveAsBmp("Output_GeneratWidePortraitImage.bmp");
    }
}
