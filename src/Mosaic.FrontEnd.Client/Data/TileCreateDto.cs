namespace Mosaic.FrontEnd.Data;

public record TileCreateDto
{
    public required string Source { get; set; }
    public required string SourceId { get; set; }
    public required string SourceData { get; set; }
}
