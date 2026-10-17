import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ringolingo/models/conquista_model.dart';
import 'package:ringolingo/models/missao_model.dart';
import 'package:ringolingo/models/ringo_model.dart';

class ApiService {
  static const String baseUrl = "https://ringolingo.onrender.com";

  static Future<List<RingoModel>?> buscarPersonas() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/Personas'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => RingoModel.fromJson(e)).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<ConquistaModel>?> buscarConquistas(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/Conquista'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => ConquistaModel.fromJson(e)).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> buscarHistorico(
    int usuarioId,
    String nomePersona, {
    String? token,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/Chat/Historico?NomePersona=${Uri.encodeComponent(nomePersona)}',
      );
      final response = await http
          .get(
            uri,
            headers: {if (token != null) 'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<MissaoModel>?> buscarMissoes(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/Miss%C3%B5es'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => MissaoModel.fromJson(e)).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> salvarFcmToken(int usuarioId, String fcmToken) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/Usuario/FcmToken?usuarioId=$usuarioId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'fcmToken': fcmToken}),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> atualizarFoto(int usuarioId, String fotoUrl) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/Usuario/Foto?usuarioId=$usuarioId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'fotoUrl': fotoUrl}),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<ApiResponse> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/Controller/CadastroUsuario'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nome': nome,
              'email': email,
              'senha': senha,
              'confirmarSenha': senha,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);
      return ApiResponse(
        sucesso: body['status'] == true,
        mensagem: body['mensagem'] ?? 'Erro desconhecido',
        dados: body['dados'],
      );
    } catch (e) {
      return ApiResponse(sucesso: false, mensagem: 'Erro de conexão: $e');
    }
  }

  static Future<ApiResponse> loginUsuario({
    required String email,
    required String senha,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/Controller/LoginUsuario'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'senha': senha}),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);
      final dados = body['dados'];
      return ApiResponse(
        sucesso: body['status'] == true,
        mensagem: body['mensagem'] ?? 'Erro desconhecido',
        dados: dados,
      );
    } catch (e) {
      return ApiResponse(sucesso: false, mensagem: 'Erro de conexão: $e');
    }
  }


static Future<ApiResponse> enviarMensagem({
  required String token,
  required String conteudo,
  required String persona,
}) async {
  try {
    final response = await http
        .post(
          Uri.parse('$baseUrl/Chat/EnviarMensagem'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'conteudo': conteudo,
            'nomePersona': persona,
          }),
        )
        .timeout(const Duration(seconds: 60));

    dynamic body;

    try {
      body = jsonDecode(response.body);
    } on FormatException {
      body = null;
    }

    final Map<String, dynamic>? dados =
        body is Map ? Map<String, dynamic>.from(body) : null;

    final sucessoHttp =
        response.statusCode >= 200 && response.statusCode < 300;

    final respostaIa = dados?['respostaIa']?.toString().trim() ?? '';

    if (sucessoHttp && respostaIa.isNotEmpty) {
      return ApiResponse(
        sucesso: true,
        mensagem: respostaIa,
        dados: dados,
      );
    }

    String mensagemErro =
        dados?['mensagem']?.toString() ??
        dados?['message']?.toString() ??
        dados?['erro']?.toString() ??
        dados?['title']?.toString() ??
        '';

    if (mensagemErro.isEmpty) {
      mensagemErro = response.statusCode == 401
          ? 'Sessão inválida. Faça login novamente.'
          : response.statusCode == 403
              ? 'Você não tem autorização para enviar mensagens.'
              : response.statusCode == 429
                  ? 'Limite de mensagens atingido. Tente novamente em instantes.'
                  : 'A API retornou HTTP ${response.statusCode} sem uma resposta válida.';
    }

    return ApiResponse(
      sucesso: false,
      mensagem: mensagemErro,
      dados: {
        ...?dados,
        'statusCode': response.statusCode,
      },
    );
  } catch (e) {
    return ApiResponse(
      sucesso: false,
      mensagem: e is http.ClientException
          ? 'Não foi possível conectar à API.'
          : e.toString().contains('TimeoutException')
              ? 'A API demorou demais para responder.'
              : 'Falha na comunicação com a API: $e',
    );
  }
}


  static Future<int> buscarStreak(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/Usuario/Streak'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['streak'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<XpInfo?> buscarXp(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/Usuario/XP'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return XpInfo(
          nivel: body['nivel'] ?? 1,
          xpTotal: body['xpTotal'] ?? 0,
          xpDoNivel: body['xpDoNivel'] ?? 0,
          xpNecessarioProximoNivel: body['xpNecessarioProximoNivel'] ?? 500,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> reiniciarChat({
    required String token,
    required String nomePersona,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/Chat/ReiniciarChat?nomePersona=${Uri.encodeComponent(nomePersona)}',
      );
      final response = await http
          .delete(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

class ApiResponse {
  final bool sucesso;
  final String mensagem;
  final dynamic dados;

  ApiResponse({required this.sucesso, required this.mensagem, this.dados});
}

class XpInfo {
  final int nivel;
  final int xpTotal;
  final int xpDoNivel;
  final int xpNecessarioProximoNivel;

  XpInfo({
    required this.nivel,
    required this.xpTotal,
    required this.xpDoNivel,
    required this.xpNecessarioProximoNivel,
  });
}
