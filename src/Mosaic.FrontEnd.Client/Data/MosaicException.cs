namespace Mosaic.FrontEnd.Data;

public class MosaicException : Exception
{
    public MosaicException()
    {
    }

    public MosaicException(string? message) : base(message)
    {
    }

    public MosaicException(string? message, Exception? innerException) : base(message, innerException)
    {
    }
}
