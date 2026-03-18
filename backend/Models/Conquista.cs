namespace Ringolingo.Models
{
    public class Conquista
    {
        public int Id { get; set; }
        public string Titulo { get; set; } = null!;
        public string Descricao { get; set; } = null!;
        public int xpGanhado {get; set;}

         public ICollection<ConquistaUsuario> UsuarioConquista { get; set; } = new List<ConquistaUsuario>();
 
    }

}
