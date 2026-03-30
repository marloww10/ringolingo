namespace Ringolingo.Service.XpService
{
    public interface IXpService
    {
        // 1. Corrigido: Adicionado o int personaId = 0
        Task GanharXpAsync(int usuarioId, int quantidade, string motivo, int personaId = 0);
        
        int XpNecessarioParaProximoNivel(int nivel);
        
        // 2 e 3. Corrigido: Apagado o duplicado e a versão antiga
        Task GanharXpPorMensagemAsync(int usuarioId, int personaId);
        
        Task GanharXpPorLoginAsync(int usuarioId);
        
        Task GanharXpPorPrimeiraInteracaoAsync(int usuarioId);
        
        Task GanharXpPorSequenciaDiasAsync(int usuarioId);

        Task VerificarSequenciaDiasAsync(int usuarioId);

        Task<int> CalcularStreakAsync(int usuarioId);

        Task<object> ObterXpAtualAsync(int usuarioId);
    }
}