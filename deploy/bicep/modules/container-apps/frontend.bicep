param containerAppsEnvName string
param apiGatewayName string
param appInsightsName string
param location string
param nameSuffix string
param AADB2CInstance string
param AADB2CClientId string
param AADB2CDomain string
param AADB2CScopes string
param AADB2CSignUpSignInPolicyId string
param DefaultAccessTokenScopes string

resource cappsEnv 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: containerAppsEnvName
}

resource apiGateway 'Microsoft.App/containerApps@2022-01-01-preview' existing = {
  name: apiGatewayName
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
              name: 'AzureAdB2C:Instance'
              value: AADB2CInstance
            }
            {
              name: 'AzureAdB2C:ClientId'
              value: AADB2CClientId
            }
            {
              name: 'AzureAdB2C:Domain'
              value: AADB2CDomain
            }
            {
              name: 'AzureAdB2C:Scopes'
              value: AADB2CScopes
            }
            {
              name: 'AzureAdB2C:SignUpSignInPolicyId'
              value: AADB2CSignUpSignInPolicyId
            }
            {
              name: 'DefaultAccessTokenScopes'
              value: DefaultAccessTokenScopes
            }
            {
              name: 'clientConfig:ApiUri'
              value: apiGateway.properties.configuration.ingress.fqdn
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
      ]
    }
  }
}
