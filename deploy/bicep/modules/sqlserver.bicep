param administratorLogin string = 'postgres'
@secure()
param administratorLoginPassword string
param location string = resourceGroup().location
param serverName string
param tilesDatabaseName string = 'tiles'
param mosaicDatabaseName string = 'mosaic'

module sqlServerModule 'sqlServer-db.bicep' = {
  name: '${deployment().name}--sqlServer'
  params: {
    serverName: serverName
    tilesDatabaseName: tilesDatabaseName
    mosaicDatabaseName: mosaicDatabaseName
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    location: location
  }
}

module sqlServerExtensions 'sqlserver-extensions.bicep' = {
  dependsOn: [ sqlServerModule ]
  name: '${deployment().name}--sqlServerExtensions'
  params: {
    serverName: serverName
  }
}

output fqdn string = sqlServerModule.outputs.fqdn
output tilesDatabaseName string = sqlServerModule.outputs.tilesDatabaseName
