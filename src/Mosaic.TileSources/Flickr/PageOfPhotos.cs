namespace Mosaic.TileSources.Flickr;
#pragma warning disable CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Consider declaring as nullable.

public record PageOfPhotos
{
    public int page { get; set; }
    public int pages { get; set; }
    public int perpage { get; set; }
    public int total { get; set; }
    public Photo[] photo { get; set; }

}
