using System.ComponentModel.DataAnnotations;

namespace Mosaic.FrontEnd.Data;

public class MosaicOptions
{
    [Required]
    public string Name { get; set; }
    [Required]
    public int SourceTileId { get; set; }
    [Required]
    [Range(1, 100, ErrorMessage = "must be 1-100")]
    public int HorizontalTileCount { get; set; }
    [Required]
    [Range(1, 100, ErrorMessage = "must be 1-100")]
    public int VerticalTileCount { get; set; }
}
