namespace Mosaic.MosaicApi;

public record MosaicOptions(
    string SourceId,
    int HorizontalTileCount,
    int VerticalTileCount
    );

public record TileId(string Source, string SourceId);
