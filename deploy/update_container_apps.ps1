Param(
    [Parameter(Mandatory = $true)]
    [string] $STAGE,
    [Parameter(Mandatory = $true)]
    [string] $CONTAINER_REGISTRY,
    [string] $APP_NAME = "mosaic",
    [string] $RESOURCE_GROUP_BASE = "mosaic",
    [string] $IMAGE_TAG = "latest"
)

# update all container apps to the latest image

$RESOURCE_GROUP_NAME = "$RESOURCE_GROUP_BASE-rg-$STAGE"

# az containerapp update --resource-group $RESOURCE_GROUP_NAME --name "$APP_NAME-frontend-ca-$STAGE" --image "$CONTAINER_REGISTRY/mosaic/frontend:$IMAGE_TAG"
# az containerapp update --resource-group $RESOURCE_GROUP_NAME --name "$APP_NAME-tilesapi-ca-$STAGE" --image "$CONTAINER_REGISTRY/mosaic/tilesapi:$IMAGE_TAG"
az containerapp update --resource-group $RESOURCE_GROUP_NAME --name "$APP_NAME-tilesactors-ca-$STAGE" --image "$CONTAINER_REGISTRY/mosaic/tilesactors:$IMAGE_TAG"
# az containerapp update --resource-group $RESOURCE_GROUP_NAME --name "$APP_NAME-tileprocessor-ca-$STAGE" --image "$CONTAINER_REGISTRY/mosaic/tileprocessor:$IMAGE_TAG"
# az containerapp update --resource-group $RESOURCE_GROUP_NAME --name "$APP_NAME-mosaicapi-ca-$STAGE" --image "$CONTAINER_REGISTRY/mosaic/mosaicapi:$IMAGE_TAG"
# az containerapp update --resource-group $RESOURCE_GROUP_NAME --name "$APP_NAME-mosaicgenerator-ca-$STAGE" --image "$CONTAINER_REGISTRY/mosaic/mosaicgenerator:$IMAGE_TAG"
# az containerapp update --resource-group $RESOURCE_GROUP_NAME --name "$APP_NAME-apigateway-ca-$STAGE" --image "$CONTAINER_REGISTRY/mosaic/apigateway:$IMAGE_TAG"

az containerapp revision copy --resource-group $RESOURCE_GROUP --name "$APP_NAME-tilesactors-ca-$STAGE"