using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Ringolingo.Migrations
{
    /// <inheritdoc />
    public partial class SessaoAndHistorico : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "FinalizadaEm",
                table: "Sessaos");

            migrationBuilder.AddColumn<int>(
                name: "PersonaId",
                table: "Sessaos",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "SessaoId",
                table: "Mensagens",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "PersonaId",
                table: "HistoricoXps",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "Descricao",
                table: "Conquistas",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateTable(
                name: "missaos",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Nome = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Descricao = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Emoji = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    QuantidadeNecessaria = table.Column<int>(type: "int", nullable: false),
                    XpRecompensa = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_missaos", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "missaoUsuarios",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UsuarioId = table.Column<int>(type: "int", nullable: false),
                    MissaoId = table.Column<int>(type: "int", nullable: false),
                    Progresso = table.Column<int>(type: "int", nullable: false),
                    Data = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Concluida = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_missaoUsuarios", x => x.Id);
                });

            migrationBuilder.InsertData(
                table: "Conquistas",
                columns: new[] { "Id", "Descricao", "Titulo", "xpGanhado" },
                values: new object[] { 1, "Envie 100 mensagens com qualquer um dos ringos", "Mensageiro", 200 });

            migrationBuilder.UpdateData(
                table: "Personas",
                keyColumn: "Id",
                keyValue: 1,
                column: "NivelNecessario",
                value: 10);

            migrationBuilder.UpdateData(
                table: "Personas",
                keyColumn: "Id",
                keyValue: 3,
                column: "NivelNecessario",
                value: 5);

            migrationBuilder.InsertData(
                table: "missaos",
                columns: new[] { "Id", "Descricao", "Emoji", "Nome", "QuantidadeNecessaria", "XpRecompensa" },
                values: new object[,]
                {
                    { 1, "Envie 5 mensagens para qualquer ringo", "💬", "Conversador", 0, 30 },
                    { 2, "Envie 10 mensagens para qualquer ringo", "🗣️", "Tagarela", 0, 50 },
                    { 3, "Converse com pelo menos 2 Ringos diferentes", "🌍", "Explorador", 0, 25 }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "missaos");

            migrationBuilder.DropTable(
                name: "missaoUsuarios");

            migrationBuilder.DeleteData(
                table: "Conquistas",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DropColumn(
                name: "PersonaId",
                table: "Sessaos");

            migrationBuilder.DropColumn(
                name: "SessaoId",
                table: "Mensagens");

            migrationBuilder.DropColumn(
                name: "PersonaId",
                table: "HistoricoXps");

            migrationBuilder.DropColumn(
                name: "Descricao",
                table: "Conquistas");

            migrationBuilder.AddColumn<DateTime>(
                name: "FinalizadaEm",
                table: "Sessaos",
                type: "datetime2",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "Personas",
                keyColumn: "Id",
                keyValue: 1,
                column: "NivelNecessario",
                value: 15);

            migrationBuilder.UpdateData(
                table: "Personas",
                keyColumn: "Id",
                keyValue: 3,
                column: "NivelNecessario",
                value: 10);
        }
    }
}
