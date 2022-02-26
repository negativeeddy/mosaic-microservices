Param(
    [string] $APP_NAME,
    [string] $STAGE,
    [string] $IMAGE_TAG
)

$RESOURCE_GROUP = "$APP_NAME-rg-$STAGE"

az containerapp update --resource-group $RESOURCE_GROUP --name "$APP_NAME-frontend-$STAGE" --image "mosaicprod.azurecr.io/mosaic/frontend:$IMAGE_TAG"
az containerapp update --resource-group $RESOURCE_GROUP --name "$APP_NAME-tilesapi-$STAGE" --image "mosaicprod.azurecr.io/mosaic/tilesapi:$IMAGE_TAG"
az containerapp update --resource-group $RESOURCE_GROUP --name "$APP_NAME-tileprocessor-$STAGE" --image "mosaicprod.azurecr.io/mosaic/tileprocessor:$IMAGE_TAG"
