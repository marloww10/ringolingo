import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ringolingo/models/missao_model.dart';
import 'package:ringolingo/models/ringo_model.dart';
import 'package:ringolingo/pages/chat_page.dart';
import 'package:ringolingo/pages/level_up_page.dart';
import 'package:ringolingo/pages/perfil_page.dart';
import 'package:ringolingo/providers/auth_provider.dart';
import 'package:ringolingo/services/analytics_service.dart';
import 'package:ringolingo/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _streak = 0;
  int _nivel = 1;
  int _xpDoNivel = 0;
  int _xpNecessario = 200;
  int _xpTotal = 0;
  bool _carregando = true;
  bool _erroMissoes = false;
  bool _erroRingos = false;
  String? _mensagemFixada;
  int _ultimoXpVerificado = -1;
  bool _mostrarXp = false;
  int _xpGanhadoRecente = 0;
  String? _ultimoRingoNome;

  List<MissaoModel> _missoes = [];
  List<RingoModel> _ringos = [];

  @override
  void initState() {
    super.initState();
    _carregarTudo();
  }

  Future<void> _carregarTudo() async {
    setState(() {
      _carregando = true;
      _erroMissoes = false;
      _erroRingos = false;
    });
    await Future.wait([
      _carregarDados(),
      _buscarPersonas(),
      _buscarMissoes(),
      _buscarUltimoRingo(),
    ]);
  }

  Future<void> _buscarPersonas() async {
    final personas = await ApiService.buscarPersonas();
    if (mounted) {
      if (personas != null) {
        personas.sort((a, b) => a.nivelNecessario.compareTo(b.nivelNecessario));

        setState(() => _ringos = personas);
      } else {
        AnalyticsService.erroCarregarPersonas();
        setState(() => _erroRingos = true);
      }
    }
  }

  Future<void> _buscarUltimoRingo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ultimoRingoNome = prefs.getString('ultimo_ringo_acessado');
    });
  }

  Future<void> _buscarMissoes() async {
    final token = AuthProvider().token;
    if (token == null) return;
    final missoes = await ApiService.buscarMissoes(token);
    if (mounted) {
      if (missoes != null) {
        setState(() => _missoes = missoes);
      } else {
        setState(() => _erroMissoes = true);
      }
    }
  }

  Future<void> _carregarDados() async {
    final auth = AuthProvider();
    final token = auth.token;
    final nivelAnterior = auth.nivel ?? 1;
    final streakAnterior = auth.streak ?? 0;

    if (token == null) {
      setState(() => _carregando = false);
      return;
    }

    final resultados = await Future.wait([
      ApiService.buscarStreak(token),
      ApiService.buscarXp(token),
    ]);

    final streak = resultados[0] as int;
    final xpInfo = resultados[1] as XpInfo?;

    const streaksMarcantes = [3, 7, 14, 30];
    if (streaksMarcantes.contains(streak) && streak != streakAnterior) {
      AnalyticsService.streakAtingido(streak);
    }
    if (xpInfo != null) {
      final xpAnterior = auth.xpTotal ?? 0;

      // Dispara o balão se o XP subiu (e não é a primeira carga do app)
      if (xpInfo.xpTotal > xpAnterior && xpAnterior > 0) {
        setState(() {
          _xpGanhadoRecente = xpInfo.xpTotal - xpAnterior;
          _mostrarXp = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _mostrarXp = false);
        });
      }

      // Lógica de Level Up
      if (xpInfo.nivel > nivelAnterior) {
        AnalyticsService.nivelSubiu(xpInfo.nivel);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LevelUpPage(novoNivel: xpInfo.nivel),
          ),
        );
      }

      auth.atualizarXp(
        xpInfo.nivel,
        xpInfo.xpTotal,
        xpInfo.xpDoNivel,
        xpInfo.xpNecessarioProximoNivel,
      );
      auth.atualizarStreak(streak);
    }

    if (mounted) {
      setState(() {
        _streak = streak;
        _nivel = xpInfo?.nivel ?? auth.nivel ?? 1;
        _xpDoNivel = xpInfo?.xpDoNivel ?? auth.xpDoNivel ?? 0;
        _xpTotal = xpInfo?.xpTotal ?? auth.xpTotal ?? 0;
        _xpNecessario =
            xpInfo?.xpNecessarioProximoNivel ??
            auth.xpNecessarioProximoNivel ??
            500;
        _carregando = false;
      });
    }
  }

  String _obterSaudacaoProgresso() {
    if (_mensagemFixada == null || _ultimoXpVerificado != _xpTotal) {
      _mensagemFixada = _gerarNovaSaudacao();
      _ultimoXpVerificado = _xpTotal; // Salva o XP atual para não trocar mais
    }
    return _mensagemFixada!;
  }

  String _gerarNovaSaudacao() {
    final random = Random();
    final progresso = _xpNecessario > 0 ? (_xpDoNivel / _xpNecessario) : 0.0;

    if (_streak >= 30) {
      final lendarias = [
        '$_streak dias invicto! 👑',
        'Voando no inglês! 🚀',
        'Lenda do Ringo! 🔥',
        '$_streak dias de foco! 🏆',
        'Ofensiva brutal! 🤩',
      ];
      return lendarias[random.nextInt(lendarias.length)];
    }

    if (_streak >= 14) {
      final fortes = [
        '$_streak dias no ritmo! 🎯',
        'Hábito formado! 🧠',
        'Orgulho do Ringo! 🍎',
        '$_streak dias seguidos! 👏',
        'Firme e forte! 🔑',
      ];
      return fortes[random.nextInt(fortes.length)];
    }

    if (_streak >= 3) {
      final iniciais = [
        'Belo ritmo! 💪',
        'Motor aquecido! 🚗',
        'Boa ofensiva! ✨',
        'Mantenha a ofensiva! 🔥',
        '$_streak dias! Mandou bem. 🌱',
      ];
      return iniciais[random.nextInt(iniciais.length)];
    }

    if (progresso >= 0.8) {
      final quaseLa = [
        'Quase Nv. ${_nivel + 1}! ⚡',
        'Nível novo chegando! 🏅',
        'Falta pouco! 🏃‍♂️',
        'Barra quase cheia! 🔋',
        'Sprint final! 🏁',
      ];
      return quaseLa[random.nextInt(quaseLa.length)];
    }

    if (_xpDoNivel == 0 && _xpTotal == 0) {
      final novato = ['Bem-vindo! 🎉', 'Vamos começar? 🗺️'];
      return novato[random.nextInt(novato.length)];
    } else if (_xpDoNivel == 0) {
      final preguica = [
        'Bora praticar? 🕒',
        'Senti sua falta! 🥺',
        '5 minutinhos hoje? 🚀',
        'Foco na fluência! 🧠',
        'Pratique agora! ⏳',
      ];
      return preguica[random.nextInt(preguica.length)];
    }

    final gerais = [
      'Belo progresso! 😍',
      'Continue assim! 🗣️',
      'Ringo tá orgulhoso! 🍎',
      'Mandando bem! 🎯',
      'Belo vocabulário! 🧠',
      'You got this! 👊',
    ];
    return gerais[random.nextInt(gerais.length)];
  }

  RingoModel? _proximoRingoADesbloquear() {
    final bloqueados = _ringos
        .where((r) => r.nivelNecessario > _nivel)
        .toList();
    if (bloqueados.isEmpty) return null;
    bloqueados.sort((a, b) => a.nivelNecessario.compareTo(b.nivelNecessario));
    return bloqueados.first;
  }

  int _xpParaProximoRingo(RingoModel ringo) {
    int xpTotal = 0;
    for (int n = _nivel; n < ringo.nivelNecessario; n++) {
      xpTotal += _xpNecessarioPorNivel(n);
    }
    return (xpTotal - _xpDoNivel).clamp(0, 999999);
  }

  int _xpNecessarioPorNivel(int nivel) {
    const tabela = {
      1: 200,
      2: 300,
      3: 450,
      4: 550,
      5: 700,
      6: 900,
      7: 1200,
      8: 1600,
      9: 2100,
      10: 2800,
      11: 3700,
      12: 5000,
      13: 6800,
      14: 9000,
      15: 12000,
      16: 16000,
      17: 21000,
      18: 28000,
      19: 37000,
      20: 50000,
    };
    return tabela[nivel] ?? 50000;
  }

  @override
  Widget build(BuildContext context) {
    final nomeCompleto = AuthProvider().nomeUsuario ?? 'Usuário';

    // Lógica para pegar a primeira palavra e formatar (Ex: "MARLON FRANCO" vira "Marlon")
    final primeiroNome = nomeCompleto.split(' ').first;
    final nomeFormatado = primeiroNome.isNotEmpty
        ? primeiroNome[0].toUpperCase() +
              primeiroNome.substring(1).toLowerCase()
        : "Usuário";
    final progresso = _xpNecessario > 0
        ? (_xpDoNivel / _xpNecessario).clamp(0.0, 1.0)
        : 0.0;
    final proximoRingo = _proximoRingoADesbloquear();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text("Sair do app"),
              content: const Text("Deseja sair do RingoLingo?"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    "Não",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    SystemNavigator.pop();
                  },
                  child: const Text(
                    "Sim, sair",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Olá, $nomeFormatado!',
                            style: GoogleFonts.poppins(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 2,
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    '🔥',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 4),
                                  _carregando
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFFFF6B00),
                                          ),
                                        )
                                      : Text(
                                          '$_streak',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () {
                                AnalyticsService.homePerfilAberto();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PerfilPage(),
                                  ),
                                ).then((_) => setState(() {}));
                              },
                              child: CircleAvatar(
                                radius: 22,
                                backgroundImage:
                                    AuthProvider().fotoUrl != null &&
                                        AuthProvider().fotoUrl!.isNotEmpty
                                    ? (AuthProvider().fotoUrl!.startsWith(
                                            'http',
                                          )
                                          ? NetworkImage(
                                                  AuthProvider().fotoUrl!,
                                                )
                                                as ImageProvider
                                          : FileImage(
                                              File(AuthProvider().fotoUrl!),
                                            ))
                                    : const AssetImage(
                                        'lib/assets/ringoEntrevistador.png',
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF4FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Seu progresso',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _carregando
                                        ? 'Carregando...'
                                        : _obterSaudacaoProgresso(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Nv.$_nivel',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                  color: Color(0xFF4DA3FF),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progresso,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFD0E4FF),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF4DA3FF),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$_xpDoNivel / $_xpNecessario XP',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (!_carregando && proximoRingo != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '🎯',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Faltam ${_xpParaProximoRingo(proximoRingo)} XP para o ${proximoRingo.nome}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(0xFF4DA3FF),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    if (_ultimoRingoNome != null && _ringos.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Builder(
                            builder: (context) {
                              final ringoRetomada = _ringos.firstWhere(
                                (r) => r.nome == _ultimoRingoNome,
                                orElse: () => _ringos.first,
                              );

                              return GestureDetector(
                                onTap: () {
                                  AnalyticsService.homeRingoAberto(
                                    ringoRetomada.nome,
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ChatPage(ringo: ringoRetomada),
                                    ),
                                  ).then((_) {
                                    _carregarDados();
                                    _buscarMissoes();
                                    _buscarUltimoRingo();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF4FF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: const Border(
                                      bottom: BorderSide(
                                        color: Color(0xFF4DA3FF),
                                        width: 6,
                                      ),
                                      left: BorderSide(
                                        color: Color(0xFF4DA3FF),
                                        width: 2,
                                      ),
                                      right: BorderSide(
                                        color: Color(0xFF4DA3FF),
                                        width: 2,
                                      ),
                                      top: BorderSide(
                                        color: Color(0xFF4DA3FF),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Image.network(
                                        'https://ringolingo-production.up.railway.app${ringoRetomada.imagemUrl}',
                                        height: 50,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.person,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Continuar conversa com",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              ringoRetomada.nome,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Color(0xFF4DA3FF),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                            height: 24,
                          ), // Espaço antes de começar os Ringos em Destaque
                        ],
                      ),
                    Text(
                      'Ringo em destaque',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: _erroRingos
                          ? Center(
                              child: TextButton.icon(
                                onPressed: () {
                                  setState(() => _erroRingos = false);
                                  _buscarPersonas();
                                },
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  color: Color(0xFF4DA3FF),
                                ),
                                label: Text(
                                  'Tentar novamente',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF4DA3FF),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(
                              height:
                                  210, // ⬅️ Isso impede o overflow! Delimita a altura da lista.
                              child: ListView.builder(
                                padding: const EdgeInsets.only(bottom: 20),
                                scrollDirection: Axis.horizontal,
                                itemCount: _ringos.isEmpty ? 3 : _ringos.length,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  if (_ringos.isEmpty) {
                                    return _skeletonRingo();
                                  }
                                  final ringo = _ringos[index];
                                  final desbloqueado =
                                      _nivel >= ringo.nivelNecessario;

                                  return GestureDetector(
                                    onTap: desbloqueado
                                        ? () {
                                            AnalyticsService.homeRingoAberto(
                                              ringo.nome,
                                            );
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    ChatPage(ringo: ringo),
                                              ),
                                            ).then((_) {
                                              _carregarDados();
                                              _buscarMissoes();
                                              _buscarUltimoRingo();
                                            });
                                          }
                                        : () {
                                            AnalyticsService.homeRingoBloqueadoClick(
                                              ringo.nome,
                                            );
                                            _mostrarDialogBloqueado(ringo);
                                          },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border(
                                          bottom: BorderSide(
                                            color: desbloqueado
                                                ? const Color(0xFF4DA3FF)
                                                : Colors.grey.shade400,
                                            width: 6,
                                          ),
                                          left: BorderSide(
                                            color: desbloqueado
                                                ? const Color(0xFF4DA3FF)
                                                : Colors.grey.shade400,
                                            width: 2,
                                          ),
                                          right: BorderSide(
                                            color: desbloqueado
                                                ? const Color(0xFF4DA3FF)
                                                : Colors.grey.shade400,
                                            width: 2,
                                          ),
                                          top: BorderSide(
                                            color: desbloqueado
                                                ? const Color(0xFF4DA3FF)
                                                : Colors.grey.shade400,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      padding: const EdgeInsets.only(top: 20),
                                      width: 150,
                                      child: Column(
                                        children: [
                                          Opacity(
                                            opacity: desbloqueado ? 1.0 : 0.4,
                                            child: Image.network(
                                              'https://ringolingo-production.up.railway.app${ringo.imagemUrl}',
                                              height: 100,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.person,
                                                    size: 60,
                                                    color: Colors.grey,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            ringo.nome,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            desbloqueado
                                                ? 'Disponível'
                                                : 'Nv. ${ringo.nivelNecessario}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: desbloqueado
                                                  ? const Color(0xFF4DA3FF)
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),

                    // ── MISSÕES ──
                    Text(
                      'Missões disponíveis',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_erroMissoes)
                      _erroInline(
                        mensagem: 'Não foi possível carregar as missões.',
                        onTentar: () {
                          setState(() => _erroMissoes = false);
                          _buscarMissoes();
                        },
                      )
                    else if (_missoes.isEmpty)
                      Column(
                        children: List.generate(3, (_) => _skeletonMissao()),
                      )
                    else
                      ..._missoes.map((missao) => _cartaoMissao(missao)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            if (_mostrarXp)
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, -20 * value),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4DA3FF),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 10),
                            ],
                          ),
                          child: Text(
                            "⭐ +$_xpGanhadoRecente XP",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _erroInline({
    required String mensagem,
    required VoidCallback onTentar,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Text(
              mensagem,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onTentar,
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4DA3FF)),
              label: Text(
                'Tentar novamente',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF4DA3FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _skeletonRingo() {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          _shimmerBox(width: 100, height: 100, radius: 8),
          const SizedBox(height: 8),
          _shimmerBox(width: 80, height: 12, radius: 6),
          const SizedBox(height: 6),
          _shimmerBox(width: 60, height: 10, radius: 6),
        ],
      ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    required double radius,
  }) {
    return _ShimmerBox(width: width, height: height, radius: radius);
  }

  Widget _skeletonMissao() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _shimmerBox(width: 36, height: 36, radius: 8),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(width: 120, height: 12, radius: 6),
                    const SizedBox(height: 6),
                    _shimmerBox(width: 180, height: 10, radius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _shimmerBox(width: 60, height: 24, radius: 12),
            ],
          ),
          const SizedBox(height: 12),
          _shimmerBox(width: double.infinity, height: 8, radius: 10),
          const SizedBox(height: 6),
          _shimmerBox(width: 60, height: 10, radius: 6),
        ],
      ),
    );
  }

  void _mostrarDialogBloqueado(RingoModel ringo) {
    final xpFaltando = _xpParaProximoRingo(ringo);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🔒 Ringo bloqueado'),
        content: Text(
          'Faltam $xpFaltando XP para desbloquear o ${ringo.nome}.\n\nAlcance o nível ${ringo.nivelNecessario} para liberar!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  Widget _cartaoMissao(MissaoModel missao) {
    final borderColor = missao.concluida
        ? Colors.green
        : const Color(0xFF4DA3FF);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: missao.concluida ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          bottom: BorderSide(color: borderColor, width: 6),
          left: BorderSide(color: borderColor, width: 2),
          right: BorderSide(color: borderColor, width: 2),
          top: BorderSide(color: borderColor, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(missao.icone, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      missao.titulo,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      missao.descricao,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              missao.concluida
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '✓ Feito',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4DA3FF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '+${missao.xpRecompensa} XP',
                        style: const TextStyle(
                          color: Color(0xFF4DA3FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: missao.progresso == 0 ? 0.02 : missao.progresso,
              minHeight: 8,
              backgroundColor: const Color(0xFFEEEEEE),
              valueColor: AlwaysStoppedAnimation<Color>(
                missao.concluida ? Colors.green : const Color(0xFF4DA3FF),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            missao.concluida
                ? 'Missão concluída!'
                : '${missao.progressoAtual}/${missao.meta}',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: missao.concluida ? Colors.green : Colors.grey,
              fontWeight: missao.concluida
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(widget.radius),
            ),
          ),
        );
      },
    );
  }
}
