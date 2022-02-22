#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["Mosaic.TileProcessor/Mosaic.TileProcessor.csproj", "Mosaic.TileProcessor/"]
COPY ["Mosaic.TilesApi.Events/Mosaic.TilesApi.Shared.csproj", "Mosaic.TilesApi.Events/"]
RUN dotnet restore "Mosaic.TileProcessor/Mosaic.TileProcessor.csproj"
COPY . .
WORKDIR "/src/Mosaic.TileProcessor"
RUN dotnet build "Mosaic.TileProcessor.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Mosaic.TileProcessor.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Mosaic.TileProcessor.dll"]