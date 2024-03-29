param containerAppsEnvName string
param cosmosDbName string

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2022-02-15-preview' existing = {
  name: cosmosDbName
}

resource cappsEnv 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: containerAppsEnvName
}

resource daprComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-01-01-preview' = {
  name: 'mosaicstate'
  parent: cappsEnv
  properties: {
    componentType: 'state.azure.cosmosdb'
    version: 'v1'
    metadata: [
      {
        name: 'masterKey'
        secretRef: 'cosmosdbkey'
      }
      {
        name:'url'
        value: cosmosDb.properties.documentEndpoint
      }
      {
         name: 'database'
         value: 'mosaic'
      }
      {
        name: 'collection'
        value: 'state'
     }     
     {
      name: 'actorStateStore'
      value: 'true'
     }
    ]
    secrets: [
      {
        name: 'cosmosdbkey'
        value: cosmosDb.listKeys()['primaryMasterKey']
      }
    ]
    scopes: [
      'tilesapi'
      'tileprocessor'
      'mosaicgenerator'
      'mosaicapi'
      'tilesactors'
    ]
  }
}
