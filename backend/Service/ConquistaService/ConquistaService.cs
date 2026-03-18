using Microsoft.EntityFrameworkCore;
using Ringolingo.Data;
using Ringolingo.Models;
using Ringolingo.Service.XpService;
namespace Ringolingo.Service
{
    public class ConquistaService : IConquistaService
    {
        private readonly AppDbContext _context;
        private readonly IXpService _xpService;

        public ConquistaService(AppDbContext context, IXpService xpService)
        {
            _context = context; _xpService = xpService;
        }

        public async Task Mensageiro(int usuarioId)
        {

            var mensagensEnviadas = await _context.HistoricoXps
            .CountAsync(h => h.UsuarioId == usuarioId && h.Motivo == "Mensagem enviada");

            var conquistaMensageiro = await _context.Conquistas
            .FirstOrDefaultAsync(c => c.Titulo == "Mensageiro");

            if (conquistaMensageiro != null && mensagensEnviadas >= 100)
            {
                var jaTem = await _context.conquistaUsuarios
                    .AnyAsync(cu => cu.UsuarioId == usuarioId && cu.ConquistaId == conquistaMensageiro.Id);
                    
            if (!jaTem)
            {
                var conquistaUsuario = new ConquistaUsuario
                    {
                        UsuarioId = usuarioId,
                        ConquistaId = conquistaMensageiro.Id,
                        DataConquista = DateTime.Now
                    };

                _context.conquistaUsuarios.Add(conquistaUsuario);

                var usuario = await _context.Usuarios.FindAsync(usuarioId);
                if (usuario != null)
                {
                    usuario.XpTotal += conquistaMensageiro.xpGanhado;
                    usuario.XpDoNivel += conquistaMensageiro.xpGanhado;

                    int xpNecessario = _xpService.XpNecessarioParaProximoNivel(usuario.Nivel);
                    if (usuario.XpDoNivel >= xpNecessario)
                    {
                        usuario.Nivel++;
                        usuario.XpDoNivel -= xpNecessario;
                    }

                     _context.HistoricoXps.Add(new HistoricoXp
                    {
                        UsuarioId = usuarioId,
                        Motivo = "ConquistaMensageiro",
                        Quantidade = conquistaMensageiro.xpGanhado,
                        Data = DateTime.Now
                    });

                    await _context.SaveChangesAsync();
                }
            }
            }
        }


        public async Task Veterano(int usuarioId)
        {
            var hoje = DateTime.Today;
            var diasConsecutivos = 0;

            for (int i = 0; i < 30; i++)
            {
                var dia = hoje.AddDays(-i);
                var temAtividade = await _context.HistoricoXps
                    .AnyAsync(h => h.UsuarioId == usuarioId && h.Data.Date == dia);

                if (temAtividade) diasConsecutivos++;
                else break;
            }

            var conquista = await _context.Conquistas
                .FirstOrDefaultAsync(c => c.Titulo == "Veterano");

            if (conquista != null && diasConsecutivos >= 30)
            {
                var jaTem = await _context.conquistaUsuarios
                    .AnyAsync(cu => cu.UsuarioId == usuarioId && cu.ConquistaId == conquista.Id);

                if (!jaTem)
                {
                    _context.conquistaUsuarios.Add(new ConquistaUsuario
                    {
                        UsuarioId = usuarioId,
                        ConquistaId = conquista.Id,
                        DataConquista = DateTime.Now
                    });

                    var usuario = await _context.Usuarios.FindAsync(usuarioId);
                    if (usuario != null)
                    {
                        usuario.XpTotal += conquista.xpGanhado;
                        usuario.XpDoNivel += conquista.xpGanhado;

                        int xpNecessario = _xpService.XpNecessarioParaProximoNivel(usuario.Nivel);
                        if (usuario.XpDoNivel >= xpNecessario)
                        {
                            usuario.Nivel++;
                            usuario.XpDoNivel -= xpNecessario;
                        }

                        _context.HistoricoXps.Add(new HistoricoXp
                        {
                            UsuarioId = usuarioId,
                            Motivo = "ConquistaVeterano",
                            Quantidade = conquista.xpGanhado,
                            Data = DateTime.Now
                        });

                        await _context.SaveChangesAsync();
                    }
                }
            }
        }


