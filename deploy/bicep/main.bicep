param location string = resourceGroup().location
param uniqueSeed string = '${subscription().subscriptionId}-${resourceGroup().name}'
param uniqueSuffix string = 'mosaic-${uniqueString(uniqueSeed)}'
param containerAppsEnvName string = 'mosaic-cae-${uniqueSuffix}'
param logAnalyticsWorkspaceName string = 'mosaic-log-${uniqueSuffix}'
param appInsightsName string = 'mosaic-appi-${uniqueSuffix}'
param serviceBusNamespaceName string = 'mosaic-sb-${uniqueSuffix}'
param storageAccountName string = 'mosaicstg${replace(uniqueSuffix, '-', '')}'
param sqlServerName string = 'mosaic-sql-${uniqueSuffix}'
param sqlDatabaseName string = 'mosaic'
param sqlAdminLogin string = 'mosaic'
param sqlAdminLoginPassword string = take(newGuid(), 16)

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

module sqlServerModule 'modules/sqlserver.bicep' = {
  name: '${deployment().name}--sqlserver'
  params: {
    sqlServerName: sqlServerName
    sqlDatabaseName: sqlDatabaseName
    sqlAdminLogin: sqlAdminLogin
    sqlAdminLoginPassword: sqlAdminLoginPassword
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
    sqlConnectionString: 'Server=tcp:${sqlServerName}${environment().suffixes.sqlServerHostname},1433;Initial Catalog=${sqlDatabaseName};Persist Security Info=False;User ID=${sqlAdminLogin};Password=${sqlAdminLoginPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
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
  }
}

output urls array = [
  'UI: https://${frontEndModule.name}.${containerAppsEnvModule.outputs.defaultDomain}'
]
