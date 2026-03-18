namespace Ringolingo.Service
{
    public interface IMissaoService
    {
        Task Conversador(int usuarioId);

        Task Tagarela(int usuarioId);

        Task Explorador (int usuarioId);

        Task ProcessarMissao(int usuarioId, string nomeMissao, string motivoHistorico, int progresso);
    }
}