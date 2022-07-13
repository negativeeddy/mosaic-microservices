namespace Mosaic.FrontEnd.Data;

public record MosaicCreateDto(
    string Name,
    int SourceTileId,
    int HorizontalTileCount,
    int VerticalTileCount,
    int MatchStyle,
    int Width,
    int Height);
