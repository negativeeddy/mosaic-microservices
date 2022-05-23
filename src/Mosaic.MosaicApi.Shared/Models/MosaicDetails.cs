using Mosaic.MosaicApi.Models;

namespace Mosaic.MosaicApi;

public class MosaicDetails
{
    public string Id { get; set; } = null!;
    public TileId SourceId { get; set; } = null!;
    public int HorizontalTileCount { get; set; }
    public int VerticalTileCount { get; set; }
    public TileId?[] TileDetails { get; set; } = new TileId?[0];
    public bool Complete { get; set; }
}
