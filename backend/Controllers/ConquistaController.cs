using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Ringolingo.Data;
using Ringolingo.Models.Dto;
namespace Ringolingo.Controllers
{
    
    [ApiController]
    [Route("Conquista")]
    public class ConquistaController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ConquistaController(AppDbContext context)
        {
            _context = context;
        }

        [Authorize]
        [HttpGet]
        public async Task<IActionResult> GetConquistas()
        {
            var usuarioIdClaim = User.FindFirst("UserId");
            if (usuarioIdClaim == null) return Unauthorized();
            var usuarioId = int.Parse(usuarioIdClaim.Value);

            var conquistas = await _context.Conquistas.ToListAsync();

            var desbloqueadas = await _context.conquistaUsuarios
                .Where(ua => ua.UsuarioId == usuarioId)
                .ToListAsync();

            var resultado = conquistas.Select(c => new ConquistaDto
            {
                Id = c.Id,
                Nome = c.Titulo,
                Descricao = c.Descricao,
                XpGanho = c.xpGanhado,
                Desbloqueada = desbloqueadas.Any(ua => ua.ConquistaId == c.Id),
                DataConquista = desbloqueadas.FirstOrDefault(ua => ua.ConquistaId == c.Id)?.DataConquista
            });

            return Ok(resultado);
        }




    
    }
    }
