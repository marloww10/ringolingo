using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Ringolingo.Migrations
{
    /// <inheritdoc />
    public partial class Supabase : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "SupabaseId",
                table: "Usuarios",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "SupabaseId",
                table: "Usuarios");
        }
    }
}
