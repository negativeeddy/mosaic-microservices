﻿using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.Identity.Web;
using Mosaic.TilesApi.Data;
using System.Text.Json;
using Mosaic.TileSources;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddEntityFrameworkNpgsql()
                .AddDbContext<TilesDbContext>(options =>
{
    options.UseNpgsql(builder.Configuration.GetConnectionString("tiledbconnectionstring"),
        x =>
        {
            x.UseNetTopologySuite();
            x.EnableRetryOnFailure();
        });

    if (builder.Environment.IsDevelopment())
    {
        options.EnableDetailedErrors();
        options.EnableSensitiveDataLogging();
        options.UseQueryTrackingBehavior(QueryTrackingBehavior.NoTrackingWithIdentityResolution);
        options.ConfigureWarnings(action =>
        {
            action.Log(new[]
            {
                CoreEventId.FirstWithoutOrderByAndFilterWarning,
                CoreEventId.RowLimitingOperationWithoutOrderByWarning,
            });
        });
    }
});

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddMicrosoftIdentityWebApi(builder.Configuration.GetSection("AzureAdB2C"));

builder.Services.AddDatabaseDeveloperPageExceptionFilter();

var daprJsonOptions = new JsonSerializerOptions()
{
    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
    PropertyNameCaseInsensitive = true,
};

builder.Services.AddControllers().AddDapr(builder => builder.UseJsonSerializationOptions(daprJsonOptions));

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

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


builder.Services.AddHealthChecks()
                .AddDbContextCheck<TilesDbContext>();

builder.Services.AddTileSources();

var app = builder.Build();



// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
    app.UseSwagger();
    app.UseSwaggerUI();

    using (var scope = app.Services.CreateScope())
    {
        var services = scope.ServiceProvider;

        ////r context = services.GetRequiredService<TilesDbContext>();
        ////ntext.Database.EnsureCreated();
        // DbInitializer.Initialize(context);
    }
}

//app.UseHttpsRedirection();
app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.MapGet("/", (IConfiguration config) => $"Tiles API : {config["SRC_COMMIT"]}");

app.MapHealthChecks("/healthz");

app.Run();
