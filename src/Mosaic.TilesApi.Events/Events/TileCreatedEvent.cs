namespace Mosaic.TilesApi;

public record TileCreatedEvent
{
    public int TileId { get; set; }
    public required string Source { get; set; }
    public required string SourceId { get; set; }
    public string? SourceData { get; set; }
}
