using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;
using System;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;

namespace Mosaic.ImageAnalysis.Tests;

[TestClass]
public class TintingTests
{
    [TestMethod]
    [DataRow("39553260992.jpg", 0, 0, 0)]
    [DataRow("39553260992.jpg", 0, 0, 255)]
    [DataRow("39553260992.jpg", 0, 255, 0)]
    [DataRow("39553260992.jpg", 0, 255, 255)]
    [DataRow("39553260992.jpg", 255, 0, 0)]
    [DataRow("39553260992.jpg", 255, 0, 255)]
    [DataRow("39553260992.jpg", 255, 255, 0)]
    [DataRow("39553260992.jpg", 255, 255, 255)]
    [DataRow("39553260992.jpg", 0, 0, 0)]
    [DataRow("39553260992.jpg", 0, 0, 255)]
    [DataRow("39553260992.jpg", 0, 255, 0)]
    [DataRow("39553260992.jpg", 0, 255, 255)]
    [DataRow("39553260992.jpg", 255, 0, 0)]
    [DataRow("39553260992.jpg", 255, 0, 255)]
    [DataRow("39553260992.jpg", 255, 255, 0)]
    [DataRow("39553260992.jpg", 255, 255, 255)]
    public async Task TestColorAveraging(string filename, int r, int g, int b)
    {
        var analyzer = new ImageAnalyzer(NullLogger<ImageAnalyzer>.Instance);
        using var stream = File.OpenRead(Path.Combine("images", "flickr", filename));
        using var image = Image.Load<Rgba32>(stream);
        Rgba32 expected = new Rgba32((byte)r, (byte)g, (byte)b);

        var sourceAvgColor = analyzer.CalculateAverageColor(image);
        var targetAvgColor = new Rgba32((byte)r, (byte)g, (byte)b);
        var delta = targetAvgColor.ToVector4() - sourceAvgColor.ToVector4();

        var newImage = analyzer.CreateTintedImage(image, delta);

        await newImage.SaveAsJpegAsync("out_" + expected.ToHex() + filename);
        var actual = analyzer.CalculateAverageColor(newImage);
        System.Console.WriteLine($"{filename} = {actual}");

        var difference = expected.ToVector4() - actual.ToVector4();
        Trace.WriteLine($"Difference:{difference.Length()}");
        Trace.WriteLine($"actual:{actual}");
        Trace.WriteLine($"expected:{expected}");
        Assert.IsTrue(difference.Length() < 0.18);
    }

}
