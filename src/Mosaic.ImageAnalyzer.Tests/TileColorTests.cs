using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;
using System.IO;

namespace Mosaic.ImageAnalysis.Tests
{
    [TestClass]
    public class TileColorTests
    {
        [TestMethod]
        [DataRow("images/800080.png", 127, 0, 127)]
        [DataRow("images/ff0000.png", 255, 0, 0)]
        [DataRow("images/00ff00.png", 0, 255, 0)]
        [DataRow("images/0000ff.png", 0, 0, 255)]
        [DataRow("images/128-64-0.png", 128, 64, 0)]
        public void TestColorAveraging(string filename, int r, int g, int b)
        {
            using var stream = File.OpenRead(filename);
            using var image = Image.Load<Rgba32>(stream);
            Rgba32 expected = new Rgba32((byte)r, (byte)g, (byte)b);

            var analyzer = new ImageAnalyzer(null);
            var actual = analyzer.CalculateAverageColor(image);
            System.Console.WriteLine($"{filename} = {actual}");
            Assert.AreEqual(expected, actual);
        }

        ///// +---+---+
        ///// | 0 | 1 |
        ///// +---+---+
        ///// | 2 | 3 |
        ///// +---+---+
        [TestMethod]
        [DataRow("images/quadranttest.png", 0xFF0000FF, 0xFF00FF00, 0xFFDADA46, 0xFFE800FF)]
        public void TestQuadrantColorAveraging(string filename, uint rgba0, uint rgba1, uint rgba2, uint rgba3)
        {
            var analyzer = new ImageAnalyzer(null);

            using var stream = File.OpenRead(filename);
            using var image = Image.Load<Rgba32>(stream);
            Rgba32 expected = new Rgba32(rgba0);
            var actual = analyzer.CalculateAverageColor(image, 0, image.Height / 2, 0, image.Width / 2);
            System.Console.WriteLine($"{filename} 0 = {actual}");
            Assert.AreEqual(expected, actual);

            expected = new Rgba32(rgba1);
            actual = analyzer.CalculateAverageColor(image, 0, image.Height / 2, image.Width / 2, image.Width / 2);
            System.Console.WriteLine($"{filename} 1 = {actual}");
            Assert.AreEqual(expected, actual);

            expected = new Rgba32((byte)0xDA, (byte)0xDA, (byte)0x46);
            actual = analyzer.CalculateAverageColor(image, image.Height / 2, image.Height/2, 0, image.Width / 2);
            System.Console.WriteLine($"{filename} 1 = {actual}");
            Assert.AreEqual(expected, actual);

            expected = new Rgba32((byte)232, (byte)0, (byte)255);
            actual = analyzer.CalculateAverageColor(image, image.Height / 2, image.Height/2, image.Width / 2, image.Width / 2);
            System.Console.WriteLine($"{filename} 1 = {actual}");
            Assert.AreEqual(expected, actual);
        }
    }
}