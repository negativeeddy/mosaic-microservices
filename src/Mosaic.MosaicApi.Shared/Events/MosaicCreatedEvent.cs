
namespace Mosaic.MosaicApi;

public record MosaicCreatedEvent(string mosaicId, string userId, MosaicCreateDto Options);
