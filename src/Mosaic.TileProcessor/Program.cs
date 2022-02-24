using Mosaic.ImageAnalysis;
using Mosaic.TileProcessor;
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
