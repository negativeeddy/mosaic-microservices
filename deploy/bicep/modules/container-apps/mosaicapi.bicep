param containerAppsEnvName string
param appInsightsName string
param location string
param sqlConnectionString string
param nameSuffix string
param containerRegistry string

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
          image: '${containerRegistry}/mosaic/mosaicapi:latest'
          env: [
            {
              name: 'ConnectionStrings__tiledbconnectionstring'
              secretRef: 'tiledbconnectionstring'
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              secretRef: 'appinsightsconnectionstring'
            }
            {
              name: 'AzureAdB2C__SignUpSignInPolicyId'
              value: ''
            }
            {
              name: 'AzureAdB2C__Scopes'
              value: 'Mosaics.ReadWrite'
            }
            {
              name: 'AzureAdB2C__Instance'
              value: ''
            }
            {
              name: 'AzureAdB2C__Domain'
              value: ''
            }
            {
              name: 'AzureAdB2C__ClientId'
              value: ''
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
