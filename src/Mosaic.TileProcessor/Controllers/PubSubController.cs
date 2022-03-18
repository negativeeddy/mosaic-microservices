using Dapr;
using Microsoft.AspNetCore.Mvc;
using Mosaic.TilesApi;

namespace Mosaic.TileProcessor.Controllers;

/// <summary>
/// Sample showing Dapr integration with controller.
/// </summary>
[ApiController]
public class PubSubController : ControllerBase
{
    /// <summary>
    /// SampleController Constructor with logger injection
    /// </summary>
    /// <param name="logger"></param>
    public PubSubController(ILogger<PubSubController> logger)
    {
        this._logger = logger;
    }

    private const string PubsubName = "pubsub";
    private readonly ILogger<PubSubController> _logger;

    /// <summary>
    /// Method for depositing to account as specified in transaction.
    /// </summary>
    /// <param name="transaction">Transaction info.</param>
    /// <param name="daprClient">State client to interact with Dapr runtime.</param>
    /// <returns>A <see cref="Task{TResult}"/> representing the result of the asynchronous operation.</returns>
    ///  "pubsub", the first parameter into the Topic attribute, is name of the default pub/sub configured by the Dapr CLI.
    [Topic(PubsubName, nameof(TileCreatedEvent))]
    [HttpPost("tileCreated")]
    public void TileCreatedHandler(TileCreatedEvent tile)
    {
        _logger.LogInformation($"Received {nameof(TileCreatedEvent)} event - tile ID {{TileId}}", tile.TileId);
        TileProcessingService.TileQueue.Add(tile);
    }
}
