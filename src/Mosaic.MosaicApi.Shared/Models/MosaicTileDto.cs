namespace Mosaic.MosaicApi;

public record MosaicTileDto
{
    public required string MosaicId { get; init; }
    public int Row { get; init; }
    public int Column { get; init; }
    public int TileId { get; init; }
}