namespace Mosaic.TileSources.Flickr;

public class PageOfPhotos
{
    public int page { get; set; }
    public int pages { get; set; }
    public int perpage { get; set; }
    public int total { get; set; }
    public Photo[] photo { get; set; }
}
