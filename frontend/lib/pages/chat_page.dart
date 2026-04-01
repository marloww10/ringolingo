import 'package:flutter/material.dart';
import 'package:ringolingo/models/ringo_model.dart';
import 'package:ringolingo/providers/auth_provider.dart';
import 'package:ringolingo/services/analytics_service.dart';
import 'package:ringolingo/services/api_service.dart';

class ChatPage extends StatefulWidget {
  final RingoModel ringo;
  const ChatPage({super.key, required this.ringo});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _mensagemController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _mensagens = [];
  bool _digitando = false;
  bool _mostrarXp = false;
  bool _carregandoHistorico = true;

  late AnimationController _xpController;
  late Animation<double> _xpOpacity;
  late Animation<double> _xpOffset;

  @override
  void initState() {
    super.initState();
    AnalyticsService.chatAberto(widget.ringo.nome);
    _carregarHistorico();

    _xpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _xpOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_xpController);

    _xpOffset = Tween(
      begin: 0.0,
      end: -24.0,
    ).animate(CurvedAnimation(parent: _xpController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _mensagemController.dispose();
    _scrollController.dispose();
    _xpController.dispose();
    super.dispose();
  }

  Future<void> _carregarHistorico() async {
    final auth = AuthProvider();
    if (auth.id == null) {
      setState(() => _carregandoHistorico = false);
      return;
    }

    final historico = await ApiService.buscarHistorico(
      auth.id!,
      widget.ringo.nome,
      token: auth.token,
    );

    if (historico != null && mounted) {
      final mensagensConvertidas = <Map<String, dynamic>>[];

      for (final msg in historico.reversed) {
        final isUsuario =
            msg['usuarioId'] == auth.id &&
            msg['conteudo'] != null &&
            !_textoParecerRingo(msg['conteudo'] as String);

        if (isUsuario) {
          mensagensConvertidas.add({
            "remetente": "usuario",
            "texto": msg['conteudo'] ?? '',
            "hora": _extrairHora(msg['enviadaEm']),
          });
        } else {
          final partes = _parsearResposta(msg['conteudo'] ?? '');
          if (partes['english']!.isNotEmpty) {
            mensagensConvertidas.add({
              "remetente": "ringo",
              "partes": partes,
              "mostrarTraducao": false,
              "mostrarDica": false,
              "hora": _extrairHora(msg['enviadaEm']),
            });
          } else {
            mensagensConvertidas.add({
              "remetente": "usuario",
              "texto": msg['conteudo'] ?? '',
              "hora": _extrairHora(msg['enviadaEm']),
            });
          }
        }
      }

      setState(() {
        _mensagens.addAll(mensagensConvertidas);
        _carregandoHistorico = false;
      });

      _scrollParaBaixo();
    } else {
      setState(() => _carregandoHistorico = false);
    }
  }

  String _extrairHora(dynamic enviadaEm) {
    if (enviadaEm == null) return '';
    try {
      final dt = DateTime.parse(enviadaEm.toString()).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '';
    }
  }

  bool _textoParecerRingo(String texto) {
    return texto.contains('English:') || texto.contains("Teacher's Tip");
  }

  void _scrollParaBaixo() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _mostrarAnimacaoXp() async {
    if (mounted) {
      setState(() => _mostrarXp = true);
      _xpController.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) setState(() => _mostrarXp = false);
    }
  }

  Map<String, String> _parsearResposta(String texto) {
    String english = '';
    String portuguese = '';
    String tipEnglish = '';
    String tipPortuguese = '';

    final linhas = texto.split('\n');
    String secaoAtual = '';

    for (final linha in linhas) {
      final l = linha.trim();
      if (l.startsWith('English:')) {
        secaoAtual = 'english';
        final resto = l.replaceFirst('English:', '').trim();
        if (resto.isNotEmpty) english += '$resto\n';
      } else if (l.startsWith('Portuguese:')) {
        secaoAtual = 'portuguese';
        final resto = l.replaceFirst('Portuguese:', '').trim();
        if (resto.isNotEmpty) portuguese += '$resto\n';
      } else if (l.startsWith("Teacher's Tip (English):")) {
        secaoAtual = 'tipEnglish';
        final resto = l.replaceFirst("Teacher's Tip (English):", '').trim();
        if (resto.isNotEmpty) tipEnglish += '$resto\n';
      } else if (l.startsWith('Dica do Professor (Português):')) {
        secaoAtual = 'tipPortuguese';
        final resto = l
            .replaceFirst('Dica do Professor (Português):', '')
            .trim();
        if (resto.isNotEmpty) tipPortuguese += '$resto\n';
      } else if (l.isNotEmpty) {
        if (secaoAtual == 'english') {
          english += '$l\n';
        } else if (secaoAtual == 'portuguese') {
          portuguese += '$l\n';
        } else if (secaoAtual == 'tipEnglish') {
          tipEnglish += '$l\n';
        } else if (secaoAtual == 'tipPortuguese') {
          tipPortuguese += '$l\n';
        }
      }
    }

    return {
      'english': english.trim(),
      'portuguese': portuguese.trim(),
      'tipEnglish': tipEnglish.trim(),
      'tipPortuguese': tipPortuguese.trim(),
    };
  }

