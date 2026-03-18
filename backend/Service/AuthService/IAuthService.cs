using Ringolingo.Models;
using Ringolingo.Models.Dto;

namespace Ringolingo.Service.AuthService
{
    public interface IAuthService
    {
        Task<Response<UsuarioCadastrar>> CadastroUsuario(UsuarioCadastrar usuarioCadastrar);
        Task<Response<RespostaLogin>> LoginUsuario(UsuarioLogin usuarioLogin);
    }
}
