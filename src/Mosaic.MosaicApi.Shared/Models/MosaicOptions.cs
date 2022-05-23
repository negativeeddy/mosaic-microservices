namespace Mosaic.MosaicApi.Models;

public record MosaicOptions(
    TileId SourceId,
    int HorizontalTileCount,
    int VerticalTileCount
    );
