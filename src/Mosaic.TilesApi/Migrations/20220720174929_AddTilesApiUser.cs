using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Mosaic.TilesApi.Migrations
{
    public partial class AddTilesApiUser : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "OwnerId",
                table: "Tiles",
                type: "text",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "OwnerId",
                table: "Tiles");
        }
    }
}
