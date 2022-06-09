Param(
  [Parameter(Mandatory = $true)]
  [string] $STAGE,
  [string] $RESOURCE_GROUP_BASE = "mosaic",
  [string] $APPNAME_BASE = "mosaic",
  [string] $LOCATION = "eastus",
  [string] $TILE_DB_CONNECTIONSTRING,
  [string] $FLICKR_API_KEY
)

$RESOURCE_GROUP_NAME = "$RESOURCE_GROUP_BASE-rg-$STAGE"
$DEPLOYMENT_NAME = "$APPNAME_BASE-$STAGE"

az group create -n $RESOURCE_GROUP_NAME -l $LOCATION

az deployment group create -n $DEPLOYMENT_NAME -g $RESOURCE_GROUP_NAME  -f ./bicep/main.bicep --parameters uniqueSuffix=$STAGE

az deployment group show -n $DEPLOYMENT_NAME -g $RESOURCE_GROUP_NAME -o json --query properties.outputs.urls.value

Write-Output "Dont forget to set up the DB schema!"