import 'package:flutter/material.dart';
import 'package:ringolingo/pages/teladecarregamento_page.dart';

class EsquecisenhaPage extends StatefulWidget {
  const EsquecisenhaPage({super.key});

  @override
  State<EsquecisenhaPage> createState() => _EsquecisenhaPageState();
}

class _EsquecisenhaPageState extends State<EsquecisenhaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Esqueci a senha")),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 50, horizontal: 20),
            child: Column(
              children: [
                TextField(decoration: InputDecoration(hintText: "Email")),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: Material(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeladecarregamentoPage(),
                          ),
                        );
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(15, 255, 255, 255),
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
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
                            Text(
                              "Entrar",
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
      ),
    );
  }
}
