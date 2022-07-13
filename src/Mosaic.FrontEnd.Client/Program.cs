using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Authentication;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using Mosaic.FrontEnd.Client;
using Mosaic.FrontEnd.Data;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");

builder.Services.AddHttpClient("BlazorSample.ServerAPI", client => client.BaseAddress = new Uri(builder.HostEnvironment.BaseAddress))
    .AddHttpMessageHandler<BaseAddressAuthorizationMessageHandler>();

// load the appSettings.json from the server instead of from wwwroot
using (var client = new HttpClient { BaseAddress = new Uri(builder.HostEnvironment.BaseAddress) })
{
    var configStream = await client.GetStreamAsync("clientConfig");
    builder.Configuration.AddJsonStream(configStream);
}

// Supply HttpClient instances that include access tokens when making requests to the server project
builder.Services.AddScoped(sp => sp.GetRequiredService<IHttpClientFactory>().CreateClient("BlazorSample.ServerAPI"));

builder.Services.AddMsalAuthentication(options =>
{
    builder.Configuration.Bind("AzureAdB2C", options.ProviderOptions.Authentication);
    string? defaultAccessTokenScopes = builder.Configuration["DefaultAccessTokenScopes"];
    options.ProviderOptions.DefaultAccessTokenScopes.Add(defaultAccessTokenScopes);
});

builder.Services.AddScoped<MosaicService>();


await builder.Build().RunAsync();
