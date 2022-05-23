namespace Mosaic.MosaicApi;

public record MosaicOptions(
    TileId SourceId,
    int HorizontalTileCount,
    int VerticalTileCount
    );

public record TileId(string Source, string SourceId);
