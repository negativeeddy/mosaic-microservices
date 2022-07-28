#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["Mosaic.FrontEnd.Server/Mosaic.FrontEnd.Server.csproj", "Mosaic.FrontEnd.Server/"]
COPY ["Mosaic.FrontEnd.Shared/Mosaic.FrontEnd.Shared.csproj", "Mosaic.FrontEnd.Shared/"]
COPY ["Mosaic.FrontEnd.Client/Mosaic.FrontEnd.Client.csproj", "Mosaic.FrontEnd.Client/"]
COPY ["Mosaic.TilesApi.Events/Mosaic.TilesApi.Shared.csproj", "Mosaic.TilesApi.Events/"]
RUN dotnet restore "Mosaic.FrontEnd.Server/Mosaic.FrontEnd.Server.csproj"
COPY . .
WORKDIR "/src/Mosaic.FrontEnd.Server"
ARG COMMIT_ID=LOCAL_DEV
RUN dotnet build "Mosaic.FrontEnd.Server.csproj" -c Release -o /app/build /p:SourceRevisionId=$COMMIT_ID

FROM build AS publish
RUN dotnet publish "Mosaic.FrontEnd.Server.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Mosaic.FrontEnd.Server.dll"]