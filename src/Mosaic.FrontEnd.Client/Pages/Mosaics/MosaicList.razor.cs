using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.WebAssembly.Authentication;
using Mosaic.FrontEnd.Data;

namespace Mosaic.FrontEnd.Client.Pages.Mosaics;

public partial class MosaicList
{
    [Inject]
    MosaicService MosaicService { get; set; } = null!;

    [Parameter]
    public int page { get; set; } = 1;

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
        catch (AccessTokenNotAvailableException exception)
        {
            exception.Redirect();
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
}
