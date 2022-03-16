namespace Mosaic.MosaicApi;

public class MosaicDetails
{
    public string Id { get; set; }
    public int HorizontalTileCount { get; set; }
    public int VerticalTileCount { get; set; }
    public TileId?[,] TileDetails { get; set; } = new TileId?[0, 0];
    public bool Complete { get; set; }
}
