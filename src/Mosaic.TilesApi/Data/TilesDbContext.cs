#nullable disable
using Microsoft.EntityFrameworkCore;

namespace Mosaic.TilesApi.Data;

public class TilesDbContext : DbContext
{
    public TilesDbContext (DbContextOptions<TilesDbContext> options)
        : base(options)
    {
    }

    public DbSet<TileEntity> Tiles { get; set; }
}
