using Mosaic.ImageAnalysis;
using Mosaic.MosaicGenerator.Services;
using Mosaic.TileSources;
using Mosaic.TileSources.Flickr;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddTileSources();

builder.Services.AddControllers().AddDapr(builder =>
       builder.UseJsonSerializationOptions(
           new JsonSerializerOptions()
           {
               PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
               PropertyNameCaseInsensitive = true,
           }));

builder.Services.AddSingleton<ImageAnalyzer>();
builder.Services.AddScoped<MosaicService>();
builder.Services.AddScoped<MosaicGenerator>();
builder.Services.AddHostedService<MosaicGeneratorService>();
builder.Services.AddHttpClient();

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

app.Run();
