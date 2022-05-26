using System.ComponentModel.DataAnnotations;

namespace Mosaic.TilesApi.Models;

public class TileCreateDto
{
    [Required]
    public string Source { get; set; }
    [Required]
    public string SourceId { get; set; }
    [Required]
    public string SourceData { get; set; }
}
