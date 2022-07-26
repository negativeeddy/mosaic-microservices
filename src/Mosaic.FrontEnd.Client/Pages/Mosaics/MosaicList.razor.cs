using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.WebAssembly.Authentication;
using Mosaic.FrontEnd.Data;

namespace Mosaic.FrontEnd.Client.Pages.Mosaics;

public partial class MosaicList
{
    [Inject]
    NavigationManager nav { get; set; } = null!;

    [Inject]
    MosaicService MosaicService { get; set; } = null!;

    [SupplyParameterFromQuery]
    [Parameter]
    public int Page { get; set; }

    [SupplyParameterFromQuery]
    [Parameter]
    public int PageSize { get; set; }

    private MosaicReadDto[]? mosaics;

    private string? errorMessage = null;

    public override async Task SetParametersAsync(ParameterView parameterValues)
    {
        await base.SetParametersAsync(parameterValues);

        if (PageSize <= 5) PageSize = 15;
        if (Page <= 0) Page = 1;

        try
        {
            await RefreshMosaicList();
            StateHasChanged();
        }
        catch (Exception ex)
        {
            SetError(ex);
        }
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
            mosaics = await MosaicService.GetMosaics(Page, PageSize);
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

    private void OnClickNext()
    {
        nav.NavigateTo($"mosaics?Page={Page + 1}&PageSize={PageSize}");
    }

    private void OnClickPrev()
    {
        nav.NavigateTo($"mosaics?Page={Page - 1}&PageSize={PageSize}");
    }

}
