namespace Ringolingo.Models
{
    public class Missao
    {
        public int Id { get; set; }
        public string Nome { get; set; } = string.Empty;
        public string Descricao { get; set; } = string.Empty;
        public string Emoji { get; set; } = string.Empty;
        public int QuantidadeNecessaria { get; set; }
        public int XpRecompensa { get; set; }
    }
}