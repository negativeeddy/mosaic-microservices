namespace Mosaic.TileSources.Flickr
{
    /// <summary>
    /// The information needed to process a flickr image
    /// </summary>
    /// <param name="Id"></param>
    /// <param name="Secret"></param>
    /// <param name="Server"></param>
    public record FlickrTileData(string Id, string Secret, string Server);
}