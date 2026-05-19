import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class LocalDiarios extends Table {
  IntColumn get id => integer()();

  IntColumn get obraId => integer().nullable()();
  TextColumn get dataDiario => text().nullable()();
  TextColumn get dataRegistro => text().nullable()();
  TextColumn get equipe => text().nullable()();
  TextColumn get statusAprovacao => text().nullable()();
  TextColumn get tipoServico => text().nullable()();
  TextColumn get descricao => text().nullable()();

  TextColumn get jsonCompleto => text()();

  DateTimeColumn get sincronizadoEm => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncMetadados extends Table {
  TextColumn get chave => text()();
  TextColumn get valor => text().nullable()();

  @override
  Set<Column> get primaryKey => {chave};
}

class RascunhosDiarios extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get obraNome => text()();
  TextColumn get dataDiario => text().nullable()();
  TextColumn get equipe => text().nullable()();
  TextColumn get clima => text().nullable()();
  TextColumn get tipoServico => text().nullable()();
  TextColumn get kmInicial => text().nullable()();
  TextColumn get kmFinal => text().nullable()();
  TextColumn get ocorrencias => text().nullable()();
  TextColumn get observacoes => text().nullable()();

  TextColumn get status => text().withDefault(const Constant('rascunho'))();
  TextColumn get jsonCompleto => text()();

  DateTimeColumn get criadoEm => dateTime()();
  DateTimeColumn get atualizadoEm => dateTime()();
}

