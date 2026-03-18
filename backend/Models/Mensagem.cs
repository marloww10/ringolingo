using System.Text.Json.Serialization;

namespace Ringolingo.Models
{
    public class Mensagem
    {
        public int Id { get; set; }
        public string Conteudo { get; set; } = null!;
        public DateTime EnviadaEm { get; set; }

        public int SessaoId {get; set;}
        public int UsuarioId { get; set; }
        public int PersonaId {get; set;}
        [JsonIgnore]
        public Usuario Usuario { get; set; } = null!;
        [JsonIgnore]
        public Persona persona {get; set;} = null!;

    }

}
