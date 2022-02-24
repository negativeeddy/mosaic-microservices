using System.ComponentModel.DataAnnotations.Schema;

namespace Mosaic.TilesApi.Data
{
    public class TileEntity
    {
        public int Id { get; set; }
        public string Source { get; set; }
        public string SourceId { get; set; }
        public int? Width { get; set; }
        public int? Height { get; set; }
        public byte? AverageR { get; set; }
        public byte? AverageG { get; set; }
        public byte? AverageB { get; set; }
        public DateTime? Date { get; set; }
        public float? Aspect { get; set; }
    }
}
