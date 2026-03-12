import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ringolingo/models/missao_model.dart';
import 'package:ringolingo/models/ringo_model.dart';
import 'package:ringolingo/pages/chat_page.dart';
import 'package:ringolingo/pages/perfil_page.dart';
import 'package:ringolingo/providers/auth_provider.dart';
import 'package:ringolingo/services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _streak = 0;
  int _nivel = 1;
  int _xpDoNivel = 0;
  int _xpNecessario = 500;
  bool _carregando = true;

  final List<MissaoModel> missoes = MissaoModel.missoesDiarias()
    ..[0].avancar(3)
    ..[2].avancar(1);

  List<RingoModel> meusRingos = [];
  Future<void> buscarpersona() async {
    final personas = await ApiService.buscarPersonas();
    if (personas != null && mounted) {
      setState(() => meusRingos = personas);
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarDados();
    buscarpersona();
  }

  Future<void> _carregarDados() async {
    final auth = AuthProvider();
    final id = auth.id;

    if (id == null) {
      setState(() => _carregando = false);
      return;
    }

    final resultados = await Future.wait([
      ApiService.buscarStreak(id),
      ApiService.buscarXp(id),
    ]);

    final streak = resultados[0] as int;
    final xpInfo = resultados[1] as XpInfo?;

    if (xpInfo != null) {
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
        _xpNecessario =
            xpInfo?.xpNecessarioProximoNivel ??
            auth.xpNecessarioProximoNivel ??
            500;
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final nome = AuthProvider().nomeUsuario ?? "Usuário";
    final progresso = _xpNecessario > 0
        ? (_xpDoNivel / _xpNecessario).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Olá, $nome!',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      // Streak badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEEDD),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Text("🔥", style: TextStyle(fontSize: 16)),
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
                                    "$_streak",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PerfilPage()),
                        ),
                        child: CircleAvatar(
                          backgroundImage:
                              AuthProvider().fotoUrl != null &&
                                  AuthProvider().fotoUrl!.isNotEmpty
                              ? (AuthProvider().fotoUrl!.startsWith('http')
                                    ? NetworkImage(AuthProvider().fotoUrl!)
                                          as ImageProvider
                                    : FileImage(File(AuthProvider().fotoUrl!)))
                              : const AssetImage(
                                  "lib/assets/ringoEntrevistador.png",
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
                              "Seu progresso",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Continue assim! 😊",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Nv.$_nivel",
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
                      "$_xpDoNivel / $_xpNecessario XP",
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // ── RINGOS ──
              Text(
                "Ringo em destaque",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 200,
                width: double.infinity,
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: meusRingos.length,
                  itemBuilder: (context, index) {
                    final ringo = meusRingos[index];
                    final desbloqueado = _nivel >= ringo.nivelNecessario;
                    return GestureDetector(
                      onTap: desbloqueado
                          ? () =>
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatPage(ringo: ringo),
                                  ),
                                ).then(
                                  (_) => _carregarDados(),
                                ) // atualiza XP ao voltar
                          : () => _mostrarDialogBloqueado(ringo),
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
                                ringo.imagemUrl,
                                height: 100,
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
                                  ? "Disponível"
                                  : "Nv. ${ringo.nivelNecessario}",
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

              Text(
                "Missões disponíveis",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              ...missoes.map((missao) => _cartaoMissao(missao)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogBloqueado(RingoModel ringo) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("🔒 Ringo bloqueado"),
        content: Text(
          "Alcance o nível ${ringo.nivelNecessario} para desbloquear o ${ringo.nome}.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Ok"),
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
                        "✓ Feito",
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
                        "+${missao.xpRecompensa} XP",
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
                ? "Missão concluída!"
                : "${missao.progressoAtual}/${missao.meta}",
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
