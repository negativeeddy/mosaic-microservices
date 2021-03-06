namespace Mosaic.TileSources;

public interface ITileSource
{
    string Source { get; }
    Task<Stream> GetTileAsync(string tileData, CancellationToken token);
}
