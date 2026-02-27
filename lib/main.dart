import 'package:flutter/material.dart';
import 'package:ringolingo/pages/inicio_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
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

        colorScheme: .fromSeed(seedColor: const Color(0xFF4DA3FF)),
      ),
      home: const InicioPage(),
    );
  }
}
