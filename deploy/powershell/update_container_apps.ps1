Param(
    [string] $RESOURCE_GROUP,
    [string] $APP_NAME,
    [string] $STAGE
)

az containerapp update --resource-group $RESOURCE_GROUP --name "$APP_NAME-tilesapi-$STAGE" --image "mosaicprod.azurecr.io/mosaictilesapi:latest"
az containerapp update --resource-group $RESOURCE_GROUP --name "$APP_NAME-frontend-$STAGE" --image "mosaicprod.azurecr.io/mosaicfrontend:latest"
