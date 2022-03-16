using Dapr.Actors;

namespace Mosaic.MosaicApi;

internal interface IMosaicActor : IActor
{
    Task<byte[]> GetImage();
    Task SetTile(int row, int column, TileId data);
    Task<TileId> GetTile(int row, int column);
    Task<TileId?[,]> GetTiles();
    Task<string> SetSize(int rows, int columns);
    Task<bool> IsComplete();
    //Task RegisterReminder();
    //Task UnregisterReminder();
    //Task RegisterTimer();
    //Task UnregisterTimer();
}