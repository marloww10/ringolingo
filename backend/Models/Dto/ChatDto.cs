

using System.Text.Json.Serialization;

namespace Ringolingo.Models.Dto
{
    public class ChatDto
    {
        public string? Conteudo {  get; set; }
        public string? NomePersona {get; set;}
        [JsonIgnore]
        public Persona? Persona { get; set; }
    }
}
