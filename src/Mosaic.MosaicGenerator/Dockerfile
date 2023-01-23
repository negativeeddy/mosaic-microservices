#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["Mosaic.MosaicGenerator/Mosaic.MosaicGenerator.csproj", "Mosaic.MosaicGenerator/"]
COPY ["Mosaic.MosaicApi.Shared/Mosaic.MosaicApi.Shared.csproj", "Mosaic.MosaicApi.Shared/"]
COPY ["Mosaic.TileSources/Mosaic.TileSources.csproj", "Mosaic.TileSources/"]
COPY ["Mosaic.ImageAnalysis/Mosaic.ImageAnalysis.csproj", "Mosaic.ImageAnalysis/"]
RUN dotnet restore "Mosaic.MosaicGenerator/Mosaic.MosaicGenerator.csproj"
COPY . .
WORKDIR "/src/Mosaic.MosaicGenerator"
RUN dotnet build "Mosaic.MosaicGenerator.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Mosaic.MosaicGenerator.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Mosaic.MosaicGenerator.dll"]