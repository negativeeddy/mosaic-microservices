using Microsoft.AspNetCore.Components;
using Mosaic.FrontEnd.Data;
using Mosaic.MosaicApi;

namespace Mosaic.FrontEnd.Pages.Mosaics;

public partial class MosaicList
{
    [Inject]
    NavigationManager NavigationManager { get; set; } = null!;

    [Inject]
    MosaicService MosaicService { get; set; } = null!;

    [Inject]
    ILogger<Index> Logger { get; set; } = null!;

    [Parameter]
    public int page { get; set; } = 0;

    [Parameter]
    public int pageSize { get; set; } = 15;

    private MosaicReadDto[]? mosaics;

    private string? errorMessage = null;

    protected override async Task OnInitializedAsync()
    {
        await RefreshMosaicList();
    }

    private void SetError(Exception ex)
    {
        var e = ex;
        while (e != null)
        {
            errorMessage += e.ToString() + "<br />";
            e = e.InnerException;
        }
    }

    private async Task RefreshMosaicList()
    {
        try
        {
            mosaics = null;
            mosaics = await MosaicService.GetMosaics(page, pageSize);
        }
        catch (Exception ex)
        {
            SetError(ex);
        }
    }

    private async Task OnClickNext()
    {
        page++;
        await RefreshMosaicList();
    }

    private async Task OnClickPrev()
    {
        page--;
        await RefreshMosaicList();
    }

    private async Task OnClickNewMosaic()
    {
        NavigationManager.NavigateTo("mosaics/create");
    }
}
