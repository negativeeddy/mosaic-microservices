using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using Mosaic.FrontEnd.Client;
using Mosaic.FrontEnd.Data;
using System.Net.Http.Json;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");

var client = new HttpClient { BaseAddress = new Uri(builder.HostEnvironment.BaseAddress) };
builder.Services.AddScoped(sp => client);
builder.Services.AddScoped<MosaicService>();

MosaicClientConfig clientCfg = await client.GetFromJsonAsync<MosaicClientConfig>("api");
builder.Services.AddSingleton<MosaicClientConfig>(clientCfg);

await builder.Build().RunAsync();
