namespace Ringolingo.Models
{
    public class Persona
    {
        public int Id { get; set; }
        public string Nome { get; set; } = null!;
        public string Descricao { get; set; } = null!;
        public string ImagemUrl { get; set; } = string.Empty;
        public int NivelNecessario { get; set; }
    }

}
