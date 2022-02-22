param location string = 'eastus'
param environment_name string = 'mosaic-app-environment'

resource pythonapp 'Microsoft.Web/containerApps@2021-03-01' = {
  name: 'mosaic-tileprocessor'
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: resourceId('Microsoft.Web/kubeEnvironments', environment_name)
    configuration:  {
      ingress: {
        external: true
        targetPort: 80
      }
    }
    template: {
      containers: [
        {
          image: 'mosaicprod.azurecr.io/mosaictileprocessor:latest'
          name: 'tilesapi'
          resources: {
            cpu: '0.5'
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
      dapr: {
        enabled: true
        appId: 'tileprocessor'
        appPort: 80
        components: [
          {
            name: 'tilestorage'
            type: 'bindings.azure.blobstorage'
            version: 'v1'
            metadata: [
              {
                name: 'storageAccount'
                value: 'mosaicstorageprod'
              }
              {
                name: 'storageAccessKey'
                value: 'gGVS2X4dVRKjdI6qPiu/bvF+4eAgEJNWZuNmPV663wrCwSIR4j+Jmv65qtfoS8vER2bE2QR7EsfP+AStrd2hlA=='
              }
              {
                name: 'container'
                value: 'tiles'
              }
              {
                name: 'decodeBase64'
                value: 'true'
              }
            ]
          }
          {
            name: 'pubsub'
            type:'pubsub.azure.servicebus'
            version: 'v1'
            metadata: [
              {
                name: 'connectionString'
                value: 'Endpoint=sb://mosaic-prod.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=Nq28LoE9145WLFJX5bJJ73wSYSElNw7ITU/bSU0CKdU='            
              }
            ]
          }
        ]      
      }
    }
  }
}
