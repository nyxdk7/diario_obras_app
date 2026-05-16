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

      await database.salvarDiarios(diarios);
    }

    return data;
  }

  Future<List<LocalDiario>> listarDiariosLocais({int limite = 50}) {
    return database.listarUltimosDiarios(limite: limite);
  }

  Future<String?> buscarUltimaSincronizacao() {
    return database.buscarUltimaSincronizacao();
  }
}