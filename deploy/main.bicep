param containerApps_mosaic_frontend_name string
param containerApps_mosaic_tileprocessor_name string
param containerApps_mosaic_tilesapi_name string
param kubeenvironments_mosaic_app_environment_name string
param namespaces_mosaic_prod_name string
param registries_mosaicprod_name string
param servers_mosaic_tiles_sqlsrv_name string
param storageAccounts_mosaicstorageprod_name string

@secure()
param vulnerabilityAssessments_Default_storageContainerPath string
param workspaces_mosaic_prod_logs_name string

resource registries_mosaicprod_name_resource 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  location: 'southcentralus'
  name: registries_mosaicprod_name
  properties: {
    adminUserEnabled: true
    anonymousPullEnabled: true
    dataEndpointEnabled: false
    encryption: {
      status: 'disabled'
    }
    networkRuleBypassOptions: 'AzureServices'
    policies: {
      exportPolicy: {
        status: 'enabled'
      }
      quarantinePolicy: {
        status: 'disabled'
      }
      retentionPolicy: {
        days: 7
        status: 'disabled'
      }
      trustPolicy: {
        status: 'disabled'
        type: 'Notary'
      }
    }
    publicNetworkAccess: 'Enabled'
    zoneRedundancy: 'Disabled'
  }
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

resource workspaces_mosaic_prod_logs_name_resource 'microsoft.operationalinsights/workspaces@2021-12-01-preview' = {
  location: 'southcentralus'
  name: workspaces_mosaic_prod_logs_name
  properties: {
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    provisioningState: 'Succeeded'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
    workspaceCapping: {
      dailyQuotaGb: '-1'
    }
  }
}

resource namespaces_mosaic_prod_name_resource 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' = {
  location: 'East US'
  name: namespaces_mosaic_prod_name
  properties: {
    disableLocalAuth: false
    zoneRedundant: false
  }
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

resource servers_mosaic_tiles_sqlsrv_name_resource 'Microsoft.Sql/servers@2021-08-01-preview' = {
  kind: 'v12.0'
  location: 'eastus'
  name: servers_mosaic_tiles_sqlsrv_name
  properties: {
    administratorLogin: 'mosaictilesadmin'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
    version: '12.0'
  }
}

resource storageAccounts_mosaicstorageprod_name_resource 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  kind: 'StorageV2'
  location: 'eastus'
  name: storageAccounts_mosaicstorageprod_name
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: true
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
      }
    }
    minimumTlsVersion: 'TLS1_0'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
      ipRules: []
      virtualNetworkRules: []
    }
    supportsHttpsTrafficOnly: true
  }
  sku: {
    name: 'Standard_RAGRS'
    tier: 'Standard'
  }
}

