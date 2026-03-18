namespace Ringolingo.Models
{
    public class HistoricoXp
    {
        public int Id { get; set; }
        public int UsuarioId { get; set; }
        public Usuario Usuario { get; set; } = null!;
        public int Quantidade { get; set; }
        public string Motivo { get; set; } = "";

        public int PersonaId {get; set;}
        public DateTime Data { get; set; }
    }

}
