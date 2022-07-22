Param(
    [string] $APP_NAME = "mosaic",
    [string] $STAGE,
    [string] $IMAGE_TAG = "latest"
)

$RESOURCE_GROUP = "$APP_NAME-rg-$STAGE"

az containerapp update --resource-group $RESOURCE_GROUP --name "$APP_NAME-frontend-ca-$STAGE" --image "mosaicprod.azurecr.io/mosaic/frontend:$IMAGE_TAG"
az containerapp update --resource-group $RESOURCE_GROUP --name "$APP_NAME-tilesapi-ca-$STAGE" --image "mosaicprod.azurecr.io/mosaic/tilesapi:$IMAGE_TAG"
az containerapp update --resource-group $RESOURCE_GROUP --name "$APP_NAME-tileprocessor-ca-$STAGE" --image "mosaicprod.azurecr.io/mosaic/tileprocessor:$IMAGE_TAG"
az containerapp update --resource-group $RESOURCE_GROUP --name "$APP_NAME-mosaicapi-ca-$STAGE" --image "mosaicprod.azurecr.io/mosaic/mosaicapi:$IMAGE_TAG"
az containerapp update --resource-group $RESOURCE_GROUP --name "$APP_NAME-mosaicgenerator-ca-$STAGE" --image "mosaicprod.azurecr.io/mosaic/mosaicgenerator:$IMAGE_TAG"
az containerapp update --resource-group $RESOURCE_GROUP --name "$APP_NAME-apigateway-ca-$STAGE" --image "mosaicprod.azurecr.io/mosaic/mosaicgenerator:$IMAGE_TAG"

az containerapp revision copy --resource-group $RESOURCE_GROUP --name "$APP_NAME-frontend-ca-$STAGE"
az containerapp revision copy --resource-group $RESOURCE_GROUP --name "$APP_NAME-tilesapi-ca-$STAGE"
az containerapp revision copy --resource-group $RESOURCE_GROUP --name "$APP_NAME-tileprocessor-ca-$STAGE"
az containerapp revision copy --resource-group $RESOURCE_GROUP --name "$APP_NAME-mosaicapi-ca-$STAGE"
az containerapp revision copy --resource-group $RESOURCE_GROUP --name "$APP_NAME-mosaicgenerator-ca-$STAGE"
az containerapp revision copy --resource-group $RESOURCE_GROUP --name "$APP_NAME-apigateway-ca-$STAGE"