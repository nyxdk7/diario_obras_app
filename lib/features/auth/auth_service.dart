import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/api/api_client.dart';
import '../../core/database/app_database.dart';

final AppDatabase appDatabaseSingleton = AppDatabase();

class AuthService {
  final ApiClient apiClient;
  final FlutterSecureStorage storage;
  final AppDatabase database;

  AuthService({
    ApiClient? apiClient,
    FlutterSecureStorage? storage,
    AppDatabase? database,
  })  : apiClient = apiClient ?? ApiClient(),
        storage = storage ?? const FlutterSecureStorage(),
        database = database ?? appDatabaseSingleton;

  static const String _tokenKey = 'mobile_token';
  static const String _nomeUsuarioKey = 'nome_usuario';
  static const String _nomeObraKey = 'nome_obra';

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await apiClient.login(
      username: username,
      password: password,
      dispositivo: 'flutter-app',
    );

    final data = Map<String, dynamic>.from(response.data);

    if (data['ok'] == true && data['token'] != null) {
      await storage.write(
        key: _tokenKey,
        value: data['token'].toString(),
      );

      final usuario = data['usuario'];
      final obra = data['obra'];

      if (usuario is Map) {
        await storage.write(
          key: _nomeUsuarioKey,
          value: usuario['nome_completo']?.toString() ??
              usuario['username']?.toString() ??
              'Engenheiro',
        );
      }

      if (obra is Map) {
        await storage.write(
          key: _nomeObraKey,
          value: obra['nome']?.toString() ?? 'Obra vinculada',
        );
      }
    }

    return data;
  }

  Future<String?> getToken() {
    return storage.read(key: _tokenKey);
  }

  Future<Map<String, String>?> getSessaoLocal() async {
    final token = await storage.read(key: _tokenKey);

    if (token == null || token.isEmpty) {
      return null;
    }

    final nomeUsuario = await storage.read(key: _nomeUsuarioKey);
    final nomeObra = await storage.read(key: _nomeObraKey);

    return {
      'nomeUsuario': nomeUsuario ?? 'Engenheiro',
      'nomeObra': nomeObra ?? 'Obra vinculada',
    };
  }

  Future<void> logout() async {
    await storage.delete(key: _tokenKey);
    await storage.delete(key: _nomeUsuarioKey);
    await storage.delete(key: _nomeObraKey);
  }

  Future<Map<String, dynamic>?> me() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    final response = await apiClient.me(token);
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>?> sync({int limite = 300}) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    final response = await apiClient.sync(token, limite: limite);
    final data = Map<String, dynamic>.from(response.data);

    if (data['ok'] == true && data['diarios'] is List) {
      final diarios = (data['diarios'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      await database.salvarDiariosIncremental(
        diarios,
        limiteSolicitado: limite,
      );

      final totalLocal = await database.contarDiariosSalvos();

      data['sincronizacao_incremental'] = {
        'recebidos_api': diarios.length,
        'total_local': totalLocal,
        'limite_solicitado': limite,
        'modo': 'incremental_upsert',
      };
    }

    return data;
  }

  Future<List<LocalDiario>> listarDiariosLocais({int? limite}) {
    return database.listarUltimosDiarios(limite: limite);
  }

  Future<int> contarDiariosLocais() {
    return database.contarDiariosSalvos();
  }

  Future<String?> buscarUltimaSincronizacao() {
    return database.buscarUltimaSincronizacao();
  }

  Future<Map<String, String?>> buscarResumoSincronizacao() {
    return database.buscarResumoSincronizacao();
  }

  Future<int> salvarRascunhoDiario(Map<String, dynamic> dados) {
    return database.salvarRascunhoDiario(dados);
  }

  Future<void> atualizarRascunhoDiario(
    int id,
    Map<String, dynamic> dados,
  ) {
    return database.atualizarRascunhoDiario(id, dados);
  }

  List<String> extrairCaminhosFotos(Map<String, dynamic> dados) {
    final fotos = dados['fotos_offline'] ?? dados['fotos'];

    if (fotos is! List) {
      return [];
    }

    final caminhos = <String>[];

    for (final foto in fotos) {
      String? caminho;

      if (foto is Map) {
        caminho = foto['path']?.toString();
      } else if (foto is String) {
        caminho = foto;
      }

      if (caminho == null || caminho.trim().isEmpty) {
        continue;
      }

      final arquivo = File(caminho.trim());

      if (arquivo.existsSync()) {
        caminhos.add(arquivo.path);
      }
    }

    return caminhos;
  }

  Map<String, dynamic> payloadSemFotos(Map<String, dynamic> dados) {
    final payload = Map<String, dynamic>.from(dados);

    payload.remove('fotos');
    payload.remove('fotos_offline');

    if ((payload['descricao']?.toString().trim() ?? '').isEmpty) {
      payload['descricao'] =
          payload['comentarios_ocorrencias']?.toString().trim().isNotEmpty ==
                  true
              ? payload['comentarios_ocorrencias'].toString().trim()
              : 'Diário DNIT preenchido pelo app mobile';
    }

    return payload;
  }

  Future<Map<String, dynamic>> enviarRascunhoDiario(
    RascunhosDiario rascunho,
  ) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sessão mobile não encontrada. Faça login novamente.');
    }

    final dados = Map<String, dynamic>.from(
      jsonDecode(rascunho.jsonCompleto) as Map,
    );

    final fotos = extrairCaminhosFotos(dados);
    final payload = payloadSemFotos(dados);

    final response = await apiClient.criarDiarioMobile(
      token,
      payload,
    );

    final data = Map<String, dynamic>.from(response.data);

    if (data['ok'] != true) {
      throw Exception(data['erro']?.toString() ?? 'Erro ao enviar diário.');
    }

    final diarioId = data['id'] ?? (data['diario'] is Map ? data['diario']['id'] : null);
    final diarioIdInt = int.tryParse(diarioId?.toString() ?? '');

    if (diarioIdInt != null && fotos.isNotEmpty) {
      final fotosResponse = await apiClient.enviarFotosDiarioMobile(
        token,
        diarioIdInt,
        fotos,
      );

      final fotosData = Map<String, dynamic>.from(fotosResponse.data);

      if (fotosData['ok'] != true) {
        throw Exception(
          fotosData['erro']?.toString() ??
              'Diário criado, mas as fotos não foram enviadas.',
        );
      }
    }

    await excluirRascunhoDiario(rascunho.id);

    try {
      final resumoSync = await sync(limite: 300);

      data['sincronizacao_pos_envio'] = resumoSync ?? {
        'ok': false,
        'erro': 'Sincronização não retornou dados.',
      };
    } catch (_) {
      data['sincronizacao_pos_envio'] = {
        'ok': false,
        'erro': 'Diário enviado, mas a sincronização automática falhou.',
      };
    }

    return data;
  }


  Future<List<RascunhosDiario>> listarRascunhosDiarios() {
    return database.listarRascunhosDiarios();
  }

  Future<int> contarRascunhosDiarios() {
    return database.contarRascunhosDiarios();
  }

  Future<void> excluirRascunhoDiario(int id) {
    return database.excluirRascunhoDiario(id);
  }
}
