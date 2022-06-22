namespace Mosaic.TilesApi;

public record TileDeletedEvent
{
    public int TileId { get; set; }
}
