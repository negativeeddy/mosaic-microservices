using System.ComponentModel.DataAnnotations;

namespace Mosaic.MosaicApi.Data;

public record MosaicEntity
{
    [Key]
    public int Id { get; set; }
    [Required]
    public int TileSourceId { get; set; }
    [Required]
    public string Name { get; set; } = null!;
    [Required]
    public int HorizontalTileCount { get; set; }
    [Required]
    public int VerticalTileCount { get; set; }
    [Required]
    public string Status { get; set; } = null!;
    public int?[]? TileIds { get; set; }

    public int GetTileIndex(int row, int col)
    {
        return (row * HorizontalTileCount) + col;
    }
}
