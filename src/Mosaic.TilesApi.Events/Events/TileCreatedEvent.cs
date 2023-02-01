namespace Mosaic.TilesApi;

public record TileCreatedEvent
{
    /// <summary>
    /// Id of the tile that was created
    /// </summary>
    public int TileId { get; set; }
    /// <summary>
    /// Name of the service that hosts the tile
    /// </summary>
    public required string Source { get; set; }
    /// <summary>
    /// Unique Id of the tile in the source service
    /// </summary>
    public required string SourceId { get; set; }
    /// <summary>
    /// Data used to retrieve the tile from the source
    /// </summary>
    public required string SourceData { get; set; }
}
