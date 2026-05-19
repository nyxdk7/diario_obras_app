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

  Future<Response> criarDiarioMobile(
    String token,
    Map<String, dynamic> payload,
  ) {
    return dio.post(
      '/api/mobile/diarios',
      data: payload,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Future<Response> enviarFotosDiarioMobile(
    String token,
    int diarioId,
    List<String> caminhosFotos,
  ) async {
    final formData = FormData();

    for (final caminho in caminhosFotos) {
      final nome = caminho.split(RegExp(r'[\\/]')).last;

      formData.files.add(
        MapEntry(
          'fotos',
          await MultipartFile.fromFile(
            caminho,
            filename: nome,
          ),
        ),
      );
    }

    return dio.post(
      '/api/mobile/diarios/$diarioId/fotos',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
  }

  Future<Response> aprovarDiarioMobile(
    String token,
    int diarioId, {
    String? observacao,
  }) {
    return dio.post(
      '/api/mobile/diarios/$diarioId/aprovar',
      data: {
        if (observacao != null && observacao.trim().isNotEmpty)
          'observacao': observacao.trim(),
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Future<Response> devolverDiarioMobile(
    String token,
    int diarioId, {
    required String motivo,
  }) {
    return dio.post(
      '/api/mobile/diarios/$diarioId/devolver',
      data: {
        'motivo': motivo.trim().isEmpty
            ? 'Registro devolvido para correção.'
            : motivo.trim(),
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }


  Future<Response> pendenciasMobile(
    String token, {
    int limite = 100,
  }) {
    return dio.get(
      '/api/mobile/pendencias',
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


  Future<Response> aprovarEdicaoDiarioMobile(
    String token,
    int diarioId, {
    String? observacao,
  }) {
    return dio.post(
      '/api/mobile/diarios/$diarioId/edicao/aprovar',
      data: {
        if (observacao != null && observacao.trim().isNotEmpty)
          'observacao': observacao.trim(),
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Future<Response> rejeitarEdicaoDiarioMobile(
    String token,
    int diarioId, {
    required String motivo,
  }) {
    return dio.post(
      '/api/mobile/diarios/$diarioId/edicao/rejeitar',
      data: {
        'motivo': motivo.trim().isEmpty
            ? 'Solicitação de edição rejeitada.'
            : motivo.trim(),
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }


  Future<Response> aprovarExclusaoDiarioMobile(
    String token,
    int diarioId,
  ) {
    return dio.post(
      '/api/mobile/diarios/$diarioId/exclusao/aprovar',
      data: {},
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Future<Response> rejeitarExclusaoDiarioMobile(
    String token,
    int diarioId, {
    required String motivo,
  }) {
    return dio.post(
      '/api/mobile/diarios/$diarioId/exclusao/rejeitar',
      data: {
        'motivo': motivo.trim().isEmpty
            ? 'Solicitação de exclusão rejeitada.'
            : motivo.trim(),
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }


  Future<Response> solicitarEdicaoDiarioMobile(
    String token,
    int diarioId, {
    required String motivo,
  }) {
    return dio.post(
      '/api/mobile/diarios/$diarioId/solicitar-edicao',
      data: {
        'motivo': motivo.trim(),
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Future<Response> solicitarExclusaoDiarioMobile(
    String token,
    int diarioId, {
    required String motivo,
  }) {
    return dio.post(
      '/api/mobile/diarios/$diarioId/solicitar-exclusao',
      data: {
        'motivo': motivo.trim(),
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

}
