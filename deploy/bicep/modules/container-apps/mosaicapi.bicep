param containerAppsEnvName string
param appInsightsName string
param location string
param sqlConnectionString string
param nameSuffix string

resource cappsEnv 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: containerAppsEnvName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  name: appInsightsName
}

resource frontend 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: 'mosaic-mosaicapi-ca-${nameSuffix}'
  location: location
  properties: {
    managedEnvironmentId: cappsEnv.id
    template: {
      containers: [
        {
          name: 'mosaicapi'
          image: 'mosaicprod.azurecr.io/mosaic/mosaicapi:latest'
          env: [
            {
              name: 'tiledbconnectionstring'
              secretRef: 'tiledbconnectionstring'
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              secretRef: 'appinsightsconnectionstring'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
      }
    }
    configuration: {
      dapr: {
        enabled: true
        appId: 'mosaicapi'
        appProtocol: 'http'
      }
      ingress: {
        external: false
        targetPort: 80
      }
      secrets: [
        {
          name: 'tiledbconnectionstring'
          value: sqlConnectionString
        }
        {
          name: 'appinsightsconnectionstring'
          value: appInsights.properties.ConnectionString
        }
      ]
    }
  }
}
