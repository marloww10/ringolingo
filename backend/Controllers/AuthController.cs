using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Ringolingo.Data;
using Ringolingo.Models;
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
        public async Task<ActionResult> LoginSocial(AppDbContext context)
        {
            var email = User.FindFirst("email")?.Value;
            var supabaseId = User.FindFirst("sub")?.Value;

            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(supabaseId))
                return Unauthorized("Token inválido ou incompleto.");

           
            var usuario = await context.Usuarios.FirstOrDefaultAsync(u => u.Email == email);

            if (usuario == null)
            {
                
                usuario = new Usuario
                {
                    Email = email,
                    Nome = email.Split('@')[0],
                    SupabaseId = supabaseId,
                    
                };

                context.Usuarios.Add(usuario);
                await context.SaveChangesAsync();
            }

           
            return Ok(new
            {
                usuario.Id,
                usuario.Email,
                usuario.Nome,
                usuario.Nivel,
                usuario.XpTotal,
                usuario.Premium
            });
        }

    }
}
