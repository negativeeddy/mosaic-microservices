using System.Net.Http.Json;

namespace Mosaic.TileSources.Flickr
{
    public class FlickrClient
    {
        public FlickrClient(HttpClient client, string apiKey)
        {
            _client = client;
            _apiKey = apiKey;
        }

        static string[] acceptableLicenses = new string[] {
            //"0", // All Rights Reserved
            "1", // Attribution-NonCommercial-ShareAlike License
            "2", // Attribution-NonCommercial License
            //"3", // Attribution-NonCommercial-NoDerivs License
            "4", // Attribution License
            "5", // Attribution-ShareAlike License
            //"6", // Attribution-NoDerivs License
            "7", // No known copyright restrictions
            "8", // United States Government Work
            "9", // Public Domain Dedication (CC0)
            "10"  // Public Domain Mark
        };

        private readonly HttpClient _client;
        private readonly string _apiKey;

        public async Task<FlickrTileData[]> GetTodaysInteresting()
        {
            int pageCount = 500;
            int pageNumber = 1;
            string interestingUrl = $"https://www.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key={_apiKey}&format=json&nojsoncallback=1&per_page={pageCount}&page={pageNumber}&extras=license";
            var response = await _client.GetFromJsonAsync<InterestingnessResponse>(interestingUrl);
            var usable = response.photos.photo.Where(p => acceptableLicenses.Contains(p.license));
            return usable.Select(p => new FlickrTileData(p.id, p.secret, p.server)).ToArray();
        }
    }
}