using Mosaic.ImageAnalysis;
using Mosaic.TileProcessor;
using Mosaic.TileProcessor.TileSources;
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

builder.Services.AddScoped<FlickrTileSource>();
builder.Services.AddScoped<BlobTileSource>();
builder.Services.AddScoped<Func<string, ITileSource>>(provider => (src => src switch
    {
        "flickr" => provider.GetRequiredService<FlickrTileSource>(),
        "local" => provider.GetRequiredService<BlobTileSource>(),
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
