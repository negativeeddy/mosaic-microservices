using System.ComponentModel.DataAnnotations;

namespace Mosaic.TilesApi;

public record TileCreateDto
{
    [Required]
    public string Source { get; set; }
    [Required]
    public string SourceId { get; set; }
    [Required]
    public string SourceData { get; set; }
}
