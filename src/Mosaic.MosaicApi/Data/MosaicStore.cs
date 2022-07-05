#nullable disable
using Dapr.Client;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;

namespace Mosaic.MosaicApi.Data;

public class MosaicStore 
{
    private const string StoreName = "mosaicstate";
    private readonly DaprClient _daprClient;

    public MosaicStore(DaprClient daprClient)
    {
        _daprClient = daprClient;
    }

    public async Task<MosaicEntity> GetMosaic(string id)
    {
        return await _daprClient.GetStateAsync<MosaicEntity>(StoreName, id);
    }

    private static JsonSerializerOptions jsonOptions = new JsonSerializerOptions
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        PropertyNameCaseInsensitive = true,
    };

public async Task<MosaicEntity[]> GetAllMosaicsForUser(string clientId)
    {
        // queries are currently in alpha
        string query = "{}";
        var response = await _daprClient.QueryStateAsync<MosaicEntity>(StoreName, query);
        var keys = response.Results.Select(x=>x.Key).ToArray();

        IReadOnlyList<BulkStateItem> results = await _daprClient.GetBulkStateAsync(StoreName, keys, 0);
        return results.Select(x => JsonSerializer.Deserialize<MosaicEntity>(x.Value, jsonOptions))
                      .ToArray();
    }

    public async Task SaveMosaic(string id, MosaicEntity mosaic)
    {
        await _daprClient.SaveStateAsync(StoreName, id, mosaic);
    }

    internal async Task<bool> DeleteMosaic(string id)
    {
        await _daprClient.DeleteStateAsync(StoreName, id);
        return true;
    }
}
