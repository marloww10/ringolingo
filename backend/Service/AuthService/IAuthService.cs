using Ringolingo.Models;
using Ringolingo.Models.Dto;

namespace Ringolingo.Service.AuthService
{
    public interface IAuthService
    {
        Task<Response<UsuarioCadastrar>> CadastroUsuario(UsuarioCadastrar usuarioCadastrar);
        Task<Response<RespostaLogin>> LoginUsuario(UsuarioLogin usuarioLogin);
        // ADICIONADO: O parâmetro 'nome' para bater com a implementação do AuthService
        Task<Response<RespostaLogin>> LoginSocial(string email, string supabaseId, string nome);
    }
}