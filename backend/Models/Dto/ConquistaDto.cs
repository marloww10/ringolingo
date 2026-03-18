namespace Ringolingo.Models.Dto
{
    public class ConquistaDto
    {
        public int Id { get; set; }
        public string Nome { get; set; }
        public string Descricao {get; set;}
        public int XpGanho { get; set; }
        public bool Desbloqueada { get; set; }
        public DateTime? DataConquista { get; set; }
    }
}