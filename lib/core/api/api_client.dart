import 'package:dio/dio.dart';

class ApiClient {
  static const String baseUrl = 'http://192.168.9.2';

  final Dio dio;

  ApiClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );

  Future<Response> login({
    required String username,
    required String password,
    String dispositivo = 'flutter-app',
  }) {
    return dio.post(
      '/api/mobile/login',
      data: {
        'username': username,
        'password': password,
        'dispositivo': dispositivo,
      },
    );
  }

  Future<Response> me(String token) {
    return dio.get(
      '/api/mobile/me',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<Response> sync(String token, {int limite = 300}) {
    return dio.get(
      '/api/mobile/sync',
      queryParameters: {
        'limite': limite,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }
}