import 'package:flutter/material.dart';
import 'package:ringolingo/pages/language_selection_page.dart';
import 'package:ringolingo/pages/teladecarregamento_page.dart';
import 'package:ringolingo/providers/auth_provider.dart';
import 'package:ringolingo/services/analytics_service.dart';
import 'package:ringolingo/services/api_service.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool carregando = false;
  bool _ocultarSenha = true;
  bool _ocultarConfirmarSenha = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    setState(() => carregando = true);

    final respostaCadastro = await ApiService.cadastrarUsuario(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      senha: _senhaController.text.trim(),
    );

    if (!respostaCadastro.sucesso) {
      await AnalyticsService.erroCadastro(respostaCadastro.mensagem); // ← NOVO
      setState(() => carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(respostaCadastro.mensagem),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final respostaLogin = await ApiService.loginUsuario(
      email: _emailController.text.trim(),
      senha: _senhaController.text.trim(),
    );

    setState(() => carregando = false);

    if (respostaLogin.sucesso) {
      await AnalyticsService.cadastroSucesso(); // ← NOVO
      AuthProvider().salvarSessao(
        token: respostaLogin.dados['token'],
        nome: respostaLogin.dados['nome'],
        id: respostaLogin.dados['id'],
        nivel: respostaLogin.dados['nivel'] ?? 1,
        xpTotal:
            respostaLogin.dados['xpTotal'] ??
            respostaLogin.dados['xPTotal'] ??
            0,
        xpDoNivel: respostaLogin.dados['xpDoNivel'] ?? 0,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LanguageSelectionPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) return const TeladecarregamentoPage();
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
                TextField(
                  controller: _nomeController,
                  decoration: InputDecoration(hintText: "Nome"),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(hintText: "Email"),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: _senhaController,
                  obscureText: _ocultarSenha,
                  decoration: InputDecoration(
                    hintText: "Senha",
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
                TextField(
                  controller: _confirmarSenhaController,
                  obscureText: _ocultarConfirmarSenha,
                  decoration: InputDecoration(
                    hintText: "Confirmar senha",
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _ocultarConfirmarSenha = !_ocultarConfirmarSenha;
                        });
                      },
                      icon: Icon(
                        _ocultarConfirmarSenha
                            ? Icons.visibility
                            : Icons.visibility_off,
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
                      onTap: carregando
                          ? null
                          : () async {
                              if (_confirmarSenhaController.text !=
                                  _senhaController.text) {
                                await AnalyticsService.erroCadastro(
                                  "senhas_diferentes",
                                ); // ← NOVO
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("As senhas não são iguais."),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                                return;
                              }
                              await _cadastrar();
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
