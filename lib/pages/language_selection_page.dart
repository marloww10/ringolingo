import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ringolingo/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String? _idiomaApp;

  final List<Map<String, String>> _idiomasApp = [
    {
      "nome": "Português",
      "bandeira": "lib/assets/bandeiraBrasil.png",
      "codigo": "pt",
    },
    {
      "nome": "English",
      "bandeira": "lib/assets/bandeiraEua.png",
      "codigo": "en",
    },
    {
      "nome": "Español",
      "bandeira": "lib/assets/bandeiraEspanha.png",
      "codigo": "es",
    },

    {
      "nome": "Frances",
      "bandeira": "lib/assets/bandeiraFranca.png",
      "codigo": "fr",
    },
  ];

  Future<void> _salvarEContinuar() async {
    if (_idiomaApp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecione um idioma para continuar."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('idioma_app', _idiomaApp!);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  Widget _cartaoIdioma({
    required String bandeira,
    required String nome,
    required String codigo,
    required String? selecionado,
    required void Function(String) onTap,
  }) {
    final isSelected = selecionado == codigo;
    return GestureDetector(
      onTap: () => onTap(codigo),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4DA3FF) : const Color(0xFFEEF4FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2C68A9) : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4DA3FF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Image.asset(bandeira, height: 32, width: 32),
            const SizedBox(width: 12),
            Text(
              nome,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selecione o idioma"),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Idioma do app
              Text(
                "Idioma do app",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Em qual idioma você quer usar o Ringolingo?",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              ...(_idiomasApp.map(
                (idioma) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _cartaoIdioma(
                    bandeira: idioma['bandeira']!,
                    nome: idioma['nome']!,
                    codigo: idioma['codigo']!,
                    selecionado: _idiomaApp,
                    onTap: (codigo) => setState(() => _idiomaApp = codigo),
                  ),
                ),
              )),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: Material(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _salvarEContinuar,
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(15, 255, 255, 255),
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          bottom: BorderSide(
                            width: 6,
                            color: Color(0xFF4DA3FF),
                          ),
                          left: BorderSide(width: 2, color: Color(0xFF4DA3FF)),
                          right: BorderSide(width: 2, color: Color(0xFF4DA3FF)),
                          top: BorderSide(width: 2, color: Color(0xFF4DA3FF)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Começar a aprender!",
                            style: TextStyle(
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
      ),
    );
  }
}
