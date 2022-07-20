using NetTopologySuite.Geometries;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Mosaic.TilesApi.Data;

public class TileEntity
{
    [Key]
    public int Id { get; set; }
    [Required]
    public string Source { get; set; } = null!;
    [Required]
    public string SourceId { get; set; } = null!;
    [Required]
    public string SourceData { get; set; } = null!;
    public int? Width { get; set; }
    public int? Height { get; set; }
    public Point? Average { get; set; }
    public DateTime? Date { get; set; }
    public float? Aspect { get; set; }
    public string? OwnerId { get; set; }
}
