using Microsoft.AspNetCore.Components;
using Mosaic.FrontEnd.Data;

namespace Mosaic.FrontEnd.Client.Pages.Mosaics;

public partial class MosaicDetails
{
    [Inject]
    MosaicService MosaicService { get; set; } = null!;

    [Parameter]
    public string Id { get; set; } = null!;

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