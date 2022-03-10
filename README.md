# Mosaic
This project is a work-in-progress example of a microservice architecture app built with [Dapr](https://dapr.io). The app creates photo mosaics (or will). It runs locally in Docker Compose with local services (Zipkin, Redis) and runs in Azure Container Apps with cloud resources (App Insights, Azure Service Bus).

![cloud architecture](/docs/cloud_architecture.png)

## App Services

### Front End
Client UI written in Blazor. Allows you to upload images directly or import them from Flickr.

### Tiles API
REST API for inserting/updating tiles in the database

### Tile Processor
ASP.NET Hosted Service which listens for create tile events and calculates the necessary color data for creating mosiacs

# Deployment
## Local
 1. Create a SQL Db and create a table with the [tile db schema](/deploy/sql/tiles.sql)
 2. Create an Azure blob storage container
 3. Create a "secrets.json" file in the src/components folder (this file will be ignored by git)
 4. In the secrets.json file, create a key "tileStorageKey" with the value of the blob storage access key 
 5. In the usersecrets of the Tile API, add a "tiledbconnectionstring" with a value of the database connection string
 6. OPTIONAL: In the usersecrets of the FrontEnd add a key "flickr:apiKey" with a flickr API key
 7. Run the solution in Visual Studio using the docker-compose project as the startup project

## In Azure
1. Create a SQL Db and create a table with the [tile db schema](/deploy/sql/tiles.sql)
2. initialize the Azure CLI - only needs run once - [prereq.ps1](/deploy/powershell/prereq.ps1)
3. provision the app with [provision.ps1](/deploy/powershell/provision.ps1)
  * REQUIRED - provide the name of the stage (dev, prod, etc). This will be used in the names of all the resources.
  * REQUIRED - provide the SQL connection string (remove the port because the comma causes a deployment failure)
  * OPTIONAL - provide the flickr key, if omitted the app will deploy but the flickr import will not work

# Futures
* Include Mosaic API and Mosaic Generation services in deployment and Dapr intergration