        public async Task Acumulador(int usuarioId)
        {
            var usuario = await _context.Usuarios.FindAsync(usuarioId);

            var conquista = await _context.Conquistas
                .FirstOrDefaultAsync(c => c.Titulo == "Acumulador");

            if (conquista != null && usuario != null && usuario.XpTotal >= 5000)
            {
                var jaTem = await _context.conquistaUsuarios
                    .AnyAsync(cu => cu.UsuarioId == usuarioId && cu.ConquistaId == conquista.Id);

                if (!jaTem)
                {
                    _context.conquistaUsuarios.Add(new ConquistaUsuario
                    {
                        UsuarioId = usuarioId,
                        ConquistaId = conquista.Id,
                        DataConquista = DateTime.Now
                    });

                    if (usuario != null)
                    {
                        usuario.XpTotal += conquista.xpGanhado;
                        usuario.XpDoNivel += conquista.xpGanhado;

                        int xpNecessario = _xpService.XpNecessarioParaProximoNivel(usuario.Nivel);
                        if (usuario.XpDoNivel >= xpNecessario)
                        {
                            usuario.Nivel++;
                            usuario.XpDoNivel -= xpNecessario;
                        }

                        _context.HistoricoXps.Add(new HistoricoXp
                        {
                            UsuarioId = usuarioId,
                            Motivo = "ConquistaAcumulador",
                            Quantidade = conquista.xpGanhado,
                            Data = DateTime.Now
                        });

                        await _context.SaveChangesAsync();
                    }
                }
            }
        }

        public async Task Evoluido(int usuarioId)
        {
            var usuario = await _context.Usuarios.FindAsync(usuarioId);

            var conquista = await _context.Conquistas
                .FirstOrDefaultAsync(c => c.Titulo == "Evoluído");

            if (conquista != null && usuario != null && usuario.Nivel >= 20)
            {
                var jaTem = await _context.conquistaUsuarios
                    .AnyAsync(cu => cu.UsuarioId == usuarioId && cu.ConquistaId == conquista.Id);

                if (!jaTem)
                {
                    _context.conquistaUsuarios.Add(new ConquistaUsuario
                    {
                        UsuarioId = usuarioId,
                        ConquistaId = conquista.Id,
                        DataConquista = DateTime.Now
                    });

                    usuario.XpTotal += conquista.xpGanhado;
                    usuario.XpDoNivel += conquista.xpGanhado;

                    int xpNecessario = _xpService.XpNecessarioParaProximoNivel(usuario.Nivel);
                    if (usuario.XpDoNivel >= xpNecessario)
                    {
                        usuario.Nivel++;
                        usuario.XpDoNivel -= xpNecessario;
                    }

                    _context.HistoricoXps.Add(new HistoricoXp
                    {
                        UsuarioId = usuarioId,
                        Motivo = "ConquistaEvoluido",
                        Quantidade = conquista.xpGanhado,
                        Data = DateTime.Now
                    });

                    await _context.SaveChangesAsync();
                }
            }
        }

        public async Task Colecionador(int usuarioId)
        {
            var personasDistintas = await _context.Sessaos
                .Where(s => s.UsuarioId == usuarioId)
                .Select(s => s.PersonaId)
                .Distinct()
                .CountAsync();

            var conquista = await _context.Conquistas
                .FirstOrDefaultAsync(c => c.Titulo == "Colecionador");

            if (conquista != null && personasDistintas >= 5)
            {
                var jaTem = await _context.conquistaUsuarios
                    .AnyAsync(cu => cu.UsuarioId == usuarioId && cu.ConquistaId == conquista.Id);

                if (!jaTem)
                {
                    _context.conquistaUsuarios.Add(new ConquistaUsuario
                    {
                        UsuarioId = usuarioId,
                        ConquistaId = conquista.Id,
                        DataConquista = DateTime.Now
                    });

                    var usuario = await _context.Usuarios.FindAsync(usuarioId);
                    if (usuario != null)
                    {
                        usuario.XpTotal += conquista.xpGanhado;
                        usuario.XpDoNivel += conquista.xpGanhado;

                        int xpNecessario = _xpService.XpNecessarioParaProximoNivel(usuario.Nivel);
                        if (usuario.XpDoNivel >= xpNecessario)
                        {
                            usuario.Nivel++;
                            usuario.XpDoNivel -= xpNecessario;
                        }

                        _context.HistoricoXps.Add(new HistoricoXp
                        {
                            UsuarioId = usuarioId,
                            Motivo = "ConquistaColecionador",
                            Quantidade = conquista.xpGanhado,
                            Data = DateTime.Now
                        });

                        await _context.SaveChangesAsync();
                    }
                }
            }
        }

        
    }
}