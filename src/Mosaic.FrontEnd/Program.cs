using Mosaic.FrontEnd.Data;
using Mosaic.TileSources.Flickr;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

var daprJsonOptions = new JsonSerializerOptions()
{
    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
    PropertyNameCaseInsensitive = true,
};

FlickrOptions flickrOptions = new();
builder.Configuration.Bind("flickr", flickrOptions);
builder.Services.AddScoped<FlickrTileSource>(sp =>
    new FlickrTileSource(
        sp.GetRequiredService<ILogger<FlickrTileSource>>(),
        sp.GetRequiredService<HttpClient>(),
        flickrOptions));

// Add services to the container.
builder.Services.AddRazorPages().AddDapr(builder => builder.UseJsonSerializationOptions(daprJsonOptions));
builder.Services.AddServerSideBlazor();
builder.Services.AddHttpClient();
builder.Services.AddScoped<TileService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseStaticFiles();

app.UseRouting();

app.MapBlazorHub();
app.MapFallbackToPage("/_Host");

app.Run();
