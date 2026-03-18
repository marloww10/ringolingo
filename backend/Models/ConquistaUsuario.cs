namespace Ringolingo.Models
{
    public class ConquistaUsuario
    {
        public int Id { get; set; }
        public int UsuarioId { get; set; }
        public Usuario Usuario { get; set; }

        public int ConquistaId { get; set; }
        public Conquista Conquista { get; set; }

        public DateTime DataConquista { get; set; } = DateTime.Now;
    }
}