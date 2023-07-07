namespace Mosaic.TileSources;

public interface ITileSource
{
    /// <summary>
    /// The name of the tile source
    /// </summary>  
    string Source { get; }

    /// <summary>
    /// Returns a byte stream of the tile image data
    /// </summary>
    /// <param name="tileData"></param>
    /// <param name="token"></param>
    /// <returns></returns>
    Task<Stream> GetTileAsync(string tileData, CancellationToken token);

    /// <summary>
    /// returns a public url to the tile image data
    /// </summary>
    /// <param name="tileData"></param>
    /// <param name="token"></param>
    /// <returns></returns>
    Task<string?> GetTileUrl(string tileData, CancellationToken token);

    /// <summary>
    /// returns a public url to a user-friendly page with more information about the tile
    /// </summary>
    /// <param name="tileData"></param>
    /// <param name="token"></param>
    /// <returns></returns>
    Task<string?> GetTileInfoUrl(string tileData, CancellationToken token);

}
