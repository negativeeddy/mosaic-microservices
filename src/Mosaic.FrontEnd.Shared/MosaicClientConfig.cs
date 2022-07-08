using Microsoft.Extensions.Configuration;

namespace Mosaic.FrontEnd.Shared
{
    public class MosaicClientConfig
    {
        public MosaicClientConfig(IConfiguration config)
        {
            ApiUri = config["apiGateway"];
        }

        public string ApiUri { get; set; }
    }
}