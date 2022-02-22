#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["Mosaic.FrontEnd/Mosaic.FrontEnd.csproj", "Mosaic.FrontEnd/"]
COPY ["Mosaic.TilesApi.Events/Mosaic.TilesApi.Shared.csproj", "Mosaic.TilesApi.Events/"]
RUN dotnet restore "Mosaic.FrontEnd/Mosaic.FrontEnd.csproj"
COPY . .
WORKDIR "/src/Mosaic.FrontEnd"
RUN dotnet build "Mosaic.FrontEnd.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Mosaic.FrontEnd.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Mosaic.FrontEnd.dll"]