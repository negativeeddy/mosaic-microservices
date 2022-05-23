namespace Mosaic.MosaicApi.Models;

public record MosaicOptions(
    TileId Source,
    int HorizontalTileCount,
    int VerticalTileCount
    );
