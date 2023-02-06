#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
RUN apt-get update -y
RUN apt-get install curl -y
RUN curl -L -o /usr/bin/dotnet-gcdump https://aka.ms/dotnet-gcdump/linux-x64
RUN chmod +x /usr/bin/dotnet-gcdump 
RUN curl -L -o /usr/bin/dotnet-counters https://aka.ms/dotnet-counters/linux-x64
RUN chmod +x /usr/bin/dotnet-counters 
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["Mosaic.Tiles.Actors/Mosaic.Tiles.Actors.csproj", "Mosaic.Tiles.Actors/"]
COPY ["Mosaic.Tiles.Actors.Interfaces/Mosaic.Tiles.Actors.Interfaces.csproj", "Mosaic.Tiles.Actors.Interfaces/"]
RUN dotnet restore "Mosaic.Tiles.Actors/Mosaic.Tiles.Actors.csproj"
COPY . .
WORKDIR "/src/Mosaic.Tiles.Actors"
RUN dotnet build "Mosaic.Tiles.Actors.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Mosaic.Tiles.Actors.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Mosaic.Tiles.Actors.dll"]