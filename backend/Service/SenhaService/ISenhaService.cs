using Ringolingo.Models;

namespace Ringolingo.Service.SenhaService
{
    public interface ISenhaService
    {
        void CriarSenhaHash(string senha, out byte[] SenhaHash, out byte[] SenhaSalt);
        bool VerificarSenhaHash(string senha, byte[] SenhaHash, byte[] SenhaSalt);
        string CriarToken(Usuario usuario);
    }
}
