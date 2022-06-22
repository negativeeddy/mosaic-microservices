using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Mosaic.TileSources.AzureBlobStorage;
using Mosaic.TileSources.Flickr;

namespace Mosaic.TileSources
{
    public static class ServiceRegistration
    {
        static public IServiceCollection AddTileSources(this IServiceCollection services, FlickrOptions flickrOptions)
        {
            services.AddScoped<FlickrTileSource>(sp =>
                new FlickrTileSource(
                    sp.GetRequiredService<ILogger<FlickrTileSource>>(),
                    sp.GetRequiredService<HttpClient>(),
                    flickrOptions));

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