resource kubeenvironments_mosaic_app_environment_name_resource 'Microsoft.Web/kubeenvironments@2021-03-01' = {
  kind: 'containerenvironment'
  location: 'eastus'
  name: kubeenvironments_mosaic_app_environment_name
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: 'b879fdd5-535d-4254-bb45-1ab8fa27f963'
      }
    }
    containerAppsConfiguration: {}
    environmentType: 'Managed'
    staticIp: '40.71.86.11'
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_General_AlphabeticallySortedComputers 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_General|AlphabeticallySortedComputers'
  properties: {
    category: 'General Exploration'
    displayName: 'All Computers with their most recent data'
    query: 'search not(ObjectName == "Advisor Metrics" or ObjectName == "ManagedSpace") | summarize AggregatedValue = max(TimeGenerated) by Computer | limit 500000 | sort by Computer asc\r\n// Oql: NOT(ObjectName="Advisor Metrics" OR ObjectName=ManagedSpace) | measure max(TimeGenerated) by Computer | top 500000 | Sort Computer // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_General_dataPointsPerManagementGroup 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_General|dataPointsPerManagementGroup'
  properties: {
    category: 'General Exploration'
    displayName: 'Which Management Group is generating the most data points?'
    query: 'search * | summarize AggregatedValue = count() by ManagementGroupName\r\n// Oql: * | Measure count() by ManagementGroupName // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_General_dataTypeDistribution 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_General|dataTypeDistribution'
  properties: {
    category: 'General Exploration'
    displayName: 'Distribution of data Types'
    query: 'search * | extend Type = $table | summarize AggregatedValue = count() by Type\r\n// Oql: * | Measure count() by Type // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_General_StaleComputers 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_General|StaleComputers'
  properties: {
    category: 'General Exploration'
    displayName: 'Stale Computers (data older than 24 hours)'
    query: 'search not(ObjectName == "Advisor Metrics" or ObjectName == "ManagedSpace") | summarize lastdata = max(TimeGenerated) by Computer | limit 500000 | where lastdata < ago(24h)\r\n// Oql: NOT(ObjectName="Advisor Metrics" OR ObjectName=ManagedSpace) | measure max(TimeGenerated) as lastdata by Computer | top 500000 | where lastdata < NOW-24HOURS // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_AllEvents 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|AllEvents'
  properties: {
    category: 'Log Management'
    displayName: 'All Events'
    query: 'Event | sort by TimeGenerated desc\r\n// Oql: Type=Event // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_AllSyslog 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|AllSyslog'
  properties: {
    category: 'Log Management'
    displayName: 'All Syslogs'
    query: 'Syslog | sort by TimeGenerated desc\r\n// Oql: Type=Syslog // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_AllSyslogByFacility 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|AllSyslogByFacility'
  properties: {
    category: 'Log Management'
    displayName: 'All Syslog Records grouped by Facility'
    query: 'Syslog | summarize AggregatedValue = count() by Facility\r\n// Oql: Type=Syslog | Measure count() by Facility // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_AllSyslogByProcessName 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|AllSyslogByProcessName'
  properties: {
    category: 'Log Management'
    displayName: 'All Syslog Records grouped by ProcessName'
    query: 'Syslog | summarize AggregatedValue = count() by ProcessName\r\n// Oql: Type=Syslog | Measure count() by ProcessName // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_AllSyslogsWithErrors 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|AllSyslogsWithErrors'
  properties: {
    category: 'Log Management'
    displayName: 'All Syslog Records with Errors'
    query: 'Syslog | where SeverityLevel == "error" | sort by TimeGenerated desc\r\n// Oql: Type=Syslog SeverityLevel=error // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_AverageHTTPRequestTimeByClientIPAddress 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|AverageHTTPRequestTimeByClientIPAddress'
  properties: {
    category: 'Log Management'
    displayName: 'Average HTTP Request time by Client IP Address'
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = avg(TimeTaken) by cIP\r\n// Oql: Type=W3CIISLog | Measure Avg(TimeTaken) by cIP // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_AverageHTTPRequestTimeHTTPMethod 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|AverageHTTPRequestTimeHTTPMethod'
  properties: {
    category: 'Log Management'
    displayName: 'Average HTTP Request time by HTTP Method'
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = avg(TimeTaken) by csMethod\r\n// Oql: Type=W3CIISLog | Measure Avg(TimeTaken) by csMethod // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_CountIISLogEntriesClientIPAddress 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|CountIISLogEntriesClientIPAddress'
  properties: {
    category: 'Log Management'
    displayName: 'Count of IIS Log Entries by Client IP Address'
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by cIP\r\n// Oql: Type=W3CIISLog | Measure count() by cIP // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_CountIISLogEntriesHTTPRequestMethod 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|CountIISLogEntriesHTTPRequestMethod'
  properties: {
    category: 'Log Management'
    displayName: 'Count of IIS Log Entries by HTTP Request Method'
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by csMethod\r\n// Oql: Type=W3CIISLog | Measure count() by csMethod // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_CountIISLogEntriesHTTPUserAgent 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|CountIISLogEntriesHTTPUserAgent'
  properties: {
    category: 'Log Management'
    displayName: 'Count of IIS Log Entries by HTTP User Agent'
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by csUserAgent\r\n// Oql: Type=W3CIISLog | Measure count() by csUserAgent // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_CountOfIISLogEntriesByHostRequestedByClient 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|CountOfIISLogEntriesByHostRequestedByClient'
  properties: {
    category: 'Log Management'
    displayName: 'Count of IIS Log Entries by Host requested by client'
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by csHost\r\n// Oql: Type=W3CIISLog | Measure count() by csHost // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_CountOfIISLogEntriesByURLForHost 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|CountOfIISLogEntriesByURLForHost'
  properties: {
    category: 'Log Management'
    displayName: 'Count of IIS Log Entries by URL for the host "www.contoso.com" (replace with your own)'
    query: 'search csHost == "www.contoso.com" | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by csUriStem\r\n// Oql: Type=W3CIISLog csHost="www.contoso.com" | Measure count() by csUriStem // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_CountOfIISLogEntriesByURLRequestedByClient 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|CountOfIISLogEntriesByURLRequestedByClient'
  properties: {
    category: 'Log Management'
    displayName: 'Count of IIS Log Entries by URL requested by client (without query strings)'
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by csUriStem\r\n// Oql: Type=W3CIISLog | Measure count() by csUriStem // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_CountOfWarningEvents 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|CountOfWarningEvents'
  properties: {
    category: 'Log Management'
    displayName: 'Count of Events with level "Warning" grouped by Event ID'
    query: 'Event | where EventLevelName == "warning" | summarize AggregatedValue = count() by EventID\r\n// Oql: Type=Event EventLevelName=warning | Measure count() by EventID // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_DisplayBreakdownRespondCodes 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|DisplayBreakdownRespondCodes'
  properties: {
    category: 'Log Management'
    displayName: 'Shows breakdown of response codes'
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by scStatus\r\n// Oql: Type=W3CIISLog | Measure count() by scStatus // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_EventsByEventLog 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|EventsByEventLog'
  properties: {
    category: 'Log Management'
    displayName: 'Count of Events grouped by Event Log'
    query: 'Event | summarize AggregatedValue = count() by EventLog\r\n// Oql: Type=Event | Measure count() by EventLog // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_EventsByEventsID 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|EventsByEventsID'
  properties: {
    category: 'Log Management'
    displayName: 'Count of Events grouped by Event ID'
    query: 'Event | summarize AggregatedValue = count() by EventID\r\n// Oql: Type=Event | Measure count() by EventID // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_EventsByEventSource 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|EventsByEventSource'
  properties: {
    category: 'Log Management'
    displayName: 'Count of Events grouped by Event Source'
    query: 'Event | summarize AggregatedValue = count() by Source\r\n// Oql: Type=Event | Measure count() by Source // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_EventsInOMBetween2000to3000 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|EventsInOMBetween2000to3000'
  properties: {
    category: 'Log Management'
    displayName: 'Events in the Operations Manager Event Log whose Event ID is in the range between 2000 and 3000'
    query: 'Event | where EventLog == "Operations Manager" and EventID >= 2000 and EventID <= 3000 | sort by TimeGenerated desc\r\n// Oql: Type=Event EventLog="Operations Manager" EventID:[2000..3000] // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_EventsWithStartedinEventID 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|EventsWithStartedinEventID'
  properties: {
    category: 'Log Management'
    displayName: 'Count of Events containing the word "started" grouped by EventID'
    query: 'search in (Event) "started" | summarize AggregatedValue = count() by EventID\r\n// Oql: Type=Event "started" | Measure count() by EventID // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_FindMaximumTimeTakenForEachPage 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|FindMaximumTimeTakenForEachPage'
  properties: {
    category: 'Log Management'
    displayName: 'Find the maximum time taken for each page'
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = max(TimeTaken) by csUriStem\r\n// Oql: Type=W3CIISLog | Measure Max(TimeTaken) by csUriStem // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_IISLogEntriesForClientIP 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|IISLogEntriesForClientIP'
  properties: {
    category: 'Log Management'
    displayName: 'IIS Log Entries for a specific client IP Address (replace with your own)'
    query: 'search cIP == "192.168.0.1" | extend Type = $table | where Type == W3CIISLog | sort by TimeGenerated desc | project csUriStem, scBytes, csBytes, TimeTaken, scStatus\r\n// Oql: Type=W3CIISLog cIP="192.168.0.1" | Select csUriStem,scBytes,csBytes,TimeTaken,scStatus // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_ListAllIISLogEntries 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|ListAllIISLogEntries'
  properties: {
    category: 'Log Management'
    displayName: 'All IIS Log Entries'
    query: 'search * | extend Type = $table | where Type == W3CIISLog | sort by TimeGenerated desc\r\n// Oql: Type=W3CIISLog // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_NoOfConnectionsToOMSDKService 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|NoOfConnectionsToOMSDKService'
  properties: {
    category: 'Log Management'
    displayName: 'How many connections to Operations Manager\'s SDK service by day'
    query: 'Event | where EventID == 26328 and EventLog == "Operations Manager" | summarize AggregatedValue = count() by bin(TimeGenerated, 1d) | sort by TimeGenerated desc\r\n// Oql: Type=Event EventID=26328 EventLog="Operations Manager" | Measure count() interval 1DAY // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_ServerRestartTime 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|ServerRestartTime'
  properties: {
    category: 'Log Management'
    displayName: 'When did my servers initiate restart?'
    query: 'search in (Event) "shutdown" and EventLog == "System" and Source == "User32" and EventID == 1074 | sort by TimeGenerated desc | project TimeGenerated, Computer\r\n// Oql: shutdown Type=Event EventLog=System Source=User32 EventID=1074 | Select TimeGenerated,Computer // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_Show404PagesList 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|Show404PagesList'
  properties: {
    category: 'Log Management'
    displayName: 'Shows which pages people are getting a 404 for'
    query: 'search scStatus == 404 | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by csUriStem\r\n// Oql: Type=W3CIISLog scStatus=404 | Measure count() by csUriStem // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_ShowServersThrowingInternalServerError 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|ShowServersThrowingInternalServerError'
  properties: {
    category: 'Log Management'
    displayName: 'Shows servers that are throwing internal server error'
    query: 'search scStatus == 500 | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = count() by sComputerName\r\n// Oql: Type=W3CIISLog scStatus=500 | Measure count() by sComputerName // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_TotalBytesReceivedByEachAzureRoleInstance 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|TotalBytesReceivedByEachAzureRoleInstance'
  properties: {
    category: 'Log Management'
    displayName: 'Total Bytes received by each Azure Role Instance'
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = sum(csBytes) by RoleInstance\r\n// Oql: Type=W3CIISLog | Measure Sum(csBytes) by RoleInstance // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_TotalBytesReceivedByEachIISComputer 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|TotalBytesReceivedByEachIISComputer'
  properties: {
    category: 'Log Management'
    displayName: 'Total Bytes received by each IIS Computer'
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = sum(csBytes) by Computer | limit 500000\r\n// Oql: Type=W3CIISLog | Measure Sum(csBytes) by Computer | top 500000 // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_TotalBytesRespondedToClientsByClientIPAddress 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|TotalBytesRespondedToClientsByClientIPAddress'
  properties: {
    category: 'Log Management'
    displayName: 'Total Bytes responded back to clients by Client IP Address'
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = sum(scBytes) by cIP\r\n// Oql: Type=W3CIISLog | Measure Sum(scBytes) by cIP // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_TotalBytesRespondedToClientsByEachIISServerIPAddress 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|TotalBytesRespondedToClientsByEachIISServerIPAddress'
  properties: {
    category: 'Log Management'
    displayName: 'Total Bytes responded back to clients by each IIS ServerIP Address'
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = sum(scBytes) by sIP\r\n// Oql: Type=W3CIISLog | Measure Sum(scBytes) by sIP // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_TotalBytesSentByClientIPAddress 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|TotalBytesSentByClientIPAddress'
  properties: {
    category: 'Log Management'
    displayName: 'Total Bytes sent by Client IP Address'
    query: 'search * | extend Type = $table | where Type == W3CIISLog | summarize AggregatedValue = sum(csBytes) by cIP\r\n// Oql: Type=W3CIISLog | Measure Sum(csBytes) by cIP // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PEF: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_WarningEvents 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|WarningEvents'
  properties: {
    category: 'Log Management'
    displayName: 'All Events with level "Warning"'
    query: 'Event | where EventLevelName == "warning" | sort by TimeGenerated desc\r\n// Oql: Type=Event EventLevelName=warning // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_WindowsFireawallPolicySettingsChanged 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|WindowsFireawallPolicySettingsChanged'
  properties: {
    category: 'Log Management'
    displayName: 'Windows Firewall Policy settings have changed'
    query: 'Event | where EventLog == "Microsoft-Windows-Windows Firewall With Advanced Security/Firewall" and EventID == 2008 | sort by TimeGenerated desc\r\n// Oql: Type=Event EventLog="Microsoft-Windows-Windows Firewall With Advanced Security/Firewall" EventID=2008 // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_LogManagement_workspaces_mosaic_prod_logs_name_LogManagement_WindowsFireawallPolicySettingsChangedByMachines 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LogManagement(${workspaces_mosaic_prod_logs_name})_LogManagement|WindowsFireawallPolicySettingsChangedByMachines'
  properties: {
    category: 'Log Management'
    displayName: 'On which machines and how many times have Windows Firewall Policy settings changed'
    query: 'Event | where EventLog == "Microsoft-Windows-Windows Firewall With Advanced Security/Firewall" and EventID == 2008 | summarize AggregatedValue = count() by Computer | limit 500000\r\n// Oql: Type=Event EventLog="Microsoft-Windows-Windows Firewall With Advanced Security/Firewall" EventID=2008 | measure count() by Computer | top 500000 // Args: {OQ: True; WorkspaceId: 00000000-0000-0000-0000-000000000000} // Settings: {PTT: True; SortI: True; SortF: True} // Version: 0.1.122'
    version: 2
  }
}

resource workspaces_mosaic_prod_logs_name_AACAudit 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AACAudit'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AACAudit'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AACHttpRequest 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AACHttpRequest'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AACHttpRequest'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AADDomainServicesAccountLogon 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AADDomainServicesAccountLogon'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AADDomainServicesAccountLogon'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AADDomainServicesAccountManagement 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AADDomainServicesAccountManagement'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AADDomainServicesAccountManagement'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AADDomainServicesDirectoryServiceAccess 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AADDomainServicesDirectoryServiceAccess'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AADDomainServicesDirectoryServiceAccess'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AADDomainServicesLogonLogoff 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AADDomainServicesLogonLogoff'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AADDomainServicesLogonLogoff'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AADDomainServicesPolicyChange 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AADDomainServicesPolicyChange'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AADDomainServicesPolicyChange'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AADDomainServicesPrivilegeUse 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AADDomainServicesPrivilegeUse'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AADDomainServicesPrivilegeUse'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AADDomainServicesSystemSecurity 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AADDomainServicesSystemSecurity'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AADDomainServicesSystemSecurity'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AADManagedIdentitySignInLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AADManagedIdentitySignInLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AADManagedIdentitySignInLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AADNonInteractiveUserSignInLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AADNonInteractiveUserSignInLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AADNonInteractiveUserSignInLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AADProvisioningLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AADProvisioningLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AADProvisioningLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AADRiskyServicePrincipals 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AADRiskyServicePrincipals'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AADRiskyServicePrincipals'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AADRiskyUsers 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AADRiskyUsers'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AADRiskyUsers'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AADServicePrincipalRiskEvents 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AADServicePrincipalRiskEvents'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AADServicePrincipalRiskEvents'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AADServicePrincipalSignInLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AADServicePrincipalSignInLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AADServicePrincipalSignInLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AADUserRiskEvents 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AADUserRiskEvents'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AADUserRiskEvents'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ABSBotRequests 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ABSBotRequests'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ABSBotRequests'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ABSChannelToBotRequests 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ABSChannelToBotRequests'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ABSChannelToBotRequests'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ABSDependenciesRequests 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ABSDependenciesRequests'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ABSDependenciesRequests'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ACICollaborationAudit 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ACICollaborationAudit'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ACICollaborationAudit'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ACRConnectedClientList 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ACRConnectedClientList'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ACRConnectedClientList'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ACSAuthIncomingOperations 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ACSAuthIncomingOperations'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ACSAuthIncomingOperations'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ACSBillingUsage 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ACSBillingUsage'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ACSBillingUsage'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ACSCallDiagnostics 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ACSCallDiagnostics'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ACSCallDiagnostics'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ACSCallSummary 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ACSCallSummary'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ACSCallSummary'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ACSChatIncomingOperations 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ACSChatIncomingOperations'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ACSChatIncomingOperations'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ACSNetworkTraversalIncomingOperations 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ACSNetworkTraversalIncomingOperations'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ACSNetworkTraversalIncomingOperations'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ACSSMSIncomingOperations 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ACSSMSIncomingOperations'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ACSSMSIncomingOperations'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AddonAzureBackupAlerts 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AddonAzureBackupAlerts'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AddonAzureBackupAlerts'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AddonAzureBackupJobs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AddonAzureBackupJobs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AddonAzureBackupJobs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AddonAzureBackupPolicy 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AddonAzureBackupPolicy'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AddonAzureBackupPolicy'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AddonAzureBackupProtectedInstance 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AddonAzureBackupProtectedInstance'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AddonAzureBackupProtectedInstance'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AddonAzureBackupStorage 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AddonAzureBackupStorage'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AddonAzureBackupStorage'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADFActivityRun 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADFActivityRun'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADFActivityRun'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADFAirflowSchedulerLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADFAirflowSchedulerLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADFAirflowSchedulerLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADFAirflowTaskLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADFAirflowTaskLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADFAirflowTaskLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADFAirflowWebLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADFAirflowWebLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADFAirflowWebLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADFAirflowWorkerLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADFAirflowWorkerLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADFAirflowWorkerLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADFPipelineRun 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADFPipelineRun'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADFPipelineRun'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADFSandboxActivityRun 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADFSandboxActivityRun'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADFSandboxActivityRun'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADFSandboxPipelineRun 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADFSandboxPipelineRun'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADFSandboxPipelineRun'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADFSSignInLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADFSSignInLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADFSSignInLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADFSSISIntegrationRuntimeLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADFSSISIntegrationRuntimeLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADFSSISIntegrationRuntimeLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADFSSISPackageEventMessageContext 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADFSSISPackageEventMessageContext'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADFSSISPackageEventMessageContext'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADFSSISPackageEventMessages 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADFSSISPackageEventMessages'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADFSSISPackageEventMessages'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADFSSISPackageExecutableStatistics 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADFSSISPackageExecutableStatistics'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADFSSISPackageExecutableStatistics'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADFSSISPackageExecutionComponentPhases 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADFSSISPackageExecutionComponentPhases'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADFSSISPackageExecutionComponentPhases'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADFSSISPackageExecutionDataStatistics 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADFSSISPackageExecutionDataStatistics'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADFSSISPackageExecutionDataStatistics'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADFTriggerRun 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADFTriggerRun'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADFTriggerRun'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADPAudit 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADPAudit'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADPAudit'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADPDiagnostics 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADPDiagnostics'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADPDiagnostics'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADPRequests 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADPRequests'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADPRequests'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADTDigitalTwinsOperation 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADTDigitalTwinsOperation'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADTDigitalTwinsOperation'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADTEventRoutesOperation 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADTEventRoutesOperation'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADTEventRoutesOperation'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADTModelsOperation 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADTModelsOperation'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADTModelsOperation'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADTQueryOperation 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADTQueryOperation'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADTQueryOperation'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADXCommand 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADXCommand'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADXCommand'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADXIngestionBatching 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADXIngestionBatching'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADXIngestionBatching'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADXJournal 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADXJournal'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADXJournal'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADXQuery 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADXQuery'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADXQuery'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADXTableDetails 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADXTableDetails'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADXTableDetails'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ADXTableUsageStatistics 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ADXTableUsageStatistics'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ADXTableUsageStatistics'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AegDeliveryFailureLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AegDeliveryFailureLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AegDeliveryFailureLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AegPublishFailureLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AegPublishFailureLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AegPublishFailureLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AEWAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AEWAuditLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AEWAuditLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AEWComputePipelinesLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AEWComputePipelinesLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AEWComputePipelinesLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AgriFoodApplicationAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AgriFoodApplicationAuditLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AgriFoodApplicationAuditLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AgriFoodFarmManagementLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AgriFoodFarmManagementLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AgriFoodFarmManagementLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AgriFoodFarmOperationLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AgriFoodFarmOperationLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AgriFoodFarmOperationLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AgriFoodInsightLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AgriFoodInsightLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AgriFoodInsightLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AgriFoodJobProcessedLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AgriFoodJobProcessedLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AgriFoodJobProcessedLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AgriFoodModelInferenceLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AgriFoodModelInferenceLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AgriFoodModelInferenceLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AgriFoodProviderAuthLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AgriFoodProviderAuthLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AgriFoodProviderAuthLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AgriFoodSatelliteLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AgriFoodSatelliteLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AgriFoodSatelliteLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AgriFoodWeatherLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AgriFoodWeatherLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AgriFoodWeatherLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AGSGrafanaLoginEvents 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AGSGrafanaLoginEvents'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AGSGrafanaLoginEvents'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AirflowDagProcessingLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AirflowDagProcessingLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AirflowDagProcessingLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_Alert 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'Alert'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'Alert'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AmlComputeClusterEvent 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AmlComputeClusterEvent'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AmlComputeClusterEvent'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AmlComputeClusterNodeEvent 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AmlComputeClusterNodeEvent'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AmlComputeClusterNodeEvent'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AmlComputeCpuGpuUtilization 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AmlComputeCpuGpuUtilization'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AmlComputeCpuGpuUtilization'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AmlComputeInstanceEvent 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AmlComputeInstanceEvent'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AmlComputeInstanceEvent'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AmlComputeJobEvent 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AmlComputeJobEvent'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AmlComputeJobEvent'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AmlDataLabelEvent 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AmlDataLabelEvent'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AmlDataLabelEvent'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AmlDataSetEvent 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AmlDataSetEvent'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AmlDataSetEvent'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AmlDataStoreEvent 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AmlDataStoreEvent'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AmlDataStoreEvent'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AmlDeploymentEvent 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AmlDeploymentEvent'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AmlDeploymentEvent'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AmlEnvironmentEvent 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AmlEnvironmentEvent'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AmlEnvironmentEvent'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AmlInferencingEvent 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AmlInferencingEvent'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AmlInferencingEvent'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AmlModelsEvent 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AmlModelsEvent'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AmlModelsEvent'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AmlOnlineEndpointConsoleLog 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AmlOnlineEndpointConsoleLog'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AmlOnlineEndpointConsoleLog'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AmlPipelineEvent 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AmlPipelineEvent'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AmlPipelineEvent'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AmlRunEvent 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AmlRunEvent'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AmlRunEvent'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AmlRunStatusChangedEvent 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AmlRunStatusChangedEvent'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AmlRunStatusChangedEvent'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ApiManagementGatewayLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ApiManagementGatewayLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ApiManagementGatewayLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AppAvailabilityResults 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppAvailabilityResults'
  properties: {
    plan: 'Analytics'
    retentionInDays: 90
    schema: {
      name: 'AppAvailabilityResults'
    }
    totalRetentionInDays: 90
  }
}

resource workspaces_mosaic_prod_logs_name_AppBrowserTimings 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppBrowserTimings'
  properties: {
    plan: 'Analytics'
    retentionInDays: 90
    schema: {
      name: 'AppBrowserTimings'
    }
    totalRetentionInDays: 90
  }
}

resource workspaces_mosaic_prod_logs_name_AppCenterError 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppCenterError'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AppCenterError'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AppDependencies 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppDependencies'
  properties: {
    plan: 'Analytics'
    retentionInDays: 90
    schema: {
      name: 'AppDependencies'
    }
    totalRetentionInDays: 90
  }
}

resource workspaces_mosaic_prod_logs_name_AppEvents 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppEvents'
  properties: {
    plan: 'Analytics'
    retentionInDays: 90
    schema: {
      name: 'AppEvents'
    }
    totalRetentionInDays: 90
  }
}

resource workspaces_mosaic_prod_logs_name_AppExceptions 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppExceptions'
  properties: {
    plan: 'Analytics'
    retentionInDays: 90
    schema: {
      name: 'AppExceptions'
    }
    totalRetentionInDays: 90
  }
}

resource workspaces_mosaic_prod_logs_name_AppMetrics 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppMetrics'
  properties: {
    plan: 'Analytics'
    retentionInDays: 90
    schema: {
      name: 'AppMetrics'
    }
    totalRetentionInDays: 90
  }
}

resource workspaces_mosaic_prod_logs_name_AppPageViews 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppPageViews'
  properties: {
    plan: 'Analytics'
    retentionInDays: 90
    schema: {
      name: 'AppPageViews'
    }
    totalRetentionInDays: 90
  }
}

resource workspaces_mosaic_prod_logs_name_AppPerformanceCounters 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppPerformanceCounters'
  properties: {
    plan: 'Analytics'
    retentionInDays: 90
    schema: {
      name: 'AppPerformanceCounters'
    }
    totalRetentionInDays: 90
  }
}

resource workspaces_mosaic_prod_logs_name_AppPlatformBuildLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppPlatformBuildLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AppPlatformBuildLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AppPlatformIngressLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppPlatformIngressLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AppPlatformIngressLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AppPlatformLogsforSpring 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppPlatformLogsforSpring'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AppPlatformLogsforSpring'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AppPlatformSystemLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppPlatformSystemLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AppPlatformSystemLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AppRequests 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppRequests'
  properties: {
    plan: 'Analytics'
    retentionInDays: 90
    schema: {
      name: 'AppRequests'
    }
    totalRetentionInDays: 90
  }
}

resource workspaces_mosaic_prod_logs_name_AppServiceAntivirusScanAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppServiceAntivirusScanAuditLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AppServiceAntivirusScanAuditLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AppServiceAppLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppServiceAppLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AppServiceAppLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AppServiceAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppServiceAuditLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AppServiceAuditLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AppServiceConsoleLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppServiceConsoleLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AppServiceConsoleLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AppServiceEnvironmentPlatformLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppServiceEnvironmentPlatformLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AppServiceEnvironmentPlatformLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AppServiceFileAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppServiceFileAuditLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AppServiceFileAuditLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AppServiceHTTPLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppServiceHTTPLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AppServiceHTTPLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AppServiceIPSecAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppServiceIPSecAuditLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AppServiceIPSecAuditLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AppServicePlatformLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppServicePlatformLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AppServicePlatformLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AppSystemEvents 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppSystemEvents'
  properties: {
    plan: 'Analytics'
    retentionInDays: 90
    schema: {
      name: 'AppSystemEvents'
    }
    totalRetentionInDays: 90
  }
}

resource workspaces_mosaic_prod_logs_name_AppTraces 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AppTraces'
  properties: {
    plan: 'Analytics'
    retentionInDays: 90
    schema: {
      name: 'AppTraces'
    }
    totalRetentionInDays: 90
  }
}

resource workspaces_mosaic_prod_logs_name_AuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AuditLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AuditLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AUIEventsAudit 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AUIEventsAudit'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AUIEventsAudit'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AUIEventsOperational 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AUIEventsOperational'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AUIEventsOperational'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AutoscaleEvaluationsLog 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AutoscaleEvaluationsLog'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AutoscaleEvaluationsLog'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AutoscaleScaleActionsLog 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AutoscaleScaleActionsLog'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AutoscaleScaleActionsLog'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AzureActivity 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AzureActivity'
  properties: {
    plan: 'Analytics'
    retentionInDays: 90
    schema: {
      name: 'AzureActivity'
    }
    totalRetentionInDays: 90
  }
}

resource workspaces_mosaic_prod_logs_name_AzureActivityV2 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AzureActivityV2'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AzureActivityV2'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AzureDevOpsAuditing 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AzureDevOpsAuditing'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AzureDevOpsAuditing'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_AzureMetrics 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'AzureMetrics'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'AzureMetrics'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_BaiClusterEvent 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'BaiClusterEvent'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'BaiClusterEvent'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_BaiClusterNodeEvent 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'BaiClusterNodeEvent'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'BaiClusterNodeEvent'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_BaiJobEvent 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'BaiJobEvent'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'BaiJobEvent'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_CassandraAudit 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'CassandraAudit'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'CassandraAudit'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_CassandraLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'CassandraLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'CassandraLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_CDBCassandraRequests 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'CDBCassandraRequests'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'CDBCassandraRequests'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_CDBControlPlaneRequests 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'CDBControlPlaneRequests'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'CDBControlPlaneRequests'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_CDBDataPlaneRequests 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'CDBDataPlaneRequests'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'CDBDataPlaneRequests'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_CDBGremlinRequests 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'CDBGremlinRequests'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'CDBGremlinRequests'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_CDBMongoRequests 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'CDBMongoRequests'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'CDBMongoRequests'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_CDBPartitionKeyRUConsumption 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'CDBPartitionKeyRUConsumption'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'CDBPartitionKeyRUConsumption'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_CDBPartitionKeyStatistics 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'CDBPartitionKeyStatistics'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'CDBPartitionKeyStatistics'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_CDBQueryRuntimeStatistics 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'CDBQueryRuntimeStatistics'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'CDBQueryRuntimeStatistics'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_CIEventsAudit 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'CIEventsAudit'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'CIEventsAudit'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_CIEventsOperational 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'CIEventsOperational'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'CIEventsOperational'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ComputerGroup 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ComputerGroup'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ComputerGroup'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ContainerAppConsoleLogs_CL 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ContainerAppConsoleLogs_CL'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      columns: [
        {
          name: 'State_byteCount_d'
          type: 'real'
        }
        {
          name: 'State_TileId_d'
          type: 'real'
        }
        {
          name: 'State_Filename_s'
          type: 'string'
        }
        {
          name: 'State_Error_s'
          type: 'string'
        }
        {
          name: 'State_parameters_s'
          type: 'string'
        }
        {
          name: 'State_commandType_s'
          type: 'string'
        }
        {
          name: 'State_commandTimeout_d'
          type: 'real'
        }
        {
          name: 'State_commandText_s'
          type: 'string'
        }
        {
          name: 'State_elapsed_s'
          type: 'string'
        }
        {
          name: 'State_newLine_s'
          type: 'string'
        }
        {
          name: 'State_error_s'
          type: 'string'
        }
        {
          name: 'State_newline_s'
          type: 'string'
        }
        {
          name: 'State_server_s'
          type: 'string'
        }
        {
          name: 'State_database_s'
          type: 'string'
        }
        {
          name: 'State_version_s'
          type: 'string'
        }
        {
          name: 'State_contextType_s'
          type: 'string'
        }
        {
          name: 'State_provider_s'
          type: 'string'
        }
        {
          name: 'State_options_s'
          type: 'string'
        }
        {
          name: 'State_providerVersion_s'
          type: 'string'
        }
        {
          name: 'State_ConnectionId_s'
          type: 'string'
        }
        {
          name: 'State_TraceIdentifier_s'
          type: 'string'
        }
        {
          name: 'Exception_s'
          type: 'string'
        }
        {
          name: 'stacktrace_s'
          type: 'string'
        }
        {
          name: 'error_s'
          type: 'string'
        }
        {
          name: 'Category'
          type: 'string'
        }
        {
          name: 'State_path_s'
          type: 'string'
        }
        {
          name: 'State_Message_s'
          type: 'string'
        }
        {
          name: 'State__OriginalFormat__s'
          type: 'string'
        }
        {
          name: 'EventId_d'
          type: 'real'
        }
        {
          name: 'Message'
          type: 'string'
        }
        {
          name: 'LogLevel_s'
          type: 'string'
        }
        {
          name: 'State_KeyId_g'
          type: 'guid'
        }
        {
          name: 'State_address_s'
          type: 'string'
        }
        {
          name: 'State_envName_s'
          type: 'string'
        }
        {
          name: 'State_contentRoot_s'
          type: 'string'
        }
        {
          name: 'address_s'
          type: 'string'
        }
        {
          name: 'caller_s'
          type: 'string'
        }
        {
          name: 'msg_s'
          type: 'string'
        }
        {
          name: 'Level'
          type: 'string'
        }
        {
          name: 'ts_d'
          type: 'real'
        }
        {
          name: '_timestamp_d'
          type: 'real'
        }
        {
          name: 'RevisionName_s'
          type: 'string'
        }
        {
          name: 'ContainerGroupId_g'
          type: 'guid'
        }
        {
          name: 'ContainerAppName_s'
          type: 'string'
        }
        {
          name: 'Kind_s'
          type: 'string'
        }
        {
          name: 'Log_s'
          type: 'string'
        }
        {
          name: 'logtag_s'
          type: 'string'
        }
        {
          name: 'ContainerGroupName_s'
          type: 'string'
        }
        {
          name: 'ContainerImage_s'
          type: 'string'
        }
        {
          name: 'ContainerId_s'
          type: 'string'
        }
        {
          name: 'ContainerName_s'
          type: 'string'
        }
        {
          name: 'Stream_s'
          type: 'string'
        }
        {
          name: 'EnvironmentName_s'
          type: 'string'
        }
      ]
      name: 'ContainerAppConsoleLogs_CL'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ContainerRegistryLoginEvents 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ContainerRegistryLoginEvents'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ContainerRegistryLoginEvents'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ContainerRegistryRepositoryEvents 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ContainerRegistryRepositoryEvents'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ContainerRegistryRepositoryEvents'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_CoreAzureBackup 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'CoreAzureBackup'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'CoreAzureBackup'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_DatabricksAccounts 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'DatabricksAccounts'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'DatabricksAccounts'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_DatabricksClusters 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'DatabricksClusters'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'DatabricksClusters'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_DatabricksDBFS 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'DatabricksDBFS'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'DatabricksDBFS'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_DatabricksFeatureStore 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'DatabricksFeatureStore'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'DatabricksFeatureStore'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_DatabricksGenie 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'DatabricksGenie'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'DatabricksGenie'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_DatabricksGlobalInitScripts 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'DatabricksGlobalInitScripts'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'DatabricksGlobalInitScripts'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_DatabricksIAMRole 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'DatabricksIAMRole'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'DatabricksIAMRole'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_DatabricksInstancePools 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'DatabricksInstancePools'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'DatabricksInstancePools'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_DatabricksJobs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'DatabricksJobs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'DatabricksJobs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_DatabricksMLflowAcledArtifact 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'DatabricksMLflowAcledArtifact'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'DatabricksMLflowAcledArtifact'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_DatabricksMLflowExperiment 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'DatabricksMLflowExperiment'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'DatabricksMLflowExperiment'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_DatabricksNotebook 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'DatabricksNotebook'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'DatabricksNotebook'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_DatabricksRemoteHistoryService 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'DatabricksRemoteHistoryService'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'DatabricksRemoteHistoryService'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_DatabricksSecrets 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'DatabricksSecrets'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'DatabricksSecrets'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_DatabricksSQL 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'DatabricksSQL'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'DatabricksSQL'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_DatabricksSQLPermissions 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'DatabricksSQLPermissions'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'DatabricksSQLPermissions'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_DatabricksSSH 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'DatabricksSSH'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'DatabricksSSH'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_DatabricksTables 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'DatabricksTables'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'DatabricksTables'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_DatabricksWorkspace 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'DatabricksWorkspace'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'DatabricksWorkspace'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_DSMAzureBlobStorageLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'DSMAzureBlobStorageLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'DSMAzureBlobStorageLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_DSMDataClassificationLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'DSMDataClassificationLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'DSMDataClassificationLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_DSMDataLabelingLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'DSMDataLabelingLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'DSMDataLabelingLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ETWEvent 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ETWEvent'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ETWEvent'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_Event 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'Event'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'Event'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_FailedIngestion 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'FailedIngestion'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'FailedIngestion'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_FunctionAppLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'FunctionAppLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'FunctionAppLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightAmbariClusterAlerts 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightAmbariClusterAlerts'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightAmbariClusterAlerts'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightAmbariSystemMetrics 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightAmbariSystemMetrics'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightAmbariSystemMetrics'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightGatewayAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightGatewayAuditLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightGatewayAuditLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightHadoopAndYarnLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightHadoopAndYarnLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightHadoopAndYarnLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightHadoopAndYarnMetrics 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightHadoopAndYarnMetrics'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightHadoopAndYarnMetrics'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightHBaseLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightHBaseLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightHBaseLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightHBaseMetrics 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightHBaseMetrics'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightHBaseMetrics'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightHiveAndLLAPLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightHiveAndLLAPLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightHiveAndLLAPLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightHiveAndLLAPMetrics 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightHiveAndLLAPMetrics'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightHiveAndLLAPMetrics'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightHiveQueryAppStats 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightHiveQueryAppStats'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightHiveQueryAppStats'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightHiveTezAppStats 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightHiveTezAppStats'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightHiveTezAppStats'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightJupyterNotebookEvents 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightJupyterNotebookEvents'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightJupyterNotebookEvents'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightKafkaLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightKafkaLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightKafkaLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightKafkaMetrics 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightKafkaMetrics'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightKafkaMetrics'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightOozieLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightOozieLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightOozieLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightRangerAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightRangerAuditLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightRangerAuditLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightSecurityLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightSecurityLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightSecurityLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightSparkApplicationEvents 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightSparkApplicationEvents'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightSparkApplicationEvents'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightSparkBlockManagerEvents 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightSparkBlockManagerEvents'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightSparkBlockManagerEvents'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightSparkEnvironmentEvents 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightSparkEnvironmentEvents'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightSparkEnvironmentEvents'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightSparkExecutorEvents 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightSparkExecutorEvents'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightSparkExecutorEvents'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightSparkExtraEvents 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightSparkExtraEvents'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightSparkExtraEvents'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightSparkJobEvents 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightSparkJobEvents'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightSparkJobEvents'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightSparkLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightSparkLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightSparkLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightSparkSQLExecutionEvents 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightSparkSQLExecutionEvents'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightSparkSQLExecutionEvents'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightSparkStageEvents 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightSparkStageEvents'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightSparkStageEvents'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightSparkStageTaskAccumulables 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightSparkStageTaskAccumulables'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightSparkStageTaskAccumulables'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightSparkTaskEvents 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightSparkTaskEvents'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightSparkTaskEvents'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightStormLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightStormLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightStormLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightStormMetrics 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightStormMetrics'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightStormMetrics'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_HDInsightStormTopologyMetrics 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'HDInsightStormTopologyMetrics'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'HDInsightStormTopologyMetrics'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_Heartbeat 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'Heartbeat'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'Heartbeat'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_InsightsMetrics 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'InsightsMetrics'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'InsightsMetrics'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_IntuneAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'IntuneAuditLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'IntuneAuditLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_IntuneDeviceComplianceOrg 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'IntuneDeviceComplianceOrg'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'IntuneDeviceComplianceOrg'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_IntuneDevices 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'IntuneDevices'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'IntuneDevices'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_IntuneOperationalLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'IntuneOperationalLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'IntuneOperationalLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_LAQueryLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'LAQueryLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'LAQueryLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_MCCEventLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'MCCEventLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'MCCEventLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_MCVPAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'MCVPAuditLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'MCVPAuditLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_MCVPOperationLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'MCVPOperationLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'MCVPOperationLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_MicrosoftAzureBastionAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'MicrosoftAzureBastionAuditLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'MicrosoftAzureBastionAuditLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_MicrosoftDataShareReceivedSnapshotLog 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'MicrosoftDataShareReceivedSnapshotLog'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'MicrosoftDataShareReceivedSnapshotLog'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_MicrosoftDataShareSentSnapshotLog 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'MicrosoftDataShareSentSnapshotLog'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'MicrosoftDataShareSentSnapshotLog'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_MicrosoftDynamicsTelemetryPerformanceLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'MicrosoftDynamicsTelemetryPerformanceLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'MicrosoftDynamicsTelemetryPerformanceLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_MicrosoftDynamicsTelemetrySystemMetricsLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'MicrosoftDynamicsTelemetrySystemMetricsLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'MicrosoftDynamicsTelemetrySystemMetricsLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_MicrosoftHealthcareApisAuditLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'MicrosoftHealthcareApisAuditLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'MicrosoftHealthcareApisAuditLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_NWConnectionMonitorDestinationListenerResult 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'NWConnectionMonitorDestinationListenerResult'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'NWConnectionMonitorDestinationListenerResult'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_NWConnectionMonitorDNSResult 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'NWConnectionMonitorDNSResult'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'NWConnectionMonitorDNSResult'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_NWConnectionMonitorPathResult 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'NWConnectionMonitorPathResult'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'NWConnectionMonitorPathResult'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_NWConnectionMonitorTestResult 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'NWConnectionMonitorTestResult'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'NWConnectionMonitorTestResult'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_OmsCustomerProfileFact 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'OmsCustomerProfileFact'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'OmsCustomerProfileFact'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_Operation 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'Operation'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'Operation'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_Perf 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'Perf'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'Perf'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_PowerBIAuditTenant 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'PowerBIAuditTenant'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'PowerBIAuditTenant'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_PowerBIDatasetsTenant 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'PowerBIDatasetsTenant'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'PowerBIDatasetsTenant'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_PowerBIDatasetsTenantPreview 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'PowerBIDatasetsTenantPreview'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'PowerBIDatasetsTenantPreview'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_PowerBIDatasetsWorkspace 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'PowerBIDatasetsWorkspace'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'PowerBIDatasetsWorkspace'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_PowerBIDatasetsWorkspacePreview 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'PowerBIDatasetsWorkspacePreview'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'PowerBIDatasetsWorkspacePreview'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_PowerBIReportUsageTenant 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'PowerBIReportUsageTenant'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'PowerBIReportUsageTenant'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_PurviewDataSensitivityLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'PurviewDataSensitivityLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'PurviewDataSensitivityLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_PurviewScanStatusLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'PurviewScanStatusLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'PurviewScanStatusLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ReservedCommonFields 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ReservedCommonFields'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ReservedCommonFields'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ResourceManagementPublicAccessLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ResourceManagementPublicAccessLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ResourceManagementPublicAccessLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ServiceFabricOperationalEvent 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ServiceFabricOperationalEvent'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ServiceFabricOperationalEvent'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ServiceFabricReliableActorEvent 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ServiceFabricReliableActorEvent'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ServiceFabricReliableActorEvent'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_ServiceFabricReliableServiceEvent 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'ServiceFabricReliableServiceEvent'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'ServiceFabricReliableServiceEvent'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SignalRServiceDiagnosticLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SignalRServiceDiagnosticLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SignalRServiceDiagnosticLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SigninLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SigninLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SigninLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SQLSecurityAuditEvents 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SQLSecurityAuditEvents'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SQLSecurityAuditEvents'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_StorageBlobLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'StorageBlobLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'StorageBlobLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_StorageFileLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'StorageFileLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'StorageFileLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_StorageQueueLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'StorageQueueLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'StorageQueueLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_StorageTableLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'StorageTableLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'StorageTableLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SucceededIngestion 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SucceededIngestion'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SucceededIngestion'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseBigDataPoolApplicationsEnded 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseBigDataPoolApplicationsEnded'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseBigDataPoolApplicationsEnded'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseBuiltinSqlPoolRequestsEnded 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseBuiltinSqlPoolRequestsEnded'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseBuiltinSqlPoolRequestsEnded'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseDXCommand 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseDXCommand'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseDXCommand'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseDXFailedIngestion 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseDXFailedIngestion'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseDXFailedIngestion'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseDXIngestionBatching 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseDXIngestionBatching'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseDXIngestionBatching'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseDXQuery 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseDXQuery'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseDXQuery'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseDXSucceededIngestion 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseDXSucceededIngestion'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseDXSucceededIngestion'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseDXTableDetails 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseDXTableDetails'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseDXTableDetails'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseDXTableUsageStatistics 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseDXTableUsageStatistics'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseDXTableUsageStatistics'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseGatewayApiRequests 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseGatewayApiRequests'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseGatewayApiRequests'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseGatewayEvents 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseGatewayEvents'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseGatewayEvents'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseIntegrationActivityRuns 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseIntegrationActivityRuns'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseIntegrationActivityRuns'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseIntegrationActivityRunsEnded 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseIntegrationActivityRunsEnded'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseIntegrationActivityRunsEnded'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseIntegrationPipelineRuns 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseIntegrationPipelineRuns'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseIntegrationPipelineRuns'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseIntegrationPipelineRunsEnded 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseIntegrationPipelineRunsEnded'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseIntegrationPipelineRunsEnded'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseIntegrationTriggerRuns 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseIntegrationTriggerRuns'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseIntegrationTriggerRuns'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseIntegrationTriggerRunsEnded 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseIntegrationTriggerRunsEnded'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseIntegrationTriggerRunsEnded'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseRBACEvents 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseRBACEvents'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseRBACEvents'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseRbacOperations 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseRbacOperations'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseRbacOperations'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseScopePoolScopeJobsEnded 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseScopePoolScopeJobsEnded'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseScopePoolScopeJobsEnded'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseScopePoolScopeJobsStateChange 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseScopePoolScopeJobsStateChange'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseScopePoolScopeJobsStateChange'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseSqlPoolDmsWorkers 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseSqlPoolDmsWorkers'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseSqlPoolDmsWorkers'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseSqlPoolExecRequests 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseSqlPoolExecRequests'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseSqlPoolExecRequests'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseSqlPoolRequestSteps 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseSqlPoolRequestSteps'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseSqlPoolRequestSteps'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseSqlPoolSqlRequests 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseSqlPoolSqlRequests'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseSqlPoolSqlRequests'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_SynapseSqlPoolWaits 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'SynapseSqlPoolWaits'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'SynapseSqlPoolWaits'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_Syslog 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'Syslog'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'Syslog'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_TSIIngress 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'TSIIngress'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'TSIIngress'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_Usage 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'Usage'
  properties: {
    plan: 'Analytics'
    retentionInDays: 90
    schema: {
      name: 'Usage'
    }
    totalRetentionInDays: 90
  }
}

resource workspaces_mosaic_prod_logs_name_W3CIISLog 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'W3CIISLog'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'W3CIISLog'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_WebPubSubConnectivity 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'WebPubSubConnectivity'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'WebPubSubConnectivity'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_WebPubSubHttpRequest 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'WebPubSubHttpRequest'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'WebPubSubHttpRequest'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_WebPubSubMessaging 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'WebPubSubMessaging'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'WebPubSubMessaging'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_WorkloadDiagnosticLogs 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'WorkloadDiagnosticLogs'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'WorkloadDiagnosticLogs'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_WVDAgentHealthStatus 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'WVDAgentHealthStatus'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'WVDAgentHealthStatus'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_WVDCheckpoints 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'WVDCheckpoints'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'WVDCheckpoints'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_WVDConnectionNetworkData 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'WVDConnectionNetworkData'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'WVDConnectionNetworkData'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_WVDConnections 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'WVDConnections'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'WVDConnections'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_WVDErrors 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'WVDErrors'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'WVDErrors'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_WVDFeeds 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'WVDFeeds'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'WVDFeeds'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_WVDHostRegistrations 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'WVDHostRegistrations'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'WVDHostRegistrations'
    }
    totalRetentionInDays: 30
  }
}

resource workspaces_mosaic_prod_logs_name_WVDManagement 'Microsoft.OperationalInsights/workspaces/tables@2021-12-01-preview' = {
  parent: workspaces_mosaic_prod_logs_name_resource
  name: 'WVDManagement'
  properties: {
    plan: 'Analytics'
    retentionInDays: 30
    schema: {
      name: 'WVDManagement'
    }
    totalRetentionInDays: 30
  }
}

resource namespaces_mosaic_prod_name_RootManageSharedAccessKey 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2021-06-01-preview' = {
  parent: namespaces_mosaic_prod_name_resource
  location: 'East US'
  name: 'RootManageSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource namespaces_mosaic_prod_name_default 'Microsoft.ServiceBus/namespaces/networkRuleSets@2021-06-01-preview' = {
  parent: namespaces_mosaic_prod_name_resource
  location: 'East US'
  name: 'default'
  properties: {
    defaultAction: 'Allow'
    ipRules: []
    publicNetworkAccess: 'Enabled'
    virtualNetworkRules: []
  }
}

resource namespaces_mosaic_prod_name_tilecreatedevent 'Microsoft.ServiceBus/namespaces/topics@2021-06-01-preview' = {
  parent: namespaces_mosaic_prod_name_resource
  location: 'East US'
  name: 'tilecreatedevent'
  properties: {
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    defaultMessageTimeToLive: 'P10675199DT2H48M5.4775807S'
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    enableBatchedOperations: true
    enableExpress: false
    enablePartitioning: false
    maxMessageSizeInKilobytes: 51200
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    status: 'Active'
    supportOrdering: true
  }
}

resource namespaces_mosaic_prod_name_tileupdatedevent 'Microsoft.ServiceBus/namespaces/topics@2021-06-01-preview' = {
  parent: namespaces_mosaic_prod_name_resource
  location: 'East US'
  name: 'tileupdatedevent'
  properties: {
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    defaultMessageTimeToLive: 'P10675199DT2H48M5.4775807S'
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    enableBatchedOperations: true
    enableExpress: false
    enablePartitioning: false
    maxMessageSizeInKilobytes: 51200
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    status: 'Active'
    supportOrdering: true
  }
}

resource servers_mosaic_tiles_sqlsrv_name_CreateIndex 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: servers_mosaic_tiles_sqlsrv_name_resource
  name: 'CreateIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
}

resource servers_mosaic_tiles_sqlsrv_name_DbParameterization 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: servers_mosaic_tiles_sqlsrv_name_resource
  name: 'DbParameterization'
  properties: {
    autoExecuteValue: 'Disabled'
  }
}

resource servers_mosaic_tiles_sqlsrv_name_DefragmentIndex 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: servers_mosaic_tiles_sqlsrv_name_resource
  name: 'DefragmentIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
}

resource servers_mosaic_tiles_sqlsrv_name_DropIndex 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: servers_mosaic_tiles_sqlsrv_name_resource
  name: 'DropIndex'
  properties: {
    autoExecuteValue: 'Disabled'
  }
}

resource servers_mosaic_tiles_sqlsrv_name_ForceLastGoodPlan 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: servers_mosaic_tiles_sqlsrv_name_resource
  name: 'ForceLastGoodPlan'
  properties: {
    autoExecuteValue: 'Enabled'
  }
}

resource servers_mosaic_tiles_sqlsrv_name_Default 'Microsoft.Sql/servers/auditingPolicies@2014-04-01' = {
  parent: servers_mosaic_tiles_sqlsrv_name_resource
  location: 'East US'
  name: 'default'
  properties: {
    auditingState: 'Disabled'
  }
}

resource Microsoft_Sql_servers_auditingSettings_servers_mosaic_tiles_sqlsrv_name_Default 'Microsoft.Sql/servers/auditingSettings@2021-08-01-preview' = {
  parent: servers_mosaic_tiles_sqlsrv_name_resource
  name: 'default'
  properties: {
    auditActionsAndGroups: []
    isAzureMonitorTargetEnabled: false
    isStorageSecondaryKeyInUse: false
    retentionDays: 0
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
}

resource Microsoft_Sql_servers_connectionPolicies_servers_mosaic_tiles_sqlsrv_name_default 'Microsoft.Sql/servers/connectionPolicies@2021-08-01-preview' = {
  parent: servers_mosaic_tiles_sqlsrv_name_resource
  location: 'eastus'
  name: 'default'
  properties: {
    connectionType: 'Default'
  }
}

resource servers_mosaic_tiles_sqlsrv_name_mosaic_tilesdb_prod 'Microsoft.Sql/servers/databases@2021-08-01-preview' = {
  parent: servers_mosaic_tiles_sqlsrv_name_resource
  kind: 'v12.0,user,vcore,serverless'
  location: 'eastus'
  name: 'mosaic-tilesdb-prod'
  properties: {
    autoPauseDelay: 60
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    isLedgerOn: false
    maintenanceConfigurationId: '/subscriptions/55752c87-0222-4dba-a9be-1ce35cade464/providers/Microsoft.Maintenance/publicMaintenanceConfigurations/SQL_Default'
    maxSizeBytes: 2147483648
    minCapacity: '0.5'
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Local'
    zoneRedundant: false
  }
  sku: {
    capacity: 1
    family: 'Gen5'
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
  }
}

resource servers_mosaic_tiles_sqlsrv_name_master_Default 'Microsoft.Sql/servers/databases/auditingPolicies@2014-04-01' = {
  location: 'East US'
  name: '${servers_mosaic_tiles_sqlsrv_name}/master/Default'
  properties: {
    auditingState: 'Disabled'
  }
  dependsOn: [
    servers_mosaic_tiles_sqlsrv_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_auditingSettings_servers_mosaic_tiles_sqlsrv_name_master_Default 'Microsoft.Sql/servers/databases/auditingSettings@2021-08-01-preview' = {
  name: '${servers_mosaic_tiles_sqlsrv_name}/master/Default'
  properties: {
    isAzureMonitorTargetEnabled: false
    retentionDays: 0
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
  dependsOn: [
    servers_mosaic_tiles_sqlsrv_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_extendedAuditingSettings_servers_mosaic_tiles_sqlsrv_name_master_Default 'Microsoft.Sql/servers/databases/extendedAuditingSettings@2021-08-01-preview' = {
  name: '${servers_mosaic_tiles_sqlsrv_name}/master/Default'
  properties: {
    isAzureMonitorTargetEnabled: false
    retentionDays: 0
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
  dependsOn: [
    servers_mosaic_tiles_sqlsrv_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_geoBackupPolicies_servers_mosaic_tiles_sqlsrv_name_master_Default 'Microsoft.Sql/servers/databases/geoBackupPolicies@2014-04-01' = {
  location: 'East US'
  name: '${servers_mosaic_tiles_sqlsrv_name}/master/Default'
  properties: {
    state: 'Disabled'
  }
  dependsOn: [
    servers_mosaic_tiles_sqlsrv_name_resource
  ]
}

resource servers_mosaic_tiles_sqlsrv_name_master_Current 'Microsoft.Sql/servers/databases/ledgerDigestUploads@2021-08-01-preview' = {
  name: '${servers_mosaic_tiles_sqlsrv_name}/master/Current'
  properties: {}
  dependsOn: [
    servers_mosaic_tiles_sqlsrv_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_securityAlertPolicies_servers_mosaic_tiles_sqlsrv_name_master_Default 'Microsoft.Sql/servers/databases/securityAlertPolicies@2021-08-01-preview' = {
  name: '${servers_mosaic_tiles_sqlsrv_name}/master/Default'
  properties: {
    disabledAlerts: [
      ''
    ]
    emailAccountAdmins: false
    emailAddresses: [
      ''
    ]
    retentionDays: 0
    state: 'Disabled'
  }
  dependsOn: [
    servers_mosaic_tiles_sqlsrv_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_transparentDataEncryption_servers_mosaic_tiles_sqlsrv_name_master_Current 'Microsoft.Sql/servers/databases/transparentDataEncryption@2021-08-01-preview' = {
  name: '${servers_mosaic_tiles_sqlsrv_name}/master/Current'
  properties: {
    state: 'Disabled'
  }
  dependsOn: [
    servers_mosaic_tiles_sqlsrv_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_vulnerabilityAssessments_servers_mosaic_tiles_sqlsrv_name_master_Default 'Microsoft.Sql/servers/databases/vulnerabilityAssessments@2021-08-01-preview' = {
  name: '${servers_mosaic_tiles_sqlsrv_name}/master/Default'
  properties: {
    recurringScans: {
      emailSubscriptionAdmins: true
      isEnabled: false
    }
  }
  dependsOn: [
    servers_mosaic_tiles_sqlsrv_name_resource
  ]
}

resource Microsoft_Sql_servers_devOpsAuditingSettings_servers_mosaic_tiles_sqlsrv_name_Default 'Microsoft.Sql/servers/devOpsAuditingSettings@2021-08-01-preview' = {
  parent: servers_mosaic_tiles_sqlsrv_name_resource
  name: 'Default'
  properties: {
    isAzureMonitorTargetEnabled: false
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
}

resource servers_mosaic_tiles_sqlsrv_name_current 'Microsoft.Sql/servers/encryptionProtector@2021-08-01-preview' = {
  parent: servers_mosaic_tiles_sqlsrv_name_resource
  kind: 'servicemanaged'
  name: 'current'
  properties: {
    autoRotationEnabled: false
    serverKeyName: 'ServiceManaged'
    serverKeyType: 'ServiceManaged'
  }
}

resource Microsoft_Sql_servers_extendedAuditingSettings_servers_mosaic_tiles_sqlsrv_name_Default 'Microsoft.Sql/servers/extendedAuditingSettings@2021-08-01-preview' = {
  parent: servers_mosaic_tiles_sqlsrv_name_resource
  name: 'default'
  properties: {
    auditActionsAndGroups: []
    isAzureMonitorTargetEnabled: false
    isStorageSecondaryKeyInUse: false
    retentionDays: 0
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
}

resource servers_mosaic_tiles_sqlsrv_name_ap_env 'Microsoft.Sql/servers/firewallRules@2021-08-01-preview' = {
  parent: servers_mosaic_tiles_sqlsrv_name_resource
  name: 'ap env'
  properties: {
    endIpAddress: '20.83.130.168'
    startIpAddress: '20.83.130.168'
  }
}

resource servers_mosaic_tiles_sqlsrv_name_container_app_env 'Microsoft.Sql/servers/firewallRules@2021-08-01-preview' = {
  parent: servers_mosaic_tiles_sqlsrv_name_resource
  name: 'container app env'
  properties: {
    endIpAddress: '40.71.86.11'
    startIpAddress: '40.71.86.11'
  }
}

resource servers_mosaic_tiles_sqlsrv_name_home 'Microsoft.Sql/servers/firewallRules@2021-08-01-preview' = {
  parent: servers_mosaic_tiles_sqlsrv_name_resource
  name: 'home'
  properties: {
    endIpAddress: '108.235.162.248'
    startIpAddress: '108.235.162.248'
  }
}

resource servers_mosaic_tiles_sqlsrv_name_query_editor_fe4aaf 'Microsoft.Sql/servers/firewallRules@2021-08-01-preview' = {
  parent: servers_mosaic_tiles_sqlsrv_name_resource
  name: 'query-editor-fe4aaf'
  properties: {
    endIpAddress: '157.58.213.115'
    startIpAddress: '157.58.213.115'
  }
}

resource servers_mosaic_tiles_sqlsrv_name_tmp 'Microsoft.Sql/servers/firewallRules@2021-08-01-preview' = {
  parent: servers_mosaic_tiles_sqlsrv_name_resource
  name: 'tmp'
  properties: {
    endIpAddress: '157.58.212.115'
    startIpAddress: '157.58.212.115'
  }
}

resource servers_mosaic_tiles_sqlsrv_name_ServiceManaged 'Microsoft.Sql/servers/keys@2021-08-01-preview' = {
  parent: servers_mosaic_tiles_sqlsrv_name_resource
  kind: 'servicemanaged'
  name: 'ServiceManaged'
  properties: {
    serverKeyType: 'ServiceManaged'
  }
}

resource Microsoft_Sql_servers_securityAlertPolicies_servers_mosaic_tiles_sqlsrv_name_Default 'Microsoft.Sql/servers/securityAlertPolicies@2021-08-01-preview' = {
  parent: servers_mosaic_tiles_sqlsrv_name_resource
  name: 'Default'
  properties: {
    disabledAlerts: [
      ''
    ]
    emailAccountAdmins: false
    emailAddresses: [
      ''
    ]
    retentionDays: 0
    state: 'Enabled'
  }
}

resource Microsoft_Sql_servers_vulnerabilityAssessments_servers_mosaic_tiles_sqlsrv_name_Default 'Microsoft.Sql/servers/vulnerabilityAssessments@2021-08-01-preview' = {
  parent: servers_mosaic_tiles_sqlsrv_name_resource
  name: 'default'
  properties: {
    recurringScans: {
      emailSubscriptionAdmins: true
      isEnabled: false
    }
    storageContainerPath: vulnerabilityAssessments_Default_storageContainerPath
  }
}

resource storageAccounts_mosaicstorageprod_name_default 'Microsoft.Storage/storageAccounts/blobServices@2021-08-01' = {
  parent: storageAccounts_mosaicstorageprod_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: false
    }
  }
  sku: {
    name: 'Standard_RAGRS'
    tier: 'Standard'
  }
}

resource Microsoft_Storage_storageAccounts_fileServices_storageAccounts_mosaicstorageprod_name_default 'Microsoft.Storage/storageAccounts/fileServices@2021-08-01' = {
  parent: storageAccounts_mosaicstorageprod_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    protocolSettings: {
      smb: {}
    }
    shareDeleteRetentionPolicy: {
      days: 7
      enabled: true
    }
  }
  sku: {
    name: 'Standard_RAGRS'
    tier: 'Standard'
  }
}

resource Microsoft_Storage_storageAccounts_queueServices_storageAccounts_mosaicstorageprod_name_default 'Microsoft.Storage/storageAccounts/queueServices@2021-08-01' = {
  parent: storageAccounts_mosaicstorageprod_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_tableServices_storageAccounts_mosaicstorageprod_name_default 'Microsoft.Storage/storageAccounts/tableServices@2021-08-01' = {
  parent: storageAccounts_mosaicstorageprod_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource containerApps_mosaic_frontend_name_resource 'Microsoft.Web/containerApps@2021-03-01' = {
  location: 'East US'
  name: containerApps_mosaic_frontend_name
  properties: {
    configuration: {
      activeRevisionsMode: 'multiple'
      ingress: {
        allowInsecure: false
        external: true
        targetPort: 80
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
        transport: 'auto'
      }
      secrets: [
        {
          name: 'tilesdbcontext'
        }
      ]
    }
    kubeEnvironmentId: kubeenvironments_mosaic_app_environment_name_resource.id
    template: {
      containers: [
        {
          image: 'mosaicprod.azurecr.io/mosaicfrontend:latest'
          name: 'frontend'
          resources: {
            cpu: '0.5'
            memory: '1Gi'
          }
        }
      ]
      dapr: {
        appId: 'frontend'
        appPort: 80
        components: [
          {
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
            name: 'tilestorage'
            type: 'bindings.azure.blobstorage'
            version: 'v1'
          }
          {
            metadata: [
              {
                name: 'connectionString'
                value: 'Endpoint=sb://mosaic-prod.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=Nq28LoE9145WLFJX5bJJ73wSYSElNw7ITU/bSU0CKdU='
              }
            ]
            name: 'pubsub'
            type: 'pubsub.azure.servicebus'
            version: 'v1'
          }
        ]
        enabled: true
      }
      scale: {
        maxReplicas: 1
        minReplicas: 1
      }
    }
  }
}

resource containerApps_mosaic_tileprocessor_name_resource 'Microsoft.Web/containerApps@2021-03-01' = {
  location: 'East US'
  name: containerApps_mosaic_tileprocessor_name
  properties: {
    configuration: {
      activeRevisionsMode: 'multiple'
      ingress: {
        allowInsecure: false
        external: true
        targetPort: 80
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
        transport: 'auto'
      }
    }
    kubeEnvironmentId: kubeenvironments_mosaic_app_environment_name_resource.id
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
      dapr: {
        appId: 'tileprocessor'
        appPort: 80
        components: [
          {
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
            name: 'tilestorage'
            type: 'bindings.azure.blobstorage'
            version: 'v1'
          }
          {
            metadata: [
              {
                name: 'connectionString'
                value: 'Endpoint=sb://mosaic-prod.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=Nq28LoE9145WLFJX5bJJ73wSYSElNw7ITU/bSU0CKdU='
              }
            ]
            name: 'pubsub'
            type: 'pubsub.azure.servicebus'
            version: 'v1'
          }
        ]
        enabled: true
      }
      scale: {
        maxReplicas: 1
        minReplicas: 1
      }
    }
  }
}

resource containerApps_mosaic_tilesapi_name_resource 'Microsoft.Web/containerApps@2021-03-01' = {
  location: 'East US'
  name: containerApps_mosaic_tilesapi_name
  properties: {
    configuration: {
      activeRevisionsMode: 'multiple'
      ingress: {
        allowInsecure: false
        external: true
        targetPort: 80
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
        transport: 'auto'
      }
      secrets: [
        {
          name: 'tilesdbcontext'
        }
      ]
    }
    kubeEnvironmentId: kubeenvironments_mosaic_app_environment_name_resource.id
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
      dapr: {
        appId: 'tilesapi'
        appPort: 80
        components: [
          {
            metadata: [
              {
                name: 'connectionString'
                value: 'Endpoint=sb://mosaic-prod.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=Nq28LoE9145WLFJX5bJJ73wSYSElNw7ITU/bSU0CKdU='
              }
            ]
            name: 'pubsub'
            type: 'pubsub.azure.servicebus'
            version: 'v1'
          }
        ]
        enabled: true
      }
      scale: {
        maxReplicas: 1
        minReplicas: 1
      }
    }
  }
}

resource namespaces_mosaic_prod_name_tilecreatedevent_tileprocessor 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2021-06-01-preview' = {
  parent: namespaces_mosaic_prod_name_tilecreatedevent
  location: 'East US'
  name: 'tileprocessor'
  properties: {
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    deadLetteringOnFilterEvaluationExceptions: true
    deadLetteringOnMessageExpiration: false
    defaultMessageTimeToLive: 'P10675199DT2H48M5.4775807S'
    enableBatchedOperations: true
    isClientAffine: false
    lockDuration: 'PT1M'
    maxDeliveryCount: 10
    requiresSession: false
    status: 'Active'
  }
  dependsOn: [
    namespaces_mosaic_prod_name_resource
  ]
}

resource servers_mosaic_tiles_sqlsrv_name_mosaic_tilesdb_prod_Default 'Microsoft.Sql/servers/databases/auditingPolicies@2014-04-01' = {
  parent: servers_mosaic_tiles_sqlsrv_name_mosaic_tilesdb_prod
  location: 'East US'
  name: 'default'
  properties: {
    auditingState: 'Disabled'
  }
  dependsOn: [
    servers_mosaic_tiles_sqlsrv_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_auditingSettings_servers_mosaic_tiles_sqlsrv_name_mosaic_tilesdb_prod_Default 'Microsoft.Sql/servers/databases/auditingSettings@2021-08-01-preview' = {
  parent: servers_mosaic_tiles_sqlsrv_name_mosaic_tilesdb_prod
  name: 'default'
  properties: {
    isAzureMonitorTargetEnabled: false
    retentionDays: 0
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
  dependsOn: [
    servers_mosaic_tiles_sqlsrv_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_backupLongTermRetentionPolicies_servers_mosaic_tiles_sqlsrv_name_mosaic_tilesdb_prod_default 'Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies@2021-08-01-preview' = {
  parent: servers_mosaic_tiles_sqlsrv_name_mosaic_tilesdb_prod
  name: 'default'
  properties: {
    monthlyRetention: 'PT0S'
    weekOfYear: 0
    weeklyRetention: 'PT0S'
    yearlyRetention: 'PT0S'
  }
  dependsOn: [
    servers_mosaic_tiles_sqlsrv_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_backupShortTermRetentionPolicies_servers_mosaic_tiles_sqlsrv_name_mosaic_tilesdb_prod_default 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2021-08-01-preview' = {
  parent: servers_mosaic_tiles_sqlsrv_name_mosaic_tilesdb_prod
  name: 'default'
  properties: {
    diffBackupIntervalInHours: 12
    retentionDays: 7
  }
  dependsOn: [
    servers_mosaic_tiles_sqlsrv_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_extendedAuditingSettings_servers_mosaic_tiles_sqlsrv_name_mosaic_tilesdb_prod_Default 'Microsoft.Sql/servers/databases/extendedAuditingSettings@2021-08-01-preview' = {
  parent: servers_mosaic_tiles_sqlsrv_name_mosaic_tilesdb_prod
  name: 'default'
  properties: {
    isAzureMonitorTargetEnabled: false
    retentionDays: 0
    state: 'Disabled'
    storageAccountSubscriptionId: '00000000-0000-0000-0000-000000000000'
  }
  dependsOn: [
    servers_mosaic_tiles_sqlsrv_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_geoBackupPolicies_servers_mosaic_tiles_sqlsrv_name_mosaic_tilesdb_prod_Default 'Microsoft.Sql/servers/databases/geoBackupPolicies@2014-04-01' = {
  parent: servers_mosaic_tiles_sqlsrv_name_mosaic_tilesdb_prod
  location: 'East US'
  name: 'Default'
  properties: {
    state: 'Disabled'
  }
  dependsOn: [
    servers_mosaic_tiles_sqlsrv_name_resource
  ]
}

resource servers_mosaic_tiles_sqlsrv_name_mosaic_tilesdb_prod_Current 'Microsoft.Sql/servers/databases/ledgerDigestUploads@2021-08-01-preview' = {
  parent: servers_mosaic_tiles_sqlsrv_name_mosaic_tilesdb_prod
  name: 'current'
  properties: {}
  dependsOn: [
    servers_mosaic_tiles_sqlsrv_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_securityAlertPolicies_servers_mosaic_tiles_sqlsrv_name_mosaic_tilesdb_prod_Default 'Microsoft.Sql/servers/databases/securityAlertPolicies@2021-08-01-preview' = {
  parent: servers_mosaic_tiles_sqlsrv_name_mosaic_tilesdb_prod
  name: 'default'
  properties: {
    disabledAlerts: [
      ''
    ]
    emailAccountAdmins: false
    emailAddresses: [
      ''
    ]
    retentionDays: 0
    state: 'Disabled'
  }
  dependsOn: [
    servers_mosaic_tiles_sqlsrv_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_transparentDataEncryption_servers_mosaic_tiles_sqlsrv_name_mosaic_tilesdb_prod_Current 'Microsoft.Sql/servers/databases/transparentDataEncryption@2021-08-01-preview' = {
  parent: servers_mosaic_tiles_sqlsrv_name_mosaic_tilesdb_prod
  name: 'current'
  properties: {
    state: 'Enabled'
  }
  dependsOn: [
    servers_mosaic_tiles_sqlsrv_name_resource
  ]
}

resource Microsoft_Sql_servers_databases_vulnerabilityAssessments_servers_mosaic_tiles_sqlsrv_name_mosaic_tilesdb_prod_Default 'Microsoft.Sql/servers/databases/vulnerabilityAssessments@2021-08-01-preview' = {
  parent: servers_mosaic_tiles_sqlsrv_name_mosaic_tilesdb_prod
  name: 'default'
  properties: {
    recurringScans: {
      emailSubscriptionAdmins: true
      isEnabled: false
    }
  }
  dependsOn: [
    servers_mosaic_tiles_sqlsrv_name_resource
  ]
}

resource storageAccounts_mosaicstorageprod_name_default_daprstate 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = {
  parent: storageAccounts_mosaicstorageprod_name_default
  name: 'daprstate'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    immutableStorageWithVersioning: {
      enabled: false
    }
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_mosaicstorageprod_name_resource
  ]
}

resource storageAccounts_mosaicstorageprod_name_default_mycontainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = {
  parent: storageAccounts_mosaicstorageprod_name_default
  name: 'mycontainer'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    immutableStorageWithVersioning: {
      enabled: false
    }
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_mosaicstorageprod_name_resource
  ]
}

resource storageAccounts_mosaicstorageprod_name_default_tiles 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = {
  parent: storageAccounts_mosaicstorageprod_name_default
  name: 'tiles'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    immutableStorageWithVersioning: {
      enabled: false
    }
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_mosaicstorageprod_name_resource
  ]
}

resource namespaces_mosaic_prod_name_tilecreatedevent_tileprocessor_Default 'Microsoft.ServiceBus/namespaces/topics/subscriptions/rules@2021-06-01-preview' = {
  parent: namespaces_mosaic_prod_name_tilecreatedevent_tileprocessor
  location: 'East US'
  name: '$Default'
  properties: {
    action: {}
    filterType: 'SqlFilter'
    sqlFilter: {
      compatibilityLevel: 20
      sqlExpression: '1=1'
    }
  }
  dependsOn: [
    namespaces_mosaic_prod_name_tilecreatedevent
    namespaces_mosaic_prod_name_resource
  ]
}