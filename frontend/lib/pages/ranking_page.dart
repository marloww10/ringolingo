import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Modelos de dados (adapte conforme seu DTO)
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
}

class RankingDto {
  final List<RankingItemDto> top3;
  final RankingItemDto? usuarioAtual;

  RankingDto({required this.top3, this.usuarioAtual});
}

// Dados mockados para exemplo — substitua pela chamada real à sua API
final _mockRanking = RankingDto(
  top3: [
    RankingItemDto(posicao: 1, usuarioId: 1, nome: 'Marlon Franco', xpTotal: 4890, nivel: 18),
    RankingItemDto(posicao: 2, usuarioId: 2, nome: 'Caio Alonso', xpTotal: 3420, nivel: 14),
    RankingItemDto(posicao: 3, usuarioId: 3, nome: 'Otavio Augusto', xpTotal: 2760, nivel: 12),
  ],
  usuarioAtual: RankingItemDto(posicao: 23, usuarioId: 99, nome: 'Pedro Ryan', xpTotal: 620, nivel: 7),
);

// Página de Ranking
class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  int _tabIndex = 0;
  final List<String> _tabs = ['Semanal', 'Mensal', 'Geral'];

  // Simula usuários abaixo do top3 para a lista
  final List<RankingItemDto> _outros = [
    RankingItemDto(posicao: 4, usuarioId: 4, nome: 'Pedro Ryan', xpTotal: 2140, nivel: 12),
    RankingItemDto(posicao: 5, usuarioId: 5, nome: 'Ana Lima', xpTotal: 1980, nivel: 10),
    RankingItemDto(posicao: 6, usuarioId: 6, nome: 'Lucas Mendes', xpTotal: 1750, nivel: 9),
    RankingItemDto(posicao: 7, usuarioId: 7, nome: 'Beatriz Costa', xpTotal: 1540, nivel: 9),
  ];

  @override
  Widget build(BuildContext context) {
    final ranking = _mockRanking;
    final top3 = ranking.top3;
    final usuarioAtual = ranking.usuarioAtual;

    // Reordena o pódio: [2°, 1°, 3°]
    final podiumOrder = <RankingItemDto?>[];
    if (top3.length >= 2) podiumOrder.add(top3[1]);
    if (top3.isNotEmpty) podiumOrder.add(top3[0]);
    if (top3.length >= 3) podiumOrder.add(top3[2]);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      body: CustomScrollView(
        slivers: [
          // Header azul com tabs
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
                  // Barra superior
                  Row(
                    children: [
                      const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 26),
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

                  // Tabs
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
                            onTap: () => setState(() => _tabIndex = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: selected ? Colors.white : Colors.transparent,
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

          // Pódio
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: podiumOrder.asMap().entries.map((entry) {
                  final item = entry.value;
                  if (item == null) return const SizedBox.shrink();

                  // Posição original no pódio (não na ordem de exibição)
                  final isFirst = item.posicao == 1;
                  final isSecond = item.posicao == 2;

                  final avatarSize = isFirst ? 68.0 : 54.0;
                  final standHeight = isFirst ? 70.0 : isSecond ? 54.0 : 42.0;
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
                        // Coroa no 1°
                        if (isFirst)
                          const Text('👑', style: TextStyle(fontSize: 18))
                        else
                          const SizedBox(height: 22),

                        const SizedBox(height: 4),

                        // Avatar com medalha
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
                                  border: Border.all(color: Colors.white, width: 2),
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

                        // Nome
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

                        // XP
                        Text(
                          '${_formatXp(item.xpTotal)} XP',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4DA3FF),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Pedestal
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

          // Lista de outros usuários
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
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _outros[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildRankCard(item, isMe: false),
                  );
                },
                childCount: _outros.length,
              ),
            ),
          ),

          // Separador "..."
          if (usuarioAtual != null && (usuarioAtual.posicao) > _outros.length + 3)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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

          // Card do usuário atual
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
          // Posição
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

          // Avatar
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

          // Nome e nível
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
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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

          // XP
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
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nome.substring(0, nome.length >= 2 ? 2 : 1).toUpperCase();
  }

  String _formatXp(int xp) {
    if (xp >= 1000) {
      final k = xp / 1000;
      return k == k.truncateToDouble() ? '${k.toInt()}k' : '${k.toStringAsFixed(1)}k';
    }
    return xp.toString();
  }
}