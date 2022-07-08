using System.Net.Http.Headers;
using System.Net.Http.Json;

namespace Mosaic.FrontEnd.Data;

public class MosaicService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<MosaicService> _logger;
    private readonly MosaicClientConfig _config = new MosaicClientConfig
    {
        ApiUrl = "http://localhost:10000"
    };

    public MosaicService(HttpClient httpClient, ILogger<MosaicService> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
    }

    public async Task<TileReadDto[]> GetTiles(int page = 0, int pageSize = 20)
    {
        var tiles = await _httpClient.GetFromJsonAsync<TileReadDto[]>($"{_config.ApiUrl}/tiles/tiles?page={page}&pageSize={pageSize}");
        return tiles ?? new TileReadDto[0];
    }

    public async Task<TileReadDto> GetTile(int id)
    {
        TileReadDto? tile = await _httpClient.GetFromJsonAsync<TileReadDto>($"{_config.ApiUrl}/tiles/tiles/{id}");
        return tile;
    }

    public async Task<TileReadDto> AddNewTile(TileCreateDto tile)
    {
        var response = await _httpClient.PostAsJsonAsync<TileCreateDto>($"{_config.ApiUrl}/tiles/tiles", tile);

        response.EnsureSuccessStatusCode();
        var newTile = await response.Content.ReadFromJsonAsync<TileReadDto>();
        return newTile;
    }

    public async Task<TileReadDto> AddNewTile(string name, byte[] imageBytes)
    {
        MultipartFormDataContent multiContent = new MultipartFormDataContent();
        {
            multiContent.Add(new ByteArrayContent(imageBytes), "files", name); // name must be "files"
        }
        var response = await _httpClient.PostAsync($"{_config.ApiUrl}/tiles/tiles/import/image", multiContent);

        response.EnsureSuccessStatusCode();
        var newTile = await response.Content.ReadFromJsonAsync<TileReadDto>();
        return newTile;
    }

    public async Task<(string Id, string Status)[]> ImportFlickr(FlickrOptions options)
    {
        var response = await _httpClient.PostAsJsonAsync<FlickrOptions>($"{_config.ApiUrl}/tiles/tiles/import/flickr", options);

        response.EnsureSuccessStatusCode();
        var newTile = await response.Content.ReadFromJsonAsync<(string Id, string Status)[]>();
        return newTile;
    }

    public async Task<MosaicReadDto[]> GetMosaics(int page = 1, int pageSize = 10)
    {
        return await _httpClient.GetFromJsonAsync<MosaicReadDto[]>($"{_config.ApiUrl}/mosaics/mosaics?page={page}&pageSize={pageSize}");
    }

    public async Task<MosaicReadDto> GetMosaic(string id)
    {
        return await _httpClient.GetFromJsonAsync<MosaicReadDto>($"{_config.ApiUrl}/mosaics/mosaics/{id}");
    }

    public async Task SetMosaicImage(string id, byte[] bytes)
    {
        var response = await _httpClient.PostAsJsonAsync<byte[]>($"{_config.ApiUrl}/mosaics/mosaics/{id}", bytes);
        response.EnsureSuccessStatusCode();

    }

    public async Task<MosaicReadDto> AddNewMosaicAsync(MosaicOptions options)
    {
        var response = await _httpClient.PostAsJsonAsync<MosaicCreateDto>($"{_config.ApiUrl}/mosaics/mosaics",
            new MosaicCreateDto(options.Name, options.SourceTileId, options.HorizontalTileCount, options.VerticalTileCount,
                                 (int)options.MatchStyle, options.Width, options.Height));

        response.EnsureSuccessStatusCode();
        var newMosaic = await response.Content.ReadFromJsonAsync<MosaicReadDto>();
        return newMosaic;
    }
}