@DriftDatabase(
  tables: [
    LocalDiarios,
    SyncMetadados,
    RascunhosDiarios,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_abrirConexao());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(rascunhosDiarios);
        }
      },
    );
  }

  Future<void> salvarDiarios(List<Map<String, dynamic>> diarios) {
    return salvarDiariosIncremental(diarios);
  }

  Future<void> salvarDiariosIncremental(
    List<Map<String, dynamic>> diarios, {
    int? limiteSolicitado,
  }) async {
    final agora = DateTime.now();

    if (diarios.isEmpty) {
      await _salvarMetadado(
        'ultima_sincronizacao',
        agora.toIso8601String(),
      );

      if (limiteSolicitado != null) {
        await _salvarMetadado(
          'ultimo_limite_solicitado',
          limiteSolicitado.toString(),
        );
      }

      await _salvarMetadado('ultimos_recebidos_api', '0');
      return;
    }

    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        localDiarios,
        diarios.map((diario) {
          final servico = _primeiroServico(diario);

          return LocalDiariosCompanion(
            id: Value(_intOuZero(diario['id'])),
            obraId: Value(_obraId(diario)),
            dataDiario: Value(_textoOuNull(diario['data_diario'])),
            dataRegistro: Value(_textoOuNull(diario['data_registro'])),
            equipe: Value(_textoOuNull(diario['equipe'])),
            statusAprovacao: Value(_textoOuNull(diario['status_aprovacao'])),
            tipoServico: Value(servico),
            descricao: Value(_textoOuNull(diario['descricao'])),
            jsonCompleto: Value(_jsonEncodeSeguro(diario)),
            sincronizadoEm: Value(agora),
          );
        }).toList(),
      );
    });

    final totalLocal = await contarDiariosSalvos();

    await _salvarMetadado(
      'ultima_sincronizacao',
      agora.toIso8601String(),
    );

    await _salvarMetadado(
      'ultimos_recebidos_api',
      diarios.length.toString(),
    );

    await _salvarMetadado(
      'total_diarios_local',
      totalLocal.toString(),
    );

    if (limiteSolicitado != null) {
      await _salvarMetadado(
        'ultimo_limite_solicitado',
        limiteSolicitado.toString(),
      );
    }
  }

  Future<List<LocalDiario>> listarUltimosDiarios({int? limite}) {
    final query = select(localDiarios)
      ..orderBy([
        (t) => OrderingTerm.desc(t.dataDiario),
        (t) => OrderingTerm.desc(t.dataRegistro),
        (t) => OrderingTerm.desc(t.id),
      ]);

    if (limite != null && limite > 0) {
      query.limit(limite);
    }

    return query.get();
  }

  Future<int> contarDiariosSalvos() async {
    final countExpression = localDiarios.id.count();
    final query = selectOnly(localDiarios)..addColumns([countExpression]);
    final row = await query.getSingle();

    return row.read(countExpression) ?? 0;
  }

  Future<String?> buscarUltimaSincronizacao() async {
    final item = await (select(syncMetadados)
          ..where((t) => t.chave.equals('ultima_sincronizacao')))
        .getSingleOrNull();

    return item?.valor;
  }

  Future<Map<String, String?>> buscarResumoSincronizacao() async {
    final itens = await select(syncMetadados).get();

    return {
      for (final item in itens) item.chave: item.valor,
    };
  }

  Future<int> salvarRascunhoDiario(Map<String, dynamic> dados) async {
    final agora = DateTime.now();

    final companion = _rascunhoCompanion(
      dados,
      criadoEm: agora,
      atualizadoEm: agora,
    );

    return into(rascunhosDiarios).insert(companion);
  }

  Future<void> atualizarRascunhoDiario(
    int id,
    Map<String, dynamic> dados,
  ) async {
    final existente = await (select(rascunhosDiarios)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();

    if (existente == null) {
      throw Exception('Rascunho não encontrado.');
    }

    final agora = DateTime.now();

    final companion = _rascunhoCompanion(
      dados,
      criadoEm: existente.criadoEm,
      atualizadoEm: agora,
    ).copyWith(
      id: Value(id),
    );

    await (update(rascunhosDiarios)..where((t) => t.id.equals(id))).write(
      companion,
    );
  }

  RascunhosDiariosCompanion _rascunhoCompanion(
    Map<String, dynamic> dados, {
    required DateTime criadoEm,
    required DateTime atualizadoEm,
  }) {
    return RascunhosDiariosCompanion(
      obraNome: Value(_textoOuNull(dados['obra_nome']) ?? 'Obra não informada'),
      dataDiario: Value(_textoOuNull(dados['data_diario'])),
      equipe: Value(_textoOuNull(dados['equipe'])),
      clima: Value(
        _textoOuNull(dados['clima_manha']) ??
            _textoOuNull(dados['clima']) ??
            _textoOuNull(dados['clima_tarde']),
      ),
      tipoServico: Value(_textoOuNull(dados['tipo_servico'])),
      kmInicial: Value(_textoOuNull(dados['km_inicial'])),
      kmFinal: Value(_textoOuNull(dados['km_final'])),
      ocorrencias: Value(_textoOuNull(dados['ocorrencias'])),
      observacoes: Value(
        _textoOuNull(dados['comentarios_ocorrencias']) ??
            _textoOuNull(dados['observacoes']) ??
            _textoOuNull(dados['descricao']),
      ),
      status: const Value('rascunho'),
      jsonCompleto: Value(_jsonEncodeSeguro(dados)),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
    );
  }

  Future<List<RascunhosDiario>> listarRascunhosDiarios() {
    return (select(rascunhosDiarios)
          ..orderBy([
            (t) => OrderingTerm.desc(t.atualizadoEm),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .get();
  }

  Future<int> contarRascunhosDiarios() async {
    final countExpression = rascunhosDiarios.id.count();
    final query = selectOnly(rascunhosDiarios)..addColumns([countExpression]);
    final row = await query.getSingle();

    return row.read(countExpression) ?? 0;
  }

  Future<void> excluirRascunhoDiario(int id) async {
    await (delete(rascunhosDiarios)..where((t) => t.id.equals(id))).go();
  }

  Future<void> _salvarMetadado(String chave, String? valor) async {
    await into(syncMetadados).insertOnConflictUpdate(
      SyncMetadadosCompanion.insert(
        chave: chave,
        valor: Value(valor),
      ),
    );
  }

  static int _intOuZero(dynamic valor) {
    if (valor is int) return valor;
    return int.tryParse(valor?.toString() ?? '') ?? 0;
  }

  static int? _intOuNull(dynamic valor) {
    if (valor == null) return null;
    if (valor is int) return valor;
    return int.tryParse(valor.toString());
  }

  static int? _obraId(Map<String, dynamic> diario) {
    final direto = _intOuNull(diario['obra_id']);

    if (direto != null) {
      return direto;
    }

    final obra = diario['obra'];

    if (obra is Map) {
      return _intOuNull(obra['id']);
    }

    return null;
  }

  static String? _textoOuNull(dynamic valor) {
    if (valor == null) return null;
    final texto = valor.toString().trim();
    return texto.isEmpty ? null : texto;
  }

  static String? _primeiroServico(Map<String, dynamic> diario) {
    final servicos = diario['servicos_executados_lista'];

    if (servicos is List && servicos.isNotEmpty) {
      final primeiro = servicos.first;

      if (primeiro is Map) {
        return _textoOuNull(
          primeiro['tipo_servico'] ?? primeiro['tipo'],
        );
      }
    }

    return _textoOuNull(diario['tipo_servico']);
  }

  static String _jsonEncodeSeguro(Map<String, dynamic> diario) {
    return jsonEncode(diario);
  }
}

LazyDatabase _abrirConexao() {
  return LazyDatabase(() async {
    final pasta = await getApplicationDocumentsDirectory();
    final arquivo = File(p.join(pasta.path, 'diario_obras.sqlite'));

    return NativeDatabase.createInBackground(arquivo);
  });
}
