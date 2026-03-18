using System.ComponentModel.DataAnnotations;

namespace Ringolingo.Models.Dto
{
    public class UsuarioLogin
    {
        [Required(ErrorMessage = "O campo email é obrigatório"), EmailAddress(ErrorMessage = "Email Inválido")]
        public string? Email {  get; set; }
        [Required(ErrorMessage = "O campo senha é obrigatório")]
        public string? Senha { get; set; }
    }
}
