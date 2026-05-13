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
            _xpService = xpService; _context = context;
        }


        [Authorize]
        [HttpGet]
        public ActionResult<Response<int>> GetUsuarioToken()
        {
            var userIdClaim = User.FindFirst("UserId");
            if (userIdClaim == null)
            {
                return Unauthorized(new Response<int> { Mensagem = "Token sem dados" });
            }

            int usuarioId = int.Parse(userIdClaim.Value);

            return Ok(new Response<int>
            {
                Mensagem = "Usuário autenticado",
                Dados = usuarioId
            });
        }


        [Authorize]
        [HttpGet("Streak")]
        public async Task<IActionResult> GetStreak()
        {
            var usuarioIdClaim = User.FindFirst("UserId");
            if (usuarioIdClaim == null) return Unauthorized();
            var usuarioId = int.Parse(usuarioIdClaim.Value);

            var streak = await _xpService.CalcularStreakAsync(usuarioId);

            return Ok(new
            {
                UsuarioId = usuarioId,
                Streak = streak
            });
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
        public async Task<ActionResult<Response<RankingDto>>> GetRanking()
        {
            var userIdClaim = User.FindFirst("UserId");
            if (userIdClaim == null)
                return Unauthorized(new Response<RankingDto> { Mensagem = "Token sem dados" });

            int usuarioId = int.Parse(userIdClaim.Value);

            // Busca todos os usuários ativos ordenados por XpTotal desc
            var usuarios = await _context.Usuarios
                .Where(u => u.Ativo)
                .OrderByDescending(u => u.XpTotal)
                .Select(u => new
                {
                    u.Id,
                    u.Nome,
                    u.FotoUrl,
                    u.XpTotal,
                    u.Nivel
                })
                .ToListAsync();

            // Monta o top 3
            var top3 = usuarios
                .Take(3)
                .Select((u, index) => new RankingItemDto
                {
                    Posicao = index + 1,
                    UsuarioId = u.Id,
                    Nome = u.Nome,
                    FotoUrl = u.FotoUrl,
                    XpTotal = u.XpTotal,
                    Nivel = u.Nivel
                })
                .ToList();

            // Posição do usuário autenticado no ranking geral
            var posicaoAtual = usuarios.FindIndex(u => u.Id == usuarioId);
            RankingItemDto? usuarioAtual = null;

            if (posicaoAtual >= 0)
            {
                var u = usuarios[posicaoAtual];
                usuarioAtual = new RankingItemDto
                {
                    Posicao = posicaoAtual + 1,
                    UsuarioId = u.Id,
                    Nome = u.Nome,
                    FotoUrl = u.FotoUrl,
                    XpTotal = u.XpTotal,
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
