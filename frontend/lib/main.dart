import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ringolingo/firebase_options.dart';
import 'package:ringolingo/pages/home_page.dart';
import 'package:ringolingo/pages/inicio_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ringolingo/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/analytics_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthProvider().carregarSessao();
  await Supabase.initialize(
    url: 'https://bdzfsdduaqngcivxpplj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJkemZzZGR1YXFuZ2NpdnhwcGxqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ2MTQzMjIsImV4cCI6MjA5MDE5MDMyMn0.jPNVG_9tDcthrEw3okcsv6w9J3ljSfcLKbCVdwudr3Y',
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Listener do Supabase — captura o retorno do OAuth do Google
  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    final session = data.session;
    if (session == null) return;

    // Evita processar se o usuário já está logado pelo nosso sistema
    if (AuthProvider().estaLogado) return;

    try {
      // ALTERAÇÃO 1: Captura o nome completo vindo do Google/Supabase
      final nomeGoogle = session.user.userMetadata?['full_name'] ?? "";

      // ALTERAÇÃO 2: Adiciona o nome como parâmetro na URL (Query String)
      final response = await http
          .get(
            Uri.parse(
              'https://ringolingo-production.up.railway.app/Controller/loginSocial?nome=$nomeGoogle',
            ),
            headers: {'Authorization': 'Bearer ${session.accessToken}'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final dados = body['dados'];

        if (dados != null) {
          await AnalyticsService.loginSucesso();
          await AuthProvider().salvarSessao(
            token: dados['token'],
            nome: dados['nome'],
            id: dados['id'] as int,
            nivel: (dados['nivel'] ?? 1) as int,
            xpTotal: (dados['xpTotal'] ?? 0) as int,
            xpDoNivel: (dados['xpDoNivel'] ?? 0) as int,
          );

          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );
        }
      } else {
        debugPrint('Erro no loginSocial: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao conectar com backend no loginSocial: $e');
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      navigatorObservers: [AnalyticsService.observer],
      debugShowCheckedModeBanner: false,
      title: 'RingoLingo',
      theme: ThemeData(
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.nunito(),
          bodyMedium: GoogleFonts.nunito(),
          titleLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 38,
            color: const Color(0xFF4DA3FF),
          ),
        ),
        appBarTheme: AppBarTheme(
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4DA3FF), width: 2),
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7FAFF),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4DA3FF)),
      ),
      home: AuthProvider().estaLogado ? const HomePage() : const InicioPage(),
    );
  }
}
