import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/api/api_client.dart';

class AuthService {
  final ApiClient apiClient;
  final FlutterSecureStorage storage;

  AuthService({
    ApiClient? apiClient,
    FlutterSecureStorage? storage,
  })  : apiClient = apiClient ?? ApiClient(),
        storage = storage ?? const FlutterSecureStorage();

  static const String _tokenKey = 'mobile_token';

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
    }

    return data;
  }

  Future<String?> getToken() {
    return storage.read(key: _tokenKey);
  }

  Future<void> logout() {
    return storage.delete(key: _tokenKey);
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
    return Map<String, dynamic>.from(response.data);
  }
}