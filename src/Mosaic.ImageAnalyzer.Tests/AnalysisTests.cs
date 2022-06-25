using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;
using System.IO;

namespace Mosaic.ImageAnalysis.Tests;

[TestClass]
public class TileCalculationTests
{
    [TestMethod]
    [DataRow(0,0,0,0,3,3)]
    [DataRow(0,1,3,0,4,3)]
    [DataRow(0,2,7,0,3,3)]
    [DataRow(1,0,0,3,3,4)]
    [DataRow(1,1,3,3,4,4)]
    [DataRow(1,2,7,3,3,4)]
    [DataRow(2,0,0,7,3,3)]
    [DataRow(2,1,3,7,4,3)]
    [DataRow(2,2,7,7,3,3)]
    public void TestGridRowColCoordinates(int row, int col, int expectedLeft, int expectedTop, int expectedWidth, int expectedHeight)
    {
        // for a 10x10 pixel image with 3 columns and 3 rows
        int rows = 3;
        int columns = 3;
        int imageWidth = 10;
        int imageHeight = 10;

        (int top, int left, int height, int width) = ImageAnalyzer.GetGridCoordinates(row, col, imageHeight, imageWidth,rows, columns);

        Assert.AreEqual(expectedTop, top, "Top");
        Assert.AreEqual(expectedLeft, left, "Left");
        Assert.AreEqual(expectedHeight, height, "Height");
        Assert.AreEqual(expectedWidth, width, "Width");
    }
}
