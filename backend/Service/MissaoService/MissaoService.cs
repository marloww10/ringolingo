


namespace Ringolingo.Service
{
    public class MissaoService : IMissaoService
    {
        private readonly AppDbContext _context;
        private readonly IXpService _xpService;

        public MissaoService(AppDbContext context, IXpService xpService)
        {
            _context = context; _xpService = xpService;
        }

    public async Task ProcessarMissao(int usuarioId, string nomeMissao, string motivoHistorico, int progresso)
    {
        var missao = await _context.missaos.FirstOrDefaultAsync(m => m.Nome == nomeMissao);
        if (missao == null) return;

        var missaoUsuario = await _context.missaoUsuarios
            .FirstOrDefaultAsync(mu => mu.UsuarioId == usuarioId
                                    && mu.MissaoId == missao.Id
                                    && mu.Data == DateTime.Today);

        if (missaoUsuario == null)
        {
            missaoUsuario = new MissaoUsuario
            {
                UsuarioId = usuarioId,
                MissaoId = missao.Id,
                Progresso = 0,
                Data = DateTime.Today,
                Concluida = false
            };
            _context.missaoUsuarios.Add(missaoUsuario);
        }

        missaoUsuario.Progresso = progresso; 

        if (missaoUsuario.Progresso >= missao.QuantidadeNecessaria && !missaoUsuario.Concluida)
        {
            missaoUsuario.Concluida = true;

            var usuario = await _context.Usuarios.FindAsync(usuarioId);

            if (usuario != null)
            {
                usuario.XpTotal += missao.XpRecompensa;
                usuario.XpDoNivel += missao.XpRecompensa;

                int xpNecessario = _xpService.XpNecessarioParaProximoNivel(usuario.Nivel);
                if (usuario.XpDoNivel >= xpNecessario)
                {
                    usuario.Nivel++;
                    usuario.XpDoNivel -= xpNecessario;
                }

                _context.HistoricoXps.Add(new HistoricoXp
                {
                    UsuarioId = usuarioId,
                    Motivo = motivoHistorico,
                    Quantidade = missao.XpRecompensa,
                    Data = DateTime.Now
                });
            }
        }

        await _context.SaveChangesAsync();
    }


    public async Task Conversador(int usuarioId)
    {
        var progresso = await _context.HistoricoXps
            .CountAsync(h => h.UsuarioId == usuarioId
                        && h.Motivo == "Mensagem enviada"
                        && h.Data.Date == DateTime.Today);

        await ProcessarMissao(usuarioId, "Conversador", "MissaoConversador", progresso);
    }

    public async Task Tagarela(int usuarioId)
    {
        var progresso = await _context.HistoricoXps
            .CountAsync(h => h.UsuarioId == usuarioId
                        && h.Motivo == "Mensagem enviada"
                        && h.Data.Date == DateTime.Today);

        await ProcessarMissao(usuarioId, "Tagarela", "MissaoTagarela", progresso);
    }

     public async Task Explorador(int usuarioId)
    {
      var progresso = await _context.HistoricoXps
    .Where(h => h.UsuarioId == usuarioId
        && h.Motivo == "Mensagem enviada"
            && h.Data.Date == DateTime.Today)
        .Select(h => h.PersonaId)
        .Distinct()
        .CountAsync();

    await ProcessarMissao(usuarioId, "Explorador", "MissaoExplorador", progresso);
     }
 }
 }

