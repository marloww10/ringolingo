import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TeladecarregamentoPage extends StatefulWidget {
  const TeladecarregamentoPage({super.key});

  @override
  State<TeladecarregamentoPage> createState() => _TeladecarregamentoPageState();
}

class _TeladecarregamentoPageState extends State<TeladecarregamentoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('lib/assets/novoRingo.json', width: 250, height: 250),
          ],
        ),
      ),
    );
  }
}
