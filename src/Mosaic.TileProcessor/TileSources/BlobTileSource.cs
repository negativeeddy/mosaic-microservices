using Dapr.Client;
using System.Text;

namespace Mosaic.TileProcessor.TileSources;

public class BlobTileSource : ITileSource
{
    private readonly ILogger _logger;
    private readonly DaprClient _daprClient;

    public string Source => "internal";

    public BlobTileSource(ILogger<BlobTileSource> logger, DaprClient daprClient)
    {
        _logger = logger;
        _daprClient = daprClient;
    }

    public async Task<Stream> GetTileAsync(string tileData, CancellationToken token)
    {
        var bindingRequest = new BindingRequest("tilestorage", "get");
        bindingRequest.Metadata.Add("blobName", tileData);
        var response = await _daprClient.InvokeBindingAsync(bindingRequest, token);
        var storageBytes = response.Data.ToArray();


        _logger.LogInformation("Processing tile {TileId} from internal storage. {byteCount} bytes", tileData, storageBytes.Length);
        _logger.LogInformation("Loaded tile {TileId} - first 4 bytes are {B1}, {B2}, {B3}, {B4}", tileData, storageBytes[0], storageBytes[1], storageBytes[2], storageBytes[3]);

        byte[] imageBytes;
        // check if is base64 encoded - can't currently deploy to Container Apps with dapr binding set to 
        // auto encode/decode. sometimes Dapr doesnt decode properly
        try
        {
            // TODO make this check better. Should not use exceptions as flow control
            _logger.LogInformation("Base64 decoding binary stream");
            var storageChars = Encoding.UTF8.GetChars(storageBytes);
            imageBytes = Convert.FromBase64CharArray(storageChars, 0, storageChars.Length);
            _logger.LogInformation("New stream is {Length} bytes", storageBytes.Length);
        }
        catch
        {
            _logger.LogInformation("Failed to Base64 decoding binary stream - using original stream");
            imageBytes = storageBytes;
        }
        MemoryStream imageStream = new MemoryStream(imageBytes);

        return imageStream;
    }
}
