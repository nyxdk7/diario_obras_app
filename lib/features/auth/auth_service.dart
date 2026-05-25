import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/api/api_client.dart';
import '../../core/database/app_database.dart';

final AppDatabase appDatabaseSingleton = AppDatabase();

class AuthService {
  static final ValueNotifier<Map<int, String>> progressoEnvioPendentes =
      ValueNotifier(<int, String>{});

  static final Set<int> _idsEnvioPendentes = <int>{};

  static Set<int> get idsEnvioPendentes =>
      Set<int>.unmodifiable(_idsEnvioPendentes);

  static bool get existeEnvioPendenteAtivo => _idsEnvioPendentes.isNotEmpty;

  static bool estaEnviandoPendente(int id) {
    return _idsEnvioPendentes.contains(id);
  }

  static void _publicarStatusEnvio(
    int id,
    String mensagem, {
    bool enviando = true,
  }) {
    final atual = Map<int, String>.from(progressoEnvioPendentes.value);
    atual[id] = mensagem;
    progressoEnvioPendentes.value = atual;

    if (enviando) {
      _idsEnvioPendentes.add(id);
    }
  }

  static void _finalizarStatusEnvio(int id, String mensagem) {
    final atual = Map<int, String>.from(progressoEnvioPendentes.value);
    atual[id] = mensagem;
    progressoEnvioPendentes.value = atual;
    _idsEnvioPendentes.remove(id);
  }

  Future<bool> enviarRascunhoComControleGlobal(RascunhosDiario rascunho) async {
    if (_idsEnvioPendentes.contains(rascunho.id)) {
      return false;
    }

    _publicarStatusEnvio(
      rascunho.id,
      'Envio já iniciado. Aguarde a conclusão...',
    );

    try {
      await enviarRascunhoDiario(
        rascunho,
        onProgresso: (mensagem) {
          _publicarStatusEnvio(rascunho.id, mensagem);
        },
      );

      _finalizarStatusEnvio(rascunho.id, 'Envio concluído com sucesso.');
      return true;
    } catch (erro) {
      final texto = erro.toString().replaceFirst('Exception: ', '').trim();

      _finalizarStatusEnvio(
        rascunho.id,
        texto.isEmpty ? 'Falha no envio. O diário continuará pendente.' : texto,
      );

      rethrow;
    }
  }

  final ApiClient apiClient;
  final FlutterSecureStorage storage;
  final AppDatabase database;

  AuthService({
    ApiClient? apiClient,
    FlutterSecureStorage? storage,
    AppDatabase? database,
  }) : apiClient = apiClient ?? ApiClient(),
       storage = storage ?? const FlutterSecureStorage(),
       database = database ?? appDatabaseSingleton;

  static const String _tokenKey = 'mobile_token';
  static const String _nomeUsuarioKey = 'nome_usuario';
  static const String _nomeObraKey = 'nome_obra';
  static const String _nivelUsuarioKey = 'nivel_usuario';

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
      await database.limparDadosLocaisUsuario();

      await storage.write(key: _tokenKey, value: data['token'].toString());

      final usuario = data['usuario'];
      final obra = data['obra'];
      final obras = _extrairListaObras(data);

      if (usuario is Map) {
        await storage.write(
          key: _nomeUsuarioKey,
          value:
              usuario['nome_completo']?.toString() ??
              usuario['username']?.toString() ??
              'Usuário',
        );

        await storage.write(
          key: _nivelUsuarioKey,
          value: usuario['nivel']?.toString() ?? '',
        );
      }

      if (obras.isNotEmpty) {
        await database.sincronizarObrasPermitidas(obras);

        final primeiraObra = obras.first;

        await storage.write(
          key: _nomeObraKey,
          value: primeiraObra['nome']?.toString() ?? 'Obra vinculada',
        );
      } else if (obra is Map) {
        final obraMap = Map<String, dynamic>.from(obra);

        await database.sincronizarObrasPermitidas([obraMap]);

        await storage.write(
          key: _nomeObraKey,
          value: obraMap['nome']?.toString() ?? 'Obra vinculada',
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
    final nivelUsuario = await storage.read(key: _nivelUsuarioKey);

    return {
      'nomeUsuario': nomeUsuario ?? 'Usuário',
      'nomeObra': nomeObra ?? 'Obra vinculada',
      'nivelUsuario': nivelUsuario ?? '',
    };
  }

  Future<void> logout() async {
    await storage.delete(key: _tokenKey);
    await storage.delete(key: _nomeUsuarioKey);
    await storage.delete(key: _nomeObraKey);
    await storage.delete(key: _nivelUsuarioKey);

    await database.limparDadosLocaisUsuario();
  }

  Future<Map<String, dynamic>?> me() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    final response = await apiClient.me(token);
    final data = Map<String, dynamic>.from(response.data);

    if (data['ok'] == true) {
      final obras = _extrairListaObras(data);
      final obra = data['obra'];

      if (obras.isNotEmpty) {
        await database.sincronizarObrasPermitidas(obras);

        await storage.write(
          key: _nomeObraKey,
          value: obras.first['nome']?.toString() ?? 'Obra vinculada',
        );
      } else if (obra is Map) {
        final obraMap = Map<String, dynamic>.from(obra);

        await database.sincronizarObrasPermitidas([obraMap]);

        await storage.write(
          key: _nomeObraKey,
          value: obraMap['nome']?.toString() ?? 'Obra vinculada',
        );
      }
    }

    return data;
  }

