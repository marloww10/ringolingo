using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Ringolingo.Migrations
{
    /// <inheritdoc />
    public partial class Initial2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "PersonaId",
                table: "Mensagens",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_Mensagens_PersonaId",
                table: "Mensagens",
                column: "PersonaId");

            migrationBuilder.AddForeignKey(
                name: "FK_Mensagens_Personas_PersonaId",
                table: "Mensagens",
                column: "PersonaId",
                principalTable: "Personas",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Mensagens_Personas_PersonaId",
                table: "Mensagens");

            migrationBuilder.DropIndex(
                name: "IX_Mensagens_PersonaId",
                table: "Mensagens");

            migrationBuilder.DropColumn(
                name: "PersonaId",
                table: "Mensagens");
        }
    }
}
