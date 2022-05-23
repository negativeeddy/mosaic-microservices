using Mosaic.ImageAnalysis;
using Mosaic.TileProcessor;
using Mosaic.TileProcessor.TileSources;
using Mosaic.TileSources;
using Mosaic.TileSources.Flickr;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers().AddDapr(builder =>
       builder.UseJsonSerializationOptions(
           new JsonSerializerOptions()
           {
               PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
               PropertyNameCaseInsensitive = true,
           }));

builder.Services.AddSingleton<ImageAnalyzer>();
builder.Services.AddHostedService<TileProcessingService>();
builder.Services.AddHttpClient();

FlickrOptions flickrOptions = new();
builder.Configuration.Bind("flickr", flickrOptions);
builder.Services.AddScoped<FlickrTileSource>(sp =>
    new FlickrTileSource(
        sp.GetRequiredService<ILogger<FlickrTileSource>>(),
        sp.GetRequiredService<HttpClient>(),
        flickrOptions));

builder.Services.AddScoped<BlobTileSource>();
builder.Services.AddScoped<Func<string, ITileSource>>(provider => (src => src switch
    {
        "flickr" => provider.GetRequiredService<FlickrTileSource>(),
        "internal" => provider.GetRequiredService<BlobTileSource>(),
        _ => throw new NotImplementedException(),
    }));

var app = builder.Build();

app.UseRouting();

//app.UseHttpsRedirection();

app.UseCloudEvents();

app.UseAuthorization();

app.UseEndpoints(endpoints =>
{
    endpoints.MapSubscribeHandler();
    endpoints.MapControllers();
});

app.Run();
