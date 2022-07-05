using Dapr.Client;
using Mosaic.MosaicApi;
using System.Collections.Concurrent;

namespace Mosaic.MosaicGenerator.Services;
public class MosaicGeneratorService : BackgroundService
{
    public static BlockingCollection<MosaicCreatedEvent> MosaicQueue { get; set; } = new();

    private readonly ILogger<MosaicGeneratorService> _logger;
    private readonly DaprClient _daprClient;
    private readonly IServiceProvider _serviceProvider;

    public MosaicGeneratorService(IServiceProvider serviceProvider, ILogger<MosaicGeneratorService> logger, DaprClient daprClient)
    {
        _logger = logger;
        _daprClient = daprClient;
        _serviceProvider = serviceProvider;
    }

    protected override Task ExecuteAsync(CancellationToken stoppingToken)
    {
        return Task.Run(async () =>
        {
            try
            {
                MosaicCreatedEvent mosaic;
                while (!stoppingToken.IsCancellationRequested)
                {
                    mosaic = MosaicQueue.Take(stoppingToken);

                    try
                    {
                        // generate tile details
                        using var scope = _serviceProvider.CreateScope();

                        var generator = scope.ServiceProvider.GetRequiredService<MosaicGenerator>();
                        await generator.CreateMosaic(mosaic, stoppingToken);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Failed to generate mosaic ID {MosaicId}", mosaic.mosaicId);
                    }
                }
            }
            catch (OperationCanceledException)
            {
                return;
            }
        });
    }

}