  Future<Map<String, dynamic>?> sync({int limite = 300}) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    final response = await apiClient.sync(token, limite: limite);
    final data = Map<String, dynamic>.from(response.data);

    if (data['ok'] == true) {
      final obras = _extrairListaObras(data);
      final obra = data['obra'];

      if (obras.isNotEmpty) {
        await database.sincronizarObrasPermitidas(obras);

        await storage.write(
          key: _nomeObraKey,
          value: obras.first['nome']?.toString() ?? 'Obra vinculada',
        );
      } else if (obra is Map) {
        final obraMap = Map<String, dynamic>.from(obra);

        await database.sincronizarObrasPermitidas([obraMap]);

        await storage.write(
          key: _nomeObraKey,
          value: obraMap['nome']?.toString() ?? 'Obra vinculada',
        );
      }
    }

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
      final totalObras = await database.contarObrasSalvas();

      data['sincronizacao_incremental'] = {
        'recebidos_api': diarios.length,
        'total_local': totalLocal,
        'total_obras_local': totalObras,
        'limite_solicitado': limite,
        'modo': 'incremental_upsert',
      };
    }

    return data;
  }

  Future<List<LocalObra>> listarObrasLocais() {
    return database.listarObrasLocais();
  }

  Future<int> contarObrasLocais() {
    return database.contarObrasSalvas();
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

  Future<void> atualizarRascunhoDiario(int id, Map<String, dynamic> dados) {
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

  List<List<String>> dividirFotosEmLotes(
    List<String> fotos, {
    int tamanhoLote = 3,
  }) {
    final lotes = <List<String>>[];

    for (var i = 0; i < fotos.length; i += tamanhoLote) {
      final fim = (i + tamanhoLote) > fotos.length
          ? fotos.length
          : i + tamanhoLote;
      lotes.add(fotos.sublist(i, fim));
    }

    return lotes;
  }

  Future<Map<String, dynamic>> enviarFotosEmLotes({
    required String token,
    required int diarioId,
    required List<String> fotos,
    int tamanhoLote = 3,
    void Function(String mensagem)? onProgresso,
  }) async {
    if (fotos.isEmpty) {
      return {'ok': true, 'total': 0, 'enviadas': 0, 'falhas': 0};
    }

    final lotes = dividirFotosEmLotes(fotos, tamanhoLote: tamanhoLote);
    final erros = <String>[];
    var enviadas = 0;
    var falhas = 0;

    onProgresso?.call('Enviando fotos em lotes... 0 de ${fotos.length}');

    for (var indice = 0; indice < lotes.length; indice++) {
      final lote = lotes[indice];
      var tentativa = 0;
      var enviado = false;

      final inicio = enviadas + 1;
      final fim = (enviadas + lote.length) > fotos.length
          ? fotos.length
          : enviadas + lote.length;

      onProgresso?.call('Enviando fotos $inicio a $fim de ${fotos.length}...');

      while (!enviado && tentativa < 3) {
        tentativa++;

        try {
          final response = await apiClient.enviarFotosDiarioMobile(
            token,
            diarioId,
            lote,
          );

          final data = Map<String, dynamic>.from(response.data);

          if (data['ok'] == true) {
            enviadas += lote.length;
            enviado = true;

            onProgresso?.call('Fotos enviadas: $enviadas de ${fotos.length}');
          } else {
            if (tentativa >= 3) {
              falhas += lote.length;
              erros.add(
                data['erro']?.toString() ??
                    'Lote ${indice + 1} não foi aceito pelo servidor.',
              );
            } else {
              onProgresso?.call('Tentando novamente lote ${indice + 1}...');
            }
          }
        } catch (erro) {
          if (tentativa >= 3) {
            falhas += lote.length;
            erros.add('Lote ${indice + 1} falhou: $erro');
          } else {
            onProgresso?.call(
              'Falha no lote ${indice + 1}. Tentando novamente...',
            );
          }
        }
      }
    }

    if (erros.isNotEmpty) {
      throw Exception(
        'Diário criado, mas algumas fotos não foram enviadas. '
        'Enviadas: $enviadas de ${fotos.length}. '
        'Erro: ${erros.first}',
      );
    }

    return {
      'ok': true,
      'total': fotos.length,
      'enviadas': enviadas,
      'falhas': falhas,
      'lotes': lotes.length,
    };
  }

  Future<Map<String, dynamic>> enviarRascunhoDiario(
    RascunhosDiario rascunho, {
    void Function(String mensagem)? onProgresso,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sessão mobile não encontrada. Faça login novamente.');
    }

    onProgresso?.call('Preparando diário pendente...');

    final dados = Map<String, dynamic>.from(
      jsonDecode(rascunho.jsonCompleto) as Map,
    );

    if (rascunho.obraId != null && dados['obra_id'] == null) {
      dados['obra_id'] = rascunho.obraId;
    }

    if ((dados['obra_nome'] == null ||
            dados['obra_nome'].toString().trim().isEmpty) &&
        rascunho.obraNome != null &&
        rascunho.obraNome!.trim().isNotEmpty) {
      dados['obra_nome'] = rascunho.obraNome;
    }

    final fotos = extrairCaminhosFotos(dados);
    final payload = payloadSemFotos(dados);

    if (payload['obra_id'] == null ||
        payload['obra_id'].toString().trim().isEmpty) {
      throw Exception(
        'Obra não encontrada no rascunho. Abra o lançamento e selecione a obra novamente.',
      );
    }

    final diarioDevolvidoId = int.tryParse(
      dados['diario_devolvido_id']?.toString() ??
          dados['id_devolvido']?.toString() ??
          '',
    );

    final diarioIdSalvo = int.tryParse(
      dados['diario_id_servidor']?.toString() ?? '',
    );

    Map<String, dynamic> data = {};
    int? diarioIdInt = diarioIdSalvo;

    if (diarioDevolvidoId != null) {
      onProgresso?.call('Reenviando diário corrigido para aprovação...');

      payload.remove('diario_id_servidor');
      payload.remove('diario_devolvido_id');
      payload.remove('id_devolvido');
      payload.remove('modo_correcao_devolvido');
      payload.remove('status_aprovacao');

      final response = await apiClient.reenviarDiarioDevolvidoMobile(
        token,
        diarioDevolvidoId,
        payload,
      );

      data = Map<String, dynamic>.from(response.data);

      if (data['ok'] != true) {
        throw Exception(
          data['erro']?.toString() ?? 'Erro ao reenviar diário corrigido.',
        );
      }

      diarioIdInt = diarioDevolvidoId;
    } else if (diarioIdInt == null) {
      onProgresso?.call('Criando diário no sistema...');

      final response = await apiClient.criarDiarioMobile(token, payload);
      data = Map<String, dynamic>.from(response.data);

      if (data['ok'] != true) {
        throw Exception(data['erro']?.toString() ?? 'Erro ao enviar diário.');
      }

      final diarioId =
          data['id'] ?? (data['diario'] is Map ? data['diario']['id'] : null);
      diarioIdInt = int.tryParse(diarioId?.toString() ?? '');

      if (diarioIdInt != null) {
        dados['diario_id_servidor'] = diarioIdInt;
        dados['diario_criado_servidor_em'] = DateTime.now().toIso8601String();

        try {
          await atualizarRascunhoDiario(rascunho.id, dados);
        } catch (_) {}
      }
    } else {
      data = {
        'ok': true,
        'id': diarioIdInt,
        'mensagem':
            'Diário já criado no servidor. Reenviando apenas fotos pendentes.',
      };

      onProgresso?.call('Diário já criado. Conferindo envio das fotos...');
    }

    if (diarioIdInt == null) {
      throw Exception('Diário enviado, mas o sistema não retornou o ID.');
    }

    if (fotos.isNotEmpty) {
      onProgresso?.call(
        'Enviando ${fotos.length} foto(s). Isso pode levar alguns minutos...',
      );

      try {
        final resumoFotos = await enviarFotosEmLotes(
          token: token,
          diarioId: diarioIdInt,
          fotos: fotos,
          tamanhoLote: 3,
          onProgresso: onProgresso,
        );

        data['upload_fotos'] = resumoFotos;
      } catch (erro) {
        final diarioNaoEncontrado =
            erro is DioException && erro.response?.statusCode == 404;

        final veioDeIdSalvoAntigo = diarioIdSalvo != null;

        if (!diarioNaoEncontrado || !veioDeIdSalvoAntigo) {
          rethrow;
        }

        onProgresso?.call('Diário anterior não encontrado. Recriando envio...');

        dados.remove('diario_id_servidor');
        dados.remove('diario_criado_servidor_em');

        try {
          await atualizarRascunhoDiario(rascunho.id, dados);
        } catch (_) {}

        final novoResponse = await apiClient.criarDiarioMobile(token, payload);
        final novoData = Map<String, dynamic>.from(novoResponse.data);

        if (novoData['ok'] != true) {
          throw Exception(
            novoData['erro']?.toString() ??
                'Erro ao recriar diário para envio.',
          );
        }

        final novoDiarioId =
            novoData['id'] ??
            (novoData['diario'] is Map ? novoData['diario']['id'] : null);

        final novoDiarioIdInt = int.tryParse(novoDiarioId?.toString() ?? '');

        if (novoDiarioIdInt == null) {
          throw Exception('Diário recriado, mas o sistema não retornou o ID.');
        }

        diarioIdInt = novoDiarioIdInt;
        data = novoData;

        dados['diario_id_servidor'] = novoDiarioIdInt;
        dados['diario_criado_servidor_em'] = DateTime.now().toIso8601String();

        try {
          await atualizarRascunhoDiario(rascunho.id, dados);
        } catch (_) {}

        final resumoFotos = await enviarFotosEmLotes(
          token: token,
          diarioId: novoDiarioIdInt,
          fotos: fotos,
          tamanhoLote: 3,
          onProgresso: onProgresso,
        );

        data['upload_fotos'] = resumoFotos;
      }
    }

    onProgresso?.call('Sincronizando dados enviados...');

    await excluirRascunhoDiario(rascunho.id);

    try {
      final resumoSync = await sync(limite: 300);

      data['sincronizacao_pos_envio'] =
          resumoSync ??
          {'ok': false, 'erro': 'Sincronização não retornou dados.'};
    } catch (_) {
      data['sincronizacao_pos_envio'] = {
        'ok': false,
        'erro': 'Diário enviado, mas a sincronização automática falhou.',
      };
    }

    onProgresso?.call('Envio concluído com sucesso.');

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

  Future<Map<String, dynamic>> aprovarDiarioMobile(
    int diarioId, {
    String? observacao,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sessão mobile não encontrada. Faça login novamente.');
    }

    final response = await apiClient.aprovarDiarioMobile(
      token,
      diarioId,
      observacao: observacao,
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> devolverDiarioMobile(
    int diarioId, {
    required String motivo,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sessão mobile não encontrada. Faça login novamente.');
    }

    final response = await apiClient.devolverDiarioMobile(
      token,
      diarioId,
      motivo: motivo,
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>?> listarPendenciasMobile({
    int limite = 100,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    final response = await apiClient.pendenciasMobile(token, limite: limite);

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> aprovarEdicaoDiarioMobile(
    int diarioId, {
    String? observacao,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sessão mobile não encontrada. Faça login novamente.');
    }

    final response = await apiClient.aprovarEdicaoDiarioMobile(
      token,
      diarioId,
      observacao: observacao,
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> rejeitarEdicaoDiarioMobile(
    int diarioId, {
    required String motivo,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sessão mobile não encontrada. Faça login novamente.');
    }

    final response = await apiClient.rejeitarEdicaoDiarioMobile(
      token,
      diarioId,
      motivo: motivo,
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> aprovarExclusaoDiarioMobile(int diarioId) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sessão mobile não encontrada. Faça login novamente.');
    }

    final response = await apiClient.aprovarExclusaoDiarioMobile(
      token,
      diarioId,
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> rejeitarExclusaoDiarioMobile(
    int diarioId, {
    required String motivo,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sessão mobile não encontrada. Faça login novamente.');
    }

    final response = await apiClient.rejeitarExclusaoDiarioMobile(
      token,
      diarioId,
      motivo: motivo,
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> solicitarEdicaoDiarioMobile(
    int diarioId, {
    required String motivo,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sessão mobile não encontrada. Faça login novamente.');
    }

    final response = await apiClient.solicitarEdicaoDiarioMobile(
      token,
      diarioId,
      motivo: motivo,
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> solicitarExclusaoDiarioMobile(
    int diarioId, {
    required String motivo,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sessão mobile não encontrada. Faça login novamente.');
    }

    final response = await apiClient.solicitarExclusaoDiarioMobile(
      token,
      diarioId,
      motivo: motivo,
    );

    return Map<String, dynamic>.from(response.data);
  }

  List<Map<String, dynamic>> _extrairListaObras(Map<String, dynamic> data) {
    final obras = data['obras'];

    if (obras is List) {
      return obras
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .where((item) => item['id'] != null)
          .toList();
    }

    final obra = data['obra'];

    if (obra is Map && obra['id'] != null) {
      return [Map<String, dynamic>.from(obra)];
    }

    return [];
  }
}
