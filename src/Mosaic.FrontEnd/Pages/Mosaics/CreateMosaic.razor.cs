using Microsoft.AspNetCore.Components;
using Mosaic.FrontEnd.Data;

namespace Mosaic.FrontEnd.Pages.Mosaics;

public partial class CreateMosaic
{
    [Inject]
    NavigationManager NavigationManager { get; set; } = null!;

    [Inject]
    MosaicService MosaicService { get; set; } = null!;

    [Inject]
    ILogger<Index> Logger { get; set; } = null!;

    private MosaicOptions options = new MosaicOptions { HorizontalTileCount = 20, VerticalTileCount =20};
    private string? ErrorMessage;

    private async Task HandleValidSubmit()
    {
        try
        {
            await MosaicService.AddNewMosaicAsync(options.Name, options.SourceTileId, options.HorizontalTileCount, options.VerticalTileCount);
            NavigationManager.NavigateTo("mosaics");
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, "Failed to add new mosaic");
            ErrorMessage = ex.ToString();
        }
    }
}