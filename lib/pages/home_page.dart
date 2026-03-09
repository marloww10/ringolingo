import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ringolingo/models/missao_model.dart';
import 'package:ringolingo/models/ringo_model.dart';
import 'package:ringolingo/pages/chat_page.dart';
import 'package:ringolingo/pages/perfil_page.dart';
import 'package:ringolingo/providers/auth_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final streak = 7;

  final List<MissaoModel> missoes = MissaoModel.missoesDiarias()
    ..[0].avancar(3) // simulando progresso para o design
    ..[2].avancar(1); // missão de streak concluída

  final List<RingoModel> meusRingos = [
    RingoModel(
      nome: "Ringo, Best Friend",
      imagem: "lib/assets/ringoBestFriend.png",
      nivelNecessario: 1,
      bloqueado: false,
      persona: "MelhorAmigo",
    ),
    RingoModel(
      nome: "Ringo, Garçom",
      imagem: "lib/assets/ringoGarçom.png",
      nivelNecessario: 5,
      bloqueado: false,
      persona: "Garcom",
    ),
    RingoModel(
      nome: "Ringo, Entrevistador",
      imagem: "lib/assets/ringoEntrevistador.png",
      nivelNecessario: 10,
      bloqueado: false,
      persona: "Entrevistador",
    ),
    RingoModel(
      nome: "Ringo Aniversariante",
      imagem: "lib/assets/ringoAniversariante.png",
      nivelNecessario: 15,
      bloqueado: false,
      persona: "Aniversariante",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    var nome = AuthProvider().nomeUsuario ?? "Usuário";
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, $nome!',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFEEDD),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text("🔥", style: TextStyle(fontSize: 16)),
                            SizedBox(width: 4),
                            Text(
                              "$streak",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PerfilPage()),
                        ),
                        child: CircleAvatar(
                          backgroundImage: AssetImage(
                            "lib/assets/ringoEntrevistador.png",
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Seu progresso",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Continue assim! 😊",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Nv.${AuthProvider().nivel ?? 1}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: Color(0xFF4DA3FF),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Text(
                "Ringo em destaque",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 5),
              SizedBox(
                height: 200,
                width: double.infinity,
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: meusRingos.length,
                  itemBuilder: (context, index) {
                    final ringo = meusRingos[index];
                    return GestureDetector(
                      onTap: ringo.bloqueado
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatPage(ringo: ringo),
                                ),
                              );
                            },
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          border: Border(
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
                            top: BorderSide(color: Color(0xFF4DA3FF), width: 2),
                          ),
                        ),
                        padding: EdgeInsets.only(top: 20),
                        width: 150,
                        child: Column(
                          children: [
                            Opacity(
                              opacity: ringo.bloqueado ? 0.4 : 1.0,
                              child: Image.asset(ringo.imagem, height: 100),
                            ),
                            SizedBox(height: 5),
                            Text(
                              ringo.nome,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("Nivel: ${ringo.nivelNecessario}"),
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
              SizedBox(height: 10),
              ...missoes.map((missao) => _cartaoMissao(missao)),
              SizedBox(height: 20),
            ],
          ),
        ),
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
              value: missao.progresso,
              minHeight: 8,
              backgroundColor: Color.fromARGB(255, 238, 238, 238),
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
