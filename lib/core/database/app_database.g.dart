// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalDiariosTable extends LocalDiarios
    with TableInfo<$LocalDiariosTable, LocalDiario> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalDiariosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _obraIdMeta = const VerificationMeta('obraId');
  @override
  late final GeneratedColumn<int> obraId = GeneratedColumn<int>(
    'obra_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataDiarioMeta = const VerificationMeta(
    'dataDiario',
  );
  @override
  late final GeneratedColumn<String> dataDiario = GeneratedColumn<String>(
    'data_diario',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dataRegistroMeta = const VerificationMeta(
    'dataRegistro',
  );
  @override
  late final GeneratedColumn<String> dataRegistro = GeneratedColumn<String>(
    'data_registro',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _equipeMeta = const VerificationMeta('equipe');
  @override
  late final GeneratedColumn<String> equipe = GeneratedColumn<String>(
    'equipe',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusAprovacaoMeta = const VerificationMeta(
    'statusAprovacao',
  );
  @override
  late final GeneratedColumn<String> statusAprovacao = GeneratedColumn<String>(
    'status_aprovacao',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tipoServicoMeta = const VerificationMeta(
    'tipoServico',
  );
  @override
  late final GeneratedColumn<String> tipoServico = GeneratedColumn<String>(
    'tipo_servico',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descricaoMeta = const VerificationMeta(
    'descricao',
  );
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
    'descricao',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jsonCompletoMeta = const VerificationMeta(
    'jsonCompleto',
  );
  @override
  late final GeneratedColumn<String> jsonCompleto = GeneratedColumn<String>(
    'json_completo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sincronizadoEmMeta = const VerificationMeta(
    'sincronizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> sincronizadoEm =
      GeneratedColumn<DateTime>(
        'sincronizado_em',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    obraId,
    dataDiario,
    dataRegistro,
    equipe,
    statusAprovacao,
    tipoServico,
    descricao,
    jsonCompleto,
    sincronizadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_diarios';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalDiario> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('obra_id')) {
      context.handle(
        _obraIdMeta,
        obraId.isAcceptableOrUnknown(data['obra_id']!, _obraIdMeta),
      );
    }
    if (data.containsKey('data_diario')) {
      context.handle(
        _dataDiarioMeta,
        dataDiario.isAcceptableOrUnknown(data['data_diario']!, _dataDiarioMeta),
      );
    }
    if (data.containsKey('data_registro')) {
      context.handle(
        _dataRegistroMeta,
        dataRegistro.isAcceptableOrUnknown(
          data['data_registro']!,
          _dataRegistroMeta,
        ),
      );
    }
    if (data.containsKey('equipe')) {
      context.handle(
        _equipeMeta,
        equipe.isAcceptableOrUnknown(data['equipe']!, _equipeMeta),
      );
    }
    if (data.containsKey('status_aprovacao')) {
      context.handle(
        _statusAprovacaoMeta,
        statusAprovacao.isAcceptableOrUnknown(
          data['status_aprovacao']!,
          _statusAprovacaoMeta,
        ),
      );
    }
    if (data.containsKey('tipo_servico')) {
      context.handle(
        _tipoServicoMeta,
        tipoServico.isAcceptableOrUnknown(
          data['tipo_servico']!,
          _tipoServicoMeta,
        ),
      );
    }
    if (data.containsKey('descricao')) {
      context.handle(
        _descricaoMeta,
        descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta),
      );
    }
    if (data.containsKey('json_completo')) {
      context.handle(
        _jsonCompletoMeta,
        jsonCompleto.isAcceptableOrUnknown(
          data['json_completo']!,
          _jsonCompletoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_jsonCompletoMeta);
    }
    if (data.containsKey('sincronizado_em')) {
      context.handle(
        _sincronizadoEmMeta,
        sincronizadoEm.isAcceptableOrUnknown(
          data['sincronizado_em']!,
          _sincronizadoEmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sincronizadoEmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalDiario map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalDiario(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      obraId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}obra_id'],
      ),
      dataDiario: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_diario'],
      ),
      dataRegistro: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_registro'],
      ),
      equipe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipe'],
      ),
      statusAprovacao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_aprovacao'],
      ),
      tipoServico: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_servico'],
      ),
      descricao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descricao'],
      ),
      jsonCompleto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_completo'],
      )!,
      sincronizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sincronizado_em'],
      )!,
    );
  }

  @override
  $LocalDiariosTable createAlias(String alias) {
    return $LocalDiariosTable(attachedDatabase, alias);
  }
}

