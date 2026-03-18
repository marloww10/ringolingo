using Ringolingo.Models;

namespace Ringolingo.Service.IAService
{
    public interface IApiService
    {
        Task<string> GerarResposta(string mensagemUsuario, Persona persona, string contexto);
    }
}
