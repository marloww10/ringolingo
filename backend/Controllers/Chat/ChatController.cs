using System.Text;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Ringolingo.Data;
using Ringolingo.Models;
using Ringolingo.Models.Dto;
using Ringolingo.Service;
using Ringolingo.Service.IAService;
using Ringolingo.Service.XpService;

namespace Ringolingo.Controllers
{
    [ApiController]
    [Route("Chat")]
    public class ChatController : Controller
    {
        private readonly AppDbContext _context;
        private readonly IApiService _IaService;
        private readonly IXpService _xpService;
        private readonly IMissaoService _missaoService;

        private readonly IConquistaService _conquistaService;

        public ChatController(AppDbContext context, IApiService apiService, IXpService xpService, IMissaoService missaoService, IConquistaService conquistaService)
        {
            _context = context;
            _IaService = apiService; 
            _xpService = xpService;
            _missaoService = missaoService;
            _conquistaService = conquistaService;
        }

            [Authorize]
            [HttpPost]
            [Route("EnviarMensagem")]
            public async Task<ActionResult> EnviarMensagem([FromBody] ChatDto chatDto)
            {
                var usuarioIdClaim = User.FindFirst("UserId"); 
                if (usuarioIdClaim == null) return Unauthorized();
                var usuarioId = int.Parse(usuarioIdClaim.Value);

                Persona persona = await _context.Personas.FirstOrDefaultAsync(x => x.Nome == chatDto.NomePersona);
                if (persona == null) return NotFound("Persona não encontrada");

                var sessao = await _context.Sessaos
                    .FirstOrDefaultAsync(s => s.UsuarioId == usuarioId && s.PersonaId == persona.Id);

                if (sessao == null)
                {
                    sessao = new Sessao
                    {
                        UsuarioId = usuarioId,
                        PersonaId = persona.Id,
                        IniciadaEm = DateTime.Now
                    };
                    _context.Sessaos.Add(sessao);
                    await _context.SaveChangesAsync();
                }

                var historico = await _context.Mensagens
                    .Where(m => m.SessaoId == sessao.Id)
                    .OrderByDescending(m => m.EnviadaEm)
                    .Take(10)
                    .ToListAsync();

                var contextoBuilder = new StringBuilder();
                contextoBuilder.AppendLine($"Persona: {persona.Descricao}");
                contextoBuilder.AppendLine();

                foreach (var msg in historico.OrderBy(m => m.EnviadaEm))
                {
                    var remetente = msg.UsuarioId == usuarioId ? "Usuário" : persona.Nome;
                    contextoBuilder.AppendLine($"{remetente}: {msg.Conteudo}");
                }

                var contexto = contextoBuilder.ToString();

                var mensagem = new Mensagem
                {
                    Conteudo = chatDto.Conteudo,
                    UsuarioId = usuarioId,
                    SessaoId = sessao.Id,
                    PersonaId = persona.Id,
                    EnviadaEm = DateTime.Now
                };

                _context.Mensagens.Add(mensagem);

                // Try/catch na IA — se cair não perde a mensagem do usuário
                string respostaIa;
                try
                {
                    respostaIa = await _IaService.GerarResposta(chatDto.Conteudo, persona, contexto);
                }
                catch (Exception ex)
                                {
                                    // O espião que vai gritar o erro no log do Railway:
                                    Console.WriteLine("🚨 ERRO FATAL DO GEMINI: " + ex.Message);
                                    if (ex.InnerException != null)
                                    {
                                        Console.WriteLine("🚨 DETALHE INTERNO: " + ex.InnerException.Message);
                                    }

                                    await _context.SaveChangesAsync();
                                    return StatusCode(503, "Serviço de IA indisponível. Tente novamente.");
                                }

                var respostaMensagem = new Mensagem
                {
                    UsuarioId = usuarioId,
                    Conteudo = respostaIa,
                    PersonaId = persona.Id,
                    SessaoId = sessao.Id,
                    EnviadaEm = DateTime.Now
                };

                _context.Mensagens.Add(respostaMensagem);
                await _context.SaveChangesAsync();

                var hoje = DateTime.Today;
                var amanha = hoje.AddDays(1);

                var primeiraInteracaoHoje = !await _context.HistoricoXps
                    .AnyAsync(h => h.UsuarioId == usuarioId
                                && h.Motivo == "Primeira interação do dia"
                                && h.Data >= hoje
                                && h.Data < amanha);

                if (primeiraInteracaoHoje)
                    await _xpService.GanharXpPorPrimeiraInteracaoAsync(usuarioId);

                await _xpService.GanharXpPorMensagemAsync(usuarioId, persona.Id);

                await _missaoService.Conversador(usuarioId);
                await _missaoService.Tagarela(usuarioId);
                await _missaoService.Explorador(usuarioId);

                await _conquistaService.Mensageiro(usuarioId);
                await _conquistaService.Veterano(usuarioId);
                await _conquistaService.Acumulador(usuarioId);
                await _conquistaService.Evoluido(usuarioId);
                await _conquistaService.Colecionador(usuarioId);

                return Ok(new { mensagemUsuario = mensagem, respostaIa });
            }


        [Authorize]
        [HttpGet("Historico")]
        public async Task<IActionResult> GetHistorico( string NomePersona,int page = 1, int pageSize = 20)
        {

            var usuarioIdClaim = User.FindFirst("UserId");
            if (usuarioIdClaim == null) return Unauthorized();
            var usuarioId = int.Parse(usuarioIdClaim.Value);

            Persona persona = await _context.Personas.FirstOrDefaultAsync(x=> x.Nome == NomePersona);
            if (persona == null)
            {
                return NotFound("Persona não encontrada");
            }

            var sessao = await _context.Sessaos
                .FirstOrDefaultAsync(s => s.UsuarioId == usuarioId && s.PersonaId == persona.Id);

            if (sessao == null)
                return Ok(new List<Mensagem>());

            var mensagens = await _context.Mensagens
                .Where(m => m.SessaoId == sessao.Id)
                .OrderByDescending(m => m.EnviadaEm)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return Ok(mensagens);
        }
    


        [Authorize]
        [HttpDelete]
        [Route("ReiniciarChat")]
        public async Task<IActionResult> ReiniciarChat([FromQuery] string nomePersona)
        {
            var usuarioIdClaim = User.FindFirst("UserId");
            if (usuarioIdClaim == null) return Unauthorized();
            var usuarioId = int.Parse(usuarioIdClaim.Value);

            var persona = await _context.Personas.FirstOrDefaultAsync(x => x.Nome == nomePersona);
            if (persona == null) return NotFound("Persona não encontrada");

            var sessao = await _context.Sessaos
                .FirstOrDefaultAsync(s => s.UsuarioId == usuarioId && s.PersonaId == persona.Id);

            if (sessao == null) return Ok("Nenhuma sessão para reiniciar");

            var mensagens = await _context.Mensagens
                .Where(m => m.SessaoId == sessao.Id)
                .ToListAsync();

            _context.Mensagens.RemoveRange(mensagens);
            _context.Sessaos.Remove(sessao);

            await _context.SaveChangesAsync();

            return Ok("Chat reiniciado com sucesso");
        }
}
}
