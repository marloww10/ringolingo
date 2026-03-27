using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Ringolingo.Models.Dto;
using Ringolingo.Service.AuthService;

namespace Ringolingo.Controllers
{
    [ApiController]
    [Route("Controller")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost]
        [Route("CadastroUsuario")]
        public async Task<ActionResult> CadastrarUsuario([FromBody] UsuarioCadastrar usuarioCadastrar)
        {
            var resposta = await _authService.CadastroUsuario(usuarioCadastrar);
            return Ok(resposta);
        }

        [HttpPost]
        [Route("LoginUsuario")]
        public async Task<ActionResult> LoginUsuario([FromBody] UsuarioLogin usuarioLogin)
        {
            var resposta = await _authService.LoginUsuario(usuarioLogin);
            return Ok(resposta);
        }


        [Authorize(AuthenticationSchemes = "Supabase")]
        [HttpGet("loginSocial")]
        public async Task<ActionResult> LoginSocial()
        {
            var email = User.FindFirst("email")?.Value;
            var supabaseId = User.FindFirst("sub")?.Value;

            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(supabaseId))
                return Unauthorized("Token inválido ou incompleto.");

            var resposta = await _authService.LoginSocial(email, supabaseId);
            return Ok(resposta);
        }

    }
}
