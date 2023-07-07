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
        return $"{_httpClient.BaseAddress}mosaics/mosaics/{mosaic.Name}/image";
    }

    public async Task<TileReadDto[]> GetTiles(int page = 0, int pageSize = 20, string? source = null)
    {
        string query = $"page={page}&pageSize={pageSize}";

        if (source is not null)
        {
            query += "&source=" + source;
        }

        var tiles = await _httpClient.GetFromJsonAsync<TileReadDto[]>($"/tiles/tiles?{query}");
        return tiles ?? new TileReadDto[0];
    }

    public async Task<TileReadDto?> GetTile(int id)
    {
        TileReadDto? tile = await _httpClient.GetFromJsonAsync<TileReadDto>($"/tiles/tiles/{id}");
        return tile;
    }

    public record ImageLink(int id, string url);

    public async Task<ImageLink[]> GetTileImageUrls(int[] tileIds)
    {
        var response = await _httpClient.PostAsJsonAsync("/tiles/tiles/imageLinks", tileIds);
        response.EnsureSuccessStatusCode();
        var links = await response.Content.ReadFromJsonAsync<ImageLink[]>() ?? Array.Empty<ImageLink>();
        return links;
    }

    public async Task<TileReadDto> AddNewTile(TileCreateDto tile)
    {
        var response = await _httpClient.PostAsJsonAsync<TileCreateDto>($"/tiles/tiles", tile);

        response.EnsureSuccessStatusCode();
        var newTile = await response.Content.ReadFromJsonAsync<TileReadDto>()
                      ?? throw new Exception($"Failed to deserialize {tile.Source} tile {tile.SourceId} response");
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
        var newTile = await response.Content.ReadFromJsonAsync<TileReadDto>()
                      ?? throw new Exception($"Failed to deserialize tile {name} response");
        return newTile;
    }

    public record ImportStatus
    {
        public DateTime FlickrLastImportDate { get; init; }
        public int FlickrLastImportCount { get; init; }
        public int FlickrTotalImportCount { get; init; }
    }

    public async Task StartFlickrImport(ImportOptions options)
    {
        _logger.LogInformation("importing from flickr");
        var response = await _httpClient.PostAsJsonAsync<ImportOptions>($"/tiles/tiles/import/start", options);

        response.EnsureSuccessStatusCode();
    }

    public async Task<ImportStatus> GetImportStatus()
    {
        _logger.LogInformation("importing from flickr");
        var response = await _httpClient.GetAsync($"/tiles/tiles/import/status");

        response.EnsureSuccessStatusCode();
        var tileStatuses = await response.Content.ReadFromJsonAsync<ImportStatus>(new System.Text.Json.JsonSerializerOptions { PropertyNameCaseInsensitive = true });

        return tileStatuses ?? new();
    }

    public async Task StopFlickrImport()
    {
        _logger.LogInformation("stopping importing from flickr");
        var response = await _httpClient.PostAsync($"/tiles/tiles/import/stop", null);

        response.EnsureSuccessStatusCode();
        _logger.LogInformation("stopped importing from flicker");
    }

    public async Task<MosaicReadDto[]?> GetMosaics(int page = 1, int pageSize = 10)
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
        return await _httpClient.GetFromJsonAsync<MosaicReadDto>($"/mosaics/mosaics/{id}")
               ?? throw new Exception($"Failed to deserialize mosaic {id} response");
    }

    public async Task<Stream> GetMosaicImage(string id)
    {
        return await _httpClient.GetStreamAsync($"/mosaics/mosaics/{id}/image");
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
