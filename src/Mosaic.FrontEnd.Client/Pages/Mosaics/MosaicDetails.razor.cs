using Microsoft.AspNetCore.Components;
using Microsoft.JSInterop;
using Mosaic.FrontEnd.Data;

namespace Mosaic.FrontEnd.Client.Pages.Mosaics;

public partial class MosaicDetails
{
    [Inject]
    IJSRuntime JS { get; set; } = null!;

    [Inject]
    MosaicService MosaicService { get; set; } = null!;

    [Parameter]
    public string Id { get; set; } = null!;

    private MosaicReadDto? mosaic;
    private string? errorMessage = null;
    private string mosaicImageUrl => MosaicService.GenerateImageUrl(mosaic);


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
    private async Task ShowImage()
    {
        await SetImageAsync(mosaic.Name);
    }

    private async Task SetImageAsync(string mosaicName)
    {
        using var imageStream = await MosaicService.GetMosaicImage(mosaicName);
        using var dotnetImageStream = new DotNetStreamReference(imageStream);
        await JS.InvokeVoidAsync("mosaic.setImage", "mosaicImage", dotnetImageStream);
    }
}