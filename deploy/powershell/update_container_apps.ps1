Param(
    [string] $APP_NAME,
    [string] $STAGE,
    [string] $IMAGE_TAG
)

$RESOURCE_GROUP = "$APP_NAME-rg-$STAGE"

az containerapp update --resource-group $RESOURCE_GROUP --name "$APP_NAME-frontend-$STAGE" --image "mosaicprod.azurecr.io/mosaicfrontend:$IMAGE_TAG"
az containerapp update --resource-group $RESOURCE_GROUP --name "$APP_NAME-tilesapi-$STAGE" --image "mosaicprod.azurecr.io/mosaictilesapi:$IMAGE_TAG"
az containerapp update --resource-group $RESOURCE_GROUP --name "$APP_NAME-tileprocessor-$STAGE" --image "mosaicprod.azurecr.io/mosaictileprocessor:$IMAGE_TAG"
