#nullable disable
using Microsoft.EntityFrameworkCore;

namespace Mosaic.TilesApi.Data;

public class TilesDbContext : DbContext
{
    public TilesDbContext (DbContextOptions<TilesDbContext> options)
        : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasPostgresExtension("postgis");
    }

    public DbSet<TileEntity> Tiles { get; set; }
}
