import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ringolingo/pages/cadastro_page.dart';
import 'package:ringolingo/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsetsGeometry.all(20),
            child: Column(
              children: [
                SizedBox(height: 280),
                Text(
                  "Seja bem vindo!",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 12),
                Text(
                  "Faça login e tenha acesso ao RingoLingo.",
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: Material(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        await Supabase.instance.client.auth.signInWithOAuth(
                          OAuthProvider.google,
                          redirectTo: 'ringolingo://login-callback',
                          authScreenLaunchMode: LaunchMode.inAppWebView,
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
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: Material(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          color: Color(0xFF4DA3FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            bottom: BorderSide(
                              width: 6,
                              color: Color(0xFF2C68A9),
                            ),
                            left: BorderSide(
                              width: 2,
                              color: Color(0xFF2C68A9),
                            ),
                            right: BorderSide(
                              width: 2,
                              color: Color(0xFF2C68A9),
                            ),
                            top: BorderSide(width: 2, color: Color(0xFF2C68A9)),
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
                              Icon(
                                Icons.email,
                                size: 25,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                              SizedBox(width: 40),
                              Text(
                                "Continuar com Email",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: Material(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {},
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                "lib/assets/facebook.svg",
                                height: 25,
                              ),
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
                ),
                SizedBox(height: 15),
                RichText(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