class LocalDiario extends DataClass implements Insertable<LocalDiario> {
  final int id;
  final int? obraId;
  final String? dataDiario;
  final String? dataRegistro;
  final String? equipe;
  final String? statusAprovacao;
  final String? tipoServico;
  final String? descricao;
  final String jsonCompleto;
  final DateTime sincronizadoEm;
  const LocalDiario({
    required this.id,
    this.obraId,
    this.dataDiario,
    this.dataRegistro,
    this.equipe,
    this.statusAprovacao,
    this.tipoServico,
    this.descricao,
    required this.jsonCompleto,
    required this.sincronizadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || obraId != null) {
      map['obra_id'] = Variable<int>(obraId);
    }
    if (!nullToAbsent || dataDiario != null) {
      map['data_diario'] = Variable<String>(dataDiario);
    }
    if (!nullToAbsent || dataRegistro != null) {
      map['data_registro'] = Variable<String>(dataRegistro);
    }
    if (!nullToAbsent || equipe != null) {
      map['equipe'] = Variable<String>(equipe);
    }
    if (!nullToAbsent || statusAprovacao != null) {
      map['status_aprovacao'] = Variable<String>(statusAprovacao);
    }
    if (!nullToAbsent || tipoServico != null) {
      map['tipo_servico'] = Variable<String>(tipoServico);
    }
    if (!nullToAbsent || descricao != null) {
      map['descricao'] = Variable<String>(descricao);
    }
    map['json_completo'] = Variable<String>(jsonCompleto);
    map['sincronizado_em'] = Variable<DateTime>(sincronizadoEm);
    return map;
  }

  LocalDiariosCompanion toCompanion(bool nullToAbsent) {
    return LocalDiariosCompanion(
      id: Value(id),
      obraId: obraId == null && nullToAbsent
          ? const Value.absent()
          : Value(obraId),
      dataDiario: dataDiario == null && nullToAbsent
          ? const Value.absent()
          : Value(dataDiario),
      dataRegistro: dataRegistro == null && nullToAbsent
          ? const Value.absent()
          : Value(dataRegistro),
      equipe: equipe == null && nullToAbsent
          ? const Value.absent()
          : Value(equipe),
      statusAprovacao: statusAprovacao == null && nullToAbsent
          ? const Value.absent()
          : Value(statusAprovacao),
      tipoServico: tipoServico == null && nullToAbsent
          ? const Value.absent()
          : Value(tipoServico),
      descricao: descricao == null && nullToAbsent
          ? const Value.absent()
          : Value(descricao),
      jsonCompleto: Value(jsonCompleto),
      sincronizadoEm: Value(sincronizadoEm),
    );
  }

