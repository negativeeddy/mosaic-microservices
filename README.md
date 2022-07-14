# Mosaic
This project is a work-in-progress example of a microservice architecture app built with [Dapr](https://dapr.io). The app creates photo mosaics. It runs locally in Docker Compose with local services (Zipkin, Redis, Postgres) and runs in Azure Container Apps with cloud resources (App Insights, Azure Service Bus, Cosmos DB, Azure PostgreSQL).

![cloud architecture](/docs/cloud_architecture.png)

## App Services

### Front End
Client UI written in Blazor Web Assembly. The WASM app is served from an ASP.NET Host which also helps with  authentication (AAD B2C)

### Tiles API
REST API for inserting/updating tiles in the database

### Tile Processor
ASP.NET Hosted Service which listens for create tile events and pre-calculates the necessary color data for creating mosiacs

### Mosaic API
REST API for creating mosaics from the tiles in the database

### Mosaic Processor
ASP.NET Hosted Service which listens for create mosaic events and generates the mosaics

## Azure Resources

- Azure Service Bus
- Azure Database for PostgreSQL
- Azure Storage
- Application Insights
- Azure Container Apps
- Cosmos DB
- AAD B2C

# Deployment
## Local
1. Create an Azure blob storage container
2. Create a "secrets.json" file in the src/components folder (this file will be ignored by git)
3. In the secrets.json file, create a key "tileStorageKey" with the value of the blob storage access key 
4. In the usersecrets of the Tile API, add a key "ConnectionStrings:tiledbconnectionstring" with a value below
     - NOTE: The admin username and password can changed from the defaults in docker-composer.override.yml

```
  "Server=mosaic.tilesapi.db;Database=tiles;Port=5432;User Id={POSTGRESADMIN};Password={POSTGRESADMINPWD};Ssl Mode=Prefer;"
```

5. Run the solution in Visual Studio using the docker-compose project as the startup project
6. Once started up, the front end will display, but the database still needs to be initialized. Run the following command from the Mosaic.TilesApi project directory. The connection string is the same as step 4 except the server is "localhost"
   ```
   dotnet ef database update --connection "{CONNECTION STRING}"
   ```

## In Azure
1. initialize the Azure CLI - only needs run once - [prereq.ps1](/deploy/powershell/prereq.ps1)
2. provision the app with [provision.ps1](/deploy/powershell/provision.ps1)
  * REQUIRED - provide the name of the stage (dev, prod, etc). This will be used in the names of all the resources
  * REQUIRED - provide the SQL admin password
3. Update the database schema. Run the following command from the Mosaic.TilesApi project directory. The connection string is the same form as above step 4 except the server will be the azure postgres instance domain name, the admin user name is "mosaic" and the password is whatever you specified when running the script
```
dotnet ef database update --connection "{CONNECTION STRING}"
```