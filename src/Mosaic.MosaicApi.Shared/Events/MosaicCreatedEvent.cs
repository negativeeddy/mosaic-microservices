using Mosaic.MosaicApi.Models;

namespace Mosaic.MosaicApi.Events;

public record MosaicCreatedEvent(string MosaicId, MosaicOptions Options);
