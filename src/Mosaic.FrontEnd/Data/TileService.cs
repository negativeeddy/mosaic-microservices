using Dapr.Client;

namespace Mosaic.FrontEnd.Data
{
    public class TileService
    {
        private readonly DaprClient _dapr;

        public TileService(DaprClient dapr)
        {
            _dapr = dapr;
        }
        public async Task<Tile[]> GetAllTiles()
        {
            var tiles = await _dapr.InvokeMethodAsync<Tile[]>(HttpMethod.Get, "tilesapi", "Tiles");
            return tiles;
        }
    }
}