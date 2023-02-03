using Dapr.Client;
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
        UserData? userInfo = await _daprClient.GetStateAsync<UserData>(StoreName, clientId);

        if (userInfo is null || userInfo.mosaicIds.Count == 0)
        {
            return new MosaicEntity[0];
        }

        IReadOnlyList<BulkStateItem> results = await _daprClient.GetBulkStateAsync(StoreName, userInfo.mosaicIds, 0);
        return results.Select(x => JsonSerializer.Deserialize<MosaicEntity>(x.Value, jsonOptions)!)
                      .ToArray();
    }

    public async Task SaveMosaic(string? clientId, string id, MosaicEntity mosaic)
    {
        if (clientId is not null)
        {
            var userInfo = await _daprClient.GetStateAsync<UserData>(StoreName, clientId);
            if (userInfo is null)
            {
                userInfo = new UserData(new List<string> { id });
            }
            else
            {
                if (userInfo.mosaicIds.Contains(id))
                {
                    throw new InvalidOperationException("mosaic exists with same id");
                }

                userInfo.mosaicIds.Add(id);
            }

            await _daprClient.SaveStateAsync(StoreName, clientId, userInfo);
        }

        await _daprClient.SaveStateAsync(StoreName, id, mosaic);
    }

    internal async Task<bool> DeleteMosaic(string id)
    {
        await _daprClient.DeleteStateAsync(StoreName, id);
        return true;
    }
}

public record UserData(List<string> mosaicIds);
