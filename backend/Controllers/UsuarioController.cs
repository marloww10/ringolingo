using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Ringolingo.Data;
using Ringolingo.Models;
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
    }
}
