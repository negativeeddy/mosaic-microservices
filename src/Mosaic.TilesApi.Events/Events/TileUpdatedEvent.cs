namespace Mosaic.TilesApi
{
    public class TileUpdatedEvent
    {
        public int TileId { get; set; }
        public int? Width { get; set; }
        public int? Height { get; set; }
        public byte? AverageColor { get; set; }
        public float? Aspect { get; set; }
    }
}