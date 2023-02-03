using System.ComponentModel.DataAnnotations;

namespace Mosaic.MosaicApi.Data;

public record MosaicEntity
{
    [Required]
    public required string UserId { get; set; }
    [Required]
    public int TileSourceId { get; set; }
    [Required]
    public required string Name { get; set; }
    [Required]
    public int HorizontalTileCount { get; set; }
    [Required]
    public int VerticalTileCount { get; set; }
    [Required]
    public string Status { get; set; } = null!;
    public int?[]? TileIds { get; set; }
    public string? ImageId { get; set; }
    public int Width { get; set; }
    public int Height { get; set; }
    public TileMatchAlgorithm MatchStyle { get; set; }

    public int GetTileIndex(int row, int col)
    {
        return (row * HorizontalTileCount) + col;
    }
}
