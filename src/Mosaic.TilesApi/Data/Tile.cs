namespace Mosaic.TilesApi.Data
{
    public class Tile
    {
        public string Id { get; set; }
        public string Source { get; set; }
        public string SourceData { get; set; }
        public int? Width { get; set; }
        public int? Height { get; set; }
        public byte? AverageColor { get; set; }
        public DateTime? Date { get; set; }
        public float? Aspect { get; set; }
    }
}
