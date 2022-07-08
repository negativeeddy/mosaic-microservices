using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Mosaic.TileSources.AzureBlobStorage;
using Mosaic.TileSources.Flickr;

namespace Mosaic.TileSources
{
    public static class ServiceRegistration
    {
        static public IServiceCollection AddTileSources(this IServiceCollection services)
        {
            services.AddScoped<FlickrTileSource>();
            services.AddScoped<BlobTileSource>();
            services.AddScoped<Func<string, ITileSource>>(provider => (src => src switch
            {
                "flickr" => provider.GetRequiredService<FlickrTileSource>(),
                "internal" => provider.GetRequiredService<BlobTileSource>(),
                _ => throw new NotImplementedException(),
            }));

            return services;
        }
    }
}
