using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Ringolingo.Migrations
{
    /// <inheritdoc />
    public partial class AuthLoginAdionado : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "Premium",
                table: "Usuarios",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Premium",
                table: "Usuarios");
        }
    }
}
