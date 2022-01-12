namespace Mosaic.TilesApi
{
    public class TileCreatedEvent
    {
        public int TileId { get; set; }
        public string Source { get; set; }
        public string SourceId { get; set; }
    }
}