import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ringolingo/pages/conquista_page.dart';
import 'package:ringolingo/pages/inicio_page.dart';
import 'package:ringolingo/pages/language_selection_page.dart';
import 'package:ringolingo/pages/quem_somos_page.dart';
import 'package:ringolingo/providers/auth_provider.dart';
import 'package:ringolingo/services/api_service.dart';
import 'package:ringolingo/services/analytics_service.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  List<String> _badgesDesbloqueadas = [];

  @override
  void initState() {
    super.initState();
    _atualizarXp();
    _carregarBadges();
  }

  Future<void> _carregarBadges() async {
    final auth = AuthProvider();
    if (auth.token == null) return;
    final conquistas = await ApiService.buscarConquistas(auth.token!);
    if (conquistas != null && mounted) {
      setState(() {
        _badgesDesbloqueadas = conquistas
            .where((c) => c.desbloqueada)
            .map((c) => c.nome)
            .toList();
      });
    }
  }

  Future<void> _atualizarXp() async {
    final auth = AuthProvider();
    if (auth.token == null) return;
    final xpInfo = await ApiService.buscarXp(auth.token!);
    if (xpInfo != null && mounted) {
      auth.atualizarXp(
        xpInfo.nivel,
        xpInfo.xpTotal,
        xpInfo.xpDoNivel,
        xpInfo.xpNecessarioProximoNivel,
      );
      setState(() {});
    }
  }

  void _editarFoto(BuildContext context) {
    final controller = TextEditingController();
    final auth = AuthProvider();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Alterar foto de perfil'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Cole a URL da imagem'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final url = controller.text.trim();
              if (url.isEmpty || auth.id == null) return;
              final sucesso = await ApiService.atualizarFoto(auth.id!, url);
              if (sucesso) {
                auth.atualizarFoto(url);
                if (mounted) setState(() {});
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthProvider();

    final nivel = auth.nivel ?? 1;
    final xpDoNivel = auth.xpDoNivel ?? 0;
    final xpTotal = auth.xpTotal ?? 0;
    final xpNecessario = auth.xpNecessarioProximoNivel ?? 500;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4DA3FF),
        foregroundColor: Colors.white,
        title: const Text("Perfil", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── HEADER ──
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF4DA3FF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        AnalyticsService.perfilEditarFoto();
                        _editarFoto(context);
                      },
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            auth.fotoUrl != null && auth.fotoUrl!.isNotEmpty
                            ? NetworkImage(auth.fotoUrl!) as ImageProvider
                            : const AssetImage(
                                "lib/assets/ringoEntrevistador.png",
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      auth.nomeUsuario.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Row(
                        children: [
                          Text(
                            "Nv.$nivel",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: xpNecessario > 0
                                  ? (xpDoNivel / xpNecessario).clamp(0.0, 1.0)
                                  : 0.0,
                              backgroundColor: Colors.white38,
                              color: Colors.white,
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "$xpDoNivel/$xpNecessario",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_badgesDesbloqueadas.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: _badgesDesbloqueadas.map((nome) {
                          return Tooltip(
                            message: nome,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '🏆',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    nome,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // XP Total
                  _itemCard(
                    icon: Icons.star_rounded,
                    label: "XP Total",
                    valor: "$xpTotal XP",
                    iconColor: const Color(0xFF4DA3FF),
                    bgColor: const Color(0xFFEEF4FF),
                  ),
                  const SizedBox(height: 10),

                  // Conquistas
                  GestureDetector(
                    onTap: () async {
                      await AnalyticsService.perfilConquistas();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ConquistasPage(),
                        ),
                      );
                    },
                    child: _itemCard(
                      icon: Icons.emoji_events_rounded,
                      label: "Conquistas",
                      iconColor: const Color(0xFFFFAA00),
                      bgColor: const Color(0xFFFFF8E7),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Idiomas
                  GestureDetector(
                    onTap: () async {
                      await AnalyticsService.perfilIdiomas();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LanguageSelectionPage(),
                        ),
                      );
                    },
                    child: _itemCard(
                      icon: Icons.language_rounded,
                      label: "Idiomas",
                      iconColor: const Color(0xFF34C759),
                      bgColor: const Color(0xFFEAF7EE),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Quem somos
                  GestureDetector(
                    onTap: () async {
                      await AnalyticsService.perfilQuemSomos();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const QuemSomosPage(),
                        ),
                      );
                    },
                    child: _itemCard(
                      icon: Icons.info_outline_rounded,
                      label: "Quem somos",
                      iconColor: const Color(0xFF7B61FF),
                      bgColor: const Color(0xFFF3EEFF),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Botão Sair
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: Material(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          AnalyticsService.perfilLogout();
                          AuthProvider().encerrarSessao();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const InicioPage(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(15, 255, 255, 255),
                            borderRadius: BorderRadius.circular(12),
                            border: const Border(
                              bottom: BorderSide(
                                width: 6,
                                color: Colors.redAccent,
                              ),
                              left: BorderSide(
                                width: 2,
                                color: Colors.redAccent,
                              ),
                              right: BorderSide(
                                width: 2,
                                color: Colors.redAccent,
                              ),
                              top: BorderSide(
                                width: 2,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Sair",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemCard({
    required IconData icon,
    required String label,
    String? valor,
    required Color iconColor,
    required Color bgColor,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8F0FE), width: 1.5),
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
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                if (valor != null)
                  Text(
                    valor,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
