import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ringolingo/firebase_options.dart';
import 'package:ringolingo/pages/home_page.dart';
import 'package:ringolingo/pages/inicio_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ringolingo/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthProvider().carregarSessao();
  await Supabase.initialize(
    url: 'https://reorkwznacmxtfsvpmfv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJlb3Jrd3puYWNteHRmc3ZwbWZ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIxOTYwODIsImV4cCI6MjA4Nzc3MjA4Mn0.52IWl7vS7Tm0aoCzbjhdROzRPZBD9cGFAZDZiK8Ppkg',
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RingoLingo',
      theme: ThemeData(
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.nunito(),
          bodyMedium: GoogleFonts.nunito(),
          titleLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 38,
            color: Color(0xFF4DA3FF),
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
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF4DA3FF), width: 2),
          ),
        ),

        scaffoldBackgroundColor: const Color(0xFFF7FAFF),

        colorScheme: .fromSeed(seedColor: const Color(0xFF4DA3FF)),
      ),
      home: AuthProvider().estaLogado ? const HomePage() : const InicioPage(),
    );
  }
}
