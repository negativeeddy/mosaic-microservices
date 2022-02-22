param location string = 'eastus'
param environment_name string = 'mosaic-app-environment'

resource pythonapp 'Microsoft.Web/containerApps@2021-03-01' = {
  name: 'mosaic-tilesapi'
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: resourceId('Microsoft.Web/kubeEnvironments', environment_name)
    configuration:  {
      ingress: {
        external: true
        targetPort: 80
      }
      secrets: [
        {
          name: 'tiledbconnectionstring'
          value: 'Server=tcp:mosaic-tiles-sqlsrv.database.windows.net,1433;Initial Catalog=mosaic-tilesdb-prod;Persist Security Info=False;User ID=mosaictilesadmin;Password=yellowledbetter1!;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
        }
      ]
    }
    template: {
      containers: [
        {
          image: 'mosaicprod.azurecr.io/mosaictilesapi:latest'
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
        appId: 'tilesapi'
        appPort: 80
        components: [
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
