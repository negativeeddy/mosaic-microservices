namespace Mosaic.TileSources.Flickr;

#pragma warning disable CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Consider declaring as nullable.
public record Photo
{
    public string id { get; set; }
    public string owner { get; set; }
    public string secret { get; set; }
    public string server { get; set; }
    public int farm { get; set; }
    public string title { get; set; }
    public int ispublic { get; set; }
    public int isfriend { get; set; }
    public int isfamily { get; set; }
    public string url_m { get; set; }
    public int height_m { get; set; }
    public int width_m { get; set; }
    public string license { get; set; }

    public string BuildUrl(string size) => $"https://live.staticflickr.com/{server}/{id}_{secret}_{size}.jpg";
}

