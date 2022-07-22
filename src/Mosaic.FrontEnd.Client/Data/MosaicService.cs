using System.Net;
using System.Net.Http.Json;

namespace Mosaic.FrontEnd.Data;

public class MosaicService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<MosaicService> _logger;

    public MosaicService(IHttpClientFactory httpClient, ILogger<MosaicService> logger)
    {
        _httpClient = httpClient.CreateClient(nameof(MosaicService));
        _logger = logger;
    }

    public string GenerateImageUrl(MosaicReadDto mosaic)
    {
        return $"{_httpClient.BaseAddress}/mosaics/mosaics/{mosaic.Name}/image";
    }

    public async Task<TileReadDto[]> GetTiles(int page = 0, int pageSize = 20)
    {
        var tiles = await _httpClient.GetFromJsonAsync<TileReadDto[]>($"/tiles/tiles?page={page}&pageSize={pageSize}");
        return tiles ?? new TileReadDto[0];
    }

    public async Task<TileReadDto> GetTile(int id)
    {
        TileReadDto? tile = await _httpClient.GetFromJsonAsync<TileReadDto>($"/tiles/tiles/{id}");
        return tile;
    }

    public async Task<TileReadDto> AddNewTile(TileCreateDto tile)
    {
        var response = await _httpClient.PostAsJsonAsync<TileCreateDto>($"/tiles/tiles", tile);

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
        var response = await _httpClient.PostAsync($"/tiles/tiles/import/image", multiContent);

        response.EnsureSuccessStatusCode();
        var newTile = await response.Content.ReadFromJsonAsync<TileReadDto>();
        return newTile;
    }

    public async Task<(string Id, string Status)[]> ImportFlickr(FlickrOptions options)
    {
        var response = await _httpClient.PostAsJsonAsync<FlickrOptions>($"/tiles/tiles/import/flickr", options);

        response.EnsureSuccessStatusCode();
        var newTile = await response.Content.ReadFromJsonAsync<(string Id, string Status)[]>();
        return newTile;
    }

    public async Task<MosaicReadDto[]> GetMosaics(int page = 1, int pageSize = 10)
    {
        try
        {
            return await _httpClient.GetFromJsonAsync<MosaicReadDto[]>($"/mosaics/mosaics?page={page}&pageSize={pageSize}");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to get mosaics page {page} pagesize {pagesize}", page, pageSize);
            return new MosaicReadDto[0];
        }
    }

    public async Task<MosaicReadDto> GetMosaic(string id)
    {
        return await _httpClient.GetFromJsonAsync<MosaicReadDto>($"/mosaics/mosaics/{id}");
    }

    public async Task SetMosaicImage(string id, byte[] bytes)
    {
        var response = await _httpClient.PostAsJsonAsync<byte[]>($"/mosaics/mosaics/{id}", bytes);
        response.EnsureSuccessStatusCode();

    }

    public async Task<MosaicReadDto> AddNewMosaicAsync(MosaicOptions options)
    {
        var response = await _httpClient.PostAsJsonAsync<MosaicCreateDto>($"/mosaics/mosaics",
            new MosaicCreateDto(options.Name, options.SourceTileId, options.HorizontalTileCount, options.VerticalTileCount,
                                 (int)options.MatchStyle, options.Width, options.Height));

        if (response.StatusCode == HttpStatusCode.BadRequest)
        {
            string message = await response.Content.ReadAsStringAsync();
            throw new MosaicException(message);
        }

        var newMosaic = await response.Content.ReadFromJsonAsync<MosaicReadDto>();
        return newMosaic ?? throw new InvalidOperationException();
    }
}
