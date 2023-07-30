how to run locally with Docker Compose

Requirements:
 * Tools
   * [Docker Desktop](https://docs.docker.com/desktop/install/windows-install/)
   * [Entity Framework Core tools](https://learn.microsoft.com/en-us/ef/core/get-started/overview/install#get-the-entity-framework-core-tools)
* Application IDs
  * this solution requires 2 Azure B2C application registrations. One for the user to log in to the Blazor client. One for the authentication to the APIs.

Steps
1. create an Azure Storage account 
1. in tileStorage.yaml & mosaicstorage.yaml, set the value of "storageAccount" to the name of your storage account
1. Create a file src/components/secrets.json with the following content
```javascript
{
    "mosaicStorageKey": "YOUR_STORAGE_KEY",
    "tileStorageKey": "YOUR_STORAGE_KEY"
}
```
2. Update the solution with authentication info 
 - in projects front end,  tilesapi, and mosaicapi, update the appsettings.json (or use user secrets) to contain
 ```javascript
   "AzureAdB2C": {
    "Instance": "YOUR_B2C_INSTANCE",
    "ClientId": "YOUR_API_CLIENT_ID",
    "Domain": "YOUR_B2C_DOMAIN",
    "Scopes": "REQURIRED_SCOPE",
    "SignUpSignInPolicyId": "YOUR_B2C_SIGN_IN_POLICY"
  }
  ```
  - The required scopes are as follows
    - for front end: ```Tiles.ReadWrite Mosaics.ReadWrite```
    - for tiles api: ```Tiles.ReadWrite```
    - for mosaic api: ```Mosaics.ReadWrite```
  - in front end settings/secrets also add the client login info

  ```javascript
  "clientConfig": {
    "AzureAdB2C": {
      "Authority": "YOUR_AUTHORITY",
      "ClientId": "YOUR_BLAZOR_CLIENT_ID",
      "ValidateAuthority": false
    },
    "ApiUri": "http://localhost:10000",
    "DefaultAccessTokenScopes": "https://YOUR_B2C_DOMAIN/YOUR_API_CLIENT_ID/Mosaics.ReadWrite https://YOUR_B2C_DOMAIN/YOUR_API_CLIENT_ID/Tiles.ReadWrite"
  }
  ```

2. Ensure the startup project in Visual Studio is set to *docker-compose*
2. Run the solution. This will create and launch all the docker containers
3. Open a terminal to the Mosaic.TilesApi directory
3. Create the EF update package

```bash
dotnet ef migrations bundle --output ./bin/tilesapi-efbundle-win.exe --self-contained --target-runtime win-x64 --configuration Bundle
```

4. run the tool to update the database schema. Note that here we use the server name localhost because we are accessing the db via the port that docker exposes on localhost. 

```bash
.\bin\tilesapi-efbundle-win.exe --connection "Server=localhost;Database=tiles;Port=5432;User Id=postgres;Password=localmosaicpwd;Ssl Mode=Prefer;"
```

5. Update TilesApi project user secrets to include the connection string. Note that for local development the server name should be "mosaic.tilesapi.db" because that is the network name the tiles API will use to access it within the docker network
```javascript
"ConnectionStrings": {
  "tiledbconnectionstring": "Server=mosaic.tilesapi.db;Database=tiles;Port=5432;User Id=postgres;Password=localmosaicpwd;Ssl Mode=Prefer;"
}
```
6. Open the browser to https://localhost:5100/ and log in