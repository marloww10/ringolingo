import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:ringolingo/providers/auth_provider.dart';
import 'package:ringolingo/services/api_service.dart';

class RankingItemDto {
  final int posicao;
  final int usuarioId;
  final String nome;
  final String? fotoUrl;
  final int xpTotal;
  final int nivel;

  RankingItemDto({
    required this.posicao,
    required this.usuarioId,
    required this.nome,
    this.fotoUrl,
    required this.xpTotal,
    required this.nivel,
  });

  factory RankingItemDto.fromJson(Map<String, dynamic> json) {
    return RankingItemDto(
      posicao: json['posicao'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      nome: json['nome'] ?? '',
      fotoUrl: json['fotoUrl'],
      xpTotal: json['xpTotal'] ?? 0,
      nivel: json['nivel'] ?? 1,
    );
  }
}

class RankingDto {
  final List<RankingItemDto> top3;
  final RankingItemDto? usuarioAtual;

  RankingDto({required this.top3, this.usuarioAtual});

  factory RankingDto.fromJson(Map<String, dynamic> json) {
    final listTop3 = (json['top3'] as List? ?? [])
        .map((e) => RankingItemDto.fromJson(e))
        .toList();

    return RankingDto(
      top3: listTop3,
      usuarioAtual: json['usuarioAtual'] != null
          ? RankingItemDto.fromJson(json['usuarioAtual'])
          : null,
    );
  }
}

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  int _tabIndex = 0;
  final List<String> _tabs = ['Semanal', 'Mensal', 'Geral'];

  List<RankingItemDto> _outros = [];
  RankingDto? _dadosApi;
  bool _carregando = true;
  bool _erro = false;

  @override
  void initState() {
    super.initState();
    _carregarRankingReal();
  }

