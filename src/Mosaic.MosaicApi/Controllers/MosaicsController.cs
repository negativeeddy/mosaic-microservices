using Dapr.Actors;
using Dapr.Actors.Client;
using Dapr.Client;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace Mosaic.MosaicApi.Controllers;

[ApiController]
public class MosaicsController : ControllerBase
{
    private readonly DaprClient _daprClient;

    public MosaicsController(DaprClient dapr)
    {
        _daprClient = dapr;
    }

    // GET api/<MosaicController>/5
    [HttpGet("[controller]/mosaics/{id}")]
    public MosaicDetails Get(string id)
    {
        return new MosaicDetails
        {
            Id = id,
            HorizontalTileCount = 5,
            VerticalTileCount = 5,
            TileDetails = new TileId[0, 0]
        };
    }

    // POST api/<MosaicController>
    [Route("[controller]/create")]
    [HttpPost]
    public async Task<ActionResult> Post([FromBody] MosaicOptions value)
    {
        Console.WriteLine("Startup up...");

        // Registered Actor Type in Actor Service
        var actorType = "MyActor";

        // An ActorId uniquely identifies an actor instance
        // If the actor matching this id does not exist, it will be created
        var actorId = new ActorId("1");

        // Create the local proxy by using the same interface that the service implements.
        //
        // You need to provide the type and id so the actor can be located. 
        var proxy = ActorProxy.Create<IMosaicActor>(actorId, actorType);

        // Now you can use the actor interface to call the actor's methods.
        Console.WriteLine($"Calling SetDataAsync on {actorType}:{actorId}...");
        var response = await proxy.SetTile(new MosaicDetails()
        {
            PropertyA = "ValueA",
            PropertyB = "ValueB",
        });
        Console.WriteLine($"Got response: {response}");

        Console.WriteLine($"Calling GetDataAsync on {actorType}:{actorId}...");
        var savedData = await proxy.GetDataAsync();
        Console.WriteLine($"Got response: {response}");

        return Created("5", new { Test = "test" });
    }

    // PUT api/<MosaicController>/5
    [HttpPut("{id}")]
    public void Put(int id, [FromBody] string value)
    {
    }

    // DELETE api/<MosaicController>/5
    [HttpDelete("{id}")]
    public void Delete(int id)
    {
    }
}
