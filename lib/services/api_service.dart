import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5269';

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
            body: jsonEncode({'conteudo': conteudo, 'persona': persona}),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(response.body);
      return ApiResponse(
        sucesso: response.statusCode == 200,
        mensagem: body['respostaIa'] ?? '',
        dados: body,
      );
    } catch (e) {
      return ApiResponse(sucesso: false, mensagem: 'Erro de conexão: $e');
    }
  }
}

class ApiResponse {
  final bool sucesso;
  final String mensagem;
  final dynamic dados;

  ApiResponse({required this.sucesso, required this.mensagem, this.dados});
}
