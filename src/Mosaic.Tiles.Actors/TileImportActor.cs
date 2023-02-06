using Dapr.Actors.Runtime;
using Dapr.Client;
using Mosaic.Tiles.Actors.Interfaces;

namespace Mosaic.Tiles.Actors;

internal class TileImportActor : Actor, ITileImportActor
{
    private const string TimerName = "TileImportActorTimer";
    private readonly ILogger<TileImportActor> _logger;
    private readonly DaprClient _daprClient;

    // The constructor must accept ActorHost as a parameter, and can also accept additional
    // parameters that will be retrieved from the dependency injection container
    //
    /// <summary>
    /// Initializes a new instance of MyActor
    /// </summary>
    /// <param name="host">The Dapr.Actors.Runtime.ActorHost that will host this actor instance.</param>
    public TileImportActor(ActorHost host, ILogger<TileImportActor> logger, DaprClient daprClient)
        : base(host)
    {
        _logger = logger;
        _daprClient = daprClient;
    }

    /// <summary>
    /// This method is called whenever an actor is activated.
    /// An actor is activated the first time any of its methods are invoked.
    /// </summary>
    protected override Task OnActivateAsync()
    {
        // Provides opportunity to perform some optional setup.
        _logger.LogInformation($"Activating actor id: {this.Id}");
        return Task.CompletedTask;
    }

    /// <summary>
    /// This method is called whenever an actor is deactivated after a period of inactivity.
    /// </summary>
    protected override Task OnDeactivateAsync()
    {
        // Provides Opporunity to perform optional cleanup.
        _logger.LogInformation($"Deactivating actor id: {this.Id}");
        return Task.CompletedTask;
    }

    /// <summary>
    /// Set MyData into actor's private state store
    /// </summary>
    /// <param name="data">the user-defined MyData which will be stored into state store as "my_data" state</param>
    private async Task SetDataAsync(ImportData data)
    {
        // Data is saved to configured state store implicitly after each method execution by Actor's runtime.
        // Data can also be saved explicitly by calling this.StateManager.SaveStateAsync();
        // State to be saved must be DataContract serializable.
        await this.StateManager.SetStateAsync<ImportData>(
            nameof(ImportData),  // state name
            data);      // data saved for the named state "my_data"
    }

    /// <summary>
    /// Get MyData from actor's private state store
    /// </summary>
    /// <return>the user-defined MyData which is stored into state store as "my_data" state</return>
    private async Task<ImportData?> GetDataAsync()
    {
        // Gets state from the state store.
        try
        {
            return await this.StateManager.GetStateAsync<ImportData>(nameof(ImportData));
        }
        catch(KeyNotFoundException)
        {
            return null;
        }
    }

    private async Task RemoveDataAsync()
    {
        try
        {
            await this.StateManager.RemoveStateAsync(nameof(ImportData));
        }
        catch (KeyNotFoundException)
        {
        }
    }

    /// <summary>
    /// Register MyTimer timer with the actor
    /// </summary>
    public async Task StartImporting(string apiKey)
    {
        _logger.LogInformation($"Registering {TimerName}...");

        await SetDataAsync(new ImportData { FlickrKey = apiKey });

        await RegisterTimerAsync(
            TimerName,                      // The name of the timer
            nameof(this.OnTimerCallBack),   // Timer callback
            null,                           // User state passed to OnTimerCallback()
            TimeSpan.FromSeconds(0),        // Time to delay before the async callback is first invoked
            TimeSpan.FromHours(1));         // Time interval between invocations of the async callback
    }

    /// <summary>
    /// Unregister MyTimer timer with the actor
    /// </summary>
    public async Task StopImporting()
    {
        _logger.LogInformation($"Unregistering {TimerName}...");
        await UnregisterTimerAsync(TimerName);
        await RemoveDataAsync();
    }

    /// <summary>
    /// Timer callback once timer is expired
    /// </summary>
    private async Task OnTimerCallBack(byte[] data)
    {
        await ImportFromFlicker();
    }

    public struct ItemStatus
    {
        public string Name { get; set; }
        public string Status { get; set; }
    }


    private async Task ImportFromFlicker()
    {
        try
        {
            _logger.LogInformation("ImportFromFlicker is called!");
            var state = await GetDataAsync();

            var statuses = await _daprClient.InvokeMethodAsync<ImportOptions, ItemStatus[]>(
                HttpMethod.Post,
                "tilesapi",
                $"internal/tiles/import/flickr?userId={this.Id.GetId()}",
                new ImportOptions { FlickrApiKey = state.FlickrKey });

            int importedCount = statuses.Count(x => x.Status == "processing");

            state = state with
            {
                FlickrLastImport = DateTime.UtcNow,
                FlickrLastImportCount = importedCount,
                FlickrTotalImportCount = state.FlickrTotalImportCount + importedCount,
            };

            await this.SetDataAsync(state);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error while importing from flicker");
        }

    }

    public async Task<ImportStatus> GetImportStatus()
    {
        var state = await GetDataAsync();
        return new ImportStatus
        {
            FlickrLastImportCount = state?.FlickrLastImportCount ?? 0,
            FlickrLastImportDate = state?.FlickrLastImport ?? DateTime.MinValue,
            FlickrTotalImportCount = state?.FlickrTotalImportCount ?? 0,
        };
    }
}

