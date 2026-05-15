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

@DriftDatabase(
  tables: [
    LocalDiarios,
    SyncMetadados,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_abrirConexao());

  @override
  int get schemaVersion => 1;

  Future<void> salvarDiarios(List<Map<String, dynamic>> diarios) async {
    final agora = DateTime.now();

    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        localDiarios,
        diarios.map((diario) {
          final servico = _primeiroServico(diario);

          return LocalDiariosCompanion(
            id: Value(_intOuZero(diario['id'])),
            obraId: Value(_intOuNull(diario['obra_id'])),
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

    await into(syncMetadados).insertOnConflictUpdate(
      SyncMetadadosCompanion.insert(
        chave: 'ultima_sincronizacao',
        valor: Value(agora.toIso8601String()),
      ),
    );
  }

  Future<List<LocalDiario>> listarUltimosDiarios({int limite = 50}) {
    return (select(localDiarios)
          ..orderBy([
            (t) => OrderingTerm.desc(t.dataRegistro),
            (t) => OrderingTerm.desc(t.id),
          ])
          ..limit(limite))
        .get();
  }

  Future<String?> buscarUltimaSincronizacao() async {
    final item = await (select(syncMetadados)
          ..where((t) => t.chave.equals('ultima_sincronizacao')))
        .getSingleOrNull();

    return item?.valor;
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