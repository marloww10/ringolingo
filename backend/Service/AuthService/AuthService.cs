using Microsoft.EntityFrameworkCore;
using Ringolingo.Data;
using Ringolingo.Models;
using Ringolingo.Models.Dto;
using Ringolingo.Service.SenhaService;
using Ringolingo.Service.XpService;

namespace Ringolingo.Service.AuthService
{
    public class AuthService : IAuthService
    {
        private readonly AppDbContext _context;
        private readonly ISenhaService _senhaService;
        private readonly IXpService _xpService;

        public AuthService(AppDbContext dbContext, ISenhaService senhaService, IXpService xpService)
        {
            _context = dbContext; 
            _senhaService = senhaService; 
            _xpService = xpService;
        }

        public async Task<Response<UsuarioCadastrar>> CadastroUsuario (UsuarioCadastrar usuarioCadastrar)
        {
            Response<UsuarioCadastrar> resposta = new Response<UsuarioCadastrar> ();

            try
            {
                if (await VerificarUsuarioExistente(usuarioCadastrar) == true)
                {
                    resposta.Dados = null;
                    resposta.Mensagem = "Nome/email já existentes";
                    resposta.status = false;
                    return resposta;
                }

                _senhaService.CriarSenhaHash(usuarioCadastrar.Senha, out byte[] SenhaHash, out byte[] SenhaSalt);

                Usuario usuario = new Usuario()
                {
                    Nome = usuarioCadastrar.Nome,
                    Email = usuarioCadastrar.Email,
                    SenhaHash = SenhaHash,
                    SenhaSalt = SenhaSalt,
                    SupabaseId = ""
                };

                await _context.AddAsync(usuario);
                await _context.SaveChangesAsync();

                resposta.Dados = usuarioCadastrar;
                resposta.Mensagem = "Usuario Cadastrado!";
                resposta.status = true; 
                return resposta;

            }
            catch (Exception ex)
            {
                resposta.Dados = null;
                resposta.Mensagem = ex.Message;
                resposta.status = false;
                return resposta;
            }
        }

        public async Task<Response<RespostaLogin>> LoginUsuario(UsuarioLogin usuarioLogin)
        {
            Response<RespostaLogin> resposta = new Response<RespostaLogin>();

            try
            {
                var usuario = await _context.Usuarios.FirstOrDefaultAsync(x => x.Email == usuarioLogin.Email);

                if (usuario == null)
                {
                    resposta.Dados = null;
                    resposta.Mensagem = "Credencias inválidadas";
                    resposta.status = false;
                    return resposta;
                }

                if (!_senhaService.VerificarSenhaHash(usuarioLogin.Senha, usuario.SenhaHash, usuario.SenhaSalt))
                {
                    resposta.Mensagem = "Credencias inválidadas";
                    resposta.status = false;
                    return resposta;
                }

                var token = _senhaService.CriarToken(usuario);

                var hoje = DateTime.Today;
                var amanha = hoje.AddDays(1);

                var jaGanhouHoje = await _context.HistoricoXps
                    .AnyAsync(h => h.UsuarioId == usuario.Id
                                && h.Motivo == "Login diário"
                                && h.Data >= hoje
                                && h.Data < amanha);

                if (!jaGanhouHoje)
                    await _xpService.GanharXpPorLoginAsync(usuario.Id);

                await _xpService.VerificarSequenciaDiasAsync(usuario.Id);

                resposta.Dados = new RespostaLogin
                {
                    Id = usuario.Id,
                    Nome = usuario.Nome,
                    Nivel = usuario.Nivel,
                    XpDoNivel = usuario.XpDoNivel,
                    Token = token,
                    XPTotal = usuario.XpTotal
                };
                resposta.Mensagem = "Usuario logado!";
                resposta.status = true;
                return resposta;
            }
            catch (Exception ex)
            {
                resposta.Mensagem = ex.Message;
                resposta.status = false;
                return resposta;
            }
        }

        public async Task<bool> VerificarUsuarioExistente (UsuarioCadastrar usuarioCadastrar)
        {
            var usuario = await _context.Usuarios.FirstOrDefaultAsync(x=> x.Nome == usuarioCadastrar.Nome || x.Email == usuarioCadastrar.Email);

            if (usuario == null)
            {
                return false;
            }
            else
            {
                return true;
            }
        }

        // CORREÇÃO: Método atualizado para receber o nome e evitar o valor null no Postgres do Railway
        public async Task<Response<RespostaLogin>> LoginSocial(string email, string supabaseId, string nome)
        {
            Response<RespostaLogin> resposta = new Response<RespostaLogin>();

            try
            {
                // Busca o usuário no banco do Railway
                var usuario = await _context.Usuarios.FirstOrDefaultAsync(u => u.SupabaseId == supabaseId || u.Email == email);

                if (usuario == null)
                {
                    // Se não existe, cria o registro com os dados do Google
                    usuario = new Usuario
                    {
                        Email = email,
                        Nome = nome ?? email.Split('@')[0], // Prioriza o nome real para evitar o 'null'
                        SupabaseId = supabaseId,
                        XpTotal = 0,
                        Nivel = 1,
                        XpDoNivel = 0,
                        // Inicializa campos de senha como vazios para o Postgres aceitar
                        SenhaHash = Array.Empty<byte>(),
                        SenhaSalt = Array.Empty<byte>()
                    };

                    _context.Usuarios.Add(usuario);
                    await _context.SaveChangesAsync();
                }
                else if (string.IsNullOrEmpty(usuario.SupabaseId))
                {
                    // Vincula o SupabaseId se ele ainda não estiver preenchido
                    usuario.SupabaseId = supabaseId;
                    await _context.SaveChangesAsync();
                }

                var token = _senhaService.CriarToken(usuario);

                var hoje = DateTime.Today;
                var amanha = hoje.AddDays(1);

                var jaGanhouHoje = await _context.HistoricoXps
                    .AnyAsync(h => h.UsuarioId == usuario.Id
                                && h.Motivo == "Login diário"
                                && h.Data >= hoje
                                && h.Data < amanha);

                if (!jaGanhouHoje)
                    await _xpService.GanharXpPorLoginAsync(usuario.Id);

                await _xpService.VerificarSequenciaDiasAsync(usuario.Id);

                resposta.Dados = new RespostaLogin
                {
                    Id = usuario.Id,
                    Nome = usuario.Nome,
                    Nivel = usuario.Nivel,
                    XpDoNivel = usuario.XpDoNivel,
                    Token = token,
                    XPTotal = usuario.XpTotal
                };
                resposta.Mensagem = "Usuario logado!";
                resposta.status = true;
                return resposta;
            }
            catch (Exception ex)
            {
                resposta.Mensagem = ex.Message;
                resposta.status = false;
                return resposta;
            }
        }
    }
}