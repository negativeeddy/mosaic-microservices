Param(
    [string] $RESOURCE_GROUP = 'mosaic-prod',
    [string] $CONTAINERAPPS_ENVIRONMENT = 'mosaic-app-environment',
    [string] $LOCATION="eastus",
    [string] $LOG_ANALYTICS_WORKSPACE="mosaic-prod-logs"
)

az deployment group create `
  --resource-group "$RESOURCE_GROUP" `
  --template-file ./mosaic-tileprocessor.bicep `
  --parameters `
      environment_name="$CONTAINERAPPS_ENVIRONMENT" `
      location="$LOCATION"