namespace Mosaic.TileSources.Flickr;
#pragma warning disable CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Consider declaring as nullable.

public record Extra
{
    public required string explore_date { get; set; }
    public int next_prelude_interval { get; set; }
}
