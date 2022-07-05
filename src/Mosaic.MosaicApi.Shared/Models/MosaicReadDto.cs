namespace Mosaic.MosaicApi;

public record MosaicReadDto
{
    public string Name { get; set; } = null!;
    public int SourceId { get; set; }
    public int HorizontalTileCount { get; set; }
    public int VerticalTileCount { get; set; }
    public int?[]? TileDetails { get; set; } 
    public MosaicStatus Status { get; set; }
    public int Width { get; set; }
    public int Height { get; set; }
    public int MatchStyle { get; set; }

    public int GetTileIndex(int row, int col)
    {
        return row * HorizontalTileCount + col;
    }
}

public enum MosaicStatus
{
    Created,
    CalculatingTiles,
    CalculatedTiles,
    CreatingMosaic,
    Complete,
    Error
}