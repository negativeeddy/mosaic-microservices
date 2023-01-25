using System.ComponentModel.DataAnnotations;

namespace Mosaic.TilesApi;

public record TileCreateDto
{
    [Required]
    public required string Source { get; set; }
    [Required]
    public required string SourceId { get; set; }
    [Required]
    public required string SourceData { get; set; }
}
