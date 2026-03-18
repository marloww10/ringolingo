using System.ComponentModel.DataAnnotations;

namespace Ringolingo.Models.Dto
{
    public class UsuarioCadastrar
    {
        [Required(ErrorMessage = "O campo Nome é obrigatório")]
        public string Nome { get; set; } = null!;
        [Required(ErrorMessage = "O campo Email é obrigatório"), EmailAddress(ErrorMessage = "Email Inválido")]
        public string Email { get; set;}  = null!;
        [Required(ErrorMessage = "O campo Senha é obrigatório")]
        public string Senha { get; set; } = null!;
        [Compare("Senha", ErrorMessage = "As Senhas não se coincides")]
        public string ConfirmarSenha { get; set; } = null!;
    }
}
