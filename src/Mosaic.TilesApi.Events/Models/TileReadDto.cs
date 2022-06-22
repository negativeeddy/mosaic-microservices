namespace Mosaic.TilesApi;

public record TileReadDto
{
    public int Id { get; set; }
    public string Source { get; set; }
    public string SourceId { get; set; }
    public string SourceData { get; set; }
    public int? Width { get; set; }
    public int? Height { get; set; }
    public Color? AverageColor { get; set; }
    public DateTime? Date { get; set; }
    public float? Aspect { get; set; }
}
