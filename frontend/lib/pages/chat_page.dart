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

class _ChatPageState extends State<ChatPage> {
  final _mensagemController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _mensagens = [];
  bool _digitando = false;
  bool _mostrarXp = false;
  bool _carregandoHistorico = true;

  @override
  void initState() {
    super.initState();
    AnalyticsService.chatAberto(widget.ringo.nome);
    _carregarHistorico();
  }

  @override
  void dispose() {
    _mensagemController.dispose();
    _scrollController.dispose();
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

      // O histórico vem em ordem decrescente, então invertemos
      for (final msg in historico.reversed) {
        final isUsuario =
            msg['usuarioId'] == auth.id &&
            msg['conteudo'] != null &&
            !_textoParecerRingo(msg['conteudo'] as String);

        if (isUsuario) {
          mensagensConvertidas.add({
            "remetente": "usuario",
            "texto": msg['conteudo'] ?? '',
          });
        } else {
          final partes = _parsearResposta(msg['conteudo'] ?? '');
          // só adiciona se tiver conteúdo english parseado
          if (partes['english']!.isNotEmpty) {
            mensagensConvertidas.add({
              "remetente": "ringo",
              "partes": partes,
              "mostrarTraducao": false,
              "mostrarDica": false,
            });
          } else {
            // mensagem do usuário que veio sem formato de ringo
            mensagensConvertidas.add({
              "remetente": "usuario",
              "texto": msg['conteudo'] ?? '',
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

  // Detecta se o conteúdo é uma resposta do Ringo (tem label "English:")
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
    if (mounted) setState(() => _mostrarXp = true);
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) setState(() => _mostrarXp = false);
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

    setState(() {
      _mensagens.add({"remetente": "usuario", "texto": texto});
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
        });
      }
    });

    if (resposta.sucesso) _mostrarAnimacaoXp();
    _scrollParaBaixo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                'https://ringolingo-production.up.railway.app${widget.ringo.imagemUrl}',
              ),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Text(
              widget.ringo.nome,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _carregandoHistorico
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4DA3FF),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: _mensagens.length + (_digitando ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (_digitando && index == _mensagens.length) {
                            return _bolhaDigitando();
                          }
                          final msg = _mensagens[index];
                          final isUsuario = msg['remetente'] == 'usuario';
                          if (isUsuario) {
                            return _bolhaMensagem(msg['texto'], true);
                          }
                          return _bolhaRingo(index, msg);
                        },
                      ),
              ),
              _campoMensagem(),
            ],
          ),

          // Animação +10 XP
          if (_mostrarXp)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1500),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value < 0.7 ? value / 0.7 : (1 - value) / 0.3,
                    child: Transform.translate(
                      offset: Offset(0, -40 * value),
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
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Text(
                            "⭐ +10 XP",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
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

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
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
              style: const TextStyle(color: Colors.black87, fontSize: 15),
            ),
            if (temTraducao) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  if (!mostrarTraducao) {
                    AnalyticsService.chatTraducaoAberta(widget.ringo.nome);
                  }
                  setState(() {
                    _mensagens[index]['mostrarTraducao'] = !mostrarTraducao;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mostrarTraducao
                          ? "🇧🇷 Ocultar tradução"
                          : "🇧🇷 Ver tradução",
                      style: const TextStyle(
                        color: Color(0xFF4DA3FF),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(
                      Icons.expand_more,
                      color: Color(0xFF4DA3FF),
                      size: 18,
                    ),
                  ],
                ),
              ),
              if (mostrarTraducao) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    partes['portuguese'] ?? '',
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                ),
              ],
            ],
            if (temDica) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  if (!mostrarDica) {
                    AnalyticsService.chatDicaAberta(widget.ringo.nome);
                  }
                  setState(() {
                    _mensagens[index]['mostrarDica'] = !mostrarDica;
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mostrarDica ? "💡 Ocultar dica" : "💡 Ver dica",
                      style: const TextStyle(
                        color: Color(0xFF4DA3FF),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(
                      Icons.expand_more,
                      color: Color(0xFF4DA3FF),
                      size: 18,
                    ),
                  ],
                ),
              ),
              if (mostrarDica) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
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
                      if ((partes['tipPortuguese'] ?? '').isNotEmpty) ...[
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
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _bolhaMensagem(String texto, bool isUsuario) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
    );
  }

  Widget _bolhaDigitando() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
    );
  }

  Widget _campoMensagem() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _mensagemController,
              decoration: InputDecoration(
                hintText: "Digite uma mensagem...",
                filled: true,
                fillColor: const Color(0xFFEEF4FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _enviarMensagem(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _enviarMensagem,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF4DA3FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
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
