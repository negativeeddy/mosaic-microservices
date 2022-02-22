Param(
    [string] $RESOURCE_GROUP = 'mosaic-prod',
    [string] $CONTAINERAPPS_ENVIRONMENT = 'mosaic-app-environment',
    [string] $LOCATION="eastus",
    [string] $LOG_ANALYTICS_WORKSPACE="mosaic-prod-logs"
)


# $LOG_ANALYTICS_WORKSPACE_CLIENT_ID=(az monitor log-analytics workspace show --query customerId -g $RESOURCE_GROUP -n $LOG_ANALYTICS_WORKSPACE --out tsv)
# $LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET=(az monitor log-analytics workspace get-shared-keys --query primarySharedKey -g $RESOURCE_GROUP -n $LOG_ANALYTICS_WORKSPACE --out tsv)

# az containerapp env create `
#   --name $CONTAINERAPPS_ENVIRONMENT `
#   --resource-group $RESOURCE_GROUP `
#   --logs-workspace-id $LOG_ANALYTICS_WORKSPACE_CLIENT_ID `
#   --logs-workspace-key $LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET `
#   --location "$LOCATION"

# $params = @{
#   environment_name = $CONTAINERAPPS_ENVIRONMENT
#   location = $LOCATION
# }

# New-AzResourceGroupDeployment `
#   -ResourceGroupName $RESOURCE_GROUP `
#   -TemplateParameterObject $params `
#   -TemplateFile ./tilesapi.bicep `
#   -SkipTemplateParameterPrompt

az deployment group create `
  --resource-group "$RESOURCE_GROUP" `
  --template-file ./mosaic-tilesapi.bicep `
  --parameters `
      environment_name="$CONTAINERAPPS_ENVIRONMENT" `
      location="$LOCATION"

# az containerapp create `
#   --name $APP_NAME `
#   --location "$LOCATION" `
#   --resource-group $RESOURCE_GROUP `
#   --environment $CONTAINERAPPS_ENVIRONMENT `
#   --image $IMAGE_NAME `
#   --ingress 'external' `
#   --target-port 80 `
#   --min-replicas 1 `
#   --max-replicas 1 `
#   --enable-dapr true `
#   --dapr-app-port 80 `
#   --dapr-app-id "$APP_NAME" `
#   --dapr-components ./components.yaml
  #--secrets "storage-account-name=${STORAGE_ACCOUNT},storage-account-key=${STORAGE_ACCOUNT_KEY}" `