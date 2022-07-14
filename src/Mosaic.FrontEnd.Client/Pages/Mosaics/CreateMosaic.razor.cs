using Microsoft.AspNetCore.Components;
using Mosaic.FrontEnd.Data;

namespace Mosaic.FrontEnd.Client.Pages.Mosaics;

public partial class CreateMosaic
{
    [Inject]
    NavigationManager NavigationManager { get; set; } = null!;

    [Inject]
    MosaicService MosaicService { get; set; } = null!;

    [Inject]
    ILogger<Index> Logger { get; set; } = null!;

    private MosaicOptions options = new MosaicOptions
    {
        HorizontalTileCount = 20,
        VerticalTileCount = 20,
        Width = 640,
        Height = 480
    };

    private string? ErrorMessage;

    private TileMatchAlgorithm[] Algorithms => Enum.GetValues<TileMatchAlgorithm>();

    private async Task HandleValidSubmit()
    {
        try
        {
            await MosaicService.AddNewMosaicAsync(options);
            NavigationManager.NavigateTo("mosaics");
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, "Failed to add new mosaic");
            ErrorMessage = ex.Message;
        }
    }
}