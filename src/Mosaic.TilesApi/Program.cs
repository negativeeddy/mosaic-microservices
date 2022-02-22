using Dapr.Client;
using Dapr.Extensions.Configuration;
using Microsoft.EntityFrameworkCore;
using Mosaic.TilesApi.Data;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());

// Add services to the container.
builder.Services.AddDbContext<TilesDbContext>(options =>
{
    //string connectionString = builder.Configuration["tiledbconnectionstring"];
    //options.UseSqlServer(connectionString);
    options.UseSqlServer("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
    //options.UseSqlServer("Server=(localdb)\\mssqllocaldb;Database=MosaicTiles;Trusted_Connection=True;MultipleActiveResultSets=true");
    //options.UseSqlServer(builder.Configuration["TilesDbContext"])
});

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

app.UseAuthorization();

app.MapControllers();

app.MapGet("/", () => "Tile API");

app.Run();
