using System.ComponentModel.DataAnnotations;

namespace Mosaic.TilesApi.Models;

public record TileUpdateDto
{
    [Required]
    public int Id { get; set; }
    public int? Width { get; set; }
    public int? Height { get; set; }
    public Color? AverageColor { get; set; }
    public float? Aspect { get; set; }
}
