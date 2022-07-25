#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
RUN apt-get update -y
RUN apt-get install curl -y
RUN curl -L -o /usr/bin/dotnet-gcdump https://aka.ms/dotnet-gcdump/linux-x64
RUN chmod +x /usr/bin/dotnet-gcdump 
RUN curl -L -o /usr/bin/dotnet-counters https://aka.ms/dotnet-counters/linux-x64
RUN chmod +x /usr/bin/dotnet-counters 
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["Mosaic.TilesApi/Mosaic.TilesApi.csproj", "Mosaic.TilesApi/"]
COPY ["Mosaic.TilesApi.Events/Mosaic.TilesApi.Shared.csproj", "Mosaic.TilesApi.Events/"]
RUN dotnet restore "Mosaic.TilesApi/Mosaic.TilesApi.csproj"
COPY . .
WORKDIR "/src/Mosaic.TilesApi"
RUN dotnet build "Mosaic.TilesApi.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Mosaic.TilesApi.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Mosaic.TilesApi.dll"]