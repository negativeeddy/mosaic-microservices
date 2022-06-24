﻿namespace Mosaic.MosaicApi;

public record MosaicCreateDto(
    string Name,
    int SourceTileId,
    int HorizontalTileCount,
    int VerticalTileCount
    );
