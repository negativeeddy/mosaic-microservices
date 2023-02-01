using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace Mosaic.FrontEnd.Data;

public class MosaicOptions
{
    [Required]
    public required string Name { get; set; }
    
    [Required]
    public int SourceTileId { get; set; }
    
    [Required]
    [Range(1, 100, ErrorMessage = "must be 1-100")]
    [Description("Horizontal tile count")]
    public int HorizontalTileCount { get; set; }
    
    [Required]
    [Description("Vertical tile count")]
    [Range(1, 100, ErrorMessage = "must be 1-100")]
    public int VerticalTileCount { get; set; }

    [Required]
    public TileMatchAlgorithm MatchStyle { get; set; }

    [Required]
    [Range(10, 2000, ErrorMessage = "must be 10-2000")]
    public int Height { get; set; }

    [Required]
    [Range(10, 2000, ErrorMessage = "must be 10-2000")]
    public int Width { get; set; }
}
