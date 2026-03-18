namespace Ringolingo.Service.XpService
{
    public interface IXpService
    {
        Task GanharXpAsync(int usuarioId, int quantidade, string motivo);
        int XpNecessarioParaProximoNivel(int nivel);
        Task GanharXpPorMensagemAsync(int usuarioId);
        Task GanharXpPorLoginAsync(int usuarioId);
        Task GanharXpPorPrimeiraInteracaoAsync(int usuarioId);
        Task GanharXpPorSequenciaDiasAsync(int usuarioId);

        Task VerificarSequenciaDiasAsync(int usuarioId);

        Task<int> CalcularStreakAsync(int usuarioId);

        Task<object> ObterXpAtualAsync(int usuarioId);
    }
}
