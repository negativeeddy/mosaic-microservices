using Dapr.Actors.Runtime;

namespace Mosaic.MosaicApi;

internal class MosaicActor : Actor, IMosaicActor
{
    private const string MosaicDetailsKey = "mosaicDetails";

    // The constructor must accept ActorHost as a parameter, and can also accept additional
    // parameters that will be retrieved from the dependency injection container
    //
    /// <summary>
    /// Initializes a new instance of MyActor
    /// </summary>
    /// <param name="host">The Dapr.Actors.Runtime.ActorHost that will host this actor instance.</param>
    public MosaicActor(ActorHost host) // Accept BankService in the constructor
        : base(host)
    {
    }

    public async Task<MosaicDetails> GetDetails()
    {
        return await this.StateManager.GetStateAsync<MosaicDetails>(MosaicDetailsKey);
    }

    public async Task<byte[]> GetImage()
    {
        throw new NotImplementedException();
    }

    public Task<TileId> GetTile(int row, int column)
    {
        throw new NotImplementedException();
    }

    public Task<TileId?[,]> GetTiles()
    {
        throw new NotImplementedException();
    }

    public Task<bool> IsComplete()
    {
        throw new NotImplementedException();
    }

    public Task<string> SetSize(int rows, int columns)
    {
        throw new NotImplementedException();
    }

    public async Task SetTile(int row, int column, TileId tile)
    {
        var details = await this.StateManager.GetStateAsync<MosaicDetails>(MosaicDetailsKey);
        details.TileDetails[column * row] = tile;
        await StateManager.SetStateAsync(MosaicDetailsKey, details);
    }

    ///// <summary>
    ///// This method is called whenever an actor is activated.
    ///// An actor is activated the first time any of its methods are invoked.
    ///// </summary>
    //protected override Task OnActivateAsync()
    //{
    //    // Provides opportunity to perform some optional setup.
    //    Console.WriteLine($"Activating actor id: {this.Id}");
    //    return Task.CompletedTask;
    //}

    ///// <summary>
    ///// This method is called whenever an actor is deactivated after a period of inactivity.
    ///// </summary>
    //protected override Task OnDeactivateAsync()
    //{
    //    // Provides Opporunity to perform optional cleanup.
    //    Console.WriteLine($"Deactivating actor id: {this.Id}");
    //    return Task.CompletedTask;
    //}

    ///// <summary>
    ///// Set MyData into actor's private state store
    ///// </summary>
    ///// <param name="data">the user-defined MyData which will be stored into state store as "my_data" state</param>
    //public async Task<string> SetDataAsync(MosaicDetails data)
    //{
    //    // Data is saved to configured state store implicitly after each method execution by Actor's runtime.
    //    // Data can also be saved explicitly by calling this.StateManager.SaveStateAsync();
    //    // State to be saved must be DataContract serializable.
    //    await this.StateManager.SetStateAsync<MosaicDetails>(
    //        "my_data",  // state name
    //        data);      // data saved for the named state "my_data"

    //    return "Success";
    //}

    ///// <summary>
    ///// Get MyData from actor's private state store
    ///// </summary>
    ///// <return>the user-defined MyData which is stored into state store as "my_data" state</return>
    //public Task<MosaicDetails> GetDataAsync()
    //{
    //    // Gets state from the state store.
    //    return this.StateManager.GetStateAsync<MosaicDetails>("my_data");
    //}

    ///// <summary>
    ///// Register MyReminder reminder with the actor
    ///// </summary>
    //public async Task RegisterReminder()
    //{
    //    await this.RegisterReminderAsync(
    //        "MyReminder",              // The name of the reminder
    //        null,                      // User state passed to IRemindable.ReceiveReminderAsync()
    //        TimeSpan.FromSeconds(5),   // Time to delay before invoking the reminder for the first time
    //        TimeSpan.FromSeconds(5));  // Time interval between reminder invocations after the first invocation
    //}

    ///// <summary>
    ///// Unregister MyReminder reminder with the actor
    ///// </summary>
    //public Task UnregisterReminder()
    //{
    //    Console.WriteLine("Unregistering MyReminder...");
    //    return this.UnregisterReminderAsync("MyReminder");
    //}

    //// <summary>
    //// Implement IRemindeable.ReceiveReminderAsync() which is call back invoked when an actor reminder is triggered.
    //// </summary>
    //public Task ReceiveReminderAsync(string reminderName, byte[] state, TimeSpan dueTime, TimeSpan period)
    //{
    //    Console.WriteLine("ReceiveReminderAsync is called!");
    //    return Task.CompletedTask;
    //}

    ///// <summary>
    ///// Register MyTimer timer with the actor
    ///// </summary>
    //public Task RegisterTimer()
    //{
    //    return this.RegisterTimerAsync(
    //        "MyTimer",                  // The name of the timer
    //        nameof(this.OnTimerCallBack),       // Timer callback
    //        null,                       // User state passed to OnTimerCallback()
    //        TimeSpan.FromSeconds(5),    // Time to delay before the async callback is first invoked
    //        TimeSpan.FromSeconds(5));   // Time interval between invocations of the async callback
    //}

    ///// <summary>
    ///// Unregister MyTimer timer with the actor
    ///// </summary>
    //public Task UnregisterTimer()
    //{
    //    Console.WriteLine("Unregistering MyTimer...");
    //    return this.UnregisterTimerAsync("MyTimer");
    //}

    ///// <summary>
    ///// Timer callback once timer is expired
    ///// </summary>
    //private Task OnTimerCallBack(byte[] data)
    //{
    //    Console.WriteLine("OnTimerCallBack is called!");
    //    return Task.CompletedTask;
    //}
}
