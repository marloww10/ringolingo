namespace Ringolingo.Models
{
    public class MissaoUsuario
    {
        public int Id { get; set; }
        public int UsuarioId { get; set; }
        public int MissaoId { get; set; }
        public int Progresso { get; set; } = 0;
        public DateTime Data { get; set; } = DateTime.Today;
        public bool Concluida { get; set; 
    }
}
}