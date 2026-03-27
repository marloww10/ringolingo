using Microsoft.EntityFrameworkCore;
using Ringolingo.Data;
using Ringolingo.Models;

namespace Ringolingo.Service.XpService
{
    public class XpService : IXpService
    {
        private readonly AppDbContext _context;

        public XpService(AppDbContext context)
        {
            _context = context;
        }


        private static readonly Dictionary<int, int> XpPorNivel = new Dictionary<int, int>
    {
        { 1, 200 },
        { 2, 300 },
        { 3, 450 },
        { 4, 550 },
        { 5, 700 },
        { 6, 900 },
        { 7, 1200 },
        { 8, 1600 },
        { 9, 2100 },
        { 10, 2800 },
        { 11, 3700 },
        { 12, 5000 },
        { 13, 6800 },
        { 14, 9000 },
        { 15, 12000 },
        { 16, 16000 },
        { 17, 21000 },
        { 18, 28000 },
        { 19, 37000 },
        { 20, 50000 }
    };

        public async Task GanharXpAsync(int usuarioId, int quantidade, string motivo)
        {
            var perfil = await _context.Usuarios.FindAsync(usuarioId);

            if (perfil == null)
            {
                throw new Exception("Usuário não encontrado");
            }

            perfil.XpTotal += quantidade;

            perfil.XpDoNivel += quantidade;

            while (XpPorNivel.ContainsKey(perfil.Nivel) && perfil.XpDoNivel >= XpPorNivel[perfil.Nivel])
            {
                perfil.XpDoNivel -= XpPorNivel[perfil.Nivel];
                perfil.Nivel++;
            }

            var historico = new HistoricoXp
            {
                UsuarioId = usuarioId,
                Quantidade = quantidade,
                Motivo = motivo,
                Data = DateTime.Now
            };

            _context.HistoricoXps.Add(historico);

            await _context.SaveChangesAsync();
        }


        public async Task GanharXpPorMensagemAsync(int usuarioId)
        {
            await GanharXpAsync(usuarioId, 10, "Mensagem enviada");
        }

        public async Task GanharXpPorLoginAsync(int usuarioId)
        {
            await GanharXpAsync(usuarioId, 20, "Login diário");
        }

        public async Task GanharXpPorPrimeiraInteracaoAsync(int usuarioId)
        {
            await GanharXpAsync(usuarioId, 30, "Primeira interação do dia");
        }

        public async Task GanharXpPorSequenciaDiasAsync(int usuarioId)
        {
            await GanharXpAsync(usuarioId, 200, "Sequência de dias ativos");
        }

        public async Task VerificarSequenciaDiasAsync(int usuarioId)
        {
           
            var dias = await _context.HistoricoXps
                .Where(h => h.UsuarioId == usuarioId)
                .Select(h => h.Data.Date)
                .Distinct()
                .OrderByDescending(d => d)
                .ToListAsync();

            if (!dias.Any())
                return;

            int streak = 1;
            for (int i = 1; i < dias.Count; i++)
            {
                if (dias[i] == dias[i - 1].AddDays(-1))
                    streak++;
                else
                    break;
            }

            
            if (streak % 5 == 0)
            {
                await GanharXpPorSequenciaDiasAsync(usuarioId);
            }
        }

        public async Task<int> CalcularStreakAsync(int usuarioId)
        {
            var dias = await _context.HistoricoXps
                .Where(h => h.UsuarioId == usuarioId)
                .Select(h => h.Data.Date)
                .Distinct()
                .OrderByDescending(d => d)
                .ToListAsync();

            if (!dias.Any())
                return 0;

            int streak = 1;
            for (int i = 1; i < dias.Count; i++)
            {
                if (dias[i] == dias[i - 1].AddDays(-1))
                    streak++;
                else
                    break;
            }

            return streak;
        }

        public async Task<object> ObterXpAtualAsync(int usuarioId)
        {
            var usuario = await _context.Usuarios.FindAsync(usuarioId);
            if (usuario == null)
                throw new Exception("Usuário não encontrado");

            return new
            {
                UsuarioId = usuario.Id,
                Nivel = usuario.Nivel,
                XpTotal = usuario.XpTotal,
                XpDoNivel = usuario.XpDoNivel,
                XpNecessarioProximoNivel = XpNecessarioParaProximoNivel(usuario.Nivel)
            };
        }



        public int XpNecessarioParaProximoNivel(int nivel)
        {
            return XpPorNivel.ContainsKey(nivel) ? XpPorNivel[nivel] : XpPorNivel.Values.Last();
        }


        
    }
}
