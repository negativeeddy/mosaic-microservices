using Dapr.Client;
using Mosaic.TilesApi;
using Mosaic.TilesApi.Models;
using System.Collections.Concurrent;

namespace Mosaic.TileProcessor
{
    public class TileProcessingService : BackgroundService
    {
        public static BlockingCollection<TileCreatedEvent> TileQueue { get; set; } = new();

        private readonly ILogger<TileProcessingService> _logger;
        private readonly DaprClient _daprClient;

        public TileProcessingService(ILogger<TileProcessingService> logger, DaprClient daprClient)
        {
            _logger = logger;
            _daprClient = daprClient;
        }

        protected override Task ExecuteAsync(CancellationToken stoppingToken)
        {
            return Task.Run(async () =>
            {
                try
                {
                    TileCreatedEvent tile;
                    while (!stoppingToken.IsCancellationRequested)
                    {
                        tile = TileQueue.Take(stoppingToken);

                        try
                        {
                            // generate tile details
                            TileUpdateDto data = await PopulateTileInfo(tile, stoppingToken);

                            // store tile details
                            await _daprClient.InvokeMethodAsync<TileUpdateDto>(
                                    HttpMethod.Put,
                                    "tilesapi",
                                    $"tiles/{tile.TileId}",
                                    data);
                        }
                        catch (Exception ex)
                        {
                            _logger.LogError(ex, "Failed to process tile {TileId}", tile.TileId);
                        }
                    }
                }
                catch (OperationCanceledException)
                {
                    return;
                }
            });
        }

        private async Task<TileUpdateDto> PopulateTileInfo(TileCreatedEvent tile, CancellationToken cancel)
        {

            var result = tile.Source switch
            {
                "internal" => await PopulateInternallyStoredTile(tile, cancel),
                _ => new TileUpdateDto
                {
                    Id = tile.TileId,
                    Aspect = 1.0f,
                    AverageColor = 128,
                    Width = 1024,
                    Height = 768,
                }
            };

            return result;
        }

        private async Task<TileUpdateDto> PopulateInternallyStoredTile(TileCreatedEvent tile, CancellationToken cancel)
        {
            var bindingRequest = new BindingRequest("tilestorage", "get");
            bindingRequest.Metadata.Add("blobName", tile.SourceId); 
            var response = await _daprClient.InvokeBindingAsync(bindingRequest, cancel);
            var byteArray = response.Data.ToArray();

            _logger.LogInformation("Processing tile {TileId} from internal storage. {byteCount} bytes", tile.TileId, byteArray.Length);

            return new TileUpdateDto
            {
                Id = tile.TileId,
                Aspect = 1.333f,
                AverageColor = 128,
                Width = 1024,
                Height = 768,
            };
        }
    }
}
