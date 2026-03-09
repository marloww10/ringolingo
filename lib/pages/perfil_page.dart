import 'package:flutter/material.dart';
import 'package:ringolingo/pages/inicio_page.dart';
import 'package:ringolingo/pages/language_selection_page.dart';
import 'package:ringolingo/providers/auth_provider.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final xpDoNivel = AuthProvider().xpDoNivel ?? 0;
  final xpTotal = AuthProvider().xpTotal ?? 0;
  final nivel = AuthProvider().nivel ?? 1;

  final Map<int, int> xpPorNivel = {
    1: 500,
    2: 750,
    3: 1000,
    4: 1500,
    5: 2000,
    6: 3000,
    7: 4500,
    8: 7000,
    9: 10500,
    10: 15500,
  };

  int get xpNecessario => xpPorNivel[AuthProvider().nivel ?? 1] ?? 500;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4DA3FF),
        foregroundColor: Colors.white,
        title: Text("Perfil", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 310,
              decoration: BoxDecoration(
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
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage(
                        "lib/assets/ringoEntrevistador.png",
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      AuthProvider().nomeUsuario.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: Row(
                        children: [
                          Text(
                            "Nv.$nivel",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: xpDoNivel / xpNecessario,
                              backgroundColor: Colors.white38,
                              color: Colors.white,
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "$xpDoNivel/$xpNecessario",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF4DA3FF), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Color(0xFF4DA3FF)),
                        SizedBox(width: 10),
                        Text(
                          "XP Total: $xpTotal",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF4DA3FF), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.emoji_events, color: Color(0xFF4DA3FF)),
                        SizedBox(width: 10),
                        Text(
                          "Conquistas",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LanguageSelectionPage(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF4DA3FF), width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.language, color: Color(0xFF4DA3FF)),
                          SizedBox(width: 10),
                          Text(
                            "Idiomas",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: Material(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          await AuthProvider().encerrarSessao();
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
                            color: Color.fromARGB(15, 255, 255, 255),
                            borderRadius: BorderRadius.circular(12),
                            border: Border(
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
          ],
        ),
      ),
    );
  }
}
