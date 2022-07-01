namespace Mosaic.MosaicApi;

public record MosaicReadDto
{
    public int Id { get; set; } 
    public string Name { get; set; } = null!;
    public int SourceId { get; set; }
    public int HorizontalTileCount { get; set; }
    public int VerticalTileCount { get; set; }
    public int?[]? TileDetails { get; set; } 
    public MosaicStatus Status { get; set; }
    public int GetTileIndex(int row, int col)
    {
        return row * HorizontalTileCount + col;
    }
}

public enum MosaicStatus
{
    Created,
    CalculatingTiles,
    CreatingMosaic,
    Complete,
    Error
}

public record MosaicStatusResponse(int Id, MosaicStatus Status);

public record MosaicImageIdResponse(int Id, string ImageId);

