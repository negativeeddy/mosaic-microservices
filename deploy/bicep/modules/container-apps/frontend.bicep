param containerAppsEnvName string
param location string
param nameSuffix string

resource cappsEnv 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: containerAppsEnvName
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
      }
    }
  }
}
