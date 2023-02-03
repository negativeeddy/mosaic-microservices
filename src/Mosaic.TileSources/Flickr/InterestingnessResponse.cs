namespace Mosaic.TileSources.Flickr;
#pragma warning disable CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Consider declaring as nullable.

public record InterestingnessResponse
{
    public required PageOfPhotos photos { get; set; }
    public required Extra extra { get; set; }
    public required string stat { get; set; }
}
