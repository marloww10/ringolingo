import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuemSomosPage extends StatelessWidget {
  const QuemSomosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4DA3FF),
        foregroundColor: Colors.white,
        title: const Text("Quem somos", style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF4DA3FF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(28, 10, 28, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Seu parceiro de\nconversação em inglês.",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Construído por quem já ficou travado no intermediário, e não queria mais depender de aulas caras ou parceiros difíceis de encontrar.",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            _secao(
              context,
              icone: Icons.lightbulb_outline_rounded,
              cor: const Color(0xFF4DA3FF),
              corFundo: const Color(0xFFEEF4FF),
              titulo: "Como tudo começou",
              texto:
                  "Somos um grupo de estudantes do ensino médio técnico em Desenvolvimento de Sistemas da rede FIRJAN SENAI SESI de Petrópolis, mais especificamente a lendária Turma 3º Info A.\n\nO RingoLingo nasceu oficialmente como projeto do Projeto Integrador. Mas, cá entre nós, a ideia já estava borbulhando muito antes disso. Quando surgiu a oportunidade, a resposta foi na hora: \"é agora ou nunca\", e aqui estamos.\n\nNão somos uma big tech, não temos escritório com puffs coloridos nem café grátis. Somos um grupo de adolescentes que achou que dar uma aula de inglês pra uma IA e deixar ela conversar com as pessoas era boa demais pra ficar só no papel.\n\nDesenvolvido por Marlon Franco, Caio Alonso, Otavio Augusto e Pedro Ryan.",
            ),

            _divider(),

            _secao(
              context,
              icone: Icons.flag_rounded,
              cor: const Color(0xFF34C759),
              corFundo: const Color(0xFFEAF7EE),
              titulo: "Nossa missão",
              texto:
                  "Dar a cada brasileiro que já tem uma base no inglês a oportunidade de praticar conversação real, com confiança, sem vergonha e sem gastar R\$ 100 por hora de aula.\n\nAcreditamos que fluência não é talento. É prática consistente. E é exatamente isso que o RingoLingo oferece.",
            ),

            _divider(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "O que nos diferencia",
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _diferencialCard(
                    icone: Icons.chat_bubble_outline_rounded,
                    titulo: "Conversação real",
                    descricao:
                        "Não são exercícios de múltipla escolha. São conversas de verdade com personagens diferentes, cada um com seu contexto, vocabulário e personalidade.",
                  ),
                  const SizedBox(height: 12),
                  _diferencialCard(
                    icone: Icons.sentiment_satisfied_alt_rounded,
                    titulo: "Sem julgamentos",
                    descricao:
                        "O Ringo nunca ri dos seus erros. Ele corrige, explica e encoraja, porque errar faz parte de aprender.",
                  ),
                  const SizedBox(height: 12),
                  _diferencialCard(
                    icone: Icons.access_time_rounded,
                    titulo: "Disponível 24h",
                    descricao:
                        "Não precisa agendar, não precisa esperar. Quando você tiver 5 minutos, o Ringo está pronto para conversar.",
                  ),
                  const SizedBox(height: 12),
                  _diferencialCard(
                    icone: Icons.trending_up_rounded,
                    titulo: "Progressão visível",
                    descricao:
                        "XP, níveis e Ringos desbloqueados mostram que você está evoluindo, porque motivação precisa de evidência.",
                  ),
                ],
              ),
            ),

            _divider(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE8F0FE),
                    width: 1.5,
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
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF4FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF4DA3FF),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "RingoLingo",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        Text(
                          "Versão 1.0.0",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _secao(
    BuildContext context, {
    required IconData icone,
    required Color cor,
    required Color corFundo,
    required String titulo,
    required String texto,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: corFundo,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icone, color: cor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                titulo,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            texto,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF555555),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _diferencialCard({
    required IconData icone,
    required String titulo,
    required String descricao,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8F0FE), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF4FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icone, color: const Color(0xFF4DA3FF), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descricao,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF777777),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      child: Divider(color: Colors.grey.shade200, thickness: 1),
    );
  }
}
