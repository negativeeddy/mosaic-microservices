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

builder.Services.AddApplicationInsightsTelemetry(builder.Configuration["APPLICATIONINSIGHTS_CONNECTION_STRING"]);

var app = builder.Build();

app.UseRouting();

//app.UseHttpsRedirection();

app.UseCloudEvents();

app.UseAuthorization();

app.MapSubscribeHandler();
app.MapControllers();

app.MapGet("/", () => "TileProcessor");

app.Run();
