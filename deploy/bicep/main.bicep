param location string = resourceGroup().location
param uniqueSeed string = '${subscription().subscriptionId}-${resourceGroup().name}'
param uniqueSuffix string = 'mosaic-${uniqueString(uniqueSeed)}'
param containerAppsEnvName string = 'mosaic-cae-${uniqueSuffix}'
param logAnalyticsWorkspaceName string = 'mosaic-log-${uniqueSuffix}'
param appInsightsName string = 'mosaic-appi-${uniqueSuffix}'
param serviceBusNamespaceName string = 'mosaic-sb-${uniqueSuffix}'
param storageAccountName string = 'mosaicstg${replace(uniqueSuffix, '-', '')}'
param sqlServerName string = 'mosaic-tilesdb-${uniqueSuffix}'
param sqlTilesDatabaseName string = 'tiles'
param sqlMosaicDatabaseName string = 'mosaics'
param sqlAdminLogin string = 'mosaic'
@secure()
param sqlAdminLoginPassword string
param cosmosDbName string = 'mosaic-cosmosdb-${uniqueSuffix}'
param flickrApiKey string = ''

module containerAppsEnvModule 'modules/capps-env.bicep' = {
  name: '${deployment().name}--containerAppsEnv'
  params: {
    location: location
    containerAppsEnvName: containerAppsEnvName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    appInsightsName: appInsightsName
  }
}

module serviceBusModule 'modules/servicebus.bicep' = {
  name: '${deployment().name}--servicebus'
  params: {
    serviceBusNamespaceName: serviceBusNamespaceName
    location: location
  }
}

module storageModule 'modules/storage.bicep' = {
  name: '${deployment().name}--storage'
  params: {
    storageAccountName: storageAccountName
    location: location
  }
}

module sqlServerModule 'modules/sqlServer.bicep' = {
  name: '${deployment().name}--sqlServer'
  params: {
    serverName: sqlServerName
    tilesDatabaseName: sqlTilesDatabaseName
    mosaicDatabaseName: sqlMosaicDatabaseName
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminLoginPassword
    location: location
  }
}

module cosmosDatabase 'modules/cosmosdb.bicep' = {
  name: '${deployment().name}--cosmosdb'
  params: {
    databaseName: cosmosDbName
    location: location
  }
}

//////////////////
// Dapr Components
////////////////// 

module daprBindingTileStorage 'modules/dapr-components/binding-tilestorage.bicep' = {
  name: '${deployment().name}--dapr-binding-tilestorage'
  dependsOn: [
    containerAppsEnvModule
    storageModule
  ]
  params: {
    containerAppsEnvName: containerAppsEnvName
    storageAccountName: storageAccountName
  }
}

module daprBindingMosaicStorage 'modules/dapr-components/binding-mosaicstorage.bicep' = {
  name: '${deployment().name}--dapr-binding-mosaicstorage'
  dependsOn: [
    containerAppsEnvModule
    storageModule
  ]
  params: {
    containerAppsEnvName: containerAppsEnvName
    storageAccountName: storageAccountName
  }
}

module daprPubsub 'modules/dapr-components/pubsub.bicep' = {
  name: '${deployment().name}--dapr-pubsub'
  dependsOn: [
    containerAppsEnvModule
    serviceBusModule
  ]
  params: {
    containerAppsEnvName: containerAppsEnvName
    serviceBusNamespaceName: serviceBusNamespaceName
  }
}

module daprStateStore 'modules/dapr-components/statestore-mosaic.bicep' = {
  name: '${deployment().name}--dapr-statestore'
  dependsOn: [
    containerAppsEnvModule
    serviceBusModule
  ]
  params: {
    cosmosDbName: cosmosDbName
    containerAppsEnvName: containerAppsEnvName
  }
}

// module bootstrapperModule 'modules/container-apps/bootstrapper.bicep' = {
//   name: '${deployment().name}--bootstrapper'
//   dependsOn: [
//     containerAppsEnvModule
//     sqlServerModule
//     orderServiceModule
//   ]
//   params: {
//     location: location
//     containerAppsEnvName: containerAppsEnvName
//     sqlDatabaseName: sqlDatabaseName
//     sqlServerName: sqlServerName
//     sqlAdminLogin: sqlAdminLogin
//     sqlAdminLoginPassword: sqlAdminLoginPassword
//   }
// }

/////////////////
// Container Apps
/////////////////

module frontEndModule 'modules/container-apps/frontend.bicep' = {
  name: '${deployment().name}--frontend'
  dependsOn: [
    containerAppsEnvModule
    daprBindingTileStorage
    tilesApiModule
  ]
  params: {
    location: location
    containerAppsEnvName: containerAppsEnvName
    nameSuffix: uniqueSuffix
    appInsightsName: appInsightsName
    flickrApiKey: flickrApiKey
  }
}

module tilesApiModule 'modules/container-apps/tilesapi.bicep' = {
  name: '${deployment().name}--tilesapi'
  dependsOn: [
    containerAppsEnvModule
    daprPubsub
    sqlServerModule
  ]
  params: {
    location: location
    containerAppsEnvName: containerAppsEnvName
    sqlConnectionString: 'Server=${sqlServerModule.outputs.fqdn};Database=${sqlTilesDatabaseName};Port=5432;User Id=${sqlAdminLogin};Password=${sqlAdminLoginPassword};Ssl Mode=Prefer;'
appInsightsName: appInsightsName
    nameSuffix: uniqueSuffix
  }
}

module tileProcessor 'modules/container-apps/tileprocessor.bicep' = {
  name: '${deployment().name}--tileprocessor'
  dependsOn: [
    containerAppsEnvModule
    daprPubsub
    storageModule
  ]
  params: {
    location: location
    containerAppsEnvName: containerAppsEnvName
    nameSuffix: uniqueSuffix
    appInsightsName: appInsightsName
    flickrApiKey: flickrApiKey
  }
}

module mosaicApiModule 'modules/container-apps/mosaicapi.bicep' = {
  name: '${deployment().name}--mosaicapi'
  dependsOn: [
    containerAppsEnvModule
    daprPubsub
    sqlServerModule
    daprBindingMosaicStorage
  ]
  params: {
    location: location
    containerAppsEnvName: containerAppsEnvName
    sqlConnectionString: 'Server=${sqlServerModule.outputs.fqdn};Database=${sqlTilesDatabaseName};Port=5432;User Id=${sqlAdminLogin};Password=${sqlAdminLoginPassword};Ssl Mode=Prefer;'
    appInsightsName: appInsightsName
    nameSuffix: uniqueSuffix
  }
}

module mosaicGenerator 'modules/container-apps/mosaicgenerator.bicep' = {
  name: '${deployment().name}--mosaicgenerator'
  dependsOn: [
    containerAppsEnvModule
    daprPubsub
    storageModule
  ]
  params: {
    location: location
    containerAppsEnvName: containerAppsEnvName
    nameSuffix: uniqueSuffix
    appInsightsName: appInsightsName
  }
}

output urls array = [
  'UI: https://${frontEndModule.name}.${containerAppsEnvModule.outputs.defaultDomain}'
]
