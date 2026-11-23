import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/filme.dart';

class ApiException implements Exception {
  final String mensagem;
  ApiException(this.mensagem);

  @override
  String toString() => mensagem;
}

class ApiService {
  // Emulador Android acessa o computador pelo IP 10.0.2.2.
  // Chrome, Windows e simulador iOS usam 127.0.0.1.
  // Em celular físico, troque pelo IP do computador na rede (ex.: http://192.168.0.10:8000).
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  static const _timeout = Duration(seconds: 10);
  static const _erroConexao =
      'Não foi possível conectar à API. Verifique se o servidor Django está rodando.';

  // Token JWT recebido no login, enviado nas requisições protegidas.
  static String? token;

  static Future<void> login(String usuario, String senha) async {
    final resposta = await _post('/api/token/', {
      'username': usuario,
      'password': senha,
    });

    if (resposta.statusCode == 200) {
      token = _decodificar(resposta)['access'];
    } else if (resposta.statusCode == 401) {
      throw ApiException('Usuário ou senha inválidos.');
    } else {
      throw ApiException('Erro ao fazer login (código ${resposta.statusCode}).');
    }
  }

  static Future<void> cadastrar(String usuario, String email, String senha) async {
    final resposta = await _post('/api/usuarios/cadastro/', {
      'username': usuario,
      'email': email,
      'password': senha,
    });

    if (resposta.statusCode == 201) return;
    if (resposta.statusCode == 400) {
      throw ApiException(_primeiroErro(resposta));
    }
    throw ApiException('Erro ao cadastrar (código ${resposta.statusCode}).');
  }

  static Future<List<Filme>> listarFilmes() async {
    final http.Response resposta;
    try {
      resposta = await http.get(
        Uri.parse('$baseUrl/api/filmes/'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(_timeout);
    } catch (_) {
      throw ApiException(_erroConexao);
    }

    if (resposta.statusCode == 200) {
      final lista = _decodificar(resposta) as List;
      return lista.map((item) => Filme.fromJson(item)).toList();
    }
    if (resposta.statusCode == 401) {
      throw ApiException('Sessão expirada. Faça login novamente.');
    }
    throw ApiException('Erro ao buscar filmes (código ${resposta.statusCode}).');
  }

  static Future<http.Response> _post(String caminho, Map<String, String> dados) async {
    try {
      return await http
          .post(
            Uri.parse('$baseUrl$caminho'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(dados),
          )
          .timeout(_timeout);
    } catch (_) {
      throw ApiException(_erroConexao);
    }
  }

  // Decodifica em UTF-8 para manter os acentos das respostas da API.
  static dynamic _decodificar(http.Response resposta) {
    return jsonDecode(utf8.decode(resposta.bodyBytes));
  }

  // Pega a primeira mensagem de erro devolvida pelo Django.
  static String _primeiroErro(http.Response resposta) {
    try {
      final erros = _decodificar(resposta) as Map<String, dynamic>;
      final primeiro = erros.values.first;
      return primeiro is List ? primeiro.first.toString() : primeiro.toString();
    } catch (_) {
      return 'Dados inválidos.';
    }
  }
}
