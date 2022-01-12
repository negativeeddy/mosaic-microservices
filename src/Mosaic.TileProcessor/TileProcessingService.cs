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

                        // generate tile details
                        TileUpdateDto data = PopulateTileInfo(tile);

                        // store tile details
                        await _daprClient.InvokeMethodAsync<TileUpdateDto>(
                                HttpMethod.Put,
                                "tilesapi",
                                $"tiles/{tile.TileId}",
                                data);
                    }
                }
                catch (OperationCanceledException)
                {
                    return;
                }
            });
        }

        private static TileUpdateDto PopulateTileInfo(TileCreatedEvent tile)
        {
            return new TileUpdateDto
            {
                Id = tile.TileId,
                Aspect = 1.0f,
                AverageColor = 128,
                Width = 1024,
                Height = 768,
            };
        }
    }
}