  Future<void> _carregarRankingReal() async {
    setState(() {
      _carregando = true;
      _erro = false;
    });

    try {
      final token = AuthProvider().token ?? '';
      final tipo = _tabs[_tabIndex].toLowerCase();

      final response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/Usuario/Ranking?tipo=$tipo'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonCompleto = jsonDecode(response.body);

        // O backend retorna Response<RankingDto>, então os dados estão em 'dados'
        final dados = jsonCompleto['dados'] as Map<String, dynamic>;
        final dadosConvertidos = RankingDto.fromJson(dados);

        // Todos os usuários além do top 3 — o backend não tem campo 'outros',
        // então montamos a lista a partir do top3 excluindo as 3 primeiras posições.
        // O usuarioAtual pode aparecer fora do top3 e é exibido separadamente.
        final top3Ids = dadosConvertidos.top3.map((e) => e.usuarioId).toSet();
        final usuarioAtualId = dadosConvertidos.usuarioAtual?.usuarioId;

        // 'outros' = usuários do ranking que não estão no top3
        // Como o backend só retorna top3 + usuarioAtual, montamos assim:
        final List<RankingItemDto> outros = [];
        if (dadosConvertidos.usuarioAtual != null &&
            !top3Ids.contains(usuarioAtualId)) {
          // usuarioAtual fora do top3 é exibido no card separado — não em outros
        }

        setState(() {
          _dadosApi = dadosConvertidos;
          _outros = outros;
          _carregando = false;
        });
      } else {
        setState(() {
          _erro = true;
          _carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        _erro = true;
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ranking = _dadosApi;
    final top3 = ranking?.top3 ?? [];
    final usuarioAtual = ranking?.usuarioAtual;

    final podiumOrder = <RankingItemDto?>[];
    if (top3.length >= 2) podiumOrder.add(top3[1]);
    if (top3.isNotEmpty) podiumOrder.add(top3[0]);
    if (top3.length >= 3) podiumOrder.add(top3[2]);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4DA3FF)),
            )
          : _erro
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Erro ao carregar o ranking.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _carregarRankingReal,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF4DA3FF),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 12,
                      left: 20,
                      right: 20,
                      bottom: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.emoji_events_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Ranking',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Veja os maiores acumuladores de XP',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: List.generate(_tabs.length, (i) {
                              final selected = i == _tabIndex;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (_tabIndex != i) {
                                      setState(() => _tabIndex = i);
                                      _carregarRankingReal();
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: Text(
                                      _tabs[i],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: selected
                                            ? const Color(0xFF4DA3FF)
                                            : Colors.white.withOpacity(0.75),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: podiumOrder.asMap().entries.map((entry) {
                        final item = entry.value;
                        if (item == null) return const SizedBox.shrink();

                        final isFirst = item.posicao == 1;
                        final isSecond = item.posicao == 2;

                        final avatarSize = isFirst ? 68.0 : 54.0;
                        final standHeight = isFirst
                            ? 70.0
                            : isSecond
                            ? 54.0
                            : 42.0;
                        final standColor = isFirst
                            ? const Color(0xFF4DA3FF)
                            : isSecond
                            ? const Color(0xFF7CB9FF)
                            : const Color(0xFFA8D4FF);
                        final medalColor = isFirst
                            ? const Color(0xFFFFD700)
                            : isSecond
                            ? const Color(0xFFC0C8D0)
                            : const Color(0xFFCD7F32);
                        final medalTextColor = isFirst
                            ? const Color(0xFF7A5A00)
                            : isSecond
                            ? const Color(0xFF445566)
                            : const Color(0xFF5C3510);

                        return Expanded(
                          child: Column(
                            children: [
                              if (isFirst)
                                const Text('👑', style: TextStyle(fontSize: 18))
                              else
                                const SizedBox(height: 22),

                              const SizedBox(height: 4),

                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  _buildAvatar(item.nome, avatarSize),
                                  Positioned(
                                    bottom: -4,
                                    right: -4,
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: medalColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${item.posicao}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: medalTextColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Text(
                                item.nome.split(' ').first,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A1A2E),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              Text(
                                '${_formatXp(item.xpTotal)} XP',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF4DA3FF),
                                ),
                              ),

                              const SizedBox(height: 6),

                              Container(
                                height: standHeight,
                                decoration: BoxDecoration(
                                  color: standColor,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${item.posicao}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                if (_outros.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'CLASSIFICAÇÃO GERAL',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = _outros[index];
                        final ehUsuarioLogado =
                            item.usuarioId == AuthProvider().id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildRankCard(item, isMe: ehUsuarioLogado),
                        );
                      }, childCount: _outros.length),
                    ),
                  ),
                ],

                if (usuarioAtual != null &&
                    usuarioAtual.posicao > _outros.length + 3)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '• • •',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade400,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ),
                  ),

                if (usuarioAtual != null)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: _buildRankCard(usuarioAtual, isMe: true),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
    );
  }

  Widget _buildAvatar(String nome, double size) {
    final initials = _getInitials(nome);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4DA3FF), Color(0xFF2980E8)],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.28,
        ),
      ),
    );
  }

  Widget _buildRankCard(RankingItemDto item, {required bool isMe}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFEEF4FF) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe ? const Color(0xFF4DA3FF) : const Color(0xFFE8F0FE),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${item.posicao}',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4DA3FF),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4DA3FF), Color(0xFF2980E8)],
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _getInitials(item.nome),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.nome,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4DA3FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'você',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  'Nível ${item.nivel}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatXp(item.xpTotal),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4DA3FF),
                ),
              ),
              Text(
                'XP',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getInitials(String nome) {
    final partes = nome.trim().split(' ');
    if (partes.length >= 2 && partes[0].isNotEmpty && partes[1].isNotEmpty) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nome.substring(0, nome.length >= 2 ? 2 : 1).toUpperCase();
  }

  String _formatXp(int xp) {
    if (xp >= 1000) {
      final k = xp / 1000;
      return k == k.truncateToDouble()
          ? '${k.toInt()}k'
          : '${k.toStringAsFixed(1)}k';
    }
    return xp.toString();
  }
}