import 'package:flutter/material.dart';
import 'package:ringolingo/models/ringo_model.dart';
import 'package:ringolingo/providers/auth_provider.dart';
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

  @override
  void dispose() {
    _mensagemController.dispose();
    _scrollController.dispose();
    super.dispose();
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
        if (resto.isNotEmpty) english += resto + '\n';
      } else if (l.startsWith('Portuguese:')) {
        secaoAtual = 'portuguese';
        final resto = l.replaceFirst('Portuguese:', '').trim();
        if (resto.isNotEmpty) portuguese += resto + '\n';
      } else if (l.startsWith("Teacher's Tip (English):")) {
        secaoAtual = 'tipEnglish';
        final resto = l.replaceFirst("Teacher's Tip (English):", '').trim();
        if (resto.isNotEmpty) tipEnglish += resto + '\n';
      } else if (l.startsWith('Dica do Professor (Português):')) {
        secaoAtual = 'tipPortuguese';
        final resto = l
            .replaceFirst('Dica do Professor (Português):', '')
            .trim();
        if (resto.isNotEmpty) tipPortuguese += resto + '\n';
      } else if (l.isNotEmpty) {
        if (secaoAtual == 'english')
          english += l + '\n';
        else if (secaoAtual == 'portuguese')
          portuguese += l + '\n';
        else if (secaoAtual == 'tipEnglish')
          tipEnglish += l + '\n';
        else if (secaoAtual == 'tipPortuguese')
          tipPortuguese += l + '\n';
      }
    }

    return {
      'english': english.trim(),
      'portuguese': portuguese.trim(),
      'tipEnglish': tipEnglish.trim(),
      'tipPortuguese': tipPortuguese.trim(),
    };
  }

  Future<void> _enviarMensagem() async {
    final texto = _mensagemController.text.trim();
    if (texto.isEmpty || _digitando) return;

    setState(() {
      _mensagens.add({"remetente": "usuario", "texto": texto});
      _mensagemController.clear();
      _digitando = true;
    });
    _scrollParaBaixo();

    final resposta = await ApiService.enviarMensagem(
      token: AuthProvider().token ?? "",
      conteudo: texto,
      persona: widget.ringo.persona,
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
              backgroundImage: AssetImage(widget.ringo.imagem),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Text(
              widget.ringo.nome,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            // Texto em inglês
            Text(
              partes['english'] ?? '',
              style: const TextStyle(color: Colors.black87, fontSize: 15),
            ),

            // Tradução expandível
            if (temTraducao) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
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

            // Dica expandível
            if (temDica) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ponto(0),
            const SizedBox(width: 4),
            _ponto(200),
            const SizedBox(width: 4),
            _ponto(400),
          ],
        ),
      ),
    );
  }

  Widget _ponto(int delayMs) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.3, end: 1),
      duration: Duration(milliseconds: 600 + delayMs),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: const CircleAvatar(
            radius: 4,
            backgroundColor: Color(0xFF4DA3FF),
          ),
        );
      },
    );
  }

  Widget _campoMensagem() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
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
