using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Ringolingo.Migrations
{
    /// <inheritdoc />
    public partial class LogicaXpAdicionada : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "Pontuacao",
                table: "Usuarios",
                newName: "XpTotal");

            migrationBuilder.AddColumn<int>(
                name: "XpDoNivel",
                table: "Usuarios",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "XpDoNivel",
                table: "Usuarios");

            migrationBuilder.RenameColumn(
                name: "XpTotal",
                table: "Usuarios",
                newName: "Pontuacao");
        }
    }
}
