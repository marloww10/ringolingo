namespace Ringolingo.Service
{
    public interface IConquistaService
    {
        Task Mensageiro(int usuarioId);
        Task Veterano(int usuarioId);
        Task Acumulador(int usuarioId);
        Task Evoluido(int usuarioId);
        Task Colecionador(int usuarioId);
    }
}