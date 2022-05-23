using Mosaic.ImageAnalysis;
using Mosaic.MosaicGenerator;
using Mosaic.TileSources;
using Mosaic.TileSources.Flickr;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

FlickrOptions flickrOptions = new();
builder.Configuration.Bind("flickr", flickrOptions);
builder.Services.AddTileSources(flickrOptions);

builder.Services.AddControllers().AddDapr(builder =>
       builder.UseJsonSerializationOptions(
           new JsonSerializerOptions()
           {
               PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
               PropertyNameCaseInsensitive = true,
           }));

builder.Services.AddSingleton<ImageAnalyzer>();
builder.Services.AddHostedService<MosaicGeneratorService>();
builder.Services.AddHttpClient();

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