  Future<void> _reiniciarChat() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reiniciar conversa'),
        content: const Text(
          'O histórico desta conversa será apagado e o Ringo vai esquecer tudo que foi dito. Tem certeza?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final sucesso = await ApiService.reiniciarChat(
      token: AuthProvider().token ?? '',
      nomePersona: widget.ringo.nome,
    );

    if (!mounted) return;

    if (sucesso) {
      setState(() => _mensagens.clear());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível reiniciar. Tente novamente.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _enviarMensagem() async {
    final texto = _mensagemController.text.trim();
    if (texto.isEmpty || _digitando) return;

    AnalyticsService.chatMensagemEnviada(widget.ringo.nome);

    final agora = TimeOfDay.now();
    final hora =
        '${agora.hour.toString().padLeft(2, '0')}:${agora.minute.toString().padLeft(2, '0')}';

    setState(() {
      _mensagens.add({"remetente": "usuario", "texto": texto, "hora": hora});
      _mensagemController.clear();
      _digitando = true;
    });
    _scrollParaBaixo();

    final resposta = await ApiService.enviarMensagem(
      token: AuthProvider().token ?? "",
      conteudo: texto,
      persona: widget.ringo.nome,
    );

    setState(() {
      _digitando = false;
      if (resposta.sucesso) {
        final textoResposta = resposta.dados['respostaIa'] ?? "";
        final partes = _parsearResposta(textoResposta);
        _mensagens.add({
          "remetente": "ringo",
          "partes": partes,
          "mostrarTraducao": false,
          "mostrarDica": false,
          "hora": hora,
        });
      } else {
        AnalyticsService.erroChat(widget.ringo.nome);
        _mensagens.add({
          "remetente": "ringo",
          "partes": {
            "english": "Ops, algo deu errado!",
            "portuguese": "",
            "tipEnglish": "",
            "tipPortuguese": "",
          },
          "mostrarTraducao": false,
          "mostrarDica": false,
          "hora": hora,
        });
      }
    });

    if (resposta.sucesso) _mostrarAnimacaoXp();
    _scrollParaBaixo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset true é o padrão — o Scaffold encolhe
      // automaticamente quando o teclado sobe, fazendo a Column se ajustar
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: const Color(0xFFE8F1FF),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                'https://ringolingo-production.up.railway.app${widget.ringo.imagemUrl}',
              ),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.ringo.nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'online',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _reiniciarChat,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reiniciar conversa',
          ),
        ],
      ),
      // body é uma Column simples — sem Stack, sem SafeArea
      // O resizeToAvoidBottomInset faz o trabalho de subir tudo com o teclado
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _carregandoHistorico
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4DA3FF),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                        itemCount: _mensagens.length + (_digitando ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (_digitando && index == _mensagens.length) {
                            return _bolhaDigitando();
                          }
                          final msg = _mensagens[index];
                          final isUsuario = msg['remetente'] == 'usuario';
                          return _BolhaAnimada(
                            key: ValueKey(index),
                            child: isUsuario
                                ? _bolhaMensagem(
                                    msg['texto'],
                                    msg['hora'] ?? '',
                                  )
                                : _bolhaRingo(index, msg),
                          );
                        },
                      ),
                if (_mostrarXp)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: AnimatedBuilder(
                      animation: _xpController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _xpOffset.value),
                          child: Opacity(
                            opacity: _xpOpacity.value,
                            child: const Center(
                              child: Text(
                                '⭐ +10 XP',
                                style: TextStyle(
                                  color: Color(0xFF4DA3FF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          _campoMensagem(),
        ],
      ),
    );
  }

  Widget _campoMensagem() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Column(
        children: [
          const SizedBox(height: 6),
          Focus(
            onFocusChange: (_) => setState(() {}),
            child: Builder(
              builder: (context) {
                final focado = Focus.of(context).hasFocus;
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: focado
                          ? const Color(0xFF4DA3FF)
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _mensagemController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: "Digite uma mensagem...",
                            hintStyle: TextStyle(color: Colors.black38),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) => _enviarMensagem(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _mensagemController.text.trim().isEmpty
                              ? 0.35
                              : 1.0,
                          child: GestureDetector(
                            onTap: _enviarMensagem,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4DA3FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_upward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Text(
            "O Ringo é alimentado por IA e pode haver erros.",
            style: TextStyle(fontSize: 10, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  Widget _bolhaRingo(int index, Map<String, dynamic> msg) {
    final partes = Map<String, String>.from(
      msg['partes'] ??
          {
            'english': '',
            'portuguese': '',
            'tipEnglish': '',
            'tipPortuguese': '',
          },
    );
    final mostrarTraducao = msg['mostrarTraducao'] as bool;
    final mostrarDica = msg['mostrarDica'] as bool;
    final temTraducao = (partes['portuguese'] ?? '').isNotEmpty;
    final temDica = (partes['tipEnglish'] ?? '').isNotEmpty;
    final hora = msg['hora'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              'https://ringolingo-production.up.railway.app${widget.ringo.imagemUrl}',
            ),
            radius: 16,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF4FF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partes['english'] ?? '',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                      if (temTraducao || temDica) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (temTraducao)
                              _BotaoIcone(
                                icone: '🇧🇷',
                                label: mostrarTraducao ? 'Ocultar' : 'Tradução',
                                ativo: mostrarTraducao,
                                onTap: () {
                                  if (!mostrarTraducao) {
                                    AnalyticsService.chatTraducaoAberta(
                                      widget.ringo.nome,
                                    );
                                  }
                                  setState(() {
                                    _mensagens[index]['mostrarTraducao'] =
                                        !mostrarTraducao;
                                  });
                                },
                              ),
                            if (temTraducao && temDica)
                              const SizedBox(width: 8),
                            if (temDica)
                              _BotaoIcone(
                                icone: '💡',
                                label: mostrarDica ? 'Ocultar' : 'Dica',
                                ativo: mostrarDica,
                                onTap: () {
                                  if (!mostrarDica) {
                                    AnalyticsService.chatDicaAberta(
                                      widget.ringo.nome,
                                    );
                                  }
                                  setState(() {
                                    _mensagens[index]['mostrarDica'] =
                                        !mostrarDica;
                                  });
                                },
                              ),
                          ],
                        ),
                      ],
                      _SecaoExpandivel(
                        visivel: mostrarTraducao && temTraducao,
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF4DA3FF).withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            partes['portuguese'] ?? '',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      _SecaoExpandivel(
                        visivel: mostrarDica && temDica,
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                partes['tipEnglish'] ?? '',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                              if ((partes['tipPortuguese'] ?? '')
                                  .isNotEmpty) ...[
                                const Divider(),
                                Text(
                                  partes['tipPortuguese'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (hora.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      hora,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black38,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bolhaMensagem(String texto, String hora) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF4DA3FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Text(
                texto,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
            if (hora.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 4),
                child: Text(
                  hora,
                  style: const TextStyle(fontSize: 11, color: Colors.black38),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _bolhaDigitando() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              'https://ringolingo-production.up.railway.app${widget.ringo.imagemUrl}',
            ),
            radius: 16,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFEEF4FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PontoDigitando(delay: Duration(milliseconds: 0)),
                SizedBox(width: 4),
                _PontoDigitando(delay: Duration(milliseconds: 200)),
                SizedBox(width: 4),
                _PontoDigitando(delay: Duration(milliseconds: 400)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BolhaAnimada extends StatefulWidget {
  final Widget child;
  const _BolhaAnimada({super.key, required this.child});

  @override
  State<_BolhaAnimada> createState() => _BolhaAnimadaState();
}

class _BolhaAnimadaState extends State<_BolhaAnimada>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _opacity = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slide = Tween(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _SecaoExpandivel extends StatelessWidget {
  final bool visivel;
  final Widget child;
  const _SecaoExpandivel({required this.visivel, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: const SizedBox.shrink(),
      secondChild: child,
      crossFadeState: visivel
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
      sizeCurve: Curves.easeInOut,
    );
  }
}

class _BotaoIcone extends StatelessWidget {
  final String icone;
  final String label;
  final bool ativo;
  final VoidCallback onTap;

  const _BotaoIcone({
    required this.icone,
    required this.label,
    required this.ativo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: ativo
              ? const Color(0xFF4DA3FF).withOpacity(0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ativo
                ? const Color(0xFF4DA3FF)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icone, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ativo ? const Color(0xFF4DA3FF) : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PontoDigitando extends StatefulWidget {
  final Duration delay;
  const _PontoDigitando({required this.delay});

  @override
  State<_PontoDigitando> createState() => _PontoDigitandoState();
}

class _PontoDigitandoState extends State<_PontoDigitando>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    Future.delayed(widget.delay, () {
      if (mounted) _controller.repeat(reverse: true);
    });
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
          child: const CircleAvatar(
            radius: 4,
            backgroundColor: Color(0xFF4DA3FF),
          ),
        );
      },
    );
  }
}
