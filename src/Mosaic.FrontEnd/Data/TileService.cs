using Dapr.Client;
using Mosaic.TilesApi.Models;

namespace Mosaic.FrontEnd.Data
{
    public class TileService
    {
        private readonly DaprClient _dapr;

        public TileService(DaprClient dapr)
        {
            _dapr = dapr;
        }

        public async Task<TileReadDto[]> GetAllTiles()
        {
            var tiles = await _dapr.InvokeMethodAsync<TileReadDto[]>(HttpMethod.Get, "tilesapi", "Tiles");
            return tiles;
        }

        public async Task<TileReadDto> AddNewTile(TileCreateDto tile)
        {
            var newTile = await _dapr.InvokeMethodAsync<TileCreateDto, TileReadDto>("tilesapi", "Tiles", tile);
            return newTile;
        }
    }
}