import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErroPage extends StatelessWidget {
  final String mensagem;
  final VoidCallback? onTentar;

  const ErroPage({
    super.key,
    this.mensagem = 'Ringo está descansando...\nTente novamente em instantes.',
    this.onTentar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('lib/assets/ringoTriste.png', height: 200),
              const SizedBox(height: 32),
              Text(
                mensagem,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF555555),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              if (onTentar != null)
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: Material(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: onTentar,
                      child: Ink(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(15, 255, 255, 255),
                          borderRadius: BorderRadius.circular(12),
                          border: const Border(
                            bottom: BorderSide(
                              width: 6,
                              color: Color(0xFF4DA3FF),
                            ),
                            left: BorderSide(
                              width: 2,
                              color: Color(0xFF4DA3FF),
                            ),
                            right: BorderSide(
                              width: 2,
                              color: Color(0xFF4DA3FF),
                            ),
                            top: BorderSide(width: 2, color: Color(0xFF4DA3FF)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.refresh_rounded,
                              color: Color(0xFF4DA3FF),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Tentar novamente',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
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
      ),
    );
  }
}
