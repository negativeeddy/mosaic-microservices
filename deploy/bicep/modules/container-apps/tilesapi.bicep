param containerAppsEnvName string
param location string
param sqlConnectionString string
param nameSuffix string

resource cappsEnv 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: containerAppsEnvName
}

resource frontend 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: 'mosaic-tilesapi-ca-${nameSuffix}'
  location: location
  properties: {
    managedEnvironmentId: cappsEnv.id
    template: {
      containers: [
        {
          name: 'tilesapi'
          image: 'mosaicprod.azurecr.io/mosaic/tilesapi:latest'
          env: [
            {
              name: 'tiledbconnectionstring'  
              secretRef: 'tiledbconnectionstring'
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
        appId: 'tilesapi'
        appProtocol: 'http'
      }
      ingress: {
        external: true
        targetPort: 80
      }
       secrets: [
       {
         name: 'tiledbconnectionstring'
         value: sqlConnectionString
       }
      ]
    }
  }
}
