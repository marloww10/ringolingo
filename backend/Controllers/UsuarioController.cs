using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Ringolingo.Data;
using Ringolingo.Models;
using Ringolingo.Models.Dto;
using Ringolingo.Service.XpService;

namespace Ringolingo.Controllers
{
    [ApiController]
    [Route("Usuario")]
    public class UsuarioController : ControllerBase
    {
        private readonly IXpService _xpService;
        private readonly AppDbContext _context;

        public UsuarioController(IXpService xpService, AppDbContext context)
        {
            _xpService = xpService;
            _context = context;
        }

        [Authorize]
        [HttpGet]
        public ActionResult<Response<int>> GetUsuarioToken()
        {
            var userIdClaim = User.FindFirst("UserId");
            if (userIdClaim == null)
                return Unauthorized(new Response<int> { Mensagem = "Token sem dados" });

            int usuarioId = int.Parse(userIdClaim.Value);
            return Ok(new Response<int> { Mensagem = "Usuário autenticado", Dados = usuarioId });
        }

        [Authorize]
        [HttpGet("Streak")]
        public async Task<IActionResult> GetStreak()
        {
            var usuarioIdClaim = User.FindFirst("UserId");
            if (usuarioIdClaim == null) return Unauthorized();
            var usuarioId = int.Parse(usuarioIdClaim.Value);

            var streak = await _xpService.CalcularStreakAsync(usuarioId);
            return Ok(new { UsuarioId = usuarioId, Streak = streak });
        }

        [Authorize]
        [HttpGet("XP")]
        public async Task<IActionResult> GetXp()
        {
            var usuarioIdClaim = User.FindFirst("UserId");
            if (usuarioIdClaim == null) return Unauthorized();
            var usuarioId = int.Parse(usuarioIdClaim.Value);

            var xpInfo = await _xpService.ObterXpAtualAsync(usuarioId);
            return Ok(xpInfo);
        }

        [Authorize]
        [HttpGet("Ranking")]
        public async Task<ActionResult<Response<RankingDto>>> GetRanking([FromQuery] string tipo = "geral")
        {
            var userIdClaim = User.FindFirst("UserId");
            if (userIdClaim == null)
                return Unauthorized(new Response<RankingDto> { Mensagem = "Token sem dados" });

            int usuarioId = int.Parse(userIdClaim.Value);

            // Define o filtro de data conforme o tipo
            DateTime? dataInicio = tipo.ToLower() switch
            {
                "semanal" => DateTime.UtcNow.AddDays(-7),
                "mensal"  => DateTime.UtcNow.AddMonths(-1),
                _         => null // geral = sem filtro
            };

            IQueryable<Usuario> query = _context.Usuarios.Where(u => u.Ativo);

            // Para semanal e mensal, filtra pelo XP ganho no período via HistoricoXp
            List<(int Id, string Nome, string? FotoUrl, int XpTotal, int Nivel)> usuariosOrdenados;

            if (dataInicio.HasValue)
            {
                // Soma o XP ganho no período para cada usuário
                var xpNoPeriodo = await _context.HistoricoXps
                    .Where(h => h.Data >= dataInicio.Value)
                    .GroupBy(h => h.UsuarioId)
                    .Select(g => new { UsuarioId = g.Key, XpPeriodo = g.Sum(h => h.Quantidade) })
                    .ToListAsync();

                var xpDict = xpNoPeriodo.ToDictionary(x => x.UsuarioId, x => x.XpPeriodo);

                var usuarios = await query
                    .Select(u => new { u.Id, u.Nome, u.FotoUrl, u.XpTotal, u.Nivel })
                    .ToListAsync();

                usuariosOrdenados = usuarios
                    .Select(u => (
                        u.Id,
                        u.Nome,
                        (string?)u.FotoUrl,
                        xpDict.GetValueOrDefault(u.Id, 0), // XP do período
                        u.Nivel
                    ))
                    .OrderByDescending(u => u.Item4)
                    .ToList();
            }
            else
            {
                // Geral: ordena pelo XpTotal acumulado
                var usuarios = await query
                    .OrderByDescending(u => u.XpTotal)
                    .Select(u => new { u.Id, u.Nome, u.FotoUrl, u.XpTotal, u.Nivel })
                    .ToListAsync();

                usuariosOrdenados = usuarios
                    .Select(u => (u.Id, u.Nome, (string?)u.FotoUrl, u.XpTotal, u.Nivel))
                    .ToList();
            }

            // Monta top3
            var top3 = usuariosOrdenados
                .Take(3)
                .Select((u, index) => new RankingItemDto
                {
                    Posicao = index + 1,
                    UsuarioId = u.Id,
                    Nome = u.Nome,
                    FotoUrl = u.Item3,
                    XpTotal = u.Item4,
                    Nivel = u.Nivel
                })
                .ToList();

            // Posição do usuário autenticado
            var posicaoAtual = usuariosOrdenados.FindIndex(u => u.Id == usuarioId);
            RankingItemDto? usuarioAtual = null;

            if (posicaoAtual >= 0)
            {
                var u = usuariosOrdenados[posicaoAtual];
                usuarioAtual = new RankingItemDto
                {
                    Posicao = posicaoAtual + 1,
                    UsuarioId = u.Id,
                    Nome = u.Nome,
                    FotoUrl = u.Item3,
                    XpTotal = u.Item4,
                    Nivel = u.Nivel
                };
            }

            return Ok(new Response<RankingDto>
            {
                Mensagem = "Ranking obtido com sucesso",
                Dados = new RankingDto
                {
                    Top3 = top3,
                    UsuarioAtual = usuarioAtual
                }
            });
        }
    }
}