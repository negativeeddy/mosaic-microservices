namespace Mosaic.TilesApi
{
    public static class TileEvents
    {
        public const string TileCreated = nameof(TileCreated);
        public const string TileDeleted = nameof(TileDeleted);
        public const string TileUpdated = nameof(TileUpdated);
    }

    public struct TileCreatedEvent
    {
        public int TileId { get; set; }
        public string Source { get; set; }
        public string SourceId { get; set; }
    }

    public struct TileDeletedEvent
    {
        public int TileId { get; set; }
    }

    public struct TileUpdatedEvent
    {
        public int TileId { get; set; }
        public int? Width { get; set; }
        public int? Height { get; set; }
        public byte? AverageColor { get; set; }
        public float? Aspect { get; set; }
    }
}