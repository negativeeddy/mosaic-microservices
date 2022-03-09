Param(
  [Parameter(Mandatory = $true)]
  [string] $STAGE,
  [string] $RESOURCE_GROUP_BASE = "mosaic",
  [string] $APPNAME_BASE = "mosaic",
  [string] $LOCATION = "eastus",
  [string] $TILE_DB_CONNECTIONSTRING,
  [string] $FLICKR_API_KEY
)

$RESOURCE_GROUP_NAME = "$APPNAME_BASE-rg-$STAGE"
$CONTAINERAPPS_ENVIRONMENT_NAME = "${APPNAME_BASE}-env-${STAGE}"
$LOG_ANALYTICS_WORKSPACE_NAME = "${APPNAME_BASE}-logs-${STAGE}"
$APP_INSIGHTS_NAME = "${APPNAME_BASE}-appinsights-${STAGE}"
$STORAGE_ACCOUNT_NAME = "${APPNAME_BASE}stg${STAGE}"

$FRONTEND_NAME = "frontend"
$FRONTEND_CONTAINERAPP_NAME = "$APPNAME_BASE-$FRONTEND_NAME-$STAGE"

$TILESAPI_NAME = "tilesapi"
$TILESAPI_CONTAINERAPP_NAME = "$APPNAME_BASE-$TILESAPI_NAME-$STAGE"

$TILEPROCESSOR_NAME = "tileprocessor"
$TILEPROCESSOR_CONTAINERAPP_NAME = "$APPNAME_BASE-$TILEPROCESSOR_NAME-$STAGE"


Write-Output "setting up resource group $RESOURCE_GROUP_NAME" 
$RESOURCE_GROUP = az group create `
  --name $RESOURCE_GROUP_NAME `
  --location $LOCATION `
  | ConvertFrom-Json
Write-Output $RESOURCE_GROUP.ID

# Create an environment
Write-Output "setting up log analytics" 
$LOG_ANALYTICS_WORKSPACE = az monitor log-analytics workspace create `
  --resource-group $RESOURCE_GROUP_NAME `
  --workspace-name $LOG_ANALYTICS_WORKSPACE_NAME `
  | ConvertFrom-Json
Write-Output $LOG_ANALYTICS_WORKSPACE.ID

# retrieve the Log Analytics Client ID and client secret
$LOG_ANALYTICS_WORKSPACE_CLIENT_ID = (az monitor log-analytics workspace show --query customerId -g $RESOURCE_GROUP_NAME -n $LOG_ANALYTICS_WORKSPACE_NAME --out tsv)
$LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET = (az monitor log-analytics workspace get-shared-keys --query primarySharedKey -g $RESOURCE_GROUP_NAME -n $LOG_ANALYTICS_WORKSPACE_NAME --out tsv)

# create app insights component
Write-Output "creating app insights component"
$APP_INSIGHTS = az monitor app-insights component create `
  --app $APP_INSIGHTS_NAME `
  --location $LOCATION `
  --resource-group $RESOURCE_GROUP_NAME `
  --workspace $LOG_ANALYTICS_WORKSPACE_NAME `
  | ConvertFrom-Json

# create the environment
Write-Output "setting up container app environment" 

$CONTAINER_APP_ENVIRONMENT = az containerapp env create `
  --name $CONTAINERAPPS_ENVIRONMENT_NAME `
  --resource-group $RESOURCE_GROUP_NAME `
  --logs-workspace-id $LOG_ANALYTICS_WORKSPACE_CLIENT_ID `
  --logs-workspace-key $LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET `
  --location $LOCATION `
  --instrumentation-key $APP_INSIGHTS.instrumentationKey `
  | ConvertFrom-Json

write-output $CONTAINER_APP_ENVIRONMENT.ID

Write-Output 'setting up hosted tile storage'
$STORAGE_ACCOUNT = az storage account create `
  --name $STORAGE_ACCOUNT_NAME `
  --resource-group $RESOURCE_GROUP_NAME `
  --location $LOCATION `
  --sku Standard_LRS `
  --kind StorageV2 `
  | ConvertFrom-Json

$STORAGE_ACCOUNT_KEY = az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' --out tsv

