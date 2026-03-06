import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider {
  static final AuthProvider _instance = AuthProvider._internal();
  factory AuthProvider() => _instance;
  AuthProvider._internal();

  String? _token;
  String? _nomeUsuario;
  int? _nivel;
  int? _xpTotal;
  int? _xpDoNivel;
  String? _id;

  String? get token => _token;
  String? get nomeUsuario => _nomeUsuario;
  int? get nivel => _nivel;
  int? get xpTotal => _xpTotal;
  int? get xpDoNivel => _xpDoNivel;
  String? get id => _id;
  bool get estaLogado => _token != null;

  Future<void> salvarSessao({
    required String token,
    required String nome,
    required String id,
    required int nivel,
    required int xpTotal,
    required int xpDoNivel,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('nome', nome);
    await prefs.setString('id', id);
    await prefs.setInt('nivel', nivel);
    await prefs.setInt('xpTotal', xpTotal);
    await prefs.setInt('xpDoNivel', xpDoNivel);
    _token = token;
    _nomeUsuario = nome;
    _id = id;
    _nivel = nivel;
    _xpTotal = xpTotal;
    _xpDoNivel = xpDoNivel;
  }

  Future<void> encerrarSessao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _token = null;
    _nomeUsuario = null;
    _id = null;
    _nivel = null;
    _xpTotal = null;
    _xpDoNivel = null;
  }

  Future<void> carregarSessao() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _nomeUsuario = prefs.getString('nome');
    _id = prefs.getString('id');
    _nivel = prefs.getInt('nivel');
    _xpTotal = prefs.getInt('xpTotal');
    _xpDoNivel = prefs.getInt('xpDoNivel');
  }
}
