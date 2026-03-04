import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ringolingo/models/ringo_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<RingoModel> meusRingos = [
    RingoModel(
      nome: "Ringo, Best Friend",
      imagem: "lib/assets/ringoBestFriend.png",
      nivelNecessario: 1,
      bloqueado: false,
    ),
    RingoModel(
      nome: "Ringo, Garçom",
      imagem: "lib/assets/ringoGarçom.png",
      nivelNecessario: 5,
      bloqueado: false,
    ),
    RingoModel(
      nome: "Ringo, Entrevistador",
      imagem: "lib/assets/ringoEntrevistador.png",
      nivelNecessario: 10,
      bloqueado: true,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    var nome = "Marlon";
    return Scaffold(
      appBar: AppBar(
        title: Text("Olá, $nome!"),
        automaticallyImplyLeading: false,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: CircleAvatar(
              backgroundImage: AssetImage("lib/assets/ringoEntrevistador.png"),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Color(0xFF4DA3FF),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              SizedBox(height: 10),
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
                    return Container(
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFF4DA3FF),
                            width: 6,
                          ),
                          left: BorderSide(color: Color(0xFF4DA3FF), width: 2),
                          right: BorderSide(color: Color(0xFF4DA3FF), width: 2),
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
            ],
          ),
        ),
      ),
    );
  }
}
