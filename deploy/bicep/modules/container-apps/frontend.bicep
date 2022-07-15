param containerAppsEnvName string
param apiGatewayName string
param appInsightsName string
param location string
param nameSuffix string
param AADB2CInstance string = 'https://negativeeddyb2c.b2clogin.com/'
param AADB2CClientId string = 'f172a431-5d22-4381-afe0-d64a53c39f31'
param AADB2CDomain string= 'negativeeddyb2c.onmicrosoft.com'
param AADB2CScopes string = 'API.Access'
param AADB2CSignUpSignInPolicyId string = 'B2C_1_signupsignin1'
param DefaultAccessTokenScopes string = 'https://negativeeddyb2c.onmicrosoft.com/f172a431-5d22-4381-afe0-d64a53c39f31/Tiles.ReadWrite https://negativeeddyb2c.onmicrosoft.com/f172a431-5d22-4381-afe0-d64a53c39f31/Mosaics.ReadWrite'
param clientConfigAzureAdB2CValidateAuthority string = 'False'
param clientConfigAzureAdB2CClientId string = '92f3c44a-9c2e-4c81-b763-7856e4248eb4'
param clientConfigAzureAdB2CAuthority string = 'https://negativeeddyb2c.b2clogin.com/negativeeddyb2c.onmicrosoft.com/B2C_1_signupsignin1'

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
              name: 'AzureAdB2C__Instance'
              value: AADB2CInstance
            }
            {
              name: 'AzureAdB2C__ClientId'
              value: AADB2CClientId
            }
            {
              name: 'AzureAdB2C__Domain'
              value: AADB2CDomain
            }
            {
              name: 'AzureAdB2C__Scopes'
              value: AADB2CScopes
            }
            {
              name: 'AzureAdB2C__SignUpSignInPolicyId'
              value: AADB2CSignUpSignInPolicyId
            }
            {
              name: 'clientConfig__DefaultAccessTokenScopes'
              value: DefaultAccessTokenScopes
            }
            {
              name: 'clientConfig__ApiUri'
              value:'https://${apiGateway.properties.configuration.ingress.fqdn}' 
            }
            {
              name: 'clientConfig__AzureAdB2C__ValidateAuthority'
              value: clientConfigAzureAdB2CValidateAuthority
            }
            {
              name: 'clientConfig__AzureAdB2C__ClientId'
              value: clientConfigAzureAdB2CClientId
            } 
            {
              name: 'clientConfig__AzureAdB2C__Authority'
              value: clientConfigAzureAdB2CAuthority
            
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

output fqdn string = frontend.properties.configuration.ingress.fqdn
