param databaseName string
param location string

resource database 'Microsoft.DocumentDB/databaseAccounts@2022-02-15-preview' = {
  name: databaseName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    publicNetworkAccess: 'Enabled'
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        isZoneRedundant: false
      }
    ]
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
  }
}

resource mosaicDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-02-15-preview' = {
  parent: database
  name: 'mosaic'
  properties: {
    resource: {
      id: 'mosaic'
    }
  }
}

resource stateContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2022-02-15-preview' = {
  parent: mosaicDatabase
  name: 'state'
  properties: {
    resource: {
      id: 'state'
      partitionKey: {
        paths: [
          '/partitionKey'
        ]
        kind: 'Hash'
      }
    }
  }
}
