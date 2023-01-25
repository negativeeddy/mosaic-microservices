using System.Text.Json.Serialization;

namespace Mosaic.FrontEnd.Shared;

public record MosaicClientConfig
{
    public AzureAdB2CConfig? AzureAdB2C { get; init; }
    public string? DefaultAccessTokenScopes { get; init; }
    public string? ApiUri { get; init; }
}

public record AzureAdB2CConfig
{
    public string? ValidateAuthority { get; init; }
    public string? ClientId { get; init; }
    public string? Authority { get; init; }
}