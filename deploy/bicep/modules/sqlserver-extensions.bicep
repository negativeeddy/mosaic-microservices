param serverName string

resource sqlServer 'Microsoft.DBforPostgreSQL/flexibleServers@2021-06-01' existing = {
  name: serverName
}

resource configExtensions 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2021-06-01' = {
  parent: sqlServer
  name: 'azure.extensions'
  properties: {
    value: 'POSTGIS'
    source: 'user-override'
  }
}
