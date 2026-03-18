using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Ringolingo.Migrations
{
    /// <inheritdoc />
    public partial class ATTSeeds : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "missaos",
                keyColumn: "Id",
                keyValue: 1,
                column: "QuantidadeNecessaria",
                value: 5);

            migrationBuilder.UpdateData(
                table: "missaos",
                keyColumn: "Id",
                keyValue: 2,
                column: "QuantidadeNecessaria",
                value: 10);

            migrationBuilder.UpdateData(
                table: "missaos",
                keyColumn: "Id",
                keyValue: 3,
                column: "QuantidadeNecessaria",
                value: 2);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "missaos",
                keyColumn: "Id",
                keyValue: 1,
                column: "QuantidadeNecessaria",
                value: 0);

            migrationBuilder.UpdateData(
                table: "missaos",
                keyColumn: "Id",
                keyValue: 2,
                column: "QuantidadeNecessaria",
                value: 0);

            migrationBuilder.UpdateData(
                table: "missaos",
                keyColumn: "Id",
                keyValue: 3,
                column: "QuantidadeNecessaria",
                value: 0);
        }
    }
}
