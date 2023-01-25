using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Mosaic.TilesApi.Data;
using NetTopologySuite.Geometries;

namespace Mosaic.TilesApi.Tests
{
    [TestClass]
    public class DbQueryTests
    {
        [TestMethod]
        public async Task FromSqlRaw_With()
        {
            IServiceScope scope = InitializeDatabaseContext();

            TilesDbContext context = scope.ServiceProvider.GetService<TilesDbContext>()!;

            int maxTilesToFetch = 1;

            IServiceProvider serviceProvider = scope.ServiceProvider;
            string userId = serviceProvider.GetService<IConfiguration>()!["userId"]!;

            const string sqlQuery =
                $$"""
                SELECT *, 
                       ST_3DDistance(tiles."Average", {0}) AS dist
                FROM public."Tiles" tiles
                WHERE tiles."OwnerId" is null OR tiles."OwnerId" = {1}
                ORDER BY dist LIMIT {2}
                """;

            Point searchPoint = new Point(0, 10, 100);

            var nearest = await context.Tiles
                .FromSqlRaw(sqlQuery, searchPoint, userId, maxTilesToFetch)
                .ToArrayAsync();

            Assert.AreEqual(maxTilesToFetch, nearest.Length);
        }

        [TestMethod]
        public async Task FromSqlRaw_SimpleWith()
        {
            IServiceScope scope = InitializeDatabaseContext();

            TilesDbContext context = scope.ServiceProvider.GetService<TilesDbContext>()!;

            int maxTilesToFetch = 1;

            const string sqlQuery =
                $$"""
                SELECT t."Id", t."Aspect", t."Average", t."Date", t."Height", t."OwnerId", t."Source", t."SourceData", 
                       t."SourceId", t."Width"
                FROM public."Tiles" t
                WHERE t."Source" = 'flickr'
                LIMIT 1
                """;

            Point searchPoint = new Point(0, 10, 100);

            var nearest = await context.Tiles
                .FromSqlRaw(sqlQuery, searchPoint, maxTilesToFetch)
                .ToArrayAsync();

            Assert.AreEqual(maxTilesToFetch, nearest.Length);
        }

        [TestMethod]
        public async Task FromSqlRaw_NoWith()
        {
            IServiceScope scope = InitializeDatabaseContext();

            TilesDbContext context = scope.ServiceProvider.GetService<TilesDbContext>()!;

            int maxTilesToFetch = 1;

            const string sqlQuery2 =
                $$"""
                SELECT *, 
                ST_3DDistance(tiles."Average", {0}) AS dist
                FROM public."Tiles" tiles
                ORDER BY dist LIMIT {1}
                """;


            Point searchPoint = new Point(0, 10, 100);

            var nearest = await context.Tiles
                .FromSqlRaw(sqlQuery2, searchPoint, maxTilesToFetch)
                .ToArrayAsync();

            Assert.AreEqual(maxTilesToFetch, nearest.Length);
        }

        private static IServiceScope InitializeDatabaseContext()
        {
            ServiceCollection c = new ServiceCollection();

            var configuration = new ConfigurationBuilder()
            .AddJsonFile("./appsettings.json")
            .AddUserSecrets<DbQueryTests>()
            .AddEnvironmentVariables()
            .Build();

            c.AddSingleton<IConfiguration>(configuration);

            c.AddEntityFrameworkNpgsql()
                .AddDbContext<TilesDbContext>(options =>
                {
                    string connectionString = configuration.GetConnectionString("tiledbconnectionstring")!;
                    options.UseNpgsql(connectionString,
                        x =>
                        {
                            x.UseNetTopologySuite();
                            x.EnableRetryOnFailure();
                        });

                    options.EnableDetailedErrors();
                    options.EnableSensitiveDataLogging();
                    options.UseQueryTrackingBehavior(QueryTrackingBehavior.NoTrackingWithIdentityResolution);
                    options.ConfigureWarnings(action =>
                    {
                        action.Log(new[]
                        {
                            CoreEventId.FirstWithoutOrderByAndFilterWarning,
                            CoreEventId.RowLimitingOperationWithoutOrderByWarning,
                        });
                    });
                });

            var sp = c.BuildServiceProvider();
            var scope = sp.CreateScope();
            return scope;
        }
    }
}