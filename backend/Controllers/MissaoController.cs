using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Ringolingo.Data;

namespace Ringolingo.Controllers
{

    [ApiController]
    [Route("Missões")]
    public class MissaoController : ControllerBase
    {
        private readonly AppDbContext _context;

        public MissaoController(AppDbContext context)
        {
           _context = context; 
        }

        [Authorize]
        [HttpGet]
        public async Task<IActionResult> GetMissoes()
        {
            var usuarioIdClaim = User.FindFirst("UserId");
            if (usuarioIdClaim == null) return Unauthorized();
            var usuarioId = int.Parse(usuarioIdClaim.Value);

            var missoes = await _context.missaos.ToListAsync();

            var progresso = await _context.missaoUsuarios
                .Where(mu => mu.UsuarioId == usuarioId && mu.Data == DateTime.Today)
                .ToListAsync();

            var resultado = missoes.Select(m => new
            {
                m.Id,
                m.Nome,
                m.Descricao,
                m.Emoji,
                m.XpRecompensa,
                Progresso = progresso.FirstOrDefault(p => p.MissaoId == m.Id)?.Progresso ?? 0,
                Concluida = progresso.FirstOrDefault(p => p.MissaoId == m.Id)?.Concluida ?? false
            });

            return Ok(resultado);
        }
    }
}