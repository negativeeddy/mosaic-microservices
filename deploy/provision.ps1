Param(
  [Parameter(Mandatory = $true)]
  [string] $STAGE,
  [string] $RESOURCE_GROUP_BASE = "mosaic",
  [string] $APPNAME_BASE = "mosaic",
  [string] $LOCATION = "eastus",
  [Parameter(Mandatory = $true)]
  [string] $DB_ADMIN_PWD,
  [Parameter(Mandatory = $true)]
  [string] $CONTAINER_REGISTRY
)

$RESOURCE_GROUP_NAME = "$RESOURCE_GROUP_BASE-rg-$STAGE"
$DEPLOYMENT_NAME = "$APPNAME_BASE-$STAGE"

az group create -n $RESOURCE_GROUP_NAME -l $LOCATION

$deployment = az deployment group create -n $DEPLOYMENT_NAME -g $RESOURCE_GROUP_NAME  -f ./bicep/main.bicep `
  --parameters `
  uniqueSuffix=$STAGE `
  sqlAdminLoginPassword=$DB_ADMIN_PWD `
  containerRegistry=$CONTAINER_REGISTRY `
  AADB2CInstance='' `
  AADB2CClientId='' `
  AADB2CDomain='' `
  AADB2CSignUpSignInPolicyId='' `
  DefaultAccessTokenScopes='' `
  clientConfigAzureAdB2CValidateAuthority='False' `
  clientConfigAzureAdB2CClientId='' `
  clientConfigAzureAdB2CAuthority='' `
  | ConvertFrom-Json

write-output $deployment

# add my public IP address to the firewall rules for the SQL server
$publicIP = (Invoke-WebRequest -uri “https://api.ipify.org/”).Content
$SQL_FQDN = $deployment.properties.outputs.sqlServerTilesFqdn.value
$SQL_NAME = $deployment.properties.outputs.sqlServerName.value
write-output "Adding $publicIP to firewall for $SQL_FQDN"
az postgres flexible-server firewall-rule create --resource-group $RESOURCE_GROUP_NAME --name $SQL_NAME --rule-name ClientIPAddress --start-ip-address $publicIP --end-ip-address $publicIP
# # update the sql schema
$Tiles_Database = $deployment.properties.outputs.sqlServerTilesFqdn.value
# dotnet ef migrations bundle --output ../src/Mosaic.TilesApi/bin/tilesapi-efbundle-win.exe --self-contained --target-runtime win-x64 --configuration Bundle
# ../src/Mosaic.TilesApi/bin/tilesapi-efbundle-win.exe --connection "Server=$SQL_FQDN;Database=$Tiles_Database;Port=5432;User Id=mosaic;Password=$DB_ADMIN_PWD;Ssl Mode=VerifyFull;"
write-output "../src/Mosaic.TilesApi/bin/tilesapi-efbundle-win.exe --connection 'Server=$SQL_FQDN;Database=$Tiles_Database;Port=5432;User Id=mosaic;Password=$DB_ADMIN_PWD;Ssl Mode=VerifyFull;'"

write-output $deployment.properties.outputs.urls.value

