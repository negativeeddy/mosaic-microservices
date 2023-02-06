using Mosaic.Tiles.Actors;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

var daprJsonOptions = new JsonSerializerOptions()
{
    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
    PropertyNameCaseInsensitive = true,
};

builder.Services.AddDaprClient(builder => builder.UseJsonSerializationOptions(daprJsonOptions));

builder.Services.AddActors(options =>
{
    // Register actor types and configure actor settings
    options.Actors.RegisterActor<TileImportActor>();
});

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

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}

app.MapActorsHandlers();

app.MapGet("/", () => "Mosaic Tile Actors");

app.Run();
