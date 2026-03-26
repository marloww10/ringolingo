import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ringolingo/models/conquista_model.dart';
import 'package:ringolingo/providers/auth_provider.dart';
import 'package:ringolingo/services/api_service.dart';

class ConquistasPage extends StatefulWidget {
  const ConquistasPage({super.key});

  @override
  State<ConquistasPage> createState() => _ConquistasPageState();
}

class _ConquistasPageState extends State<ConquistasPage> {
  List<ConquistaModel> _conquistas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarConquistas();
  }

  Future<void> _carregarConquistas() async {
    final auth = AuthProvider();
    if (auth.token == null) {
      setState(() => _carregando = false);
      return;
    }

    final conquistas = await ApiService.buscarConquistas(auth.token!);
    if (mounted) {
      setState(() {
        _conquistas = conquistas ?? [];
        _carregando = false;
      });
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    final desbloqueadas = _conquistas.where((c) => c.desbloqueada).length;
    final total = _conquistas.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4DA3FF),
        foregroundColor: Colors.white,
        title: const Text(
          'Conquistas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4DA3FF)),
            )
          : Column(
              children: [
                // ── HEADER RESUMO ──
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4DA3FF),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  child: Column(
                    children: [
                      Text(
                        '$desbloqueadas/$total',
                        style: GoogleFonts.poppins(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'conquistas desbloqueadas',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: total > 0 ? desbloqueadas / total : 0,
                          minHeight: 10,
                          backgroundColor: Colors.white30,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── LISTA ──
                Expanded(
                  child: _conquistas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [],
                          ),
                        )
                      : ListView.builder(
                          physics: BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: _conquistas.length,
                          itemBuilder: (context, index) {
                            final conquista = _conquistas[index];
                            return _cartaoConquista(conquista);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _cartaoConquista(ConquistaModel conquista) {
    final desbloqueada = conquista.desbloqueada;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: desbloqueada ? const Color(0xFFFFF8E7) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: desbloqueada
              ? const Color(0xFFFFAA00)
              : const Color(0xFFE8F0FE),
          width: desbloqueada ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícone
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: desbloqueada
                  ? const Color(0xFFFFAA00).withOpacity(0.15)
                  : const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                desbloqueada ? '🏆' : '🔒',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conquista.nome,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: desbloqueada
                        ? const Color(0xFF1A1A2E)
                        : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                if (desbloqueada && conquista.dataConquista != null)
                  Text(
                    'Desbloqueada em ${_formatarData(conquista.dataConquista!)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  )
                else
                  Text(
                    conquista.descricao,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
              ],
            ),
          ),

          // XP badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: desbloqueada
                  ? const Color(0xFFFFAA00).withOpacity(0.15)
                  : const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+${conquista.xpGanho} XP',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: desbloqueada
                    ? const Color(0xFFFFAA00)
                    : Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
