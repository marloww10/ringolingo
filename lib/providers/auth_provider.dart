import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider {
  static final AuthProvider _instance = AuthProvider._internal();
  factory AuthProvider() => _instance;
  AuthProvider._internal();

  String? _token;
  String? _nomeUsuario;
  int? _id;
  int? _nivel;
  int? _xpTotal;
  int? _xpDoNivel;
  int? _xpNecessarioProximoNivel;
  int? _streak;

  String? get token => _token;
  String? get nomeUsuario => _nomeUsuario;
  int? get id => _id;
  int? get nivel => _nivel;
  int? get xpTotal => _xpTotal;
  int? get xpDoNivel => _xpDoNivel;
  int? get xpNecessarioProximoNivel => _xpNecessarioProximoNivel;
  int? get streak => _streak;
  bool get estaLogado => _token != null;

  // Salva sessão após login
  void salvarSessao({
    required String token,
    required String nome,
    required int id,
    required int nivel,
    required int xpTotal,
    required int xpDoNivel,
  }) {
    _token = token;
    _nomeUsuario = nome;
    _id = id;
    _nivel = nivel;
    _xpTotal = xpTotal;
    _xpDoNivel = xpDoNivel;
    _persistir();
  }

  // Atualiza XP e nível após cada mensagem enviada no chat
  void atualizarXp(int nivel, int xpTotal, int xpDoNivel, int xpNecessarioProximoNivel) {
    _nivel = nivel;
    _xpTotal = xpTotal;
    _xpDoNivel = xpDoNivel;
    _xpNecessarioProximoNivel = xpNecessarioProximoNivel;
    _persistir();
  }

  // Atualiza streak vindo do endpoint /Usuario/Streak
  void atualizarStreak(int streak) {
    _streak = streak;
    _persistir();
  }

  void encerrarSessao() {
    _token = null;
    _nomeUsuario = null;
    _id = null;
    _nivel = null;
    _xpTotal = null;
    _xpDoNivel = null;
    _xpNecessarioProximoNivel = null;
    _streak = null;
    _limparPersistencia();
  }

  // ─────────────────────────────────────────
  // PERSISTÊNCIA COM SHARED PREFERENCES
  // ─────────────────────────────────────────

  Future<void> _persistir() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) prefs.setString('token', _token!);
    if (_nomeUsuario != null) prefs.setString('nome', _nomeUsuario!);
    if (_id != null) prefs.setInt('id', _id!);
    if (_nivel != null) prefs.setInt('nivel', _nivel!);
    if (_xpTotal != null) prefs.setInt('xpTotal', _xpTotal!);
    if (_xpDoNivel != null) prefs.setInt('xpDoNivel', _xpDoNivel!);
    if (_xpNecessarioProximoNivel != null) prefs.setInt('xpNecessario', _xpNecessarioProximoNivel!);
    if (_streak != null) prefs.setInt('streak', _streak!);
  }

  Future<void> carregarSessao() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _token = prefs.getString('token');
      _nomeUsuario = prefs.getString('nome');
      _nivel = prefs.getInt('nivel');
      _xpTotal = prefs.getInt('xpTotal');
      _xpDoNivel = prefs.getInt('xpDoNivel');
      _xpNecessarioProximoNivel = prefs.getInt('xpNecessario');
      _streak = prefs.getInt('streak');

      // id pode ter sido salvo como String em versões antigas do app — lê com segurança
      final idRaw = prefs.get('id');
      if (idRaw is int) {
        _id = idRaw;
      } else if (idRaw is String) {
        _id = int.tryParse(idRaw);
      } else {
        _id = null;
      }
    } catch (e) {
      // Se qualquer leitura falhar, limpa tudo e força novo login
      await _limparPersistencia();
    }
  }

  Future<void> _limparPersistencia() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}