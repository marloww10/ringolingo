namespace Ringolingo.Models.Dto
{
    public class RankingItemDto
    {
        public int Posicao { get; set; }
        public int UsuarioId { get; set; }
        public string Nome { get; set; } = string.Empty;
        public string FotoUrl { get; set; } = string.Empty;
        public int XpTotal { get; set; }
        public int Nivel { get; set; }
    }

    public class RankingDto
    {
        public List<RankingItemDto> Top3 { get; set; } = new();
        public RankingItemDto? UsuarioAtual { get; set; }
    }
}
