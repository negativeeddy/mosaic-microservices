using Microsoft.AspNetCore.Components;
using Microsoft.JSInterop;
using Mosaic.FrontEnd.Data;

namespace Mosaic.FrontEnd.Client.Pages.Mosaics;

public partial class MosaicDetails
{
#pragma warning disable CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Consider declaring as nullable.
    // injected properties cant be null
    [Inject]
    IJSRuntime JS { get; set; }

    [Inject]
    private MosaicService MosaicService { get; set; }
#pragma warning restore CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Consider declaring as nullable.

    [Parameter]
    public string Id { get; set; } = null!;

    private MosaicReadDto? mosaic;
    private string? errorMessage = null;
    private string? mosaicImageUrl => mosaic is not null ? MosaicService.GenerateImageUrl(mosaic) : null;


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
        if (mosaic is not null)
            await SetImageAsync(mosaic.Name);
    }

    private async Task SetImageAsync(string mosaicName)
    {
        using var imageStream = await MosaicService.GetMosaicImage(mosaicName);
        using var dotnetImageStream = new DotNetStreamReference(imageStream);
        await JS.InvokeVoidAsync("mosaic.setImage", "mosaicImage", dotnetImageStream);
    }
}