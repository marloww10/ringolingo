import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ringolingo/pages/cadastro_page.dart';
import 'package:ringolingo/pages/esqueci_senha_page.dart';
import 'package:ringolingo/pages/home_page.dart';
import 'package:ringolingo/pages/teladecarregamento_page.dart';
import 'package:ringolingo/providers/auth_provider.dart';
import 'package:ringolingo/services/analytics_service.dart';
import 'package:ringolingo/services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool carregando = false;
  bool _ocultarSenha = true;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    setState(() => carregando = true);
    final resposta = await ApiService.loginUsuario(
      email: _emailController.text.trim(),
      senha: _senhaController.text.trim(),
    );
    setState(() => carregando = false);

    if (resposta.sucesso) {
      await AnalyticsService.loginSucesso();
      final dados = resposta.dados;
      AuthProvider().salvarSessao(
        token: dados['token'],
        nome: dados['nome'],
        id: dados['id'] as int,
        nivel: (dados['nivel'] ?? 1) as int,
        xpTotal: (dados['xpTotal'] ?? 0) as int,
        xpDoNivel: (dados['xpDoNivel'] ?? 0) as int,
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    } else {
      await AnalyticsService.erroLogin(resposta.mensagem); // ← NOVO
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resposta.mensagem),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) return const TeladecarregamentoPage();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(centerTitle: true, title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: "Email"),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _senhaController,
              obscureText: _ocultarSenha,
              decoration: InputDecoration(
                hintText: "Senha",
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _ocultarSenha = !_ocultarSenha);
                  },
                  icon: Icon(
                    _ocultarSenha ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EsquecisenhaPage()),
                );
              },
              child: const Text(
                "Esqueci minha senha",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: Material(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: carregando ? null : _fazerLogin,
                  child: Ink(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(15, 255, 255, 255),
                      borderRadius: BorderRadius.circular(12),
                      border: const Border(
                        bottom: BorderSide(width: 6, color: Color(0xFF4DA3FF)),
                        left: BorderSide(width: 2, color: Color(0xFF4DA3FF)),
                        right: BorderSide(width: 2, color: Color(0xFF4DA3FF)),
                        top: BorderSide(width: 2, color: Color(0xFF4DA3FF)),
                      ),
                    ),
                    child: const Row(
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
            SizedBox(height: 45),
            Row(
              children: [
                // 1. Linha da esquerda
                Expanded(
                  child: Divider(
                    color: Colors.black, // Cor da linha
                    thickness: 2, // Grossura da linha
                  ),
                ),

                // 2. O Texto no meio (com um espacinho do lado)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "ou",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.black, thickness: 2)),
              ],
            ),
            SizedBox(height: 45),
            Material(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  setState(() => carregando = true);

                  try {
                    await Supabase.instance.client.auth.signInWithOAuth(
                      OAuthProvider.google,
                      redirectTo: 'ringolingo://login-callback',
                      authScreenLaunchMode: LaunchMode.inAppWebView,
                    );
                  } catch (erro) {
                    if (mounted) {
                      setState(() => carregando = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Erro ao abrir o login com o Google."),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                },
                child: Ink(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(15, 255, 255, 255),
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      bottom: BorderSide(width: 6, color: Color(0xFF4DA3FF)),
                      left: BorderSide(width: 2, color: Color(0xFF4DA3FF)),
                      right: BorderSide(width: 2, color: Color(0xFF4DA3FF)),
                      top: BorderSide(width: 2, color: Color(0xFF4DA3FF)),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          "lib/assets/google-icon.svg",
                          height: 25,
                        ),
                        SizedBox(width: 40),
                        Text(
                          "Continuar com Google",
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
            SizedBox(height: 15),
            Material(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {},
                child: Ink(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(15, 255, 255, 255),
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      bottom: BorderSide(width: 6, color: Color(0xFF4DA3FF)),
                      left: BorderSide(width: 2, color: Color(0xFF4DA3FF)),
                      right: BorderSide(width: 2, color: Color(0xFF4DA3FF)),
                      top: BorderSide(width: 2, color: Color(0xFF4DA3FF)),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset("lib/assets/facebook.svg", height: 25),
                        SizedBox(width: 40),
                        Text(
                          "Continuar com Facebook",
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
            SizedBox(height: 45),
            Spacer(),
            Center(
              child: RichText(
                text: TextSpan(
                  text: "Não tem cadastro?",
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 16,
                  ),
                  children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CadastroPage(),
                            ),
                          );
                        },
                      text: " Cadastre-se",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
