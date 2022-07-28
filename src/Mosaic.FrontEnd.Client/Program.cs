using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Authentication;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using Mosaic.FrontEnd.Client;
using Mosaic.FrontEnd.Client.Data;
using Mosaic.FrontEnd.Data;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");


// load the appSettings.json from the server instead of from wwwroot
using (var client = new HttpClient { BaseAddress = new Uri(builder.HostEnvironment.BaseAddress) })
{
    var configStream = await client.GetStreamAsync("clientConfig");
    builder.Configuration.AddJsonStream(configStream);
}

//configure an HTTP client to the correct endpoint with an auth header

string apiUri = builder.Configuration["ApiUri"];
string defaultAccessTokenScopes = builder.Configuration["DefaultAccessTokenScopes"];
string[] tokenScopesArray = defaultAccessTokenScopes.Split(' ', StringSplitOptions.TrimEntries);

builder.Services.AddHttpClient<MosaicService>(
        client => client.BaseAddress = new Uri(apiUri))
    .AddHttpMessageHandler(sp => sp.GetRequiredService<AuthorizationMessageHandler>()
    .ConfigureHandler(
        authorizedUrls: new[] { apiUri, builder.HostEnvironment.BaseAddress },
        scopes: tokenScopesArray ));

builder.Services.AddMsalAuthentication(options =>
{
    builder.Configuration.Bind("AzureAdB2C", options.ProviderOptions.Authentication);
    string? defaultAccessTokenScopes = builder.Configuration["DefaultAccessTokenScopes"];
    options.ProviderOptions.DefaultAccessTokenScopes.Add(defaultAccessTokenScopes);
});

builder.Services.AddScoped<MosaicService>();

builder.Services.AddSingleton<AppVersionInfo>();

await builder.Build().RunAsync();
