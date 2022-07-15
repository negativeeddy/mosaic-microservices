using Dapr.Client;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Identity.Web;
using Mosaic.MosaicApi.Data;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddMicrosoftIdentityWebApi(builder.Configuration.GetSection("AzureAdB2C"));

var daprJsonOptions = new JsonSerializerOptions()
{
    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
    PropertyNameCaseInsensitive = true,
};

builder.Services.AddControllers().AddDapr(builder => builder.UseJsonSerializationOptions(daprJsonOptions));

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddApplicationInsightsTelemetry(builder.Configuration["APPLICATIONINSIGHTS_CONNECTION_STRING"]);

builder.Services.AddScoped<MosaicStore>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

//app.UseHttpsRedirection();

app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.MapGet("/", () => "Mosaic API");

app.MapPost("/setstate/{id}", async (int id, [Microsoft.AspNetCore.Mvc.FromBody] string data, DaprClient dapr) =>
{
    await dapr.SaveStateAsync("mosaicstate", "order_1", id.ToString());
    await dapr.SaveStateAsync("mosaicstate", "order_2", new {test="testval", myint=234});
    return $"set success {id}";

});

app.MapGet("getstate/{id}", async (int id, DaprClient dapr) =>
{
    var result = await dapr.GetStateAsync<string>("mosaicstate", "order_1");
    return $"get success {result}";
});

app.Run();
