param containerAppsEnvName string
param appInsightsName string
param location string
param nameSuffix string
param flickrApiKey string = ''

resource cappsEnv 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: containerAppsEnvName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  name: appInsightsName
}

resource frontend 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: 'mosaic-mosaicgenerator-ca-${nameSuffix}'
  location: location
  properties: {
    managedEnvironmentId: cappsEnv.id
    template: {
      containers: [
        {
          name: 'mosaicgenerator'
          image: 'mosaicprod.azurecr.io/mosaic/mosaicgenerator:latest'
          env:[
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
        minReplicas: 1
      }
    }
    configuration: {
      dapr: {
        enabled: true
        appId: 'mosaicgenerator'
        appProtocol: 'http'
      }
      ingress: {
        external: false
        targetPort: 80
      }
      secrets:[
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
