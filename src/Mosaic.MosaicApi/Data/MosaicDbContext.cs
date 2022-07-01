#nullable disable
using Microsoft.EntityFrameworkCore;

namespace Mosaic.MosaicApi.Data;

public class MosaicDbContext : DbContext
{
    public MosaicDbContext (DbContextOptions<MosaicDbContext> options)
        : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
    }

    public DbSet<MosaicEntity> Mosaic { get; set; }
}
