using Microsoft.AspNetCore.Components;
using Mosaic.FrontEnd.Data;
using Mosaic.MosaicApi;

namespace Mosaic.FrontEnd.Pages.Mosaics;

public partial class MosaicDetails
{
    [Inject]
    NavigationManager NavigationManager { get; set; } = null!;

    [Inject]
    MosaicService MosaicService { get; set; } = null!;

    [Inject]
    ILogger<Index> Logger { get; set; } = null!;

    [Parameter]
    public int Id { get; set; }

    private MosaicReadDto? mosaic;
    private string? errorMessage = null;

    protected override async Task OnInitializedAsync()
    {
        try
        {
            await RefreshMosaic();
        }
        catch (Exception ex)
        {
            SetError(ex);
        }
    }

    void SetError(Exception ex)
    {
        var e = ex;
        while (e != null)
        {
            errorMessage += e.ToString() + "<br />";
            e = e.InnerException;
        }
    }

    private async Task RefreshMosaic()
    {
        mosaic = await MosaicService.GetMosaic(Id);
    }
}