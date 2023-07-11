param administratorLogin string = 'postgres'
@secure()
param administratorLoginPassword string
param location string = resourceGroup().location
param serverName string
param serverEdition string = 'Burstable'
param skuSizeGB int = 128
param dbInstanceType string = 'Standard_B1ms'
param haMode string = 'Disabled'
param availabilityZone string = '1'
param version string = '13'
param virtualNetworkExternalId string = ''
param subnetName string = ''
param privateDnsZoneArmResourceId string = ''
param tilesDatabaseName string = 'tiles'
param mosaicDatabaseName string = 'mosaic'

resource sqlServer 'Microsoft.DBforPostgreSQL/flexibleServers@2021-06-01' = {
  name: serverName
  location: location
  sku: {
    name: dbInstanceType
    tier: serverEdition
  }
  properties: {
    version: version
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    network: {
      delegatedSubnetResourceId: (empty(virtualNetworkExternalId) ? null : json('${virtualNetworkExternalId}/subnets/${subnetName}'))
      privateDnsZoneArmResourceId: (empty(virtualNetworkExternalId) ? null : privateDnsZoneArmResourceId)
    }
    highAvailability: {
      mode: haMode
    }
    storage: {
      storageSizeGB: skuSizeGB
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    availabilityZone: availabilityZone
  }
}

resource firewallAllowAllAzureServicesAndResourcesWithinAzureIps 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2021-06-01' = {
  parent: sqlServer
  name: 'AllowAllAzureServicesAndResourcesWithinAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource tilesDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2021-06-01' = {
  parent: sqlServer
  name: tilesDatabaseName
  properties: {
    charset: 'UTF8'
    collation: 'en_US.utf8'
  }
}

resource mosaicDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2021-06-01' = {
  parent: sqlServer
  name: mosaicDatabaseName
  properties: {
    charset: 'UTF8'
    collation: 'en_US.utf8'
  }
}

output tilesDatabaseName string = tilesDatabaseName
output fqdn string = sqlServer.properties.fullyQualifiedDomainName
