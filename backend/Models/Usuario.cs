namespace Ringolingo.Models
{

    public class Usuario
    {
        public int Id { get; set; }
        public string SupabaseId { get; set; } = null;
        public string Nome { get; set; } = null!;    
        public string Email { get; set; } = null!;
        public byte[] SenhaSalt { get; set; } = null!;
        public byte[] SenhaHash { get; set; } = null!;
        public int XpDoNivel { get; set; } = 0;
        public int XpTotal { get; set; } = 0;
        public int Nivel { get; set; } = 1;
        public bool Premium { get; set; } = false;
        public bool Ativo { get; set; } = true;
        public string FotoUrl { get; set; } = string.Empty;

        public DateTime TokenCriacao { get; set; } = DateTime.Now;

        public ICollection<Mensagem> Mensagens { get; set; } = new List<Mensagem>();
        public ICollection<Sessao> Sessoes { get; set; } = new List<Sessao>();
        public ICollection<ConquistaUsuario> Conquistas { get; set; } = new List<ConquistaUsuario>();
        public ICollection<HistoricoXp> HistoricoXp { get; set; } = new List<HistoricoXp>();
    }
}
