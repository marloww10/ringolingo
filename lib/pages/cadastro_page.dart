import 'package:flutter/material.dart';
import 'package:ringolingo/pages/home_page.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  bool _ocultarSenha = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro", style: TextStyle()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 50, horizontal: 20),
            child: Column(
              children: [
                TextField(decoration: InputDecoration(hintText: "Nome:")),
                SizedBox(height: 15),
                TextField(decoration: InputDecoration(hintText: "Sobrenome:")),
                SizedBox(height: 15),
                TextField(decoration: InputDecoration(hintText: "Email:")),
                SizedBox(height: 15),
                TextField(
                  obscureText: _ocultarSenha,
                  decoration: InputDecoration(
                    hintText: "Senha:",
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _ocultarSenha = !_ocultarSenha;
                        });
                      },
                      icon: Icon(
                        _ocultarSenha ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
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
                          MaterialPageRoute(builder: (context) => HomePage()),
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
                              "Cadastrar",
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
