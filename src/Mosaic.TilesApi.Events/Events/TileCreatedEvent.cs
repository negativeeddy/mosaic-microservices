namespace Mosaic.TilesApi;

public record TileCreatedEvent
{
    public int TileId { get; set; }
    public string Source { get; set; }
    public string SourceId { get; set; }
    public string SourceData { get; set; }
}
