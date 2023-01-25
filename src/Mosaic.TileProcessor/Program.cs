using Mosaic.ImageAnalysis;
using Mosaic.TileProcessor;
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

builder.Services.AddTileSources();

string? insightsConnectionString = builder.Configuration["APPLICATIONINSIGHTS_CONNECTION_STRING"];
if (insightsConnectionString is null)
{
    System.Diagnostics.Trace.WriteLine("Config is missing APPLICATIONINSIGHTS_CONNECTION_STRING");
}
else
{
    builder.Services.AddApplicationInsightsTelemetry(config =>
    {
        config.ConnectionString = insightsConnectionString;
    });
}

var app = builder.Build();

app.UseRouting();

//app.UseHttpsRedirection();

app.UseCloudEvents();

app.UseAuthorization();

app.MapSubscribeHandler();
app.MapControllers();

app.MapGet("/", () => "TileProcessor");

app.Run();
