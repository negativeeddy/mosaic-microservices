namespace Mosaic.FrontEnd.Data;

public record TileCreateDto
{
    public string Source { get; set; }
    public string SourceId { get; set; }
    public string SourceData { get; set; }
}
