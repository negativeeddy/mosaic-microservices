namespace Mosaic.TileSources.AzureBlobStorage;

/// <summary>
/// The information needed to process a flickr image
/// </summary>
/// <param name="Id"></param>
/// <param name="Secret"></param>
/// <param name="Server"></param>
public record BlobTileData(string Id, string filename);