$RESULT = az storage container create --name tiles --account-name $STORAGE_ACCOUNT_NAME --account-key $STORAGE_ACCOUNT_KEY
Write-Output $STORAGE_ACCOUNT.ID

Write-Output "setting up Azure Service Bus"

$SERVICEBUS_NAME = "$APPNAME_BASE-sb-$STAGE"
$SERVICEBUS = az servicebus namespace create --resource-group $RESOURCE_GROUP_NAME --name $SERVICEBUS_NAME `
        --location $LOCATION --sku Standard  | ConvertFrom-Json

$SERVICEBUS_CONNECTIONSTRING = az servicebus namespace authorization-rule keys list --resource-group $RESOURCE_GROUP_NAME  --namespace-name $SERVICEBUS_NAME --name RootManageSharedAccessKey --query 'primaryConnectionString'
Write-Output $SERVICEBUS.ID

Write-Output "Creating container app $APPNAME_BASE-$FRONTEND_NAME-$STAGE"

$FRONTEND_APP = `
  az containerapp create `
  --name $FRONTEND_CONTAINERAPP_NAME `
  --location $LOCATION `
  --resource-group $RESOURCE_GROUP_NAME `
  --environment $CONTAINERAPPS_ENVIRONMENT_NAME `
  --image mosaicprod.azurecr.io/mosaic/frontend:latest `
  --ingress external `
  --target-port 80 `
  --min-replicas 1 `
  --max-replicas 1 `
  --enable-dapr true `
  --dapr-app-port 80 `
  --dapr-app-id $FRONTEND_NAME `
  --dapr-components './frontend-components.yaml' `
  --secrets "storage-account-name=${STORAGE_ACCOUNT_NAME},storage-account-key=${STORAGE_ACCOUNT_KEY},flickr-api-key=${FLICKR_API_KEY}" `
  --environment-variables "flickr__apiKey=secretref:flickr-api-key" `
    | ConvertFrom-Json
  
  Write-Output $FRONTEND_APP.ID
  Write-Output $TILESAPI_APP.configuration.ingress.fqdn
  
  Write-Output "Creating container app $TILESAPI_CONTAINERAPP_NAME"
    
  $TILESAPI_APP = az containerapp create `
  --name $TILESAPI_CONTAINERAPP_NAME `
  --location $LOCATION `
  --resource-group $RESOURCE_GROUP_NAME `
  --environment $CONTAINERAPPS_ENVIRONMENT_NAME `
  --image mosaicprod.azurecr.io/mosaic/tilesapi:latest `
  --ingress external `
  --target-port 80 `
  --min-replicas 1 `
  --max-replicas 1 `
  --enable-dapr true `
  --dapr-app-port 80 `
  --dapr-app-id $TILESAPI_NAME `
  --dapr-components './tilesapi-components.yaml' `
  --secrets "servicebusconnectionstring=$SERVICEBUS_CONNECTIONSTRING,tiledbconnectionstring=$TILE_DB_CONNECTIONSTRING" `
  --environment-variables "tiledbconnectionstring=secretref:tiledbconnectionstring" `
  | ConvertFrom-Json
Write-Output $TILESAPI_APP.ID
Write-Output $TILESAPI_APP.configuration.ingress.fqdn

Write-Output "Creating container app $TILEPROCESSOR_CONTAINERAPP_NAME"
$TILEPROCESSOR_APP = az containerapp create `
  --name $TILEPROCESSOR_CONTAINERAPP_NAME `
  --location $LOCATION `
  --resource-group $RESOURCE_GROUP_NAME `
  --environment $CONTAINERAPPS_ENVIRONMENT_NAME `
  --image mosaicprod.azurecr.io/mosaic/tileprocessor:latest `
  --ingress external `
  --target-port 80 `
  --min-replicas 1 `
  --max-replicas 1 `
  --enable-dapr true `
  --dapr-app-port 80 `
  --dapr-app-id $TILEPROCESSOR_NAME `
  --dapr-components './tileprocessor-components.yaml' `
  --secrets "servicebusconnectionstring=$SERVICEBUS_CONNECTIONSTRING,storage-account-name=${STORAGE_ACCOUNT_NAME},storage-account-key=${STORAGE_ACCOUNT_KEY}" `
  | ConvertFrom-Json

Write-Output $TILEPROCESSOR_APP.ID