param containerAppsEnvName string
param appInsightsName string
param location string
param nameSuffix string
param flickrApiKey string

resource cappsEnv 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: containerAppsEnvName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  name: appInsightsName
}

resource frontend 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: 'mosaic-frontend-ca-${nameSuffix}'
  location: location
  properties: {
    managedEnvironmentId: cappsEnv.id
    template: {
      containers: [
        {
          name: 'frontend'
          image: 'mosaicprod.azurecr.io/mosaic/frontend:latest'
          env: [
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              secretRef: 'appinsightsconnectionstring'
            }
            {
              name: 'flickr__apiKey'
              secretRef: 'flickrapikey'
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
        appId: 'frontend'
        appProtocol: 'http'
      }
      ingress: {
        external: true
        targetPort: 80
        transport: 'http'
      }
      secrets: [
        {
          name: 'appinsightsconnectionstring'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'flickrapikey'
          value: flickrApiKey
        }
      ]
    }
  }
}
