namespace Mosaic.TilesApi;

public class MatchInfo
{
    public Color? Single { get; set; }
    public Color[]? TwoByTwo { get; set; }
    public Color[]? FourByFour { get; set; }
    public string[]? Sources { get; set; }
}