@description('Name of the workspace.')
param workspaceName string = 'mosaic-logs'

@description('Pricing tier: PerGB2018 or legacy tiers (Free, Standalone, PerNode, Standard or Premium) which are not available to all customers.')
@allowed([
  'Pergb2018'
  'Free'
  'Standalone'
  'PerNode'
  'Standard'
  'Premium'
])
param sku string = 'Pergb2018'

@description('Specifies the location for the workspace.')
param location string = 'eastus'

@description('Number of days to retain data.')
param retentionInDays int = 120

@description('true to use resource or workspace permissions. false to require workspace permissions.')
param resourcePermissions bool = true

@description('Number of days to retain data in Heartbeat table.')
param heartbeatTableRetention int = 30

resource workspaceName_resource 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: resourcePermissions
    }
  }
}

resource workspaceName_Heartbeat 'Microsoft.OperationalInsights/workspaces/tables@2020-08-01' = {
  parent: workspaceName_resource
  name: 'Heartbeat'
  properties: {
    RetentionInDays: heartbeatTableRetention
  }
}
