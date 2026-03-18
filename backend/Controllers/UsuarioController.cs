using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
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
        public ActionResult<Response<string>> GetUsuarioToken()
        {
            Response<string> response = new Response<string>();
            response.Mensagem = "Acessado";
            return Ok(response);
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


        [HttpPut("Foto")]
        public async Task<IActionResult> AtualizarFoto(int usuarioId, [FromBody] AtualizarFotoDto atualizarFotoDto)
        {
            var usuario = await _context.Usuarios.FindAsync(usuarioId);
            if (usuario == null)
                return NotFound("Usuário não encontrado");

            usuario.FotoUrl = atualizarFotoDto.FotoUrl;

            _context.Usuarios.Update(usuario);
            await _context.SaveChangesAsync();

            return Ok(new { usuario.Id, usuario.Nome, usuario.FotoUrl });
        }
    }
}
