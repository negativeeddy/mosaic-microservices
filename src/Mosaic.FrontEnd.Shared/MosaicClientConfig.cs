using System.Text.Json.Serialization;

namespace Mosaic.FrontEnd.Shared;

public class MosaicClientConfig
{
    public AzureAdB2CConfig AzureAdB2C { get; set; }
    public string DefaultAccessTokenScopes { get; set; }
    public string ApiUri { get; set; }
}

public class AzureAdB2CConfig
{
    public string ValidateAuthority { get; set; }
    public string ClientId { get; set; }
    public string Authority { get; set; }
}