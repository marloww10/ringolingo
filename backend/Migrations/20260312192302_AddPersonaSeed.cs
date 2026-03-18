using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Ringolingo.Migrations
{
    /// <inheritdoc />
    public partial class AddPersonaSeed : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Conquistas_Usuarios_UsuarioId",
                table: "Conquistas");

            migrationBuilder.DropIndex(
                name: "IX_Conquistas_UsuarioId",
                table: "Conquistas");

            migrationBuilder.DropColumn(
                name: "ConquistadaEm",
                table: "Conquistas");

            migrationBuilder.RenameColumn(
                name: "UsuarioId",
                table: "Conquistas",
                newName: "xpGanhado");

            migrationBuilder.AddColumn<string>(
                name: "FotoUrl",
                table: "Usuarios",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "ImagemUrl",
                table: "Personas",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int>(
                name: "NivelNecessario",
                table: "Personas",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "conquistaUsuarios",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UsuarioId = table.Column<int>(type: "int", nullable: false),
                    ConquistaId = table.Column<int>(type: "int", nullable: false),
                    DataConquista = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_conquistaUsuarios", x => x.Id);
                    table.ForeignKey(
                        name: "FK_conquistaUsuarios_Conquistas_ConquistaId",
                        column: x => x.ConquistaId,
                        principalTable: "Conquistas",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_conquistaUsuarios_Usuarios_UsuarioId",
                        column: x => x.UsuarioId,
                        principalTable: "Usuarios",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "Personas",
                columns: new[] { "Id", "Descricao", "ImagemUrl", "NivelNecessario", "Nome" },
                values: new object[,]
                {
                    { 1, "You are Ringo, an English teacher acting as a professional interviewer.  Your answers must ALWAYS follow this exact format, with the labels included:  English: <Write the dialogue in formal, professional English here>  Portuguese: <Write the same dialogue translated into Portuguese here>  Teacher's Tip (English): <Write a short teaching tip in English here>  Dica do Professor (Português): <Write the same teaching tip translated into Portuguese here>  Important rules: - Do not add slashes, asterisks, or extra symbols. - Do not mix English and Portuguese in the same section. - Always keep the labels exactly as shown. - Always use line breaks between sections.", "/personas/ringoEntrevistador.png", 15, "Entrevistador" },
                    { 2, "You are Ringo, an English teacher acting as the user's best friend. Your answers must ALWAYS follow this exact format, with the labels included:English:<Write the dialogue in casual, friendly English with slang and everyday expressions here>Portuguese:<Write the same dialogue translated into Portuguese here>Teacher's Tip (English):<Write a short teaching tip in English about informal language, slang, or natural conversation here>Dica do Professor (Português):<Write the same teaching tip translated into Portuguese here>Important rules:- Do not add slashes, asterisks, or extra symbols.- Do not mix English and Portuguese in the same section.- Always keep the labels exactly as shown.- Always use line breaks between sections.", "/personas/ringoBestFriend.png", 0, "BestFriend" },
                    { 3, "You are Ringo, an English teacher acting as a polite waiter. Your answers must ALWAYS follow this exact format, with the labels included:English:<Write the dialogue in English using restaurant and service vocabulary here>Portuguese:<Write the same dialogue translated into Portuguese here>Teacher's Tip (English)<Write a short teaching tip in English about vocabulary, grammar, or expressions used in restaurant situations here>Dica do Professor (Português):<Write the same teaching tip translated into Portuguese here>Important rules:- Do not add slashes, asterisks, or extra symbols.- Do not mix English and Portuguese in the same section.- Always keep the labels exactly as shown.- Always use line breaks between sections.", "/personas/ringoGarçom.png", 10, "Garçom" }
                });

            migrationBuilder.CreateIndex(
                name: "IX_conquistaUsuarios_ConquistaId",
                table: "conquistaUsuarios",
                column: "ConquistaId");

            migrationBuilder.CreateIndex(
                name: "IX_conquistaUsuarios_UsuarioId",
                table: "conquistaUsuarios",
                column: "UsuarioId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "conquistaUsuarios");

            migrationBuilder.DeleteData(
                table: "Personas",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Personas",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Personas",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DropColumn(
                name: "FotoUrl",
                table: "Usuarios");

            migrationBuilder.DropColumn(
                name: "ImagemUrl",
                table: "Personas");

            migrationBuilder.DropColumn(
                name: "NivelNecessario",
                table: "Personas");

            migrationBuilder.RenameColumn(
                name: "xpGanhado",
                table: "Conquistas",
                newName: "UsuarioId");

            migrationBuilder.AddColumn<DateTime>(
                name: "ConquistadaEm",
                table: "Conquistas",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.CreateIndex(
                name: "IX_Conquistas_UsuarioId",
                table: "Conquistas",
                column: "UsuarioId");

            migrationBuilder.AddForeignKey(
                name: "FK_Conquistas_Usuarios_UsuarioId",
                table: "Conquistas",
                column: "UsuarioId",
                principalTable: "Usuarios",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
