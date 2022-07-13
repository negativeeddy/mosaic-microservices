using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Authorization;
using System.Security.Claims;

namespace Mosaic.FrontEnd.Client.Pages.User;

[Authorize]
public partial class Index
{
    [Inject]
    AuthenticationStateProvider AuthenticationStateProvider { get; set; }

    private string authMessage;
    private string surnameMessage;
    private IEnumerable<Claim> claims = Enumerable.Empty<Claim>();

    protected override async Task OnInitializedAsync()
    {
        await GetClaimsPrincipalData();
    }

    private async Task GetClaimsPrincipalData()
    {
        var authState = await AuthenticationStateProvider.GetAuthenticationStateAsync();
        var user = authState.User;

        if (user.Identity.IsAuthenticated)
        {
            authMessage = $"{user.Identity.Name} is authenticated.";
            claims = user.Claims;
            surnameMessage =
                $"Surname: {user.FindFirst(c => c.Type == ClaimTypes.Surname)?.Value}";
        }
        else
        {
            authMessage = "The user is NOT authenticated.";
        }
    }
}
