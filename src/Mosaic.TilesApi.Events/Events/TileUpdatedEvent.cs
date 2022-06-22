namespace Mosaic.TilesApi;

public record TileUpdatedEvent
{
    public int TileId { get; set; }
    public int? Width { get; set; }
    public int? Height { get; set; }
    public Color? AverageColor { get; set; }
    public float? Aspect { get; set; }
}