  factory LocalDiario.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalDiario(
      id: serializer.fromJson<int>(json['id']),
      obraId: serializer.fromJson<int?>(json['obraId']),
      dataDiario: serializer.fromJson<String?>(json['dataDiario']),
      dataRegistro: serializer.fromJson<String?>(json['dataRegistro']),
      equipe: serializer.fromJson<String?>(json['equipe']),
      statusAprovacao: serializer.fromJson<String?>(json['statusAprovacao']),
      tipoServico: serializer.fromJson<String?>(json['tipoServico']),
      descricao: serializer.fromJson<String?>(json['descricao']),
      jsonCompleto: serializer.fromJson<String>(json['jsonCompleto']),
      sincronizadoEm: serializer.fromJson<DateTime>(json['sincronizadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'obraId': serializer.toJson<int?>(obraId),
      'dataDiario': serializer.toJson<String?>(dataDiario),
      'dataRegistro': serializer.toJson<String?>(dataRegistro),
      'equipe': serializer.toJson<String?>(equipe),
      'statusAprovacao': serializer.toJson<String?>(statusAprovacao),
      'tipoServico': serializer.toJson<String?>(tipoServico),
      'descricao': serializer.toJson<String?>(descricao),
      'jsonCompleto': serializer.toJson<String>(jsonCompleto),
      'sincronizadoEm': serializer.toJson<DateTime>(sincronizadoEm),
    };
  }

  LocalDiario copyWith({
    int? id,
    Value<int?> obraId = const Value.absent(),
    Value<String?> dataDiario = const Value.absent(),
    Value<String?> dataRegistro = const Value.absent(),
    Value<String?> equipe = const Value.absent(),
    Value<String?> statusAprovacao = const Value.absent(),
    Value<String?> tipoServico = const Value.absent(),
    Value<String?> descricao = const Value.absent(),
    String? jsonCompleto,
    DateTime? sincronizadoEm,
  }) => LocalDiario(
    id: id ?? this.id,
    obraId: obraId.present ? obraId.value : this.obraId,
    dataDiario: dataDiario.present ? dataDiario.value : this.dataDiario,
    dataRegistro: dataRegistro.present ? dataRegistro.value : this.dataRegistro,
    equipe: equipe.present ? equipe.value : this.equipe,
    statusAprovacao: statusAprovacao.present
        ? statusAprovacao.value
        : this.statusAprovacao,
    tipoServico: tipoServico.present ? tipoServico.value : this.tipoServico,
    descricao: descricao.present ? descricao.value : this.descricao,
    jsonCompleto: jsonCompleto ?? this.jsonCompleto,
    sincronizadoEm: sincronizadoEm ?? this.sincronizadoEm,
  );
  LocalDiario copyWithCompanion(LocalDiariosCompanion data) {
    return LocalDiario(
      id: data.id.present ? data.id.value : this.id,
      obraId: data.obraId.present ? data.obraId.value : this.obraId,
      dataDiario: data.dataDiario.present
          ? data.dataDiario.value
          : this.dataDiario,
      dataRegistro: data.dataRegistro.present
          ? data.dataRegistro.value
          : this.dataRegistro,
      equipe: data.equipe.present ? data.equipe.value : this.equipe,
      statusAprovacao: data.statusAprovacao.present
          ? data.statusAprovacao.value
          : this.statusAprovacao,
      tipoServico: data.tipoServico.present
          ? data.tipoServico.value
          : this.tipoServico,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      jsonCompleto: data.jsonCompleto.present
          ? data.jsonCompleto.value
          : this.jsonCompleto,
      sincronizadoEm: data.sincronizadoEm.present
          ? data.sincronizadoEm.value
          : this.sincronizadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalDiario(')
          ..write('id: $id, ')
          ..write('obraId: $obraId, ')
          ..write('dataDiario: $dataDiario, ')
          ..write('dataRegistro: $dataRegistro, ')
          ..write('equipe: $equipe, ')
          ..write('statusAprovacao: $statusAprovacao, ')
          ..write('tipoServico: $tipoServico, ')
          ..write('descricao: $descricao, ')
          ..write('jsonCompleto: $jsonCompleto, ')
          ..write('sincronizadoEm: $sincronizadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    obraId,
    dataDiario,
    dataRegistro,
    equipe,
    statusAprovacao,
    tipoServico,
    descricao,
    jsonCompleto,
    sincronizadoEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalDiario &&
          other.id == this.id &&
          other.obraId == this.obraId &&
          other.dataDiario == this.dataDiario &&
          other.dataRegistro == this.dataRegistro &&
          other.equipe == this.equipe &&
          other.statusAprovacao == this.statusAprovacao &&
          other.tipoServico == this.tipoServico &&
          other.descricao == this.descricao &&
          other.jsonCompleto == this.jsonCompleto &&
          other.sincronizadoEm == this.sincronizadoEm);
}

class LocalDiariosCompanion extends UpdateCompanion<LocalDiario> {
  final Value<int> id;
  final Value<int?> obraId;
  final Value<String?> dataDiario;
  final Value<String?> dataRegistro;
  final Value<String?> equipe;
  final Value<String?> statusAprovacao;
  final Value<String?> tipoServico;
  final Value<String?> descricao;
  final Value<String> jsonCompleto;
  final Value<DateTime> sincronizadoEm;
  const LocalDiariosCompanion({
    this.id = const Value.absent(),
    this.obraId = const Value.absent(),
    this.dataDiario = const Value.absent(),
    this.dataRegistro = const Value.absent(),
    this.equipe = const Value.absent(),
    this.statusAprovacao = const Value.absent(),
    this.tipoServico = const Value.absent(),
    this.descricao = const Value.absent(),
    this.jsonCompleto = const Value.absent(),
    this.sincronizadoEm = const Value.absent(),
  });
  LocalDiariosCompanion.insert({
    this.id = const Value.absent(),
    this.obraId = const Value.absent(),
    this.dataDiario = const Value.absent(),
    this.dataRegistro = const Value.absent(),
    this.equipe = const Value.absent(),
    this.statusAprovacao = const Value.absent(),
    this.tipoServico = const Value.absent(),
    this.descricao = const Value.absent(),
    required String jsonCompleto,
    required DateTime sincronizadoEm,
  }) : jsonCompleto = Value(jsonCompleto),
       sincronizadoEm = Value(sincronizadoEm);
  static Insertable<LocalDiario> custom({
    Expression<int>? id,
    Expression<int>? obraId,
    Expression<String>? dataDiario,
    Expression<String>? dataRegistro,
    Expression<String>? equipe,
    Expression<String>? statusAprovacao,
    Expression<String>? tipoServico,
    Expression<String>? descricao,
    Expression<String>? jsonCompleto,
    Expression<DateTime>? sincronizadoEm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (obraId != null) 'obra_id': obraId,
      if (dataDiario != null) 'data_diario': dataDiario,
      if (dataRegistro != null) 'data_registro': dataRegistro,
      if (equipe != null) 'equipe': equipe,
      if (statusAprovacao != null) 'status_aprovacao': statusAprovacao,
      if (tipoServico != null) 'tipo_servico': tipoServico,
      if (descricao != null) 'descricao': descricao,
      if (jsonCompleto != null) 'json_completo': jsonCompleto,
      if (sincronizadoEm != null) 'sincronizado_em': sincronizadoEm,
    });
  }

  LocalDiariosCompanion copyWith({
    Value<int>? id,
    Value<int?>? obraId,
    Value<String?>? dataDiario,
    Value<String?>? dataRegistro,
    Value<String?>? equipe,
    Value<String?>? statusAprovacao,
    Value<String?>? tipoServico,
    Value<String?>? descricao,
    Value<String>? jsonCompleto,
    Value<DateTime>? sincronizadoEm,
  }) {
    return LocalDiariosCompanion(
      id: id ?? this.id,
      obraId: obraId ?? this.obraId,
      dataDiario: dataDiario ?? this.dataDiario,
      dataRegistro: dataRegistro ?? this.dataRegistro,
      equipe: equipe ?? this.equipe,
      statusAprovacao: statusAprovacao ?? this.statusAprovacao,
      tipoServico: tipoServico ?? this.tipoServico,
      descricao: descricao ?? this.descricao,
      jsonCompleto: jsonCompleto ?? this.jsonCompleto,
      sincronizadoEm: sincronizadoEm ?? this.sincronizadoEm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (obraId.present) {
      map['obra_id'] = Variable<int>(obraId.value);
    }
    if (dataDiario.present) {
      map['data_diario'] = Variable<String>(dataDiario.value);
    }
    if (dataRegistro.present) {
      map['data_registro'] = Variable<String>(dataRegistro.value);
    }
    if (equipe.present) {
      map['equipe'] = Variable<String>(equipe.value);
    }
    if (statusAprovacao.present) {
      map['status_aprovacao'] = Variable<String>(statusAprovacao.value);
    }
    if (tipoServico.present) {
      map['tipo_servico'] = Variable<String>(tipoServico.value);
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    if (jsonCompleto.present) {
      map['json_completo'] = Variable<String>(jsonCompleto.value);
    }
    if (sincronizadoEm.present) {
      map['sincronizado_em'] = Variable<DateTime>(sincronizadoEm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalDiariosCompanion(')
          ..write('id: $id, ')
          ..write('obraId: $obraId, ')
          ..write('dataDiario: $dataDiario, ')
          ..write('dataRegistro: $dataRegistro, ')
          ..write('equipe: $equipe, ')
          ..write('statusAprovacao: $statusAprovacao, ')
          ..write('tipoServico: $tipoServico, ')
          ..write('descricao: $descricao, ')
          ..write('jsonCompleto: $jsonCompleto, ')
          ..write('sincronizadoEm: $sincronizadoEm')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadadosTable extends SyncMetadados
    with TableInfo<$SyncMetadadosTable, SyncMetadado> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadadosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chaveMeta = const VerificationMeta('chave');
  @override
  late final GeneratedColumn<String> chave = GeneratedColumn<String>(
    'chave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<String> valor = GeneratedColumn<String>(
    'valor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [chave, valor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadados';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadado> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chave')) {
      context.handle(
        _chaveMeta,
        chave.isAcceptableOrUnknown(data['chave']!, _chaveMeta),
      );
    } else if (isInserting) {
      context.missing(_chaveMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chave};
  @override
  SyncMetadado map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadado(
      chave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chave'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor'],
      ),
    );
  }

  @override
  $SyncMetadadosTable createAlias(String alias) {
    return $SyncMetadadosTable(attachedDatabase, alias);
  }
}

class SyncMetadado extends DataClass implements Insertable<SyncMetadado> {
  final String chave;
  final String? valor;
  const SyncMetadado({required this.chave, this.valor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chave'] = Variable<String>(chave);
    if (!nullToAbsent || valor != null) {
      map['valor'] = Variable<String>(valor);
    }
    return map;
  }

  SyncMetadadosCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadadosCompanion(
      chave: Value(chave),
      valor: valor == null && nullToAbsent
          ? const Value.absent()
          : Value(valor),
    );
  }

  factory SyncMetadado.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadado(
      chave: serializer.fromJson<String>(json['chave']),
      valor: serializer.fromJson<String?>(json['valor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chave': serializer.toJson<String>(chave),
      'valor': serializer.toJson<String?>(valor),
    };
  }

  SyncMetadado copyWith({
    String? chave,
    Value<String?> valor = const Value.absent(),
  }) => SyncMetadado(
    chave: chave ?? this.chave,
    valor: valor.present ? valor.value : this.valor,
  );
  SyncMetadado copyWithCompanion(SyncMetadadosCompanion data) {
    return SyncMetadado(
      chave: data.chave.present ? data.chave.value : this.chave,
      valor: data.valor.present ? data.valor.value : this.valor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadado(')
          ..write('chave: $chave, ')
          ..write('valor: $valor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chave, valor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadado &&
          other.chave == this.chave &&
          other.valor == this.valor);
}

class SyncMetadadosCompanion extends UpdateCompanion<SyncMetadado> {
  final Value<String> chave;
  final Value<String?> valor;
  final Value<int> rowid;
  const SyncMetadadosCompanion({
    this.chave = const Value.absent(),
    this.valor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadadosCompanion.insert({
    required String chave,
    this.valor = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : chave = Value(chave);
  static Insertable<SyncMetadado> custom({
    Expression<String>? chave,
    Expression<String>? valor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chave != null) 'chave': chave,
      if (valor != null) 'valor': valor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadadosCompanion copyWith({
    Value<String>? chave,
    Value<String?>? valor,
    Value<int>? rowid,
  }) {
    return SyncMetadadosCompanion(
      chave: chave ?? this.chave,
      valor: valor ?? this.valor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chave.present) {
      map['chave'] = Variable<String>(chave.value);
    }
    if (valor.present) {
      map['valor'] = Variable<String>(valor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadadosCompanion(')
          ..write('chave: $chave, ')
          ..write('valor: $valor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalDiariosTable localDiarios = $LocalDiariosTable(this);
  late final $SyncMetadadosTable syncMetadados = $SyncMetadadosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localDiarios,
    syncMetadados,
  ];
}

typedef $$LocalDiariosTableCreateCompanionBuilder =
    LocalDiariosCompanion Function({
      Value<int> id,
      Value<int?> obraId,
      Value<String?> dataDiario,
      Value<String?> dataRegistro,
      Value<String?> equipe,
      Value<String?> statusAprovacao,
      Value<String?> tipoServico,
      Value<String?> descricao,
      required String jsonCompleto,
      required DateTime sincronizadoEm,
    });
typedef $$LocalDiariosTableUpdateCompanionBuilder =
    LocalDiariosCompanion Function({
      Value<int> id,
      Value<int?> obraId,
      Value<String?> dataDiario,
      Value<String?> dataRegistro,
      Value<String?> equipe,
      Value<String?> statusAprovacao,
      Value<String?> tipoServico,
      Value<String?> descricao,
      Value<String> jsonCompleto,
      Value<DateTime> sincronizadoEm,
    });

class $$LocalDiariosTableFilterComposer
    extends Composer<_$AppDatabase, $LocalDiariosTable> {
  $$LocalDiariosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get obraId => $composableBuilder(
    column: $table.obraId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataDiario => $composableBuilder(
    column: $table.dataDiario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataRegistro => $composableBuilder(
    column: $table.dataRegistro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipe => $composableBuilder(
    column: $table.equipe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statusAprovacao => $composableBuilder(
    column: $table.statusAprovacao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoServico => $composableBuilder(
    column: $table.tipoServico,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonCompleto => $composableBuilder(
    column: $table.jsonCompleto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sincronizadoEm => $composableBuilder(
    column: $table.sincronizadoEm,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalDiariosTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalDiariosTable> {
  $$LocalDiariosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get obraId => $composableBuilder(
    column: $table.obraId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataDiario => $composableBuilder(
    column: $table.dataDiario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataRegistro => $composableBuilder(
    column: $table.dataRegistro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipe => $composableBuilder(
    column: $table.equipe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statusAprovacao => $composableBuilder(
    column: $table.statusAprovacao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoServico => $composableBuilder(
    column: $table.tipoServico,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonCompleto => $composableBuilder(
    column: $table.jsonCompleto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sincronizadoEm => $composableBuilder(
    column: $table.sincronizadoEm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalDiariosTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalDiariosTable> {
  $$LocalDiariosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get obraId =>
      $composableBuilder(column: $table.obraId, builder: (column) => column);

  GeneratedColumn<String> get dataDiario => $composableBuilder(
    column: $table.dataDiario,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dataRegistro => $composableBuilder(
    column: $table.dataRegistro,
    builder: (column) => column,
  );

  GeneratedColumn<String> get equipe =>
      $composableBuilder(column: $table.equipe, builder: (column) => column);

  GeneratedColumn<String> get statusAprovacao => $composableBuilder(
    column: $table.statusAprovacao,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipoServico => $composableBuilder(
    column: $table.tipoServico,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);

  GeneratedColumn<String> get jsonCompleto => $composableBuilder(
    column: $table.jsonCompleto,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get sincronizadoEm => $composableBuilder(
    column: $table.sincronizadoEm,
    builder: (column) => column,
  );
}

class $$LocalDiariosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalDiariosTable,
          LocalDiario,
          $$LocalDiariosTableFilterComposer,
          $$LocalDiariosTableOrderingComposer,
          $$LocalDiariosTableAnnotationComposer,
          $$LocalDiariosTableCreateCompanionBuilder,
          $$LocalDiariosTableUpdateCompanionBuilder,
          (
            LocalDiario,
            BaseReferences<_$AppDatabase, $LocalDiariosTable, LocalDiario>,
          ),
          LocalDiario,
          PrefetchHooks Function()
        > {
  $$LocalDiariosTableTableManager(_$AppDatabase db, $LocalDiariosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalDiariosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalDiariosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalDiariosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> obraId = const Value.absent(),
                Value<String?> dataDiario = const Value.absent(),
                Value<String?> dataRegistro = const Value.absent(),
                Value<String?> equipe = const Value.absent(),
                Value<String?> statusAprovacao = const Value.absent(),
                Value<String?> tipoServico = const Value.absent(),
                Value<String?> descricao = const Value.absent(),
                Value<String> jsonCompleto = const Value.absent(),
                Value<DateTime> sincronizadoEm = const Value.absent(),
              }) => LocalDiariosCompanion(
                id: id,
                obraId: obraId,
                dataDiario: dataDiario,
                dataRegistro: dataRegistro,
                equipe: equipe,
                statusAprovacao: statusAprovacao,
                tipoServico: tipoServico,
                descricao: descricao,
                jsonCompleto: jsonCompleto,
                sincronizadoEm: sincronizadoEm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> obraId = const Value.absent(),
                Value<String?> dataDiario = const Value.absent(),
                Value<String?> dataRegistro = const Value.absent(),
                Value<String?> equipe = const Value.absent(),
                Value<String?> statusAprovacao = const Value.absent(),
                Value<String?> tipoServico = const Value.absent(),
                Value<String?> descricao = const Value.absent(),
                required String jsonCompleto,
                required DateTime sincronizadoEm,
              }) => LocalDiariosCompanion.insert(
                id: id,
                obraId: obraId,
                dataDiario: dataDiario,
                dataRegistro: dataRegistro,
                equipe: equipe,
                statusAprovacao: statusAprovacao,
                tipoServico: tipoServico,
                descricao: descricao,
                jsonCompleto: jsonCompleto,
                sincronizadoEm: sincronizadoEm,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalDiariosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalDiariosTable,
      LocalDiario,
      $$LocalDiariosTableFilterComposer,
      $$LocalDiariosTableOrderingComposer,
      $$LocalDiariosTableAnnotationComposer,
      $$LocalDiariosTableCreateCompanionBuilder,
      $$LocalDiariosTableUpdateCompanionBuilder,
      (
        LocalDiario,
        BaseReferences<_$AppDatabase, $LocalDiariosTable, LocalDiario>,
      ),
      LocalDiario,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadadosTableCreateCompanionBuilder =
    SyncMetadadosCompanion Function({
      required String chave,
      Value<String?> valor,
      Value<int> rowid,
    });
typedef $$SyncMetadadosTableUpdateCompanionBuilder =
    SyncMetadadosCompanion Function({
      Value<String> chave,
      Value<String?> valor,
      Value<int> rowid,
    });

class $$SyncMetadadosTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadadosTable> {
  $$SyncMetadadosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetadadosTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadadosTable> {
  $$SyncMetadadosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadadosTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadadosTable> {
  $$SyncMetadadosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chave =>
      $composableBuilder(column: $table.chave, builder: (column) => column);

  GeneratedColumn<String> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);
}

class $$SyncMetadadosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetadadosTable,
          SyncMetadado,
          $$SyncMetadadosTableFilterComposer,
          $$SyncMetadadosTableOrderingComposer,
          $$SyncMetadadosTableAnnotationComposer,
          $$SyncMetadadosTableCreateCompanionBuilder,
          $$SyncMetadadosTableUpdateCompanionBuilder,
          (
            SyncMetadado,
            BaseReferences<_$AppDatabase, $SyncMetadadosTable, SyncMetadado>,
          ),
          SyncMetadado,
          PrefetchHooks Function()
        > {
  $$SyncMetadadosTableTableManager(_$AppDatabase db, $SyncMetadadosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadadosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadadosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadadosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> chave = const Value.absent(),
                Value<String?> valor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadadosCompanion(
                chave: chave,
                valor: valor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chave,
                Value<String?> valor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadadosCompanion.insert(
                chave: chave,
                valor: valor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadadosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetadadosTable,
      SyncMetadado,
      $$SyncMetadadosTableFilterComposer,
      $$SyncMetadadosTableOrderingComposer,
      $$SyncMetadadosTableAnnotationComposer,
      $$SyncMetadadosTableCreateCompanionBuilder,
      $$SyncMetadadosTableUpdateCompanionBuilder,
      (
        SyncMetadado,
        BaseReferences<_$AppDatabase, $SyncMetadadosTable, SyncMetadado>,
      ),
      SyncMetadado,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalDiariosTableTableManager get localDiarios =>
      $$LocalDiariosTableTableManager(_db, _db.localDiarios);
  $$SyncMetadadosTableTableManager get syncMetadados =>
      $$SyncMetadadosTableTableManager(_db, _db.syncMetadados);
}
