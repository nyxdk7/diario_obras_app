import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'core/api/api_client.dart';
import 'core/database/app_database.dart';
import 'features/auth/auth_service.dart';

String formatarQuantidadeMaterialVisivel(dynamic valor) {
  final texto = valor?.toString().trim() ?? '';

  if (texto.isEmpty || texto == '-') {
    return '-';
  }

  final partes = texto.split(',');
  final inteiroBruto = partes.first.replaceAll(RegExp(r'[^0-9]'), '');

  if (inteiroBruto.isEmpty) {
    return texto;
  }

  final buffer = StringBuffer();
  var contador = 0;

  for (var i = inteiroBruto.length - 1; i >= 0; i--) {
    buffer.write(inteiroBruto[i]);
    contador++;

    if (contador == 3 && i != 0) {
      buffer.write('.');
      contador = 0;
    }
  }

  final inteiroFormatado = buffer.toString().split('').reversed.join();

  if (partes.length > 1) {
    final decimal = partes
        .sublist(1)
        .join('')
        .replaceAll(RegExp(r'[^0-9]'), '');

    if (decimal.isNotEmpty) {
      return '$inteiroFormatado,$decimal';
    }
  }

  return inteiroFormatado;
}

class QuantidadeMaterialInputFormatter extends TextInputFormatter {
  const QuantidadeMaterialInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final textoNovo = newValue.text;

    if (textoNovo.trim().isEmpty) {
      return newValue;
    }

    final temVirgula = textoNovo.contains(',');
    final partes = textoNovo.split(',');
    final inteiroBruto = partes.first.replaceAll(RegExp(r'[^0-9]'), '');

    if (inteiroBruto.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final inteiroFormatado = formatarQuantidadeMaterialVisivel(inteiroBruto);
    var textoFormatado = inteiroFormatado;

    if (temVirgula) {
      final decimal = partes.length > 1
          ? partes.sublist(1).join('').replaceAll(RegExp(r'[^0-9]'), '')
          : '';

      textoFormatado = '$inteiroFormatado,$decimal';
    }

    return TextEditingValue(
      text: textoFormatado,
      selection: TextSelection.collapsed(offset: textoFormatado.length),
    );
  }
}

class AppUI {
  AppUI._();

  static const Color bg = Color(0xFFF4F7FB);
  static const Color surface = Colors.white;
  static const Color navy = Color(0xFF0F172A);
  static const Color blue = Color(0xFF1D4ED8);
  static const Color blue2 = Color(0xFF2563EB);
  static const Color cyan = Color(0xFF0EA5E9);
  static const Color green = Color(0xFF10B981);
  static const Color amber = Color(0xFFF59E0B);
  static const Color orange = Color(0xFFF97316);
  static const Color red = Color(0xFFDC2626);
  static const Color purple = Color(0xFF7C3AED);
  static const Color text = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1D4ED8), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softGradient = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static List<BoxShadow> softShadow = const [
    BoxShadow(color: Color(0x140F172A), blurRadius: 24, offset: Offset(0, 12)),
  ];

  static ThemeData get theme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: blue,
      brightness: Brightness.light,
      primary: blue,
      secondary: cyan,
      surface: surface,
      background: bg,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: bg,
        foregroundColor: text,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: const Color(0x1A0F172A),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: blue, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          side: const BorderSide(color: border),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: blue,
        disabledColor: const Color(0xFFE2E8F0),
        surfaceTintColor: Colors.transparent,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: const BorderSide(color: Color(0xFFCBD5E1)),
        labelStyle: const TextStyle(fontWeight: FontWeight.w900, color: text),
        secondaryLabelStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: blue, size: 18),
      ),
    );
  }
}

void main() {
  runApp(const DiarioObrasApp());
}

class DiarioObrasApp extends StatelessWidget {
  const DiarioObrasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dash Sistem',
      debugShowCheckedModeBanner: false,
      theme: AppUI.theme,
      home: const AppStartPage(),
    );
  }
}

class AppStartPage extends StatefulWidget {
  const AppStartPage({super.key});

  @override
  State<AppStartPage> createState() => _AppStartPageState();
}

class _AppStartPageState extends State<AppStartPage> {
  final authService = AuthService();

  @override
  void initState() {
    super.initState();
    verificarSessao();
  }

  Future<void> verificarSessao() async {
    try {
      final sessao = await authService.getSessaoLocal().timeout(
        const Duration(seconds: 6),
      );

      if (!mounted) return;

      if (sessao == null) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(
            nomeUsuario: sessao['nomeUsuario'] ?? 'Usuário',
            nomeObra: sessao['nomeObra'] ?? 'Obra vinculada',
            nivelUsuario: sessao['nivelUsuario'] ?? '',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      await authService.logout();

      if (!mounted) return;

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usuarioController = TextEditingController();
  final senhaController = TextEditingController();
  final authService = AuthService();

  bool carregando = false;

  @override
  void dispose() {
    usuarioController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> fazerLogin() async {
    final username = usuarioController.text.trim();
    final password = senhaController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      mostrarMensagem('Informe usuário e senha.');
      return;
    }

    setState(() {
      carregando = true;
    });

    try {
      final resposta = await authService.login(
        username: username,
        password: password,
      );

      if (!mounted) return;

      if (resposta['ok'] == true) {
        final usuario = resposta['usuario'] as Map<String, dynamic>?;
        final obra = resposta['obra'] as Map<String, dynamic>?;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomePage(
              nomeUsuario:
                  usuario?['nome_completo']?.toString() ??
                  usuario?['username']?.toString() ??
                  'Usuário',
              nomeObra: obra?['nome']?.toString() ?? 'Obra vinculada',
              nivelUsuario: usuario?['nivel']?.toString() ?? '',
            ),
          ),
        );
      } else {
        mostrarMensagem(resposta['erro']?.toString() ?? 'Erro ao fazer login.');
      }
    } on DioException catch (erro) {
      mostrarMensagem(AppErrorHandler.mensagemLogin(erro));
    } catch (_) {
      mostrarMensagem(
        'Erro inesperado ao fazer login. Feche o app, abra novamente e tente outra vez.',
      );
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  void mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1D4ED8), Color(0xFFF4F7FB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.48, 0.48],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.16),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.engineering_outlined,
                              color: AppUI.blue,
                              size: 32,
                            ),
                          ),
                          SizedBox(height: 18),
                          Text(
                            'Diário de Obras',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Lançamentos, consulta offline e sincronização de campo em um só lugar.',
                            style: TextStyle(
                              color: Color(0xFFDDEBFF),
                              fontSize: 15,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppUI.border),
                        boxShadow: AppUI.softShadow,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Acessar sistema',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppUI.text,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Use o mesmo usuário do sistema web.',
                              style: TextStyle(
                                color: AppUI.muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 22),
                            TextField(
                              controller: usuarioController,
                              decoration: const InputDecoration(
                                labelText: 'Usuário',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: senhaController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Senha',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              onSubmitted: (_) => fazerLogin(),
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: FilledButton.icon(
                                onPressed: carregando ? null : fazerLogin,
                                icon: carregando
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.login_rounded),
                                label: Text(
                                  carregando ? 'Entrando...' : 'Entrar no app',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Funciona online e mantém dados pendentes quando estiver sem conexão.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppUI.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String nomeUsuario;
  final String nomeObra;
  final String nivelUsuario;

  const HomePage({
    super.key,
    required this.nomeUsuario,
    required this.nomeObra,
    this.nivelUsuario = '',
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authService = AuthService();
  final buscaController = TextEditingController();

  bool carregando = true;
  bool usandoDadosLocais = false;
  bool enviandoPendentesAuto = false;
  int totalPendentesLocais = 0;
  String? erro;
  String? ultimaSincronizacao;
  String termoBusca = '';
  String filtroStatus = 'TODOS';
  String filtroPeriodo = 'TODOS';
  String ordenacao = 'RECENTES';
  String? obraSelecionada;
  int? obraSelecionadaId;
  int limiteSincronizacao = 50;
  List<dynamic> diarios = [];
  List<LocalObra> obrasLocais = [];

  @override
  void initState() {
    super.initState();
    carregarDiarios(tentarEnviarPendentes: true);
  }

  @override
  void dispose() {
    buscaController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get diariosBase {
    return diarios
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  bool get obraFoiSelecionada {
    return obraSelecionadaId != null ||
        (obraSelecionada != null && obraSelecionada!.trim().isNotEmpty);
  }

  List<Map<String, dynamic>> get diariosDaObraSelecionada {
    if (!obraFoiSelecionada) {
      return [];
    }

    return diariosBase.where((diario) {
      final id = obraIdDoDiario(diario);

      if (obraSelecionadaId != null && id != null) {
        return id == obraSelecionadaId;
      }

      return nomeObraDoDiario(diario) == obraSelecionada;
    }).toList();
  }

  List<Map<String, dynamic>> get diariosFiltrados {
    if (!obraFoiSelecionada) {
      return [];
    }

    final termo = termoBusca.trim().toLowerCase();

    final filtradosPorStatus = diariosDaObraSelecionada.where((diario) {
      if (filtroStatus == 'TODOS') {
        return true;
      }

      final status = normalizarStatus(
        diario['status_visual'] ?? diario['status_aprovacao'],
      );
      return status == filtroStatus;
    }).toList();

    final filtradosPorPeriodo = filtradosPorStatus.where((diario) {
      return diarioDentroDoPeriodo(diario);
    }).toList();

    final filtradosPorBusca = termo.isEmpty
        ? filtradosPorPeriodo
        : filtradosPorPeriodo.where((diario) {
            final conteudo = [
              diario['id'],
              diario['data_diario'],
              diario['data_registro'],
              diario['equipe'],
              diario['status_aprovacao'],
              diario['descricao'],
              diario['ocorrencias'],
              diario['comentarios_ocorrencias'],
              diario['clima'],
              diario['km_inicial'],
              diario['km_final'],
              primeiroServico(diario),
              nomeObraDoDiario(diario),
            ].map((valor) => valor?.toString().toLowerCase() ?? '').join(' ');

            return conteudo.contains(termo);
          }).toList();

    filtradosPorBusca.sort((a, b) {
      final dataA = dataDoDiario(a) ?? DateTime(1900);
      final dataB = dataDoDiario(b) ?? DateTime(1900);

      if (ordenacao == 'ANTIGOS') {
        return dataA.compareTo(dataB);
      }

      return dataB.compareTo(dataA);
    });

    return filtradosPorBusca;
  }

  Map<String, int> get resumoStatus {
    final base = obraFoiSelecionada
        ? diariosDaObraSelecionada
        : <Map<String, dynamic>>[];

    final resumo = {
      'TODOS': base.length,
      'PENDENTE': 0,
      'APROVADO': 0,
      'DEVOLVIDO': 0,
    };

    for (final diario in base) {
      final status = normalizarStatus(
        diario['status_visual'] ?? diario['status_aprovacao'],
      );

      if (resumo.containsKey(status)) {
        resumo[status] = resumo[status]! + 1;
      }
    }

    return resumo;
  }

  List<Map<String, dynamic>> get obrasDisponiveis {
    if (obrasLocais.isNotEmpty) {
      return obrasLocais
          .map((obra) => {'id': obra.id, 'nome': obra.nome})
          .toList()
        ..sort((a, b) => a['nome'].toString().compareTo(b['nome'].toString()));
    }

    final porNome = <String, Map<String, dynamic>>{};
    int idTemporario = -1;

    for (final diario in diariosBase) {
      final nome = nomeObraDoDiario(diario);
      final id = obraIdDoDiario(diario);

      if (nome.trim().isEmpty || nome == 'Obra não informada') {
        continue;
      }

      porNome[nome] = {'id': id ?? idTemporario--, 'nome': nome};
    }

    final lista = porNome.values.toList()
      ..sort((a, b) => a['nome'].toString().compareTo(b['nome'].toString()));

    return lista;
  }

  String nomeObraDoDiario(Map<String, dynamic> diario) {
    final obra = diario['obra'];

    if (obra is Map) {
      final nome = obra['nome']?.toString().trim() ?? '';

      if (nome.isNotEmpty) {
        return nome;
      }
    }

    final possiveis = [
      diario['obra_nome'],
      diario['nome_obra'],
      diario['obra'],
    ];

    for (final item in possiveis) {
      final valor = item?.toString().trim() ?? '';

      if (valor.isNotEmpty && valor != '{}') {
        return valor;
      }
    }

    return 'Obra não informada';
  }

  int? obraIdDoDiario(Map<String, dynamic> diario) {
    final direto = diario['obra_id'];

    if (direto is int) {
      return direto;
    }

    final diretoParseado = int.tryParse(direto?.toString() ?? '');

    if (diretoParseado != null) {
      return diretoParseado;
    }

    final obra = diario['obra'];

    if (obra is Map) {
      final id = obra['id'];

      if (id is int) {
        return id;
      }

      return int.tryParse(id?.toString() ?? '');
    }

    return null;
  }

  String labelObraSelecionada(Map<String, dynamic> obra) {
    return obra['nome']?.toString() ?? 'Obra sem nome';
  }

  int? idObraOpcao(Map<String, dynamic> obra) {
    final id = obra['id'];

    if (id is int) {
      return id;
    }

    return int.tryParse(id?.toString() ?? '');
  }

  String? nomeDaObraSelecionada() {
    if (obraSelecionada != null && obraSelecionada!.trim().isNotEmpty) {
      return obraSelecionada;
    }

    if (obraSelecionadaId == null) {
      return null;
    }

    for (final obra in obrasDisponiveis) {
      if (idObraOpcao(obra) == obraSelecionadaId) {
        return labelObraSelecionada(obra);
      }
    }

    return null;
  }

  void selecionarObra(Map<String, dynamic> obra) {
    setState(() {
      obraSelecionadaId = idObraOpcao(obra);
      obraSelecionada = labelObraSelecionada(obra);
    });
  }

  DateTime? dataDoDiario(Map<String, dynamic> diario) {
    final possiveis = [
      diario['data_diario'],
      diario['data_registro'],
      diario['created_at'],
      diario['data_criacao'],
    ];

    for (final item in possiveis) {
      final valor = item?.toString().trim() ?? '';

      if (valor.isEmpty) {
        continue;
      }

      try {
        return DateTime.parse(valor);
      } catch (_) {}

      try {
        final partes = valor.split('/');

        if (partes.length == 3) {
          final dia = int.parse(partes[0]);
          final mes = int.parse(partes[1]);
          final ano = int.parse(partes[2].split(' ').first);
          return DateTime(ano, mes, dia);
        }
      } catch (_) {}
    }

    return null;
  }

  bool diarioDentroDoPeriodo(Map<String, dynamic> diario) {
    if (filtroPeriodo == 'TODOS') {
      return true;
    }

    final data = dataDoDiario(diario);

    if (data == null) {
      return true;
    }

    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final dataLimpa = DateTime(data.year, data.month, data.day);

    int dias = 0;

    switch (filtroPeriodo) {
      case '7_DIAS':
        dias = 7;
        break;
      case '30_DIAS':
        dias = 30;
        break;
      case '90_DIAS':
        dias = 90;
        break;
      default:
        return true;
    }

    final limite = hoje.subtract(Duration(days: dias));
    return dataLimpa.isAfter(limite) || dataLimpa.isAtSameMomentAs(limite);
  }

  Future<void> atualizarContadorPendentes() async {
    final total = await authService.contarRascunhosDiarios();

    if (!mounted) {
      return;
    }

    setState(() {
      totalPendentesLocais = total;
    });
  }

  Future<int> enviarPendentesAutomaticamente({
    bool mostrarMensagem = false,
  }) async {
    final pendentes = await authService.listarRascunhosDiarios();

    if (!mounted) {
      return 0;
    }

    setState(() {
      totalPendentesLocais = pendentes.length;
    });

    if (pendentes.isEmpty) {
      return 0;
    }

    setState(() {
      enviandoPendentesAuto = true;
    });

    int enviados = 0;
    String? erroEnvio;

    try {
      for (final item in pendentes) {
        try {
          await authService
              .enviarRascunhoDiario(item)
              .timeout(const Duration(minutes: 8));

          enviados++;
        } catch (erro) {
          erroEnvio = mensagemErroEnvioPendente(erro);
          break;
        }
      }
    } finally {
      final restantes = await authService.contarRascunhosDiarios();

      if (mounted) {
        setState(() {
          totalPendentesLocais = restantes;
          enviandoPendentesAuto = false;
        });
      }
    }

    if (!mounted) {
      return enviados;
    }

    if (mostrarMensagem && enviados > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$enviados diário(s) pendente(s) enviado(s).')),
      );
    }

    if (erroEnvio != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erroEnvio),
          backgroundColor: AppUI.red,
          duration: const Duration(seconds: 7),
        ),
      );
    }

    return enviados;
  }

  String mensagemErroEnvioPendente(Object erro) {
    if (erro is DioException) {
      final data = erro.response?.data;

      if (data is Map && data['erro'] != null) {
        return data['erro'].toString();
      }

      final status = erro.response?.statusCode;

      if (status == 413) {
        return 'As fotos estão muito pesadas para envio. Tente enviar em menor quantidade.';
      }

      if (status == 403) {
        return 'Usuário sem permissão para enviar este diário/obra.';
      }

      if (status == 401) {
        return 'Sessão expirada. Faça login novamente.';
      }

      if (erro.type == DioExceptionType.connectionTimeout ||
          erro.type == DioExceptionType.sendTimeout ||
          erro.type == DioExceptionType.receiveTimeout) {
        return 'O envio demorou demais. Verifique a conexão/VPN e tente novamente.';
      }

      return AppErrorHandler.mensagemModoOffline(erro);
    }

    if (erro is TimeoutException) {
      return 'O envio demorou demais e foi interrompido. Tente novamente com internet estável.';
    }

    final texto = erro.toString().trim();

    if (texto.isNotEmpty) {
      return texto.replaceFirst('Exception: ', '');
    }

    return 'Não foi possível enviar o diário pendente.';
  }

  Future<void> carregarDiarios({bool tentarEnviarPendentes = false}) async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      ultimaSincronizacao = await authService.buscarUltimaSincronizacao();
      await atualizarContadorPendentes();

      final obrasAntesSync = await authService.listarObrasLocais();

      if (mounted) {
        setState(() {
          obrasLocais = obrasAntesSync;
        });
      }

      if (tentarEnviarPendentes) {
        await enviarPendentesAutomaticamente();
      }

      final locais = await authService.listarDiariosLocais();

      final diariosLocais = <Map<String, dynamic>>[];

      for (final item in locais) {
        try {
          final decoded = jsonDecode(item.jsonCompleto);

          if (decoded is Map) {
            diariosLocais.add(Map<String, dynamic>.from(decoded));
          }
        } catch (_) {
          // Ignora registros locais antigos que não estejam em JSON válido.
        }
      }

      if (diariosLocais.isNotEmpty && mounted) {
        setState(() {
          diarios = diariosLocais;
          obrasLocais = obrasAntesSync;
          usandoDadosLocais = true;
          carregando = false;
        });
      }

      final resposta = await authService.sync(limite: limiteSincronizacao);

      if (!mounted) return;

      if (resposta == null) {
        setState(() {
          erro = diarios.isEmpty
              ? 'Token não encontrado. Faça login novamente.'
              : null;
          carregando = false;
        });
        return;
      }

      if (resposta['ok'] == true) {
        final listaApi = resposta['diarios'] as List<dynamic>? ?? [];
        final obrasDepoisSync = await authService.listarObrasLocais();

        setState(() {
          diarios = listaApi;
          obrasLocais = obrasDepoisSync;
          usandoDadosLocais = false;
          ultimaSincronizacao = DateTime.now().toIso8601String();
          carregando = false;
          erro = null;

          if (obraSelecionadaId != null &&
              obrasLocais.isNotEmpty &&
              !obrasLocais.any((obra) => obra.id == obraSelecionadaId)) {
            obraSelecionadaId = null;
            obraSelecionada = null;
          }
        });

        await atualizarContadorPendentes();
      } else {
        setState(() {
          erro = diarios.isEmpty
              ? resposta['erro']?.toString() ?? 'Erro ao sincronizar dados.'
              : null;
          carregando = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        erro = diarios.isEmpty
            ? AppErrorHandler.mensagemSincronizacao(e)
            : null;
        usandoDadosLocais = diarios.isNotEmpty;
        carregando = false;
      });

      if (diarios.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppErrorHandler.mensagemModoOffline(e))),
        );
      }
    } catch (_) {
      setState(() {
        erro = diarios.isEmpty
            ? 'Não foi possível carregar os diários. Tente sincronizar novamente em alguns instantes.'
            : null;
        usandoDadosLocais = diarios.isNotEmpty;
        carregando = false;
      });
    }
  }

  Future<void> sair() async {
    await authService.logout();

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  Future<void> abrirConfiguracoes() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConfiguracoesPage(
          nomeUsuario: widget.nomeUsuario,
          nomeObra: widget.nomeObra,
          apiBaseUrl: ApiClient.baseUrl,
          totalDiariosOffline: diarios.length,
          usandoDadosLocais: usandoDadosLocais,
          ultimaSincronizacao: formatarUltimaSincronizacao(),
          limiteSincronizacao: limiteSincronizacao,
          urlsFotosSincronizadas: urlsFotosSincronizadas(),
          onAlterarLimiteSincronizacao: alterarLimiteSincronizacao,
          onSincronizar: () => carregarDiarios(tentarEnviarPendentes: true),
          onSair: sair,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> abrirNovoDiarioOffline() async {
    final nomeObra = nomeDaObraSelecionada();

    if (!obraFoiSelecionada ||
        obraSelecionadaId == null ||
        nomeObra == null ||
        nomeObra.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecione uma obra vinculada antes de criar um diário offline.',
          ),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NovoDiarioOfflinePage(
          obraId: obraSelecionadaId,
          obraNome: nomeObra,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    await carregarDiarios(tentarEnviarPendentes: true);
  }

  Future<void> abrirPendentesOffline() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PendentesOfflinePage()));

    if (!mounted) {
      return;
    }

    await carregarDiarios(tentarEnviarPendentes: true);
  }

  int totalPendenciasHome() {
    final pendentesLocais = resumoStatus['PENDENTE'] ?? 0;
    final devolvidosLocais = resumoStatus['DEVOLVIDO'] ?? 0;

    return pendentesLocais + devolvidosLocais;
  }

  Future<void> abrirCentralPendencias() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CentralPendenciasPage()));

    if (!mounted) {
      return;
    }

    await carregarDiarios(tentarEnviarPendentes: true);
  }

  void limparBusca() {
    buscaController.clear();

    setState(() {
      termoBusca = '';
    });
  }

  String normalizarStatus(dynamic valor) {
    final status = valor?.toString().trim().toUpperCase() ?? '';

    if (status.contains('ATUALIZ')) return 'ATUALIZADO';
    if (status.contains('APROV')) return 'APROVADO';
    if (status.contains('DEVOL')) return 'DEVOLVIDO';
    if (status.contains('PEND')) return 'PENDENTE';

    return status;
  }

  String labelFiltroStatus(String status) {
    switch (status) {
      case 'TODOS':
        return 'Todos';
      case 'PENDENTE':
        return 'Pendentes';
      case 'APROVADO':
        return 'Aprovados';
      case 'DEVOLVIDO':
        return 'Devolvidos';
      default:
        return status;
    }
  }

  IconData iconeFiltroStatus(String status) {
    switch (status) {
      case 'TODOS':
        return Icons.list_alt;
      case 'ATUALIZADO':
        return Icons.update;
      case 'PENDENTE':
        return Icons.hourglass_empty;
      case 'APROVADO':
        return Icons.check_circle_outline;
      case 'DEVOLVIDO':
        return Icons.assignment_return_outlined;
      default:
        return Icons.filter_list;
    }
  }

  String labelFiltroPeriodo(String periodo) {
    switch (periodo) {
      case 'TODOS':
        return 'Todos';
      case '7_DIAS':
        return '7 dias';
      case '30_DIAS':
        return '30 dias';
      case '90_DIAS':
        return '90 dias';
      default:
        return periodo;
    }
  }

  String labelOrdenacao(String valor) {
    switch (valor) {
      case 'RECENTES':
        return 'Mais recentes';
      case 'ANTIGOS':
        return 'Mais antigos';
      default:
        return valor;
    }
  }

  void selecionarFiltroPeriodo(String periodo) {
    setState(() {
      filtroPeriodo = periodo;
    });
  }

  void selecionarOrdenacao(String novaOrdenacao) {
    setState(() {
      ordenacao = novaOrdenacao;
    });
  }

  Color corStatusCard(String status) {
    switch (status) {
      case 'PENDENTE':
        return const Color(0xFFF59E0B);
      case 'APROVADO':
        return const Color(0xFF10B981);
      case 'DEVOLVIDO':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF1D4ED8);
    }
  }

  Widget resumoStatusCard({
    required String status,
    required String titulo,
    required int valor,
    required IconData icon,
  }) {
    final color = corStatusCard(status);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => selecionarFiltroStatus(status),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: filtroStatus == status
                ? LinearGradient(
                    colors: [color, color.withOpacity(0.82)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: filtroStatus == status ? null : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: filtroStatus == status ? color : const Color(0xFFE2E8F0),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: filtroStatus == status ? Colors.white : color,
                size: 22,
              ),
              const SizedBox(height: 7),
              Text(
                valor.toString(),
                style: TextStyle(
                  color: filtroStatus == status ? Colors.white : AppUI.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: filtroStatus == status
                      ? Colors.white.withOpacity(0.86)
                      : AppUI.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void selecionarFiltroStatus(String status) {
    setState(() {
      filtroStatus = status;
    });
  }

  Widget filtroChipModerno({
    required String label,
    required IconData icon,
    required bool selecionado,
    required VoidCallback onTap,
    Color color = AppUI.blue,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selecionado ? color : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selecionado ? color : const Color(0xFFCBD5E1),
              width: selecionado ? 1.4 : 1,
            ),
            boxShadow: selecionado
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x080F172A),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: selecionado ? Colors.white : color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selecionado ? Colors.white : AppUI.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> alterarLimiteSincronizacao(int novoLimite) async {
    setState(() {
      limiteSincronizacao = novoLimite;
    });

    await carregarDiarios();
  }

  String texto(dynamic valor, {String padrao = '-'}) {
    if (valor == null) return padrao;
    final str = valor.toString().trim();
    return str.isEmpty ? padrao : str;
  }

  String formatarUltimaSincronizacao() {
    if (ultimaSincronizacao == null || ultimaSincronizacao!.trim().isEmpty) {
      return 'Última sincronização: não informada';
    }

    try {
      final data = DateTime.parse(ultimaSincronizacao!);
      final dia = data.day.toString().padLeft(2, '0');
      final mes = data.month.toString().padLeft(2, '0');
      final ano = data.year.toString();
      final hora = data.hour.toString().padLeft(2, '0');
      final minuto = data.minute.toString().padLeft(2, '0');

      return 'Última sincronização: $dia/$mes/$ano às $hora:$minuto';
    } catch (_) {
      return 'Última sincronização: $ultimaSincronizacao';
    }
  }

  String? primeiroServico(Map<String, dynamic> diario) {
    final servicos = diario['servicos_executados_lista'];

    if (servicos is List && servicos.isNotEmpty) {
      final primeiro = servicos.first;

      if (primeiro is Map) {
        return primeiro['tipo_servico']?.toString() ??
            primeiro['tipo']?.toString();
      }
    }

    return diario['tipo_servico']?.toString();
  }

  String caminhoFotoDeItem(dynamic item) {
    if (item is Map) {
      final foto = Map<String, dynamic>.from(item);

      final possiveis = [
        foto['url'],
        foto['caminho'],
        foto['arquivo'],
        foto['path'],
        foto['filename'],
        foto['nome_arquivo'],
      ];

      for (final valor in possiveis) {
        final str = valor?.toString().trim() ?? '';

        if (str.isNotEmpty) {
          return str;
        }
      }
    }

    return item?.toString().trim() ?? '';
  }

  String urlFotoDoCaminho(String caminho) {
    if (caminho.isEmpty) {
      return '';
    }

    if (caminho.startsWith('http://') || caminho.startsWith('https://')) {
      return caminho;
    }

    if (caminho.startsWith('/')) {
      return '${ApiClient.baseUrl}$caminho';
    }

    return '${ApiClient.baseUrl}/$caminho';
  }

  List<String> urlsFotosSincronizadas() {
    final urls = <String>{};

    for (final diario in diariosBase) {
      final fotos = diario['fotos'];

      if (fotos is! List) {
        continue;
      }

      for (final foto in fotos) {
        final caminho = caminhoFotoDeItem(foto);
        final url = urlFotoDoCaminho(caminho);

        if (url.isNotEmpty) {
          urls.add(url);
        }
      }
    }

    return urls.toList();
  }

  Widget homeHeroCard(int totalFiltrado) {
    final online = !usandoDadosLocais;
    final destaque = obraFoiSelecionada
        ? (termoBusca.trim().isEmpty && filtroStatus == 'TODOS'
              ? '${diariosDaObraSelecionada.length} diário(s) nesta obra'
              : '$totalFiltrado resultado(s) encontrados')
        : 'Selecione uma obra para começar';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppUI.primaryGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppUI.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                child: const Icon(
                  Icons.engineering_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.nomeUsuario,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.nomeObra,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFDDEBFF),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            destaque,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.16)),
            ),
            child: Row(
              children: [
                Icon(
                  online ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        online
                            ? 'Online e sincronizado'
                            : 'Modo offline com dados locais',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        formatarUltimaSincronizacao(),
                        style: const TextStyle(
                          color: Color(0xFFDDEBFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget diarioCard(Map<String, dynamic> item) {
    final status = normalizarStatus(
      item['status_visual'] ?? item['status_aprovacao'],
    );
    final statusColor = corStatusCard(status);
    final servico = texto(primeiroServico(item));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppUI.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () async {
          final atualizou = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => DiarioDetalhePage(
                diario: item,
                nivelUsuario: widget.nivelUsuario,
              ),
            ),
          );

          if (atualizou == true && mounted) {
            await carregarDiarios(tentarEnviarPendentes: true);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(Icons.description_outlined, color: statusColor),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            texto(item['data_diario'], padrao: 'Sem data'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: AppUI.text,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: statusColor.withOpacity(0.30),
                            ),
                          ),
                          child: Text(
                            texto(item['status_aprovacao'], padrao: status),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      servico,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppUI.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Equipe: ${texto(item['equipe'])}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppUI.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nomeObraDoDiario(item),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppUI.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: AppUI.muted),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = diariosFiltrados;
    final obras = obrasDisponiveis;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Dash Sistem'),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton.filledTonal(
                onPressed: abrirCentralPendencias,
                icon: const Icon(Icons.rule_folder_outlined),
                tooltip: 'Pendências da obra',
              ),
              if (totalPendenciasHome() > 0)
                Positioned(
                  right: 1,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppUI.red,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 20),
                    child: Text(
                      totalPendenciasHome() > 99
                          ? '99+'
                          : totalPendenciasHome().toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: carregarDiarios,
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar',
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: abrirConfiguracoes,
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configurações',
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: carregarDiarios,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            homeHeroCard(filtrados.length),
            const SizedBox(height: 14),
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.business_outlined, color: Color(0xFF1D4ED8)),
                        SizedBox(width: 8),
                        Text(
                          'Obra em consulta',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value:
                          obraSelecionadaId != null &&
                              obras.any(
                                (obra) =>
                                    idObraOpcao(obra) == obraSelecionadaId,
                              )
                          ? obraSelecionadaId
                          : null,
                      decoration: InputDecoration(
                        labelText: 'Selecione uma obra para consultar',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                      hint: const Text('Nenhuma obra selecionada'),
                      items: obras
                          .map((obra) {
                            final id = idObraOpcao(obra);

                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(
                                labelObraSelecionada(obra),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          })
                          .where((item) => item.value != null)
                          .toList(),
                      onChanged: (valor) {
                        if (valor == null) {
                          return;
                        }

                        final obra = obras.firstWhere(
                          (item) => idObraOpcao(item) == valor,
                        );

                        selecionarObra(obra);
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      obraFoiSelecionada
                          ? 'Mostrando registros de: $obraSelecionada'
                          : 'Selecione uma obra para liberar a consulta dos diários.',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (obraFoiSelecionada) ...[
              const SizedBox(height: 14),
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.edit_document, color: Color(0xFF1D4ED8)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Lançamento de diário',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Preencha e salve o diário. Se estiver sem conexão, ele ficará pendente de envio.',
                        style: TextStyle(color: Color(0xFF64748B), height: 1.3),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: abrirNovoDiarioOffline,
                              icon: const Icon(Icons.add),
                              label: const Text('Novo diário'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: abrirPendentesOffline,
                              icon: Icon(
                                enviandoPendentesAuto
                                    ? Icons.sync
                                    : Icons.drafts_outlined,
                              ),
                              label: Text(
                                totalPendentesLocais > 0
                                    ? 'Pendentes ($totalPendentesLocais)'
                                    : 'Pendentes',
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (totalPendentesLocais > 0 ||
                          enviandoPendentesAuto) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: enviandoPendentesAuto
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: enviandoPendentesAuto
                                  ? const Color(0xFFBFDBFE)
                                  : const Color(0xFFFDE68A),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                enviandoPendentesAuto
                                    ? Icons.sync
                                    : Icons.schedule_outlined,
                                color: enviandoPendentesAuto
                                    ? const Color(0xFF1D4ED8)
                                    : const Color(0xFF92400E),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  enviandoPendentesAuto
                                      ? 'Enviando diários pendentes...'
                                      : '$totalPendentesLocais diário(s) aguardando envio.',
                                  style: TextStyle(
                                    color: enviandoPendentesAuto
                                        ? const Color(0xFF1D4ED8)
                                        : const Color(0xFF92400E),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  resumoStatusCard(
                    status: 'TODOS',
                    titulo: 'Total',
                    valor: resumoStatus['TODOS'] ?? 0,
                    icon: Icons.list_alt,
                  ),
                  const SizedBox(width: 8),
                  resumoStatusCard(
                    status: 'PENDENTE',
                    titulo: 'Pendentes',
                    valor: resumoStatus['PENDENTE'] ?? 0,
                    icon: Icons.hourglass_empty,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  resumoStatusCard(
                    status: 'APROVADO',
                    titulo: 'Aprovados',
                    valor: resumoStatus['APROVADO'] ?? 0,
                    icon: Icons.check_circle_outline,
                  ),
                  const SizedBox(width: 8),
                  resumoStatusCard(
                    status: 'DEVOLVIDO',
                    titulo: 'Devolvidos',
                    valor: resumoStatus['DEVOLVIDO'] ?? 0,
                    icon: Icons.assignment_return_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: buscaController,
                decoration: InputDecoration(
                  labelText: 'Buscar diário',
                  hintText: 'Equipe, serviço, status, data, ocorrência...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: termoBusca.isEmpty
                      ? null
                      : IconButton(
                          onPressed: limparBusca,
                          icon: const Icon(Icons.close),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (valor) {
                  setState(() {
                    termoBusca = valor;
                  });
                },
              ),
              const SizedBox(height: 14),
              const Text(
                'Filtrar por status',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppUI.text,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['TODOS', 'PENDENTE', 'APROVADO', 'DEVOLVIDO'].map((
                    status,
                  ) {
                    final selecionado = filtroStatus == status;
                    final color = corStatusCard(status);

                    return filtroChipModerno(
                      label: labelFiltroStatus(status),
                      icon: iconeFiltroStatus(status),
                      selecionado: selecionado,
                      color: color,
                      onTap: () => selecionarFiltroStatus(status),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Período',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppUI.text,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['TODOS', '7_DIAS', '30_DIAS', '90_DIAS'].map((
                    periodo,
                  ) {
                    final selecionado = filtroPeriodo == periodo;

                    return filtroChipModerno(
                      label: labelFiltroPeriodo(periodo),
                      icon: periodo == 'TODOS'
                          ? Icons.calendar_month_outlined
                          : Icons.date_range_outlined,
                      selecionado: selecionado,
                      color: const Color(0xFF2563EB),
                      onTap: () => selecionarFiltroPeriodo(periodo),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: ordenacao,
                      decoration: InputDecoration(
                        labelText: 'Ordenação',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'RECENTES',
                          child: Text('Mais recentes primeiro'),
                        ),
                        DropdownMenuItem(
                          value: 'ANTIGOS',
                          child: Text('Mais antigos primeiro'),
                        ),
                      ],
                      onChanged: (valor) {
                        if (valor == null) {
                          return;
                        }

                        selecionarOrdenacao(valor);
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            if (carregando)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (erro != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 42,
                      ),
                      const SizedBox(height: 12),
                      Text(erro!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: carregarDiarios,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              )
            else if (!obraFoiSelecionada)
              const SizedBox.shrink()
            else if (diariosDaObraSelecionada.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'Nenhum diário encontrado para a obra selecionada.',
                  ),
                ),
              )
            else if (filtrados.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.search_off,
                        size: 42,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        termoBusca.trim().isEmpty
                            ? 'Nenhum diário encontrado para o filtro "${labelFiltroStatus(filtroStatus)}".'
                            : 'Nenhum diário encontrado para "$termoBusca" no filtro "${labelFiltroStatus(filtroStatus)}".',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          limparBusca();
                          selecionarFiltroStatus('TODOS');
                          selecionarFiltroPeriodo('TODOS');
                          setState(() {
                            obraSelecionada = null;
                            obraSelecionadaId = null;
                          });
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Limpar filtros'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...filtrados.map(diarioCard),
          ],
        ),
      ),
    );
  }
}

class CentralPendenciasPage extends StatefulWidget {
  const CentralPendenciasPage({super.key});

  @override
  State<CentralPendenciasPage> createState() => _CentralPendenciasPageState();
}

class _CentralPendenciasPageState extends State<CentralPendenciasPage> {
  final authService = AuthService();

  bool carregando = true;
  String? erro;
  Map<String, dynamic> pendencias = {};
  Map<String, dynamic> totais = {};
  String filtro = 'diarios_pendentes';

  final categorias = const [
    {
      'chave': 'diarios_pendentes',
      'titulo': 'Aprovação',
      'subtitulo': 'Diários aguardando decisão',
      'icone': Icons.hourglass_empty,
      'cor': AppUI.amber,
    },
    {
      'chave': 'diarios_devolvidos',
      'titulo': 'Devolvidos',
      'subtitulo': 'Diários retornados para correção',
      'icone': Icons.assignment_return_outlined,
      'cor': AppUI.orange,
    },
    {
      'chave': 'edicoes_pendentes',
      'titulo': 'Edições',
      'subtitulo': 'Solicitações de edição pendentes',
      'icone': Icons.edit_note_outlined,
      'cor': AppUI.blue,
    },
    {
      'chave': 'exclusoes_pendentes',
      'titulo': 'Exclusões',
      'subtitulo': 'Solicitações de exclusão pendentes',
      'icone': Icons.delete_outline,
      'cor': AppUI.red,
    },
  ];

  @override
  void initState() {
    super.initState();
    carregarPendencias();
  }

  Future<void> carregarPendencias() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final resposta = await authService.listarPendenciasMobile(limite: 100);

      if (!mounted) {
        return;
      }

      if (resposta == null) {
        setState(() {
          carregando = false;
          erro = 'Sessão mobile não encontrada. Faça login novamente.';
        });
        return;
      }

      if (resposta['ok'] == true) {
        setState(() {
          pendencias = Map<String, dynamic>.from(resposta['pendencias'] ?? {});
          totais = Map<String, dynamic>.from(resposta['totais'] ?? {});
          carregando = false;
          erro = null;
        });
      } else {
        setState(() {
          carregando = false;
          erro = resposta['erro']?.toString() ?? 'Erro ao carregar pendências.';
        });
      }
    } on DioException catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        carregando = false;
        erro = AppErrorHandler.mensagemSincronizacao(e);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        carregando = false;
        erro = 'Não foi possível carregar a central de pendências.';
      });
    }
  }

  List<Map<String, dynamic>> listaCategoria(String chave) {
    final valor = pendencias[chave];

    if (valor is! List) {
      return [];
    }

    return valor
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  int totalCategoria(String chave) {
    final valor = totais[chave];

    if (valor is int) {
      return valor;
    }

    return int.tryParse(valor?.toString() ?? '') ??
        listaCategoria(chave).length;
  }

  String texto(dynamic valor, {String padrao = '-'}) {
    if (valor == null) return padrao;
    final str = valor.toString().trim();
    return str.isEmpty ? padrao : str;
  }

  String dataFormatada(dynamic valor) {
    final str = valor?.toString().trim() ?? '';

    if (str.isEmpty) {
      return 'Sem data';
    }

    try {
      final data = DateTime.parse(str);
      final dia = data.day.toString().padLeft(2, '0');
      final mes = data.month.toString().padLeft(2, '0');
      final ano = data.year.toString();
      return '$dia/$mes/$ano';
    } catch (_) {
      return str;
    }
  }

  String nomeObra(Map<String, dynamic> diario) {
    final obra = diario['obra'];

    if (obra is Map) {
      final nome = obra['nome']?.toString().trim() ?? '';

      if (nome.isNotEmpty) {
        return nome;
      }
    }

    return texto(
      diario['obra_nome'] ?? diario['nome_obra'],
      padrao: 'Obra não informada',
    );
  }

  String motivoPendencia(String chave, Map<String, dynamic> diario) {
    if (chave == 'diarios_devolvidos') {
      final candidatosMotivo = [
        diario['observacao_aprovacao'],
        diario['motivo_devolucao'],
        diario['observacao_devolucao'],
        diario['motivo'],
        diario['descricao'],
      ];

      var motivo = '';

      for (final item in candidatosMotivo) {
        final valor = item?.toString().trim() ?? '';

        if (valor.isEmpty) {
          continue;
        }

        if (valor.toLowerCase() == 'diário devolvido para correção.' ||
            valor.toLowerCase() == 'registro devolvido para correção.') {
          if (motivo.isEmpty) {
            motivo = valor;
          }
          continue;
        }

        motivo = valor;
        break;
      }

      if (motivo.isEmpty) {
        motivo = 'Diário devolvido para correção.';
      }

      final devolvidoPor = texto(
        diario['devolvido_por'] ??
            diario['aprovado_por'] ??
            diario['engenheiro_nome'] ??
            diario['responsavel_aprovacao'],
        padrao: '',
      );

      if (devolvidoPor.isNotEmpty) {
        return 'Devolvido por: $devolvidoPor\nMotivo: $motivo';
      }

      return 'Motivo: $motivo';
    }

    if (chave == 'edicoes_pendentes') {
      return texto(
        diario['edicao_solicitada_observacao'],
        padrao: 'Solicitação de edição aguardando revisão.',
      );
    }

    if (chave == 'exclusoes_pendentes') {
      return texto(
        diario['exclusao_solicitada_observacao'],
        padrao: 'Solicitação de exclusão aguardando revisão.',
      );
    }

    return 'Diário aguardando aprovação.';
  }

  Color corStatus(String chave) {
    switch (chave) {
      case 'diarios_devolvidos':
        return AppUI.orange;
      case 'edicoes_pendentes':
        return AppUI.blue;
      case 'exclusoes_pendentes':
        return AppUI.red;
      default:
        return AppUI.amber;
    }
  }

  IconData iconeStatus(String chave) {
    switch (chave) {
      case 'diarios_devolvidos':
        return Icons.assignment_return_outlined;
      case 'edicoes_pendentes':
        return Icons.edit_note_outlined;
      case 'exclusoes_pendentes':
        return Icons.delete_outline;
      default:
        return Icons.hourglass_empty;
    }
  }

  Widget chipInfo(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.26)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget cardCategoria(Map<String, Object> categoria) {
    final chave = categoria['chave'].toString();
    final selecionado = filtro == chave;
    final color = categoria['cor'] as Color;
    final icon = categoria['icone'] as IconData;
    final total = totalCategoria(chave);

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          setState(() {
            filtro = chave;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 150,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: selecionado
                ? LinearGradient(
                    colors: [color, color.withOpacity(0.78)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selecionado ? null : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: selecionado ? color : AppUI.border),
            boxShadow: selecionado
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x080F172A),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: selecionado ? Colors.white : color),
              const SizedBox(height: 12),
              Text(
                total.toString(),
                style: TextStyle(
                  color: selecionado ? Colors.white : AppUI.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                categoria['titulo'].toString(),
                style: TextStyle(
                  color: selecionado ? Colors.white : AppUI.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                categoria['subtitulo'].toString(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selecionado
                      ? Colors.white.withOpacity(0.86)
                      : AppUI.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> abrirDiario(Map<String, dynamic> diario) async {
    final atualizou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => DiarioDetalhePage(diario: diario)),
    );

    if (atualizou == true && mounted) {
      await carregarPendencias();
    }
  }

  int? idDiarioPendencia(Map<String, dynamic> diario) {
    final valor = diario['id'];
    if (valor is int) return valor;
    return int.tryParse(valor?.toString() ?? '');
  }

  String mensagemErroRevisaoEdicao(Object erro) {
    if (erro is DioException) {
      final data = erro.response?.data;

      if (data is Map && data['erro'] != null) {
        return data['erro'].toString();
      }

      return AppErrorHandler.mensagemModoOffline(erro);
    }

    return 'Não foi possível concluir a ação agora.';
  }

  Future<void> aprovarSolicitacaoEdicao(Map<String, dynamic> diario) async {
    final id = idDiarioPendencia(diario);

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID do diário não encontrado.')),
      );
      return;
    }

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Aprovar edição?'),
          content: const Text(
            'O apontador será autorizado a editar este diário. Deseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Aprovar'),
            ),
          ],
        );
      },
    );

    if (confirmou != true) {
      return;
    }

    try {
      await authService.aprovarEdicaoDiarioMobile(
        id,
        observacao: 'Solicitação de edição aprovada pelo app mobile.',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação de edição aprovada.')),
      );

      await carregarPendencias();
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagemErroRevisaoEdicao(erro))));
    }
  }

  Future<void> rejeitarSolicitacaoEdicao(Map<String, dynamic> diario) async {
    final id = idDiarioPendencia(diario);

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID do diário não encontrado.')),
      );
      return;
    }

    final motivoController = TextEditingController();

    final motivo = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rejeitar edição'),
          content: TextField(
            controller: motivoController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Motivo da rejeição',
              hintText: 'Ex.: Solicitação sem justificativa suficiente...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () {
                final texto = motivoController.text.trim();
                Navigator.of(context).pop(
                  texto.isEmpty ? 'Solicitação de edição rejeitada.' : texto,
                );
              },
              icon: const Icon(Icons.close),
              label: const Text('Rejeitar'),
              style: FilledButton.styleFrom(backgroundColor: AppUI.red),
            ),
          ],
        );
      },
    );

    if (motivo == null) {
      return;
    }

    try {
      await authService.rejeitarEdicaoDiarioMobile(id, motivo: motivo);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação de edição rejeitada.')),
      );

      await carregarPendencias();
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagemErroRevisaoEdicao(erro))));
    }
  }

  Widget botoesAcaoEdicao(Map<String, dynamic> diario) {
    if (filtro != 'edicoes_pendentes') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () => aprovarSolicitacaoEdicao(diario),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Aprovar'),
              style: FilledButton.styleFrom(
                backgroundColor: AppUI.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => rejeitarSolicitacaoEdicao(diario),
              icon: const Icon(Icons.close),
              label: const Text('Rejeitar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppUI.red,
                side: const BorderSide(color: AppUI.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> aprovarSolicitacaoExclusao(Map<String, dynamic> diario) async {
    final id = idDiarioPendencia(diario);

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID do diário não encontrado.')),
      );
      return;
    }

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Aprovar exclusão?'),
          content: const Text(
            'Essa ação vai excluir o diário do sistema. Deseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Excluir'),
              style: FilledButton.styleFrom(backgroundColor: AppUI.red),
            ),
          ],
        );
      },
    );

    if (confirmou != true) return;

    try {
      await authService.aprovarExclusaoDiarioMobile(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitação de exclusão aprovada. Diário excluído.'),
        ),
      );

      await carregarPendencias();
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagemErroRevisaoEdicao(erro))));
    }
  }

  Future<void> rejeitarSolicitacaoExclusao(Map<String, dynamic> diario) async {
    final id = idDiarioPendencia(diario);

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID do diário não encontrado.')),
      );
      return;
    }

    final motivoController = TextEditingController();

    final motivo = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rejeitar exclusão'),
          content: TextField(
            controller: motivoController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Motivo da rejeição',
              hintText: 'Ex.: Diário deve permanecer no histórico...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () {
                final texto = motivoController.text.trim();
                Navigator.of(context).pop(
                  texto.isEmpty ? 'Solicitação de exclusão rejeitada.' : texto,
                );
              },
              icon: const Icon(Icons.close),
              label: const Text('Rejeitar'),
              style: FilledButton.styleFrom(backgroundColor: AppUI.red),
            ),
          ],
        );
      },
    );

    if (motivo == null) return;

    try {
      await authService.rejeitarExclusaoDiarioMobile(id, motivo: motivo);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação de exclusão rejeitada.')),
      );

      await carregarPendencias();
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagemErroRevisaoEdicao(erro))));
    }
  }

  Widget botoesAcaoExclusao(Map<String, dynamic> diario) {
    if (filtro != 'exclusoes_pendentes') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () => aprovarSolicitacaoExclusao(diario),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Excluir'),
              style: FilledButton.styleFrom(
                backgroundColor: AppUI.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => rejeitarSolicitacaoExclusao(diario),
              icon: const Icon(Icons.close),
              label: const Text('Rejeitar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppUI.red,
                side: const BorderSide(color: AppUI.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Set<String>> idsDevolvidosComCorrecaoLocal() async {
    final ids = <String>{};

    try {
      final rascunhos = await authService.listarRascunhosDiarios();

      for (final rascunho in rascunhos) {
        try {
          final dados = Map<String, dynamic>.from(
            jsonDecode(rascunho.jsonCompleto) as Map,
          );

          final candidatos = [
            dados['diario_original_devolvido_id'],
            dados['diario_corrigido_de_id'],
            dados['diario_devolvido_id'],
            dados['id_devolvido'],
          ];

          for (final valor in candidatos) {
            final id = valor?.toString().trim() ?? '';

            if (id.isNotEmpty && id != 'null') {
              ids.add(id);
            }
          }
        } catch (_) {
          // Ignora rascunho antigo/inválido.
        }
      }
    } catch (_) {
      // Se não conseguir ler rascunhos locais, não bloqueia a Central.
    }

    return ids;
  }

  void ocultarDevolvidosComCorrecaoLocal(Set<String> ids) {
    if (ids.isEmpty) {
      return;
    }

    final listaDevolvidos = pendencias['diarios_devolvidos'];

    if (listaDevolvidos is! List) {
      return;
    }

    listaDevolvidos.removeWhere((item) {
      if (item is! Map) {
        return false;
      }

      final id = item['id']?.toString().trim() ?? '';

      return id.isNotEmpty && ids.contains(id);
    });
  }

  Future<void> corrigirDiarioDevolvido(Map<String, dynamic> diario) async {
    final diarioId = int.tryParse(diario['id']?.toString() ?? '');

    if (diarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível identificar o diário.')),
      );
      return;
    }

    final motivoDevolucao = motivoPendencia('diarios_devolvidos', diario);

    final confirmarCorrecao = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Diário devolvido'),
          content: Text(motivoDevolucao, style: const TextStyle(height: 1.35)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Voltar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.edit_note_outlined),
              label: const Text('Editar e reenviar'),
            ),
          ],
        );
      },
    );

    if (confirmarCorrecao != true) {
      return;
    }

    final dados = Map<String, dynamic>.from(diario);
    final obra = diario['obra'];

    dados['diario_devolvido_id'] = diarioId;
    dados['id_devolvido'] = diarioId;
    dados['modo_correcao_devolvido'] = true;
    dados['status_aprovacao'] = 'DEVOLVIDO';

    // Correção de devolvido: o envio vai atualizar o próprio diário existente.
    dados.remove('diario_id_servidor');

    // Não copia URLs de fotos já enviadas para o rascunho local.
    // As fotos antigas continuam vinculadas ao diário no sistema.
    dados.remove('fotos');
    dados.remove('fotos_offline');

    if (obra is Map) {
      dados['obra_id'] ??= obra['id'];
      dados['obra_nome'] ??= obra['nome'];
      dados['nome_obra'] ??= obra['nome'];
    }

    dados['observacao_devolucao'] = motivoPendencia(
      'diarios_devolvidos',
      diario,
    );

    try {
      final rascunhoId = await authService.salvarRascunhoDiario(dados);
      final rascunhos = await authService.listarRascunhosDiarios();

      RascunhosDiario? rascunho;

      for (final item in rascunhos) {
        if (item.id == rascunhoId) {
          rascunho = item;
          break;
        }
      }

      if (!mounted) {
        return;
      }

      if (rascunho == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rascunho criado, mas não foi possível abri-lo.'),
          ),
        );
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => NovoDiarioOfflinePage(
            obraNome: nomeObra(diario),
            rascunhoExistente: rascunho,
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        final listaDevolvidos = pendencias['diarios_devolvidos'];

        if (listaDevolvidos is List) {
          listaDevolvidos.removeWhere((item) {
            if (item is! Map) {
              return false;
            }

            return item['id']?.toString() == diarioId.toString();
          });
        }
      });

      await authService.sync(limite: 300);
      await carregarPendencias();

      final idsCorrigidosLocalmente = await idsDevolvidosComCorrecaoLocal();

      if (mounted) {
        setState(() {
          ocultarDevolvidosComCorrecaoLocal(idsCorrigidosLocalmente);
        });
      }
    } catch (erro) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Widget botaoCorrigirDiarioDevolvido(Map<String, dynamic> diario) {
    if (filtro != 'diarios_devolvidos') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => corrigirDiarioDevolvido(diario),
          icon: const Icon(Icons.edit_note_outlined),
          label: const Text('Corrigir e reenviar'),
          style: FilledButton.styleFrom(
            backgroundColor: AppUI.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }

  Widget cardPendencia(Map<String, dynamic> diario) {
    final color = corStatus(filtro);

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.22)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => abrirDiario(diario),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(iconeStatus(filtro), color: color),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diário #${texto(diario['id'])} • ${dataFormatada(diario['data_diario'] ?? diario['data_registro'])}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppUI.text,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      nomeObra(diario),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppUI.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      motivoPendencia(filtro, diario),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppUI.text,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        if (filtro == 'exclusoes_pendentes')
                          chipInfo('EXCLUSÃO SOLICITADA', AppUI.red)
                        else
                          chipInfo(
                            diario['status_aprovacao']?.toString() ??
                                'PENDENTE',
                            color,
                          ),
                        if (texto(diario['equipe'], padrao: '').isNotEmpty)
                          chipInfo(
                            'Equipe: ${texto(diario['equipe'])}',
                            AppUI.blue,
                          ),
                      ],
                    ),
                    botoesAcaoEdicao(diario),
                    botoesAcaoExclusao(diario),
                    botaoCorrigirDiarioDevolvido(diario),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: AppUI.muted),
            ],
          ),
        ),
      ),
    );
  }

  Widget emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppUI.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.task_alt_outlined, color: AppUI.green, size: 46),
          SizedBox(height: 12),
          Text(
            'Nada pendente aqui',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppUI.text,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Quando houver algo para revisar, aparecerá nesta central.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppUI.muted, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = listaCategoria(filtro);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendências da obra'),
        actions: [
          IconButton.filledTonal(
            onPressed: carregarPendencias,
            icon: const Icon(Icons.sync),
            tooltip: 'Atualizar',
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: carregarPendencias,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppUI.primaryGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: AppUI.softShadow,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.rule_folder_outlined,
                    color: Colors.white,
                    size: 42,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Central de pendências',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Acompanhe diários aguardando aprovação, devoluções e solicitações de edição/exclusão.',
                    style: TextStyle(
                      color: Color(0xFFDDEBFF),
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (carregando)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (erro != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppUI.orange,
                        size: 42,
                      ),
                      const SizedBox(height: 12),
                      Text(erro!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: carregarPendencias,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: categorias.map(cardCategoria).toList()),
              ),
              const SizedBox(height: 16),
              if (lista.isEmpty) emptyState() else ...lista.map(cardPendencia),
            ],
          ],
        ),
      ),
    );
  }
}

class DiarioDetalhePage extends StatelessWidget {
  final Map<String, dynamic> diario;
  final String nivelUsuario;

  const DiarioDetalhePage({
    super.key,
    required this.diario,
    this.nivelUsuario = '',
  });

  static const Color azul = Color(0xFF1D4ED8);
  static const Color azulEscuro = Color(0xFF0F172A);
  static const Color fundo = Color(0xFFF4F7FB);
  static const Color textoFraco = Color(0xFF64748B);
  static const Color borda = Color(0xFFE2E8F0);

  String texto(dynamic valor, {String padrao = '-'}) {
    if (valor == null) return padrao;
    final str = valor.toString().trim();
    return str.isEmpty ? padrao : str;
  }

  String primeiroServico() {
    final servicos = lista('servicos_executados_lista').isNotEmpty
        ? lista('servicos_executados_lista')
        : lista('servicos_executados');

    if (servicos.isNotEmpty) {
      final primeiro = servicos.first;

      if (primeiro is Map) {
        return texto(
          primeiro['tipo_servico'] ?? primeiro['tipo'],
          padrao: 'Serviço não informado',
        );
      }
    }

    return texto(diario['tipo_servico'], padrao: 'Serviço não informado');
  }

  List<dynamic> lista(String chave) {
    final valor = diario[chave];

    if (valor is List) {
      return valor;
    }

    return [];
  }

  List<dynamic> listaPrimeiraDisponivel(List<String> chaves) {
    for (final chave in chaves) {
      final valor = lista(chave);

      if (valor.isNotEmpty) {
        return valor;
      }
    }

    return [];
  }

  Map<String, dynamic> mapaPrimeiroDisponivel(List<String> chaves) {
    for (final chave in chaves) {
      final valor = diario[chave];

      if (valor is Map) {
        return Map<String, dynamic>.from(valor);
      }
    }

    return {};
  }

  String normalizarStatus(dynamic valor) {
    final status = valor?.toString().trim().toUpperCase() ?? '';

    if (status.contains('ATUALIZ')) return 'ATUALIZADO';
    if (status.contains('APROV')) return 'APROVADO';
    if (status.contains('DEVOL')) return 'DEVOLVIDO';
    if (status.contains('PEND')) return 'PENDENTE';

    return status.isEmpty ? 'NÃO INFORMADO' : status;
  }

  Color corStatus(String status) {
    switch (status) {
      case 'APROVADO':
        return const Color(0xFF10B981);
      case 'DEVOLVIDO':
        return const Color(0xFFF97316);
      case 'PENDENTE':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData iconeStatus(String status) {
    switch (status) {
      case 'APROVADO':
        return Icons.check_circle_outline;
      case 'DEVOLVIDO':
        return Icons.assignment_return_outlined;
      case 'ATUALIZADO':
        return Icons.update;
      case 'PENDENTE':
        return Icons.hourglass_empty;
      default:
        return Icons.info_outline;
    }
  }

  String dataFormatada() {
    final valor = texto(diario['data_diario'], padrao: '');

    if (valor.isEmpty) {
      return texto(diario['data_registro'], padrao: 'Sem data');
    }

    try {
      final data = DateTime.parse(valor);
      final dia = data.day.toString().padLeft(2, '0');
      final mes = data.month.toString().padLeft(2, '0');
      final ano = data.year.toString();
      return '$dia/$mes/$ano';
    } catch (_) {
      return valor;
    }
  }

  Widget statusPill(String status) {
    final color = corStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconeStatus(status), size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget chipVidro({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget numeroCard({
    required IconData icon,
    required String titulo,
    required String valor,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borda),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 23),
            ),
            const SizedBox(height: 9),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: azulEscuro,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: textoFraco,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget secaoPremium({
    required String titulo,
    required IconData icon,
    required List<Widget> children,
    String? subtitulo,
    Color color = azul,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borda),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: azulEscuro,
                      ),
                    ),
                    if (subtitulo != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitulo,
                        style: const TextStyle(
                          color: textoFraco,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget linhaInfo(String label, dynamic valor, {IconData? icon}) {
    final conteudo = texto(valor);

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borda),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: azul),
            const SizedBox(width: 9),
          ],
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: textoFraco,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              conteudo,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: azulEscuro,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget itemCard({
    required IconData icon,
    required String titulo,
    required List<String> linhas,
    Color color = azul,
  }) {
    final linhasValidas = linhas.where((linha) {
      final textoLinha = linha.trim();

      if (textoLinha.isEmpty) return false;
      if (textoLinha.endsWith(':')) return false;
      if (textoLinha.endsWith(': -')) return false;

      final partes = textoLinha.split(':');

      if (partes.length >= 2) {
        final valor = partes.sublist(1).join(':').trim().toLowerCase();

        if (valor.isEmpty) return false;
        if (valor == '-') return false;
        if (valor == 'null') return false;
        if (valor == 'não informado') return false;

        // Remove casos como:
        // Largura: - m
        // Área escavada: - m²
        // Pedra nº3: - m³
        // Temperatura CBUQ: - °C
        if (valor.startsWith('- ')) return false;
        if (valor.startsWith('null ')) return false;

        // Remove unidade solta sem valor útil.
        if (valor == 'm' ||
            valor == 'm²' ||
            valor == 'm³' ||
            valor == '°c' ||
            valor == 'ton' ||
            valor == 'un') {
          return false;
        }
      }

      return true;
    }).toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borda),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: azulEscuro,
                  ),
                ),
                if (linhasValidas.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  ...linhasValidas.map(
                    (linha) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        linha,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 13,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyBox(String texto) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borda),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline, color: textoFraco, size: 30),
          const SizedBox(height: 8),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textoFraco,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget textoObservacao(
    String conteudo, {
    Color color = const Color(0xFF92400E),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.24)),
      ),
      child: Text(
        conteudo,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          height: 1.35,
        ),
      ),
    );
  }

  bool get usuarioEhApontador {
    return nivelUsuario.trim().toLowerCase() == 'apontador';
  }

  bool get usuarioPodeAprovarDevolver {
    final nivel = nivelUsuario.trim().toLowerCase();

    // Só bloqueia visualmente para apontador.
    // Engenheiro/admin/diretor continuam vendo aprovar/devolver.
    // Se o nível vier vazio por alguma navegação antiga, não bloqueia.
    return nivel != 'apontador';
  }

  int? idDiario() {
    final valor = diario['id'];
    if (valor is int) return valor;
    return int.tryParse(valor?.toString() ?? '');
  }

  bool podeAprovarOuDevolver(String status) {
    return status == 'PENDENTE' || status == 'DEVOLVIDO';
  }

  String mensagemErroAcao(Object erro) {
    if (erro is DioException) {
      final data = erro.response?.data;

      if (data is Map && data['erro'] != null) {
        return data['erro'].toString();
      }

      return AppErrorHandler.mensagemModoOffline(erro);
    }

    return 'Não foi possível concluir a ação agora.';
  }

  Future<void> aprovarDiario(BuildContext context) async {
    final id = idDiario();

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID do diário não encontrado.')),
      );
      return;
    }

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Aprovar diário?'),
          content: const Text(
            'Confirme para aprovar este diário. Ele ficará marcado como APROVADO no sistema web.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Aprovar'),
            ),
          ],
        );
      },
    );

    if (confirmou != true) {
      return;
    }

    try {
      await AuthService().aprovarDiarioMobile(
        id,
        observacao: 'Aprovado pelo app mobile.',
      );

      await AuthService().sync(limite: 300);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diário aprovado com sucesso.')),
      );

      Navigator.of(context).pop(true);
    } catch (erro) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagemErroAcao(erro))));
    }
  }

  Future<void> devolverDiario(BuildContext context) async {
    final id = idDiario();

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID do diário não encontrado.')),
      );
      return;
    }

    final motivoController = TextEditingController();

    final motivo = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Devolver diário'),
          content: TextField(
            controller: motivoController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Motivo da devolução',
              hintText: 'Ex.: Corrigir quilometragem, fotos ou mão de obra...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () {
                final texto = motivoController.text.trim();

                if (texto.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Informe o motivo da devolução para o apontador corrigir.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop(texto);
              },
              icon: const Icon(Icons.assignment_return_outlined),
              label: const Text('Devolver'),
              style: FilledButton.styleFrom(backgroundColor: Color(0xFFF97316)),
            ),
          ],
        );
      },
    );

    if (motivo == null) {
      return;
    }

    try {
      await AuthService().devolverDiarioMobile(id, motivo: motivo);

      await AuthService().sync(limite: 300);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diário devolvido para correção.')),
      );

      Navigator.of(context).pop(true);
    } catch (erro) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagemErroAcao(erro))));
    }
  }

  bool podeSolicitarAlteracao() {
    if (!usuarioEhApontador) {
      return false;
    }

    final statusEdicao = (diario['status_edicao_solicitada'] ?? '')
        .toString()
        .trim()
        .toUpperCase();

    final statusExclusao = (diario['status_exclusao_solicitada'] ?? '')
        .toString()
        .trim()
        .toUpperCase();

    return statusEdicao != 'PENDENTE' && statusExclusao != 'PENDENTE';
  }

  Future<String?> pedirMotivo(
    BuildContext context, {
    required String titulo,
    required String label,
    required String dica,
  }) {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: label,
              hintText: dica,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () {
                final texto = controller.text.trim();

                if (texto.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Informe o motivo da solicitação.'),
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop(texto);
              },
              icon: const Icon(Icons.send_outlined),
              label: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> solicitarEdicaoDiario(BuildContext context) async {
    final id = idDiario();

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID do diário não encontrado.')),
      );
      return;
    }

    final motivo = await pedirMotivo(
      context,
      titulo: 'Solicitar edição',
      label: 'Motivo da solicitação',
      dica: 'Ex.: Corrigir quilometragem, fotos ou mão de obra...',
    );

    if (motivo == null) return;

    try {
      await AuthService().solicitarEdicaoDiarioMobile(id, motivo: motivo);

      await AuthService().sync(limite: 300);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação de edição enviada.')),
      );

      Navigator.of(context).pop(true);
    } catch (erro) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagemErroAcao(erro))));
    }
  }

  Future<void> solicitarExclusaoDiario(BuildContext context) async {
    final id = idDiario();

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID do diário não encontrado.')),
      );
      return;
    }

    final motivo = await pedirMotivo(
      context,
      titulo: 'Solicitar exclusão',
      label: 'Motivo da solicitação',
      dica: 'Ex.: Diário lançado duplicado ou no registro errado...',
    );

    if (motivo == null) return;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar solicitação?'),
          content: const Text(
            'A solicitação será enviada para revisão do engenheiro. O diário não será excluído agora.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.send_outlined),
              label: const Text('Enviar'),
            ),
          ],
        );
      },
    );

    if (confirmou != true) return;

    try {
      await AuthService().solicitarExclusaoDiarioMobile(id, motivo: motivo);

      await AuthService().sync(limite: 300);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação de exclusão enviada.')),
      );

      Navigator.of(context).pop(true);
    } catch (erro) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagemErroAcao(erro))));
    }
  }

  Widget blocoSolicitacoesApontador(BuildContext context) {
    if (!podeSolicitarAlteracao()) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borda),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: azul.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.outgoing_mail, color: azul),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solicitações',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: azulEscuro,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Peça autorização para corrigir ou excluir este diário',
                      style: TextStyle(
                        color: textoFraco,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => solicitarEdicaoDiario(context),
                  icon: const Icon(Icons.edit_note_outlined),
                  label: const Text('Solicitar edição'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: azul,
                    side: const BorderSide(color: azul),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => solicitarExclusaoDiario(context),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Solicitar exclusão'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget blocoAcoesRevisao(BuildContext context, String status) {
    if (!usuarioPodeAprovarDevolver || !podeAprovarOuDevolver(status)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borda),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: azul.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.verified_outlined, color: azul),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ações do diário',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: azulEscuro,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Aprovação e devolução pelo app mobile',
                      style: TextStyle(
                        color: textoFraco,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => aprovarDiario(context),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Aprovar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => devolverDiario(context),
                  icon: const Icon(Icons.assignment_return_outlined),
                  label: const Text('Devolver'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF97316),
                    side: const BorderSide(color: Color(0xFFF97316)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final obra = diario['obra'] is Map ? diario['obra'] as Map : {};
    final maoObra = listaPrimeiraDisponivel([
      'mao_obra_direta_lista',
      'mao_obra_direta',
    ]);
    final maoObraIndireta = listaPrimeiraDisponivel([
      'mao_obra_indireta_lista',
      'mao_obra_indireta',
    ]);
    final equipamentos = listaPrimeiraDisponivel([
      'maquinas_equipamentos_lista',
      'maquinas_equipamentos',
    ]);
    final materiais = listaPrimeiraDisponivel([
      'materiais_recebidos_utilizados_lista',
      'materiais_recebidos_utilizados',
    ]);
    final servicos = listaPrimeiraDisponivel([
      'servicos_executados_lista',
      'servicos_executados',
    ]);
    final fotos = lista('fotos');

    final compareceuCampo = mapaPrimeiroDisponivel([
      'compareceu_campo_dict',
      'compareceu_campo',
    ]);
    final sinalizacao = mapaPrimeiroDisponivel([
      'material_sinalizacao_dict',
      'material_sinalizacao',
    ]);

    final status = normalizarStatus(
      diario['status_visual'] ?? diario['status_aprovacao'],
    );
    final statusColor = corStatus(status);
    final observacoes = texto(
      diario['comentarios_ocorrencias'] ??
          diario['ocorrencias'] ??
          diario['descricao'],
      padrao: 'Sem ocorrências informadas.',
    );

    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        title: Text('Diário #${texto(diario['id'])}'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GaleriaFotosPage(
                    fotos: fotos,
                    diarioId: texto(diario['id']),
                    dataDiario: texto(diario['data_diario']),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.photo_library_outlined),
            tooltip: 'Galeria',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [azulEscuro, azul, statusColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.20),
                        ),
                      ),
                      child: const Icon(
                        Icons.assignment_turned_in_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Registro diário de obra',
                            style: TextStyle(
                              color: Color(0xFFBFDBFE),
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dataFormatada(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  texto(
                    obra['nome'] ?? diario['obra_nome'] ?? diario['nome_obra'],
                    padrao: 'Obra não informada',
                  ),
                  style: const TextStyle(
                    color: Color(0xFFE0F2FE),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  primeiroServico(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    statusPill(status),
                    chipVidro(
                      icon: Icons.cloud_outlined,
                      label: texto(
                        diario['clima'] ?? diario['clima_manha'],
                        padrao: 'Clima não informado',
                      ),
                    ),
                    chipVidro(
                      icon: Icons.groups_outlined,
                      label: 'Equipe: ${texto(diario['equipe'])}',
                    ),
                    chipVidro(
                      icon: Icons.route_outlined,
                      label:
                          'KM ${texto(diario['km_inicial'])} → ${texto(diario['km_final'])}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              numeroCard(
                icon: Icons.construction,
                titulo: 'Serviços',
                valor: servicos.length.toString(),
                color: azul,
              ),
              const SizedBox(width: 10),
              numeroCard(
                icon: Icons.groups_outlined,
                titulo: 'Pessoal',
                valor: texto(
                  diario['total_pessoal'],
                  padrao: '${maoObra.length + maoObraIndireta.length}',
                ),
                color: const Color(0xFF0F766E),
              ),
              const SizedBox(width: 10),
              numeroCard(
                icon: Icons.photo_library_outlined,
                titulo: 'Fotos',
                valor: fotos.length.toString(),
                color: const Color(0xFF7C3AED),
              ),
            ],
          ),
          const SizedBox(height: 14),
          blocoAcoesRevisao(context, status),
          blocoSolicitacoesApontador(context),
          secaoPremium(
            titulo: 'Resumo operacional',
            subtitulo: 'Dados gerais do lançamento',
            icon: Icons.dashboard_outlined,
            children: [
              linhaInfo(
                'Contrato/obra',
                obra['nome'] ?? diario['obra_nome'],
                icon: Icons.business_outlined,
              ),
              linhaInfo(
                'Equipe',
                diario['equipe'],
                icon: Icons.groups_outlined,
              ),
              linhaInfo(
                'Condição operacional',
                diario['condicao_operacao'] ?? diario['condicao_via'],
                icon: Icons.fact_check_outlined,
              ),
              linhaInfo(
                'Hora entrada',
                diario['hora_entrada'],
                icon: Icons.login,
              ),
              linhaInfo('Hora saída', diario['hora_saida'], icon: Icons.logout),
              linhaInfo(
                'KM inicial',
                diario['km_inicial'],
                icon: Icons.start_outlined,
              ),
              linhaInfo(
                'KM final',
                diario['km_final'],
                icon: Icons.flag_outlined,
              ),
              linhaInfo(
                'Distância',
                diario['distancia_total_formatada'],
                icon: Icons.route_outlined,
              ),
            ],
          ),
          secaoPremium(
            titulo: 'Clima e segurança',
            subtitulo: 'Condições e ocorrências do dia',
            icon: Icons.health_and_safety_outlined,
            color: const Color(0xFF0891B2),
            children: [
              linhaInfo(
                'Clima manhã',
                diario['clima_manha'] ?? diario['clima'],
                icon: Icons.wb_sunny_outlined,
              ),
              linhaInfo(
                'Clima tarde',
                diario['clima_tarde'],
                icon: Icons.cloud_outlined,
              ),
              linhaInfo(
                'Acidente',
                diario['acidente'] ??
                    (diario['houve_acidente'] == true ? 'Houve' : 'Não houve'),
                icon: Icons.warning_amber_outlined,
              ),
              if (texto(diario['tipo_ocorrencia'], padrao: '').isNotEmpty)
                linhaInfo(
                  'Tipo/descrição',
                  diario['tipo_ocorrencia'],
                  icon: Icons.report_problem_outlined,
                ),
              textoObservacao(observacoes),
            ],
          ),
          secaoPremium(
            titulo: 'Serviços executados',
            subtitulo: '${servicos.length} serviço(s) informado(s)',
            icon: Icons.construction,
            color: azul,
            children: servicos.isEmpty
                ? [emptyBox('Nenhum serviço informado.')]
                : servicos.map((item) {
                    final servico = item is Map ? item : {};
                    return itemCard(
                      icon: Icons.build_circle_outlined,
                      titulo: texto(
                        servico['tipo_servico'] ?? servico['tipo'],
                        padrao: 'Serviço',
                      ),
                      linhas: [
                        'KM inicial: ${texto(servico['km_inicial'] ?? servico['km_localizacao'])}',
                        'KM final: ${texto(servico['km_final'] ?? servico['km_localizacao'])}',
                        'Lado: ${texto(servico['lado'])}',
                        'Nº de remendos: ${texto(servico['numero_remendos'])}',
                        'Largura: ${texto(servico['largura_m'])} m',
                        'Área escavada: ${texto(servico['area_total_escavada_m2'])} m²',
                        'Pedra nº3: ${texto(servico['volume_pedra_3_m3'])} m³',
                        'BGS: ${texto(servico['volume_bgs_m3'])} m³',
                        'Dreno/área: ${texto(servico['area_total_escavada_dreno_m2'])} m²',
                        'Dreno/pedra nº3: ${texto(servico['volume_pedra_3_dreno_m3'])} m³',
                        'Observação: ${texto(servico['observacao'] ?? servico['observacoes'] ?? servico['descricao_livre'])}',
                      ],
                    );
                  }).toList(),
          ),
          secaoPremium(
            titulo: 'Materiais',
            subtitulo: '${materiais.length} material(is) informado(s)',
            icon: Icons.inventory_2_outlined,
            color: const Color(0xFFEA580C),
            children: materiais.isEmpty
                ? [emptyBox('Nenhum material informado.')]
                : materiais.map((item) {
                    final mat = item is Map ? item : {};
                    return itemCard(
                      icon: Icons.inventory_2_outlined,
                      titulo: texto(mat['material'], padrao: 'Material'),
                      color: const Color(0xFFEA580C),
                      linhas: [
                        'Quantidade: ${formatarQuantidadeMaterialVisivel(mat['quantidade'])} ${texto(mat['unidade'], padrao: '')}',
                        'Temperatura CBUQ: ${texto(mat['temperatura_cbuq'])} °C',
                        'Placa: ${texto(mat['placa'])}',
                        'Ticket: ${texto(mat['ticket'])}',
                        'Hora chegada: ${texto(mat['hora_chegada'])}',
                        'Observação: ${texto(mat['observacao'])}',
                      ],
                    );
                  }).toList(),
          ),
          secaoPremium(
            titulo: 'Equipamentos',
            subtitulo: '${equipamentos.length} equipamento(s) informado(s)',
            icon: Icons.precision_manufacturing_outlined,
            color: const Color(0xFF7C3AED),
            children: equipamentos.isEmpty
                ? [emptyBox('Nenhum equipamento informado.')]
                : equipamentos.map((item) {
                    final eq = item is Map ? item : {};
                    return itemCard(
                      icon: Icons.precision_manufacturing_outlined,
                      titulo: texto(eq['equipamento'], padrao: 'Equipamento'),
                      color: const Color(0xFF7C3AED),
                      linhas: [
                        'Código/Placa: ${texto(eq['codigo_placa'])}',
                        'Horímetro/KM: ${texto(eq['horimetro_quilometragem'])}',
                        'Observação: ${texto(eq['observacao'])}',
                      ],
                    );
                  }).toList(),
          ),
          secaoPremium(
            titulo: 'Mão de obra direta',
            subtitulo: '${maoObra.length} função(ões) lançada(s)',
            icon: Icons.groups,
            color: const Color(0xFF0F766E),
            children: maoObra.isEmpty
                ? [emptyBox('Nenhuma mão de obra direta informada.')]
                : maoObra.map((item) {
                    final mao = item is Map ? item : {};
                    return itemCard(
                      icon: Icons.person_outline,
                      titulo: texto(mao['funcao'], padrao: 'Função'),
                      color: const Color(0xFF0F766E),
                      linhas: ['Quantidade: ${texto(mao['quantidade'])}'],
                    );
                  }).toList(),
          ),
          secaoPremium(
            titulo: 'Mão de obra indireta',
            subtitulo: '${maoObraIndireta.length} função(ões) lançada(s)',
            icon: Icons.supervisor_account_outlined,
            color: const Color(0xFF2563EB),
            children: maoObraIndireta.isEmpty
                ? [emptyBox('Nenhuma mão de obra indireta informada.')]
                : maoObraIndireta.map((item) {
                    final mao = item is Map ? item : {};
                    return itemCard(
                      icon: Icons.badge_outlined,
                      titulo: texto(mao['funcao'], padrao: 'Função'),
                      color: const Color(0xFF2563EB),
                      linhas: ['Quantidade: ${texto(mao['quantidade'])}'],
                    );
                  }).toList(),
          ),
          secaoPremium(
            titulo: 'Fiscalização em campo',
            subtitulo: 'Presenças informadas no lançamento',
            icon: Icons.verified_user_outlined,
            color: const Color(0xFF475569),
            children: compareceuCampo.isEmpty
                ? [emptyBox('Nenhuma informação de comparecimento em campo.')]
                : [
                    linhaInfo(
                      'Inspetor de campo',
                      compareceuCampo['inspetor_campo'],
                      icon: Icons.engineering_outlined,
                    ),
                    linhaInfo(
                      'Fiscal da supervisora',
                      compareceuCampo['fiscal_supervisora'],
                      icon: Icons.manage_accounts_outlined,
                    ),
                    linhaInfo(
                      'Fiscal do DNIT',
                      compareceuCampo['fiscal_dnit'],
                      icon: Icons.account_balance_outlined,
                    ),
                    linhaInfo(
                      'Engenheiro',
                      compareceuCampo['engenheiro'],
                      icon: Icons.person_pin_circle_outlined,
                    ),
                  ],
          ),
          secaoPremium(
            titulo: 'Sinalização',
            subtitulo: 'Materiais de segurança utilizados',
            icon: Icons.traffic_outlined,
            color: const Color(0xFFF97316),
            children: [
              linhaInfo(
                'Cone plástico',
                sinalizacao['cone_plastico'],
                icon: Icons.traffic,
              ),
              linhaInfo(
                'Placa pare-siga',
                sinalizacao['placa_pare_siga'],
                icon: Icons.signpost_outlined,
              ),
              linhaInfo(
                'Cavalete metálico',
                sinalizacao['cavalete_metalico'],
                icon: Icons.construction_outlined,
              ),
            ],
          ),
          secaoPremium(
            titulo: 'Fotos do diário',
            subtitulo: '${fotos.length} foto(s) vinculada(s)',
            icon: Icons.photo_library_outlined,
            color: const Color(0xFF7C3AED),
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GaleriaFotosPage(
                        fotos: fotos,
                        diarioId: texto(diario['id']),
                        dataDiario: texto(diario['data_diario']),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEEF2FF), Color(0xFFF5F3FF)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFC7D2FE)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.photo_library_outlined,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          fotos.isEmpty
                              ? 'Nenhuma foto vinculada a este diário.'
                              : 'Abrir galeria com ${fotos.length} foto(s).',
                          style: const TextStyle(
                            color: Color(0xFF3730A3),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xFF3730A3)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GaleriaFotosPage extends StatefulWidget {
  final List<dynamic> fotos;
  final String diarioId;
  final String dataDiario;

  const GaleriaFotosPage({
    super.key,
    required this.fotos,
    required this.diarioId,
    required this.dataDiario,
  });

  @override
  State<GaleriaFotosPage> createState() => _GaleriaFotosPageState();
}

class _GaleriaFotosPageState extends State<GaleriaFotosPage> {
  static const int fotosPorPagina = 24;

  final ScrollController scrollController = ScrollController();

  int paginaAtual = 0;
  bool baixandoFotos = false;
  int fotosBaixadas = 0;
  int totalFotosDownload = 0;
  String? mensagemDownload;

  List<Map<String, dynamic>> get fotosNormalizadas {
    return widget.fotos.map(normalizarFoto).toList();
  }

  int get totalPaginas {
    if (fotosNormalizadas.isEmpty) {
      return 1;
    }

    return (fotosNormalizadas.length / fotosPorPagina).ceil();
  }

  int get indiceInicialPagina {
    return paginaAtual * fotosPorPagina;
  }

  int get indiceFinalPagina {
    final fim = indiceInicialPagina + fotosPorPagina;
    return fim > fotosNormalizadas.length ? fotosNormalizadas.length : fim;
  }

  List<Map<String, dynamic>> get fotosDaPagina {
    if (fotosNormalizadas.isEmpty) {
      return [];
    }

    return fotosNormalizadas.sublist(indiceInicialPagina, indiceFinalPagina);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void voltarParaTopoDaGaleria() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) {
        return;
      }

      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Map<String, dynamic> normalizarFoto(dynamic item) {
    if (item is Map) {
      return Map<String, dynamic>.from(item);
    }

    return {'arquivo': item?.toString() ?? ''};
  }

  String caminhoFoto(Map<String, dynamic> foto) {
    final possiveis = [
      foto['url'],
      foto['caminho'],
      foto['arquivo'],
      foto['path'],
      foto['filename'],
      foto['nome_arquivo'],
    ];

    for (final item in possiveis) {
      final valor = item?.toString().trim() ?? '';
      if (valor.isNotEmpty) {
        return valor;
      }
    }

    return '';
  }

  String urlFoto(Map<String, dynamic> foto) {
    final caminho = caminhoFoto(foto);

    if (caminho.isEmpty) {
      return '';
    }

    if (caminho.startsWith('http://') || caminho.startsWith('https://')) {
      return caminho;
    }

    if (caminho.startsWith('/')) {
      return '${ApiClient.baseUrl}$caminho';
    }

    return '${ApiClient.baseUrl}/$caminho';
  }

  String tituloFoto(Map<String, dynamic> foto, int indexGlobal) {
    final caminho = caminhoFoto(foto);

    if (caminho.isNotEmpty) {
      return caminho.split('/').last;
    }

    return 'Foto ${indexGlobal + 1}';
  }

  String descricaoFoto(Map<String, dynamic> foto) {
    final possiveis = [
      foto['descricao'],
      foto['observacao'],
      foto['legenda'],
      foto['caminho'],
      foto['url'],
      foto['arquivo'],
    ];

    for (final item in possiveis) {
      final valor = item?.toString().trim() ?? '';
      if (valor.isNotEmpty) {
        return valor;
      }
    }

    return 'Sem informações adicionais.';
  }

  void irParaPaginaAnterior() {
    if (paginaAtual <= 0) {
      return;
    }

    setState(() {
      paginaAtual--;
    });

    voltarParaTopoDaGaleria();
  }

  void irParaProximaPagina() {
    if (paginaAtual >= totalPaginas - 1) {
      return;
    }

    setState(() {
      paginaAtual++;
    });

    voltarParaTopoDaGaleria();
  }

  void abrirFoto(int indexGlobal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FotoTelaCheiaPage(
          fotos: fotosNormalizadas,
          indiceInicial: indexGlobal,
        ),
      ),
    );
  }

  Future<void> baixarTodasFotosOffline() async {
    final fotos = fotosNormalizadas;

    if (fotos.isEmpty || baixandoFotos) {
      return;
    }

    setState(() {
      baixandoFotos = true;
      fotosBaixadas = 0;
      totalFotosDownload = fotos.length;
      mensagemDownload = null;
    });

    int baixadasComSucesso = 0;

    for (final foto in fotos) {
      final url = urlFoto(foto);

      if (url.isNotEmpty) {
        final arquivo = await FotoCacheService.obterOuBaixar(url);

        if (arquivo != null) {
          baixadasComSucesso++;
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        fotosBaixadas++;
      });
    }

    if (!mounted) {
      return;
    }

    setState(() {
      baixandoFotos = false;
      mensagemDownload =
          '$baixadasComSucesso de ${fotos.length} foto(s) salvas para uso offline.';
    });
  }

  Future<bool> fotoSalvaOffline(String url) async {
    if (url.trim().isEmpty) {
      return false;
    }

    final arquivo = await FotoCacheService.arquivoLocal(url);
    return await arquivo.exists() && await arquivo.length() > 0;
  }

  Widget badgeStatusOffline(String url) {
    return FutureBuilder<bool>(
      future: fotoSalvaOffline(url),
      builder: (context, snapshot) {
        final salva = snapshot.data == true;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: salva
                ? const Color(0xFF166534).withOpacity(0.92)
                : const Color(0xFF92400E).withOpacity(0.92),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                salva ? Icons.offline_pin : Icons.cloud_download_outlined,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 5),
              Text(
                salva ? 'Salva offline' : 'Não baixada',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget cardDownloadOffline(int totalFotos) {
    final progresso = totalFotosDownload == 0
        ? 0.0
        : fotosBaixadas / totalFotosDownload;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.offline_pin_outlined, color: Color(0xFF1D4ED8)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Fotos offline',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Baixe as fotos deste diário enquanto estiver online para consultar depois sem internet.',
              style: TextStyle(color: Color(0xFF64748B), height: 1.3),
            ),
            const SizedBox(height: 12),
            if (baixandoFotos) ...[
              LinearProgressIndicator(value: progresso),
              const SizedBox(height: 8),
              Text(
                'Baixando $fotosBaixadas de $totalFotosDownload foto(s)...',
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: totalFotos == 0 ? null : baixarTodasFotosOffline,
                  icon: const Icon(Icons.download_for_offline_outlined),
                  label: Text(
                    totalFotos == 0
                        ? 'Nenhuma foto para baixar'
                        : 'Baixar $totalFotos foto(s) para offline',
                  ),
                ),
              ),
              if (mensagemDownload != null) ...[
                const SizedBox(height: 8),
                Text(
                  mensagemDownload!,
                  style: const TextStyle(
                    color: Color(0xFF166534),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget imagemFoto(String url, int indexGlobal) {
    if (url.isEmpty) {
      return Container(
        height: 190,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: 44,
            color: Color(0xFF64748B),
          ),
        ),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => abrirFoto(indexGlobal),
      child: Stack(
        children: [
          FotoCacheImage(
            url: url,
            height: 190,
            width: double.infinity,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(18),
            cacheWidth: 720,
          ),
          Positioned(left: 10, top: 10, child: badgeStatusOffline(url)),
          Positioned(
            right: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.58),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fullscreen, color: Colors.white, size: 17),
                  SizedBox(width: 4),
                  Text(
                    'Ampliar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fotos = fotosNormalizadas;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Galeria de Fotos')),
      body: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF4338CA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.photo_library_outlined,
                  color: Colors.white,
                  size: 42,
                ),
                const SizedBox(height: 14),
                Text(
                  '${widget.dataDiario} • Diário #${widget.diarioId}',
                  style: const TextStyle(
                    color: Color(0xFFC7D2FE),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${fotos.length} foto(s) vinculada(s)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  fotos.isEmpty
                      ? 'Nenhuma foto foi vinculada a este diário.'
                      : 'Mostrando ${indiceInicialPagina + 1} a $indiceFinalPagina de ${fotos.length}. Toque em uma foto para ampliar.',
                  style: const TextStyle(
                    color: Color(0xFFE0E7FF),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          cardDownloadOffline(fotos.length),
          const SizedBox(height: 14),
          if (fotos.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: const [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: 46,
                      color: Color(0xFF64748B),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Nenhuma foto vinculada a este diário.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            )
          else
            ...fotosDaPagina.asMap().entries.map((entry) {
              final indexNaPagina = entry.key;
              final indexGlobal = indiceInicialPagina + indexNaPagina;
              final foto = entry.value;
              final url = urlFoto(foto);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      imagemFoto(url, indexGlobal),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFFEEF2FF),
                            child: Text(
                              '${indexGlobal + 1}',
                              style: const TextStyle(
                                color: Color(0xFF3730A3),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tituloFoto(foto, indexGlobal),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  descricaoFoto(foto),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                if (url.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    url,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  FutureBuilder<bool>(
                                    future: fotoSalvaOffline(url),
                                    builder: (context, snapshot) {
                                      final salva = snapshot.data == true;

                                      return Text(
                                        salva
                                            ? 'Disponível sem internet'
                                            : 'Ainda precisa baixar para offline',
                                        style: TextStyle(
                                          color: salva
                                              ? const Color(0xFF166534)
                                              : const Color(0xFF92400E),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          if (fotos.length > fotosPorPagina) ...[
            const SizedBox(height: 4),
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: paginaAtual == 0 ? null : irParaPaginaAnterior,
                      icon: const Icon(Icons.chevron_left),
                      tooltip: 'Página anterior',
                    ),
                    Expanded(
                      child: Text(
                        'Página ${paginaAtual + 1} de $totalPaginas • ${fotosPorPagina} fotos por página',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      onPressed: paginaAtual >= totalPaginas - 1
                          ? null
                          : irParaProximaPagina,
                      icon: const Icon(Icons.chevron_right),
                      tooltip: 'Próxima página',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FotoTelaCheiaPage extends StatefulWidget {
  final List<Map<String, dynamic>> fotos;
  final int indiceInicial;

  const FotoTelaCheiaPage({
    super.key,
    required this.fotos,
    required this.indiceInicial,
  });

  @override
  State<FotoTelaCheiaPage> createState() => _FotoTelaCheiaPageState();
}

class _FotoTelaCheiaPageState extends State<FotoTelaCheiaPage> {
  late final PageController pageController;
  late int indiceAtual;

  @override
  void initState() {
    super.initState();
    indiceAtual = widget.indiceInicial;
    pageController = PageController(initialPage: widget.indiceInicial);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  String caminhoFoto(Map<String, dynamic> foto) {
    final possiveis = [
      foto['url'],
      foto['caminho'],
      foto['arquivo'],
      foto['path'],
      foto['filename'],
      foto['nome_arquivo'],
    ];

    for (final item in possiveis) {
      final valor = item?.toString().trim() ?? '';
      if (valor.isNotEmpty) {
        return valor;
      }
    }

    return '';
  }

  String urlFoto(Map<String, dynamic> foto) {
    final caminho = caminhoFoto(foto);

    if (caminho.isEmpty) {
      return '';
    }

    if (caminho.startsWith('http://') || caminho.startsWith('https://')) {
      return caminho;
    }

    if (caminho.startsWith('/')) {
      return '${ApiClient.baseUrl}$caminho';
    }

    return '${ApiClient.baseUrl}/$caminho';
  }

  String tituloFoto(Map<String, dynamic> foto, int index) {
    final caminho = caminhoFoto(foto);

    if (caminho.isNotEmpty) {
      return caminho.split('/').last;
    }

    return 'Foto ${index + 1}';
  }

  void irParaFotoAnterior() {
    if (indiceAtual <= 0) {
      return;
    }

    pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void irParaProximaFoto() {
    if (indiceAtual >= widget.fotos.length - 1) {
      return;
    }

    pageController.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Widget imagemAmpliada(String url) {
    if (url.isEmpty) {
      return const Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.white, size: 64),
      );
    }

    return Center(
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 5,
        child: FotoCacheImage(
          url: url,
          fit: BoxFit.contain,
          backgroundColor: Colors.black,
          loadingColor: Colors.white,
          errorDarkMode: true,
          cacheWidth: 1600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fotoAtual = widget.fotos[indiceAtual];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Foto ${indiceAtual + 1} de ${widget.fotos.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: widget.fotos.length,
            onPageChanged: (index) {
              setState(() {
                indiceAtual = index;
              });
            },
            itemBuilder: (context, index) {
              final foto = widget.fotos[index];
              return Padding(
                padding: const EdgeInsets.all(8),
                child: imagemAmpliada(urlFoto(foto)),
              );
            },
          ),
          Positioned(
            left: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton.filled(
                onPressed: indiceAtual <= 0 ? null : irParaFotoAnterior,
                icon: const Icon(Icons.chevron_left),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.18),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white.withOpacity(0.06),
                  disabledForegroundColor: Colors.white30,
                ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton.filled(
                onPressed: indiceAtual >= widget.fotos.length - 1
                    ? null
                    : irParaProximaFoto,
                icon: const Icon(Icons.chevron_right),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.18),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white.withOpacity(0.06),
                  disabledForegroundColor: Colors.white30,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.62),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Text(
                tituloFoto(fotoAtual, indiceAtual),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NovoDiarioOfflinePage extends StatefulWidget {
  final int? obraId;
  final String obraNome;
  final RascunhosDiario? rascunhoExistente;

  const NovoDiarioOfflinePage({
    super.key,
    required this.obraNome,
    this.obraId,
    this.rascunhoExistente,
  });

  @override
  State<NovoDiarioOfflinePage> createState() => _NovoDiarioOfflinePageState();
}

class _NovoDiarioOfflinePageState extends State<NovoDiarioOfflinePage> {
  final authService = AuthService();
  final formKey = GlobalKey<FormState>();
  final imagePicker = ImagePicker();

  final dataController = TextEditingController();
  final equipeController = TextEditingController();
  final condicaoOperacaoController = TextEditingController();
  final horaEntradaController = TextEditingController();
  final horaSaidaController = TextEditingController();
  final ocorrenciasController = TextEditingController();
  final observacoesController = TextEditingController();
  final acidenteDescricaoController = TextEditingController();
  final conePlasticoController = TextEditingController(text: '0');
  final placaPareSigaController = TextEditingController(text: '0');
  final cavaleteMetalicoController = TextEditingController(text: '0');

  String climaSelecionado = 'Bom';
  String climaManhaSelecionado = 'Bom';
  String climaTardeSelecionado = 'Bom';
  bool houveAcidente = false;
  bool salvando = false;
  bool carregandoObrasFormulario = false;

  int? obraIdSelecionada;
  String obraNomeSelecionada = '';
  List<LocalObra> obrasLocaisFormulario = [];

  final List<Map<String, dynamic>> servicos = [];
  final List<Map<String, dynamic>> materiais = [];
  final List<Map<String, dynamic>> equipamentos = [];
  final List<Map<String, dynamic>> maoObra = [];
  final List<Map<String, dynamic>> maoObraIndireta = [];
  final List<Map<String, dynamic>> fotosOffline = [];

  final Map<String, String> compareceuCampo = {
    'inspetor_campo': 'Não',
    'fiscal_supervisora': 'Não',
    'fiscal_dnit': 'Não',
    'engenheiro': 'Não',
  };

  final List<String> opcoesClima = const [
    'Bom',
    'Nublado',
    'Chuvoso',
    'Parcialmente chuvoso',
    'Impraticável',
  ];

  final List<String> opcoesCondicaoOperacao = const [
    'Praticável',
    'Impraticável',
    'Parcialmente praticável',
    'Operação normal',
    'Paralisado',
  ];

  final List<String> opcoesServico = const [
    'CAPA ASFÁLTICA / REVESTIMENTO',
    'DRENAGEM',
    'PALIATIVO / ENROCAMENTO DE PEDRAS',
    'REPARO PROFUNDO / TROCA DE SOLO',
    'RECICLAGEM',
    'CORREÇÃO DE DEFEITOS COM CBUQ',
    'OUTROS',
  ];

  final List<String> opcoesLado = const ['Direito', 'Esquerdo', 'Ambos'];

  final List<String> opcoesMateriais = const [
    'BRITA CORRIDA',
    'BRITA 3/8 (PEDRISCO)',
    'BRITA 5/8',
    'BRITA 3/4',
    'PEDRA N°2',
    'PEDRA N°3',
    'PEDRA RACHÃO',
    'BGS',
    'MATACO',
    'MACADAME',
    'PÓ DE BRITA',
    'AREIA',
    'CBUQ',
    'OUTRO',
  ];

  final List<String> opcoesUnidade = const ['m²', 'm³', 'ton', 'un', 'viagem'];

  final List<String> opcoesEquipamentos = const [
    'CAMINHÃO BASCULANTE TRUCK',
    'CAMINHÃO BASCULANTE LS',
    'CAMINHÃO BASCULANTE 9 EIXOS',
    'CAMINHÃO DE APOIO',
    'ESCAVADEIRA',
    'MINI-ROLO COMPACTADOR',
    'RETROESCAVADEIRA',
    'ROLO LISO DE PNEU (PNEUMÁTICO)',
    'ROLO CHAPA',
    'ROLO PÉ DE CARNEIRO',
    'VIBRO-ACABADORA',
    'RECICLADORA',
    'MOTONIVELADORA',
    'PÁ CARREGADEIRA',
    'MINI-CARREGADEIRA (BOBCAT)',
    'BOMBA COSTAL',
    'SOPRADOR',
    'OUTROS',
  ];

  final List<String> opcoesMaoObra = const [
    'APONTADOR',
    'BANDEIRINHA',
    'ENCARREGADO',
    'MOTORISTA DE APOIO',
    'MOTORISTA DE CAÇAMBA TRUCK',
    'OPERADOR DE RETROESCAVADEIRA',
    'OPERADOR DE ESCAVADEIRA',
    'OPERADOR DE PÁ CARREGADEIRA',
    'OPERADOR DE ROLO',
    'RASTELEIRO',
    'ROÇADOR',
    'SERVENTE',
    'OUTROS',
  ];

  final List<String> opcoesMaoObraIndireta = const [
    'TÉCNICO DE SEGURANÇA',
    'TOPÓGRAFO',
    'AUXILIAR DE TOPOGRAFIA',
    'LABORATORISTA',
    'AUXILIAR DE LABORATÓRIO',
    'OUTROS',
  ];

  List<Map<String, dynamic>> listaMap(dynamic valor) {
    if (valor is List) {
      return valor
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return [];
  }

  String textoJson(
    Map<String, dynamic> dados,
    String chave, {
    String padrao = '',
  }) {
    final valor = dados[chave];

    if (valor == null) {
      return padrao;
    }

    final texto = valor.toString().trim();
    return texto.isEmpty ? padrao : texto;
  }

  void carregarRascunhoExistente() {
    final rascunho = widget.rascunhoExistente;

    if (rascunho == null) {
      return;
    }

    try {
      final dados = jsonDecode(rascunho.jsonCompleto);

      if (dados is! Map) {
        return;
      }

      final map = Map<String, dynamic>.from(dados);

      final obraIdJson = int.tryParse(map['obra_id']?.toString() ?? '');
      final obraNomeJson = textoJson(map, 'obra_nome');

      if (obraIdJson != null) {
        obraIdSelecionada = obraIdJson;
      } else if (rascunho.obraId != null) {
        obraIdSelecionada = rascunho.obraId;
      }

      if (obraNomeJson.isNotEmpty) {
        obraNomeSelecionada = obraNomeJson;
      } else if ((rascunho.obraNome ?? '').trim().isNotEmpty) {
        obraNomeSelecionada = rascunho.obraNome!.trim();
      }

      final dataRascunho = textoJson(
        map,
        'data_diario',
        padrao: rascunho.dataDiario ?? dataController.text,
      );
      dataController.text = dataDiarioParaTela(dataRascunho);
      equipeController.text = textoJson(
        map,
        'equipe',
        padrao: rascunho.equipe ?? '',
      );
      condicaoOperacaoController.text = textoJson(
        map,
        'condicao_operacao',
        padrao: rascunho.clima ?? 'Praticável',
      );
      horaEntradaController.text = textoJson(map, 'hora_entrada');
      horaSaidaController.text = textoJson(map, 'hora_saida');
      ocorrenciasController.text = textoJson(
        map,
        'ocorrencias',
        padrao: rascunho.ocorrencias ?? '',
      );
      observacoesController.text = textoJson(
        map,
        'comentarios_ocorrencias',
        padrao: textoJson(
          map,
          'observacoes',
          padrao: rascunho.observacoes ?? '',
        ),
      );

      climaSelecionado = textoJson(map, 'clima', padrao: 'Bom');
      climaManhaSelecionado = textoJson(
        map,
        'clima_manha',
        padrao: climaSelecionado,
      );
      climaTardeSelecionado = textoJson(map, 'clima_tarde', padrao: 'Bom');

      final acidenteTexto = textoJson(map, 'acidente').toLowerCase();
      houveAcidente =
          acidenteTexto == 'houve' ||
          acidenteTexto == 'sim' ||
          map['houve_acidente'] == true;

      acidenteDescricaoController.text = textoJson(
        map,
        'tipo_ocorrencia',
        padrao: textoJson(map, 'descricao_acidente'),
      );

      servicos
        ..clear()
        ..addAll(
          listaMap(
            map['servicos_executados'] ?? map['servicos_executados_lista'],
          ),
        );

      materiais
        ..clear()
        ..addAll(
          listaMap(
            map['materiais_recebidos_utilizados'] ??
                map['materiais_recebidos_utilizados_lista'],
          ),
        );

      equipamentos
        ..clear()
        ..addAll(
          listaMap(
            map['maquinas_equipamentos'] ?? map['maquinas_equipamentos_lista'],
          ),
        );

      maoObra
        ..clear()
        ..addAll(
          listaMap(map['mao_obra_direta'] ?? map['mao_obra_direta_lista']),
        );

      maoObraIndireta
        ..clear()
        ..addAll(
          listaMap(map['mao_obra_indireta'] ?? map['mao_obra_indireta_lista']),
        );

      final compareceu =
          map['compareceu_campo'] ?? map['compareceu_campo_dict'];

      if (compareceu is Map) {
        for (final chave in compareceuCampo.keys) {
          final valor = compareceu[chave]?.toString();

          if (valor == 'Sim' || valor == 'Não') {
            compareceuCampo[chave] = valor!;
          }
        }
      }

      final sinalizacao =
          map['material_sinalizacao'] ?? map['material_sinalizacao_dict'];

      if (sinalizacao is Map) {
        conePlasticoController.text =
            sinalizacao['cone_plastico']?.toString() ?? '0';
        placaPareSigaController.text =
            sinalizacao['placa_pare_siga']?.toString() ?? '0';
        cavaleteMetalicoController.text =
            sinalizacao['cavalete_metalico']?.toString() ?? '0';
      }

      final fotosJson = map['fotos_offline'] ?? map['fotos'];

      fotosOffline.clear();

      if (fotosJson is List) {
        for (final foto in fotosJson) {
          if (foto is Map) {
            fotosOffline.add(Map<String, dynamic>.from(foto));
          } else if (foto is String && foto.trim().isNotEmpty) {
            fotosOffline.add({
              'path': foto.trim(),
              'nome': foto.trim().split(Platform.pathSeparator).last,
              'origem': 'offline',
            });
          }
        }
      }
    } catch (_) {
      // Se o JSON antigo estiver inválido, mantém a tela aberta com os dados básicos.
    }
  }

  Future<void> carregarObrasFormulario() async {
    if (mounted) {
      setState(() {
        carregandoObrasFormulario = true;
      });
    }

    try {
      final obras = await authService.listarObrasLocais();

      if (!mounted) {
        return;
      }

      setState(() {
        obrasLocaisFormulario = obras;

        if (obrasLocaisFormulario.isNotEmpty) {
          final existeSelecionada =
              obraIdSelecionada != null &&
              obrasLocaisFormulario.any((obra) => obra.id == obraIdSelecionada);

          if (!existeSelecionada) {
            LocalObra? porNome;

            for (final obra in obrasLocaisFormulario) {
              if (obra.nome.trim().toLowerCase() ==
                  obraNomeSelecionada.trim().toLowerCase()) {
                porNome = obra;
                break;
              }
            }

            final escolhida = porNome ?? obrasLocaisFormulario.first;
            obraIdSelecionada = escolhida.id;
            obraNomeSelecionada = escolhida.nome;
          } else {
            final escolhida = obrasLocaisFormulario.firstWhere(
              (obra) => obra.id == obraIdSelecionada,
            );
            obraNomeSelecionada = escolhida.nome;
          }
        }

        carregandoObrasFormulario = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        carregandoObrasFormulario = false;
      });
    }
  }

  Widget seletorObraFormulario() {
    if (carregandoObrasFormulario) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Carregando obras vinculadas...',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (obrasLocaisFormulario.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: const Text(
          'Nenhuma obra vinculada encontrada no app. Sincronize novamente antes de lançar.',
          style: TextStyle(
            color: Color(0xFF92400E),
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    final valorAtual =
        obraIdSelecionada != null &&
            obrasLocaisFormulario.any((obra) => obra.id == obraIdSelecionada)
        ? obraIdSelecionada
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<int>(
        value: valorAtual,
        isExpanded: true,
        validator: (valor) {
          if (valor == null) {
            return 'Selecione o contrato/obra';
          }

          return null;
        },
        decoration: InputDecoration(
          labelText: 'Contrato / obra',
          prefixIcon: const Icon(Icons.business_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          filled: true,
          fillColor: Colors.white,
        ),
        items: obrasLocaisFormulario.map((obra) {
          return DropdownMenuItem<int>(
            value: obra.id,
            child: Text(obra.nome, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (valor) {
          if (valor == null) {
            return;
          }

          final obra = obrasLocaisFormulario.firstWhere(
            (item) => item.id == valor,
          );

          setState(() {
            obraIdSelecionada = obra.id;
            obraNomeSelecionada = obra.nome;
          });
        },
      ),
    );
  }

  String dataDiarioParaTela(String valor) {
    final texto = valor.trim();

    if (texto.isEmpty) {
      return texto;
    }

    final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(texto);

    if (iso != null) {
      final ano = iso.group(1)!;
      final mes = iso.group(2)!;
      final dia = iso.group(3)!;
      return '$dia/$mes/$ano';
    }

    final br = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(texto);

    if (br != null) {
      return texto;
    }

    try {
      final data = DateTime.parse(texto);
      final dia = data.day.toString().padLeft(2, '0');
      final mes = data.month.toString().padLeft(2, '0');
      final ano = data.year.toString();

      return '$dia/$mes/$ano';
    } catch (_) {
      return texto;
    }
  }

  String dataDiarioParaApi(String valor) {
    final texto = valor.trim();

    final br = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(texto);

    if (br != null) {
      final dia = br.group(1)!;
      final mes = br.group(2)!;
      final ano = br.group(3)!;
      return '$ano-$mes-$dia';
    }

    return texto;
  }

  String? validarDataDiario(String? valor) {
    final texto = valor?.trim() ?? '';

    if (texto.isEmpty) {
      return 'Campo obrigatório';
    }

    final br = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(texto);
    final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(texto);

    int? dia;
    int? mes;
    int? ano;

    if (br != null) {
      dia = int.tryParse(br.group(1)!);
      mes = int.tryParse(br.group(2)!);
      ano = int.tryParse(br.group(3)!);
    } else if (iso != null) {
      ano = int.tryParse(iso.group(1)!);
      mes = int.tryParse(iso.group(2)!);
      dia = int.tryParse(iso.group(3)!);
    } else {
      return 'Use o formato DD/MM/AAAA';
    }

    if (dia == null || mes == null || ano == null) {
      return 'Data inválida';
    }

    try {
      final data = DateTime(ano, mes, dia);

      if (data.day != dia || data.month != mes || data.year != ano) {
        return 'Data inválida';
      }
    } catch (_) {
      return 'Data inválida';
    }

    return null;
  }

  @override
  void initState() {
    super.initState();

    obraIdSelecionada = widget.rascunhoExistente?.obraId ?? widget.obraId;
    obraNomeSelecionada = widget.rascunhoExistente?.obraNome ?? widget.obraNome;

    final agora = DateTime.now();
    final dia = agora.day.toString().padLeft(2, '0');
    final mes = agora.month.toString().padLeft(2, '0');
    final ano = agora.year.toString();

    dataController.text = '$dia/$mes/$ano';
    condicaoOperacaoController.text = 'Praticável';

    carregarRascunhoExistente();
    carregarObrasFormulario();
  }

  @override
  void dispose() {
    dataController.dispose();
    equipeController.dispose();
    condicaoOperacaoController.dispose();
    horaEntradaController.dispose();
    horaSaidaController.dispose();
    ocorrenciasController.dispose();
    observacoesController.dispose();
    acidenteDescricaoController.dispose();
    conePlasticoController.dispose();
    placaPareSigaController.dispose();
    cavaleteMetalicoController.dispose();
    super.dispose();
  }

  String? obrigatorio(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    return null;
  }

  int totalQuantidadeLista(List<Map<String, dynamic>> itens) {
    int total = 0;

    for (final item in itens) {
      final valor = item['quantidade']?.toString().replaceAll(',', '.') ?? '';
      total += int.tryParse(valor.split('.').first) ?? 0;
    }

    return total;
  }

  Map<String, String> materialSinalizacaoPayload() {
    return {
      'cone_plastico': conePlasticoController.text.trim().isEmpty
          ? '0'
          : conePlasticoController.text.trim(),
      'placa_pare_siga': placaPareSigaController.text.trim().isEmpty
          ? '0'
          : placaPareSigaController.text.trim(),
      'cavalete_metalico': cavaleteMetalicoController.text.trim().isEmpty
          ? '0'
          : cavaleteMetalicoController.text.trim(),
    };
  }

  Future<void> salvarRascunho() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (obraIdSelecionada == null || obraNomeSelecionada.trim().isEmpty) {
      mostrarMensagem('Selecione o contrato/obra do diário.');
      return;
    }

    if (servicos.isEmpty) {
      mostrarMensagem('Adicione pelo menos um serviço executado.');
      return;
    }

    if (houveAcidente && acidenteDescricaoController.text.trim().isEmpty) {
      mostrarMensagem('Descreva o acidente informado.');
      return;
    }

    setState(() {
      salvando = true;
    });

    final totalPessoal =
        totalQuantidadeLista(maoObra) + totalQuantidadeLista(maoObraIndireta);
    final totalEquipamentos = equipamentos.length;

    final dados = {
      'obra_id': obraIdSelecionada,
      'obra_nome': obraNomeSelecionada,
      'data_diario': dataDiarioParaApi(dataController.text.trim()),
      'equipe': equipeController.text.trim(),

      // Campos DNIT compatíveis com o Flask.
      'clima': climaManhaSelecionado,
      'clima_manha': climaManhaSelecionado,
      'clima_tarde': climaTardeSelecionado,
      'condicao_via': condicaoOperacaoController.text.trim(),
      'condicao_operacao': condicaoOperacaoController.text.trim(),
      'acidente': houveAcidente ? 'Houve' : 'Não houve',
      'tipo_ocorrencia': acidenteDescricaoController.text.trim(),
      'hora_entrada': horaEntradaController.text.trim(),
      'hora_saida': horaSaidaController.text.trim(),

      'tipo_servico': servicos.isNotEmpty
          ? servicos.first['tipo_servico']
          : null,
      'km_inicial': servicos.isNotEmpty ? servicos.first['km_inicial'] : null,
      'km_final': servicos.isNotEmpty ? servicos.first['km_final'] : null,

      'descricao': observacoesController.text.trim().isEmpty
          ? 'Não houve comentários ou ocorrências.'
          : observacoesController.text.trim(),
      'ocorrencias': ocorrenciasController.text.trim(),
      'comentarios_ocorrencias': observacoesController.text.trim(),

      'servicos_executados': servicos,
      'materiais_recebidos_utilizados': materiais,
      'maquinas_equipamentos': equipamentos,
      'mao_obra_direta': maoObra,
      'mao_obra_indireta': maoObraIndireta,
      'compareceu_campo': compareceuCampo,
      'material_sinalizacao': materialSinalizacaoPayload(),

      // Aliases usados pelas telas locais do app.
      'servicos_executados_lista': servicos,
      'materiais_recebidos_utilizados_lista': materiais,
      'maquinas_equipamentos_lista': equipamentos,
      'mao_obra_direta_lista': maoObra,
      'mao_obra_indireta_lista': maoObraIndireta,
      'compareceu_campo_dict': compareceuCampo,
      'material_sinalizacao_dict': materialSinalizacaoPayload(),

      'total_pessoal': totalPessoal,
      'total_equipamentos': totalEquipamentos,

      'assinatura_encarregado': '',
      'assinatura_apontador': '',
      'fotos': fotosOffline,
      'fotos_offline': fotosOffline,
      'status_local': 'rascunho',
      'origem': 'app_offline',
      'versao_formulario_offline': 3,
      'criado_em_app': DateTime.now().toIso8601String(),
    };

    try {
      if (widget.rascunhoExistente == null) {
        await authService.salvarRascunhoDiario(dados);
      } else {
        await authService.atualizarRascunhoDiario(
          widget.rascunhoExistente!.id,
          dados,
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.rascunhoExistente == null
                ? 'Diário salvo no dispositivo e pendente de envio.'
                : 'Diário pendente atualizado.',
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) {
        return;
      }

      mostrarMensagem('Não foi possível salvar o diário pendente.');
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  void mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<String?> campoDialogo({
    required String titulo,
    required String label,
    String valorInicial = '',
    int maxLines = 1,
    TextInputType? keyboardType,
  }) async {
    final controller = TextEditingController(text: valorInicial);

    final resultado = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    return resultado;
  }

  Future<void> adicionarServico() async {
    String tipo = opcoesServico.first;

    final configsPorServico = <String, List<Map<String, dynamic>>>{
      'CAPA ASFÁLTICA / REVESTIMENTO': [
        {
          'campo': 'km_inicial',
          'label': 'KM inicial',
          'tipo': 'text',
          'placeholder': 'Ex: 234,430',
        },
        {
          'campo': 'km_final',
          'label': 'KM final',
          'tipo': 'text',
          'placeholder': 'Ex: 235,100',
        },
        {
          'campo': 'lado',
          'label': 'Lado',
          'tipo': 'select',
          'opcoes': ['Direito', 'Esquerdo', 'Ambos'],
        },
        {
          'campo': 'observacao',
          'label': 'Observações',
          'tipo': 'textarea',
          'placeholder': 'Observações do serviço executado',
        },
      ],
      'DRENAGEM': [
        {
          'campo': 'km_localizacao',
          'label': 'KM de localização do dreno',
          'tipo': 'text',
          'placeholder': 'Ex: 234,430',
        },
        {
          'campo': 'observacao',
          'label': 'Observações',
          'tipo': 'textarea',
          'placeholder': 'Observações do serviço executado',
        },
      ],
      'PALIATIVO / ENROCAMENTO DE PEDRAS': [
        {
          'campo': 'km_inicial',
          'label': 'KM inicial',
          'tipo': 'text',
          'placeholder': 'Ex: 234,430',
        },
        {
          'campo': 'km_final',
          'label': 'KM final',
          'tipo': 'text',
          'placeholder': 'Ex: 235,100',
        },
        {
          'campo': 'lado',
          'label': 'Lado',
          'tipo': 'select',
          'opcoes': ['Direito', 'Esquerdo', 'Ambos'],
        },
        {
          'campo': 'observacao',
          'label': 'Observações',
          'tipo': 'textarea',
          'placeholder': 'Observações do serviço executado',
        },
      ],
      'REPARO PROFUNDO / TROCA DE SOLO': [
        {
          'campo': 'numero_remendos',
          'label': 'Número de remendos',
          'tipo': 'number',
          'placeholder': 'Ex: 5',
        },
        {
          'campo': 'km_inicial',
          'label': 'KM inicial',
          'tipo': 'text',
          'placeholder': 'Ex: 233,540',
        },
        {
          'campo': 'km_final',
          'label': 'KM final',
          'tipo': 'text',
          'placeholder': 'Ex: 233,890',
        },
        {
          'campo': 'lado',
          'label': 'Lado',
          'tipo': 'select',
          'opcoes': ['Direito', 'Esquerdo', 'Ambos'],
        },
        {
          'campo': 'area_total_escavada_m2',
          'label': 'Área total escavada em m²',
          'tipo': 'number',
          'placeholder': 'Ex: 120,50',
        },
        {
          'campo': 'volume_pedra_3_m3',
          'label': 'Volume de Pedra nº3 usado em m³',
          'tipo': 'number',
          'placeholder': 'Ex: 35,00',
        },
        {
          'campo': 'volume_bgs_m3',
          'label': 'Volume de BGS usado em m³',
          'tipo': 'number',
          'placeholder': 'Ex: 18,00',
        },
        {
          'campo': 'area_total_escavada_dreno_m2',
          'label': 'Área total escavada no dreno em m²',
          'tipo': 'number',
          'placeholder': 'Ex: 20,00',
        },
        {
          'campo': 'volume_pedra_3_dreno_m3',
          'label': 'Volume de Pedra nº3 no dreno em m³',
          'tipo': 'number',
          'placeholder': 'Ex: 8,00',
        },
        {
          'campo': 'observacao',
          'label': 'Observações',
          'tipo': 'textarea',
          'placeholder': 'Observações do serviço executado',
        },
      ],
      'RECICLAGEM': [
        {
          'campo': 'km_inicial',
          'label': 'KM inicial',
          'tipo': 'text',
          'placeholder': 'Ex: 234,430',
        },
        {
          'campo': 'km_final',
          'label': 'KM final',
          'tipo': 'text',
          'placeholder': 'Ex: 235,100',
        },
        {
          'campo': 'lado',
          'label': 'Lado',
          'tipo': 'select',
          'opcoes': ['Direito', 'Esquerdo', 'Ambos'],
        },
        {
          'campo': 'largura_m',
          'label': 'Largura em m',
          'tipo': 'number',
          'placeholder': 'Ex: 3,50',
        },
        {
          'campo': 'observacao',
          'label': 'Observações',
          'tipo': 'textarea',
          'placeholder': 'Observações do serviço executado',
        },
      ],
      'CORREÇÃO DE DEFEITOS COM CBUQ': [
        {
          'campo': 'km_inicial',
          'label': 'KM inicial',
          'tipo': 'text',
          'placeholder': 'Ex: 234,430',
        },
        {
          'campo': 'km_final',
          'label': 'KM final',
          'tipo': 'text',
          'placeholder': 'Ex: 235,100',
        },
        {
          'campo': 'lado',
          'label': 'Lado',
          'tipo': 'select',
          'opcoes': ['Direito', 'Esquerdo', 'Ambos'],
        },
        {
          'campo': 'observacao',
          'label': 'Observações',
          'tipo': 'textarea',
          'placeholder': 'Observações do serviço executado',
        },
      ],
      'OUTROS': [
        {
          'campo': 'descricao_livre',
          'label': 'Descrição do serviço',
          'tipo': 'textarea',
          'placeholder': 'Descreva o serviço executado',
        },
        {
          'campo': 'observacao',
          'label': 'Observações',
          'tipo': 'textarea',
          'placeholder': 'Observações do serviço executado',
        },
      ],
    };

    final todosCampos = configsPorServico.values
        .expand((lista) => lista)
        .map((config) => config['campo'].toString())
        .toSet()
        .toList();

    final controllers = {
      for (final campo in todosCampos) campo: TextEditingController(),
    };

    final valoresSelect = <String, String>{};

    Widget campoServico(
      Map<String, dynamic> config,
      void Function(void Function()) setDialogState,
    ) {
      final campo = config['campo'].toString();
      final label = config['label'].toString();
      final tipoCampo = config['tipo'].toString();
      final placeholder = config['placeholder']?.toString() ?? '';

      if (tipoCampo == 'select') {
        final opcoes = (config['opcoes'] as List).cast<String>();
        final valorAtual = valoresSelect[campo];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String>(
            value: opcoes.contains(valorAtual) ? valorAtual : null,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            items: opcoes.map((opcao) {
              return DropdownMenuItem(value: opcao, child: Text(opcao));
            }).toList(),
            onChanged: (valor) {
              setDialogState(() {
                valoresSelect[campo] = valor ?? '';
              });
            },
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: controllers[campo],
          maxLines: tipoCampo == 'textarea' ? 3 : 1,
          keyboardType: tipoCampo == 'number'
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            hintText: placeholder,
            border: const OutlineInputBorder(),
          ),
        ),
      );
    }

    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final campos = configsPorServico[tipo] ?? [];

            return AlertDialog(
              title: const Text('Adicionar serviço'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: tipo,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de serviço',
                          border: OutlineInputBorder(),
                        ),
                        items: opcoesServico.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(item, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (valor) {
                          if (valor == null) return;
                          setDialogState(() {
                            tipo = valor;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      if (campos.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Text(
                            'Selecione o tipo de serviço para exibir os campos.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        ...campos.map(
                          (config) => campoServico(config, setDialogState),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final item = <String, dynamic>{'tipo_servico': tipo};

                    final camposAtuais = configsPorServico[tipo] ?? [];

                    for (final config in camposAtuais) {
                      final campo = config['campo'].toString();
                      final tipoCampo = config['tipo'].toString();

                      if (tipoCampo == 'select') {
                        item[campo] = valoresSelect[campo] ?? '';
                      } else {
                        item[campo] = controllers[campo]?.text.trim() ?? '';
                      }
                    }

                    if (item['observacao'] != null &&
                        item['observacoes'] == null) {
                      item['observacoes'] = item['observacao'];
                    }

                    if (item['km_localizacao'] != null &&
                        item['km_inicial'] == null) {
                      item['km_inicial'] = item['km_localizacao'];
                      item['km_final'] = item['km_localizacao'];
                    }

                    Navigator.of(context).pop(item);
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultado != null) {
      setState(() {
        servicos.add(resultado);
      });
    }
  }

  Future<void> adicionarMaterial() async {
    String material = opcoesMateriais.first;
    String unidade = opcoesUnidade.first;
    final quantidade = TextEditingController();
    final placa = TextEditingController();
    final ticket = TextEditingController();
    final horaChegada = TextEditingController();
    final temperaturaCbuq = TextEditingController();
    final observacao = TextEditingController();

    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Adicionar material'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: material,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Material',
                        border: OutlineInputBorder(),
                      ),
                      items: opcoesMateriais.map((item) {
                        return DropdownMenuItem(value: item, child: Text(item));
                      }).toList(),
                      onChanged: (valor) {
                        if (valor == null) return;
                        setDialogState(() => material = valor);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: quantidade,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: const [
                        QuantidadeMaterialInputFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: unidade,
                      decoration: const InputDecoration(
                        labelText: 'Unidade',
                        border: OutlineInputBorder(),
                      ),
                      items: opcoesUnidade.map((item) {
                        return DropdownMenuItem(value: item, child: Text(item));
                      }).toList(),
                      onChanged: (valor) {
                        if (valor == null) return;
                        setDialogState(() => unidade = valor);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: placa,
                      decoration: const InputDecoration(
                        labelText: 'Placa',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: ticket,
                      decoration: const InputDecoration(
                        labelText: 'Ticket',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: horaChegada,
                      decoration: const InputDecoration(
                        labelText: 'Hora de chegada',
                        hintText: 'Ex: 08:30',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (material == 'CBUQ') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: temperaturaCbuq,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Temperatura do CBUQ (°C)',
                          hintText: 'Ex: 145',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: observacao,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Observação',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop({
                      'material': material,
                      'quantidade': quantidade.text.trim(),
                      'unidade': unidade,
                      'placa': placa.text.trim(),
                      'ticket': ticket.text.trim(),
                      'hora_chegada': horaChegada.text.trim(),
                      'temperatura_cbuq': material == 'CBUQ'
                          ? temperaturaCbuq.text.trim()
                          : null,
                      'observacao': observacao.text.trim(),
                    });
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultado != null) {
      setState(() {
        materiais.add(resultado);
      });
    }
  }

  Future<void> adicionarEquipamento() async {
    String equipamento = opcoesEquipamentos.first;
    final descricaoOutros = TextEditingController();
    final codigoPlaca = TextEditingController();
    final horimetroKm = TextEditingController();
    final observacao = TextEditingController();

    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Adicionar equipamento'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: equipamento,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Equipamento',
                        border: OutlineInputBorder(),
                      ),
                      items: opcoesEquipamentos.map((item) {
                        return DropdownMenuItem(value: item, child: Text(item));
                      }).toList(),
                      onChanged: (valor) {
                        if (valor == null) return;
                        setDialogState(() => equipamento = valor);
                      },
                    ),
                    if (equipamento == 'OUTROS') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: descricaoOutros,
                        decoration: const InputDecoration(
                          labelText: 'Descreva o equipamento/veículo',
                          hintText: 'Ex.: Caminhão comboio, van de apoio...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: codigoPlaca,
                      decoration: const InputDecoration(
                        labelText: 'Código/Placa',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: horimetroKm,
                      decoration: const InputDecoration(
                        labelText: 'Horímetro/KM',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: observacao,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Observação',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final descricao = descricaoOutros.text.trim();

                    if (equipamento == 'OUTROS' && descricao.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Descreva o equipamento/veículo informado como OUTROS.',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.of(context).pop({
                      'equipamento': equipamento,
                      'descricao_outros': descricao,
                      'codigo_placa': codigoPlaca.text.trim(),
                      'horimetro_quilometragem': horimetroKm.text.trim(),
                      'observacao': observacao.text.trim(),
                    });
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultado != null) {
      setState(() {
        equipamentos.add(resultado);
      });
    }
  }

  Future<void> adicionarMaoObraGenerica({
    required String titulo,
    required List<String> opcoes,
    required List<Map<String, dynamic>> destino,
  }) async {
    String funcao = opcoes.first;
    final quantidade = TextEditingController();
    final descricaoOutros = TextEditingController();

    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(titulo),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: funcao,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Função',
                        border: OutlineInputBorder(),
                      ),
                      items: opcoes.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (valor) {
                        if (valor == null) return;
                        setDialogState(() => funcao = valor);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: quantidade,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final descricao = descricaoOutros.text.trim();

                    if (funcao == 'OUTROS' && descricao.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Descreva a função informada como OUTROS.',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.of(context).pop({
                      'funcao': funcao,
                      'descricao_outros': descricao,
                      'quantidade': quantidade.text.trim(),
                    });
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultado != null) {
      setState(() {
        destino.add(resultado);
      });
    }
  }

  Future<void> adicionarMaoObra() {
    return adicionarMaoObraGenerica(
      titulo: 'Adicionar mão de obra direta',
      opcoes: opcoesMaoObra,
      destino: maoObra,
    );
  }

  Future<void> adicionarMaoObraIndireta() {
    return adicionarMaoObraGenerica(
      titulo: 'Adicionar mão de obra indireta',
      opcoes: opcoesMaoObraIndireta,
      destino: maoObraIndireta,
    );
  }

  Future<Directory> pastaFotosRascunho() async {
    final pastaBase = await getApplicationDocumentsDirectory();
    final pasta = Directory(
      '${pastaBase.path}${Platform.pathSeparator}rascunhos_fotos',
    );

    if (!await pasta.exists()) {
      await pasta.create(recursive: true);
    }

    return pasta;
  }

  String extensaoArquivo(String nome) {
    final partes = nome.split('.');

    if (partes.length < 2) {
      return '.jpg';
    }

    return '.${partes.last.toLowerCase()}';
  }

  Future<Map<String, dynamic>> salvarArquivoFoto(XFile arquivo) async {
    final pasta = await pastaFotosRascunho();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extensao = extensaoArquivo(arquivo.name);
    final nomeDestino = 'foto_${timestamp}_${fotosOffline.length + 1}$extensao';
    final destino = File('${pasta.path}${Platform.pathSeparator}$nomeDestino');

    await arquivo.saveTo(destino.path);

    return {
      'path': destino.path,
      'nome': nomeDestino,
      'origem': 'offline',
      'criado_em': DateTime.now().toIso8601String(),
    };
  }

  Future<void> adicionarFotoCamera() async {
    try {
      final foto = await imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 82,
      );

      if (foto == null) {
        return;
      }

      final salva = await salvarArquivoFoto(foto);

      setState(() {
        fotosOffline.add(salva);
      });
    } catch (_) {
      mostrarMensagem('Não foi possível abrir a câmera.');
    }
  }

  Future<void> adicionarFotosGaleria() async {
    try {
      final fotos = await imagePicker.pickMultiImage(imageQuality: 82);

      if (fotos.isEmpty) {
        return;
      }

      final total = fotos.length;
      final progresso = ValueNotifier<int>(0);

      if (mounted) {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return PopScope(
              canPop: false,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                title: const Text('Preparando fotos'),
                content: ValueListenableBuilder<int>(
                  valueListenable: progresso,
                  builder: (context, valor, _) {
                    final percentual = total == 0 ? 0.0 : valor / total;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aguarde enquanto as fotos são carregadas no rascunho.',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(value: percentual),
                        const SizedBox(height: 12),
                        Text(
                          '$valor de $total foto(s) carregada(s)',
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      }

      await Future.delayed(const Duration(milliseconds: 120));

      var carregadas = 0;

      for (final foto in fotos) {
        final salva = await salvarArquivoFoto(foto);
        fotosOffline.add(salva);

        carregadas++;
        progresso.value = carregadas;

        // Dá um respiro para a UI atualizar a barra de progresso em lotes grandes.
        if (carregadas % 5 == 0) {
          await Future.delayed(const Duration(milliseconds: 1));
        }
      }

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      progresso.dispose();

      if (!mounted) {
        return;
      }

      setState(() {});

      mostrarMensagem(
        total == 1
            ? '1 foto carregada no rascunho.'
            : '$total fotos carregadas no rascunho.',
      );
    } catch (_) {
      if (mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}
      }

      mostrarMensagem('Não foi possível selecionar as fotos.');
    }
  }

  Future<void> removerFotoOffline(int index) async {
    final foto = fotosOffline[index];
    final caminho = foto['path']?.toString() ?? '';

    setState(() {
      fotosOffline.removeAt(index);
    });

    if (caminho.isNotEmpty) {
      try {
        final arquivo = File(caminho);

        if (await arquivo.exists()) {
          await arquivo.delete();
        }
      } catch (_) {
        // Mesmo se não conseguir apagar o arquivo, remove do rascunho.
      }
    }
  }

  Future<void> removerTodasFotosOffline() async {
    if (fotosOffline.isEmpty) {
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover todas as fotos?'),
          content: Text(
            'Você está prestes a remover ${fotosOffline.length} foto(s) deste rascunho. Deseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remover'),
              style: FilledButton.styleFrom(
                backgroundColor: Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    final fotosParaExcluir = List<Map<String, dynamic>>.from(fotosOffline);

    setState(() {
      fotosOffline.clear();
    });

    for (final foto in fotosParaExcluir) {
      final caminho = foto['path']?.toString() ?? '';

      if (caminho.isEmpty) {
        continue;
      }

      try {
        final arquivo = File(caminho);

        if (await arquivo.exists()) {
          await arquivo.delete();
        }
      } catch (_) {
        // Se não conseguir apagar o arquivo físico, mantém o rascunho limpo visualmente.
      }
    }
  }

  Widget miniFotoOffline(int index, Map<String, dynamic> foto) {
    final caminho = foto['path']?.toString() ?? '';
    final arquivo = File(caminho);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          clipBehavior: Clip.antiAlias,
          child: arquivo.existsSync()
              ? Image.file(
                  arquivo,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  cacheWidth: 320,
                )
              : const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Color(0xFF64748B),
                  ),
                ),
        ),
        Positioned(
          left: 6,
          top: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.58),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ),
        Positioned(
          right: 2,
          top: 2,
          child: IconButton.filled(
            visualDensity: VisualDensity.compact,
            iconSize: 17,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              minimumSize: const Size(30, 30),
            ),
            onPressed: () => removerFotoOffline(index),
            icon: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }

  Future<void> abrirGaleriaFotosRascunho() async {
    if (fotosOffline.isEmpty) {
      mostrarMensagem('Nenhuma foto adicionada ao rascunho.');
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF8FAFC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.88,
              minChildSize: 0.55,
              maxChildSize: 0.96,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
                      child: Column(
                        children: [
                          Container(
                            width: 46,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.photo_library_outlined,
                                  color: Color(0xFF1D4ED8),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Galeria do rascunho',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      '${fotosOffline.length} foto(s) selecionada(s)',
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: fotosOffline.isEmpty
                          ? const Center(
                              child: Text(
                                'Nenhuma foto adicionada.',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            )
                          : GridView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 0.82,
                                  ),
                              itemCount: fotosOffline.length,
                              itemBuilder: (context, index) {
                                return miniFotoOffline(
                                  index,
                                  fotosOffline[index],
                                );
                              },
                            ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await adicionarFotosGaleria();
                                },
                                icon: const Icon(
                                  Icons.add_photo_alternate_outlined,
                                ),
                                label: const Text('Adicionar'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: fotosOffline.isEmpty
                                    ? null
                                    : () async {
                                        Navigator.of(context).pop();
                                        await removerTodasFotosOffline();
                                      },
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Limpar'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFDC2626),
                                  side: const BorderSide(
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );

    if (mounted) {
      setState(() {});
    }
  }

  Widget painelFotosOffline() {
    final total = fotosOffline.length;
    final previa = fotosOffline.take(9).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: const Text(
            'As fotos ficam salvas no aparelho junto com o diário pendente. No envio, o app manda em lotes para evitar falhas com muitas imagens.',
            style: TextStyle(
              color: Color(0xFF1E3A8A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: adicionarFotoCamera,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Câmera'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: adicionarFotosGaleria,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galeria'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (total == 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text(
              'Nenhuma foto adicionada ao rascunho.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.collections_outlined,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    total == 1
                        ? '1 foto selecionada'
                        : '$total fotos selecionadas',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: abrirGaleriaFotosRascunho,
                  icon: const Icon(Icons.grid_view_outlined),
                  label: const Text('Ver'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            itemCount: previa.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              return miniFotoOffline(index, previa[index]);
            },
          ),
          if (total > previa.length) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: abrirGaleriaFotosRascunho,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text('Ver todas as $total fotos'),
              ),
            ),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: removerTodasFotosOffline,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Limpar fotos selecionadas'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFDC2626)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  int totalItensPreenchidos() {
    return servicos.length +
        materiais.length +
        equipamentos.length +
        maoObra.length +
        maoObraIndireta.length +
        fotosOffline.length;
  }

  Widget campoTexto({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon == null
              ? null
              : Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: const Color(0xFF1D4ED8)),
                ),
          isDense: false,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w700,
          ),
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w600,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFD7E0EA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF1D4ED8), width: 1.6),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFEF4444)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget secaoFormulario({
    required String titulo,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1D4ED8), Color(0xFF60A5FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          title: Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            'Toque para preencher esta seção',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 8, 16, 17),
          children: children,
        ),
      ),
    );
  }

  Widget listaDinamica({
    required List<Map<String, dynamic>> itens,
    required String vazio,
    required String Function(Map<String, dynamic>) titulo,
    required String Function(Map<String, dynamic>) subtitulo,
    required VoidCallback adicionar,
  }) {
    return Column(
      children: [
        if (itens.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF94A3B8),
                  size: 34,
                ),
                const SizedBox(height: 8),
                Text(
                  vazio,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          )
        else
          ...itens.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 11),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Color(0xFF1D4ED8),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo(item),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitulo(item),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        itens.removeAt(index);
                      });
                    },
                    icon: const Icon(Icons.delete_outline),
                    color: const Color(0xFFDC2626),
                  ),
                ],
              ),
            );
          }),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: adicionar,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar item'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1D4ED8),
              side: const BorderSide(color: Color(0xFF1D4ED8)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget seletorCompareceuCampo({
    required String chave,
    required String label,
  }) {
    final valorAtual = compareceuCampo[chave] ?? 'Não';
    final marcado = valorAtual == 'Sim';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: marcado ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: marcado ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            marcado ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            color: marcado ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Sim', label: Text('Sim')),
              ButtonSegment(value: 'Não', label: Text('Não')),
            ],
            selected: {valorAtual},
            showSelectedIcon: false,
            onSelectionChanged: (valores) {
              setState(() {
                compareceuCampo[chave] = valores.first;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget cardFotoOffline(int index, Map<String, dynamic> foto) {
    final caminho = foto['path']?.toString() ?? '';
    final nome = foto['nome']?.toString() ?? 'Foto ${index + 1}';
    final arquivo = File(caminho);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (arquivo.existsSync())
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              child: Image.file(
                arquivo,
                width: double.infinity,
                height: 185,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 120,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: const Icon(
                Icons.broken_image_outlined,
                size: 42,
                color: Color(0xFF94A3B8),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Color(0xFF1D4ED8),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    nome,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => removerFotoOffline(index),
                  icon: const Icon(Icons.delete_outline),
                  color: const Color(0xFFDC2626),
                  tooltip: 'Remover foto',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text(
          widget.rascunhoExistente == null ? 'Novo diário' : 'Editar pendente',
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1D4ED8),
                    Color(0xFF38BDF8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 22,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.22),
                          ),
                        ),
                        child: const Icon(
                          Icons.edit_document,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.22),
                          ),
                        ),
                        child: Text(
                          '${totalItensPreenchidos()} item(ns)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.rascunhoExistente == null
                        ? 'Novo lançamento'
                        : 'Editando lançamento pendente',
                    style: const TextStyle(
                      color: Color(0xFFBFDBFE),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    obraNomeSelecionada.trim().isEmpty
                        ? widget.obraNome
                        : obraNomeSelecionada,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Preencha as seções do diário. Se estiver sem conexão, o lançamento fica salvo e será enviado automaticamente depois.',
                    style: TextStyle(
                      color: Color(0xFFE0F2FE),
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            secaoFormulario(
              titulo: 'Dados do diário',
              icon: Icons.assignment_outlined,
              children: [
                seletorObraFormulario(),
                campoTexto(
                  controller: dataController,
                  label: 'Data do diário',
                  hint: 'DD/MM/AAAA',
                  icon: Icons.calendar_month_outlined,
                  validator: validarDataDiario,
                ),
                campoTexto(
                  controller: equipeController,
                  label: 'Equipe',
                  icon: Icons.groups_outlined,
                  validator: obrigatorio,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<String>(
                    value: climaManhaSelecionado,
                    decoration: InputDecoration(
                      labelText: 'Clima manhã',
                      prefixIcon: const Icon(Icons.wb_sunny_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: opcoesClima.map((item) {
                      return DropdownMenuItem(value: item, child: Text(item));
                    }).toList(),
                    onChanged: (valor) {
                      if (valor == null) return;
                      setState(() {
                        climaManhaSelecionado = valor;
                        climaSelecionado = valor;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<String>(
                    value: climaTardeSelecionado,
                    decoration: InputDecoration(
                      labelText: 'Clima tarde',
                      prefixIcon: const Icon(Icons.cloud_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: opcoesClima.map((item) {
                      return DropdownMenuItem(value: item, child: Text(item));
                    }).toList(),
                    onChanged: (valor) {
                      if (valor == null) return;
                      setState(() => climaTardeSelecionado = valor);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<String>(
                    value:
                        opcoesCondicaoOperacao.contains(
                          condicaoOperacaoController.text,
                        )
                        ? condicaoOperacaoController.text
                        : 'Praticável',
                    decoration: InputDecoration(
                      labelText: 'Condição operacional',
                      prefixIcon: const Icon(Icons.fact_check_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: opcoesCondicaoOperacao.map((item) {
                      return DropdownMenuItem(value: item, child: Text(item));
                    }).toList(),
                    onChanged: (valor) {
                      if (valor == null) return;
                      setState(() => condicaoOperacaoController.text = valor);
                    },
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 330) {
                      return Column(
                        children: [
                          campoTexto(
                            controller: horaEntradaController,
                            label: 'Hora entrada',
                            hint: '07:00',
                            icon: Icons.login,
                          ),
                          campoTexto(
                            controller: horaSaidaController,
                            label: 'Hora saída',
                            hint: '17:00',
                            icon: Icons.logout,
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: campoTexto(
                            controller: horaEntradaController,
                            label: 'Hora entrada',
                            hint: '07:00',
                            icon: Icons.login,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: campoTexto(
                            controller: horaSaidaController,
                            label: 'Hora saída',
                            hint: '17:00',
                            icon: Icons.logout,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            secaoFormulario(
              titulo: 'Serviços executados',
              icon: Icons.construction,
              children: [
                listaDinamica(
                  itens: servicos,
                  vazio: 'Nenhum serviço adicionado.',
                  titulo: (item) =>
                      item['tipo_servico']?.toString() ?? 'Serviço',
                  subtitulo: (item) {
                    final kmInicial = item['km_inicial']?.toString() ?? '-';
                    final kmFinal = item['km_final']?.toString() ?? '-';
                    final lado = item['lado']?.toString() ?? '-';
                    final remendos = item['numero_remendos']?.toString();

                    if (remendos != null && remendos.isNotEmpty) {
                      return 'KM $kmInicial até $kmFinal • Lado: $lado • Remendos: $remendos';
                    }

                    return 'KM $kmInicial até $kmFinal • Lado: $lado';
                  },
                  adicionar: adicionarServico,
                ),
              ],
            ),
            secaoFormulario(
              titulo: 'Mão de obra direta',
              icon: Icons.groups,
              children: [
                listaDinamica(
                  itens: maoObra,
                  vazio: 'Nenhuma mão de obra adicionada.',
                  titulo: (item) => item['funcao']?.toString() ?? 'Função',
                  subtitulo: (item) =>
                      'Quantidade: ${item['quantidade'] ?? '-'}',
                  adicionar: adicionarMaoObra,
                ),
              ],
            ),
            secaoFormulario(
              titulo: 'Mão de obra indireta',
              icon: Icons.supervisor_account_outlined,
              children: [
                listaDinamica(
                  itens: maoObraIndireta,
                  vazio: 'Nenhuma mão de obra indireta adicionada.',
                  titulo: (item) => item['funcao']?.toString() ?? 'Função',
                  subtitulo: (item) =>
                      'Quantidade: ${item['quantidade'] ?? '-'}',
                  adicionar: adicionarMaoObraIndireta,
                ),
              ],
            ),
            secaoFormulario(
              titulo: 'Equipamentos',
              icon: Icons.precision_manufacturing_outlined,
              children: [
                listaDinamica(
                  itens: equipamentos,
                  vazio: 'Nenhum equipamento adicionado.',
                  titulo: (item) =>
                      item['equipamento']?.toString() ?? 'Equipamento',
                  subtitulo: (item) =>
                      'Código/Placa: ${item['codigo_placa'] ?? '-'} • Horímetro/KM: ${item['horimetro_quilometragem'] ?? '-'}',
                  adicionar: adicionarEquipamento,
                ),
              ],
            ),
            secaoFormulario(
              titulo: 'Materiais',
              icon: Icons.inventory_2_outlined,
              children: [
                listaDinamica(
                  itens: materiais,
                  vazio: 'Nenhum material adicionado.',
                  titulo: (item) => item['material']?.toString() ?? 'Material',
                  subtitulo: (item) {
                    final temperatura =
                        item['temperatura_cbuq']?.toString() ?? '';

                    if ((item['material']?.toString() ?? '') == 'CBUQ' &&
                        temperatura.isNotEmpty) {
                      return '${item['quantidade'] ?? '-'} ${item['unidade'] ?? ''} • Temp.: ${temperatura}°C • Placa: ${item['placa'] ?? '-'}';
                    }

                    return '${item['quantidade'] ?? '-'} ${item['unidade'] ?? ''} • Placa: ${item['placa'] ?? '-'}';
                  },
                  adicionar: adicionarMaterial,
                ),
              ],
            ),
            secaoFormulario(
              titulo: 'Compareceu em campo / fiscalização',
              icon: Icons.verified_user_outlined,
              children: [
                seletorCompareceuCampo(
                  chave: 'inspetor_campo',
                  label: 'Inspetor de campo',
                ),
                seletorCompareceuCampo(
                  chave: 'fiscal_supervisora',
                  label: 'Fiscal da supervisora',
                ),
                seletorCompareceuCampo(
                  chave: 'fiscal_dnit',
                  label: 'Fiscal do DNIT',
                ),
                seletorCompareceuCampo(
                  chave: 'engenheiro',
                  label: 'Engenheiro',
                ),
              ],
            ),
            secaoFormulario(
              titulo: 'Material de sinalização',
              icon: Icons.traffic_outlined,
              children: [
                campoTexto(
                  controller: conePlasticoController,
                  label: 'Cone plástico',
                  icon: Icons.traffic,
                ),
                campoTexto(
                  controller: placaPareSigaController,
                  label: 'Placa pare-siga',
                  icon: Icons.signpost_outlined,
                ),
                campoTexto(
                  controller: cavaleteMetalicoController,
                  label: 'Cavalete metálico',
                  icon: Icons.construction_outlined,
                ),
              ],
            ),
            secaoFormulario(
              titulo: 'Fotos do diário',
              icon: Icons.photo_library_outlined,
              children: [painelFotosOffline()],
            ),
            secaoFormulario(
              titulo: 'Ocorrências e segurança',
              icon: Icons.warning_amber_outlined,
              children: [
                campoTexto(
                  controller: ocorrenciasController,
                  label: 'Ocorrências',
                  icon: Icons.warning_amber_outlined,
                  maxLines: 3,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Houve acidente?',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  value: houveAcidente,
                  onChanged: (valor) {
                    setState(() {
                      houveAcidente = valor;
                    });
                  },
                ),
                if (houveAcidente)
                  campoTexto(
                    controller: acidenteDescricaoController,
                    label: 'Descrição do acidente',
                    icon: Icons.report_problem_outlined,
                    maxLines: 3,
                  ),
              ],
            ),
            secaoFormulario(
              titulo: 'Observações finais',
              icon: Icons.notes_outlined,
              children: [
                campoTexto(
                  controller: observacoesController,
                  label: 'Observações gerais',
                  icon: Icons.notes_outlined,
                  maxLines: 4,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x261D4ED8),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: FilledButton.icon(
                onPressed: salvando ? null : salvarRascunho,
                icon: Icon(
                  salvando ? Icons.hourglass_empty : Icons.save_outlined,
                ),
                label: Text(
                  salvando
                      ? 'Salvando...'
                      : widget.rascunhoExistente == null
                      ? 'Salvar diário'
                      : 'Salvar alterações',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PendentesOfflinePage extends StatefulWidget {
  const PendentesOfflinePage({super.key});

  @override
  State<PendentesOfflinePage> createState() => _PendentesOfflinePageState();
}

class _PendentesOfflinePageState extends State<PendentesOfflinePage> {
  final authService = AuthService();

  bool carregando = true;
  bool enviandoTodos = false;
  final Set<int> enviandoIds = {};
  final Map<int, String> statusEnvio = {};
  VoidCallback? progressoEnvioListener;
  List<RascunhosDiario> rascunhos = [];

  static const Color fundo = Color(0xFFF4F7FB);
  static const Color azul = Color(0xFF1D4ED8);
  static const Color azulEscuro = Color(0xFF0F172A);
  static const Color laranja = Color(0xFFF97316);
  static const Color textoFraco = Color(0xFF64748B);
  static const Color borda = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();

    progressoEnvioListener = sincronizarEstadoEnvioGlobal;
    AuthService.progressoEnvioPendentes.addListener(progressoEnvioListener!);

    sincronizarEstadoEnvioGlobal();
    carregarPendentes();
  }

  @override
  void dispose() {
    final listener = progressoEnvioListener;

    if (listener != null) {
      AuthService.progressoEnvioPendentes.removeListener(listener);
    }

    super.dispose();
  }

  void sincronizarEstadoEnvioGlobal() {
    if (!mounted) {
      return;
    }

    setState(() {
      statusEnvio
        ..clear()
        ..addAll(AuthService.progressoEnvioPendentes.value);

      enviandoIds
        ..clear()
        ..addAll(AuthService.idsEnvioPendentes);

      enviandoTodos = AuthService.existeEnvioPendenteAtivo;
    });
  }

  Future<void> carregarPendentes() async {
    setState(() {
      carregando = true;
    });

    final lista = await authService.listarRascunhosDiarios();

    if (!mounted) {
      return;
    }

    setState(() {
      rascunhos = lista;
      carregando = false;

      statusEnvio
        ..clear()
        ..addAll(AuthService.progressoEnvioPendentes.value);

      enviandoIds
        ..clear()
        ..addAll(AuthService.idsEnvioPendentes);

      enviandoTodos = AuthService.existeEnvioPendenteAtivo;
    });
  }

  Future<void> abrirEdicaoRascunho(RascunhosDiario rascunho) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NovoDiarioOfflinePage(
          obraId: rascunho.obraId,
          obraNome: rascunho.obraNome ?? 'Obra não informada',
          rascunhoExistente: rascunho,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    await carregarPendentes();
  }

  String mensagemErroEnvio(Object erro) {
    if (erro is DioException) {
      final data = erro.response?.data;

      if (data is Map && data['erro'] != null) {
        return data['erro'].toString();
      }

      return AppErrorHandler.mensagemModoOffline(erro);
    }

    return 'Não foi possível enviar o diário pendente agora. Ele continuará salvo no dispositivo.';
  }

  Future<bool> enviarPendenteSilencioso(RascunhosDiario item) async {
    try {
      final iniciou = await authService.enviarRascunhoComControleGlobal(item);
      return iniciou;
    } catch (_) {
      return false;
    }
  }

  Future<void> enviarTodosPendentes() async {
    if (rascunhos.isEmpty || enviandoTodos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum diário pendente para enviar.')),
      );
      return;
    }

    setState(() {
      enviandoTodos = true;
      enviandoIds
        ..clear()
        ..addAll(rascunhos.map((item) => item.id));

      for (final item in rascunhos) {
        statusEnvio[item.id] = 'Enviando...';
      }
    });

    int enviados = 0;
    int falhas = 0;

    for (final item in List<RascunhosDiario>.from(rascunhos)) {
      if (mounted) {
        setState(() {
          statusEnvio[item.id] = 'Enviando...';
        });
      }

      final ok = await enviarPendenteSilencioso(item);

      if (ok) {
        enviados++;

        if (mounted) {
          setState(() {
            statusEnvio[item.id] = 'Enviado com sucesso';
          });
        }
      } else {
        falhas++;

        if (mounted) {
          setState(() {
            statusEnvio[item.id] = 'Falhou, tente novamente';
          });
        }
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      enviandoTodos = false;
      enviandoIds.clear();
    });

    await carregarPendentes();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          falhas == 0
              ? '$enviados diário(s) enviado(s) com sucesso.'
              : '$enviados enviado(s), $falhas ainda pendente(s).',
        ),
      ),
    );
  }

  Future<void> enviarPendente(RascunhosDiario item) async {
    if (enviandoIds.contains(item.id)) {
      return;
    }

    setState(() {
      enviandoIds.add(item.id);
      statusEnvio[item.id] = 'Enviando...';
    });

    try {
      await authService.enviarRascunhoComControleGlobal(item);

      if (mounted) {
        setState(() {
          statusEnvio[item.id] = 'Enviado com sucesso';
        });
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diário enviado com sucesso.')),
      );

      await carregarPendentes();
    } catch (erro) {
      if (!mounted) {
        return;
      }

      setState(() {
        statusEnvio[item.id] = 'Falhou, tente novamente';
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagemErroEnvio(erro))));
    } finally {
      if (mounted) {
        setState(() {
          enviandoIds.remove(item.id);
        });
      }
    }
  }

  Future<void> excluirRascunho(RascunhosDiario rascunho) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir diário pendente?'),
          content: const Text(
            'Este diário pendente será removido apenas do dispositivo.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Excluir'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB91C1C),
              ),
            ),
          ],
        );
      },
    );

    if (confirmou != true) {
      return;
    }

    await authService.excluirRascunhoDiario(rascunho.id);

    setState(() {
      statusEnvio.remove(rascunho.id);
      enviandoIds.remove(rascunho.id);
    });

    await carregarPendentes();
  }

  String formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$ano às $hora:$minuto';
  }

  Color corDoStatus(String status) {
    if (status == 'Enviando...') return azul;
    if (status == 'Enviado com sucesso') return const Color(0xFF10B981);
    if (status == 'Falhou, tente novamente') return const Color(0xFFDC2626);
    return laranja;
  }

  IconData iconeDoStatus(String status) {
    if (status == 'Enviando...') return Icons.sync;
    if (status == 'Enviado com sucesso') return Icons.check_circle_outline;
    if (status == 'Falhou, tente novamente') return Icons.error_outline;
    return Icons.schedule_outlined;
  }

  Widget chipStatusEnvio(RascunhosDiario item) {
    final status = statusEnvio[item.id] ?? 'Pendente de envio';
    final color = corDoStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconeDoStatus(status), size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget infoLinha({
    required IconData icon,
    required String label,
    required String valor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        children: [
          Icon(icon, size: 17, color: textoFraco),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              color: textoFraco,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              valor.trim().isEmpty ? '-' : valor,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: azulEscuro,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget botaoAcao({
    required IconData icon,
    required VoidCallback? onTap,
    required String tooltip,
    Color color = azul,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          margin: const EdgeInsets.only(left: 7),
          decoration: BoxDecoration(
            color: onTap == null
                ? const Color(0xFFE2E8F0)
                : color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: onTap == null
                  ? const Color(0xFFCBD5E1)
                  : color.withOpacity(0.25),
            ),
          ),
          child: Icon(
            icon,
            color: onTap == null ? textoFraco : color,
            size: 21,
          ),
        ),
      ),
    );
  }

  Widget cardRascunho(RascunhosDiario item) {
    final enviando = enviandoIds.contains(item.id);
    final status = statusEnvio[item.id] ?? 'Pendente de envio';
    final statusColor = corDoStatus(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withOpacity(0.18)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => abrirEdicaoRascunho(item),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withOpacity(0.95),
                          statusColor.withOpacity(0.62),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(Icons.edit_document, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Diário pendente',
                          style: TextStyle(
                            color: textoFraco,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.obraNome ?? 'Obra não informada',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: azulEscuro,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: fundo,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borda),
                ),
                child: Column(
                  children: [
                    infoLinha(
                      icon: Icons.calendar_month_outlined,
                      label: 'Data',
                      valor: item.dataDiario ?? '-',
                    ),
                    infoLinha(
                      icon: Icons.groups_outlined,
                      label: 'Equipe',
                      valor: item.equipe ?? '-',
                    ),
                    infoLinha(
                      icon: Icons.construction,
                      label: 'Serviço',
                      valor: item.tipoServico ?? '-',
                    ),
                    infoLinha(
                      icon: Icons.cloud_outlined,
                      label: 'Clima',
                      valor: item.clima ?? '-',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  chipStatusEnvio(item),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: borda),
                    ),
                    child: Text(
                      'Atualizado em ${formatarData(item.atualizadoEm)}',
                      style: const TextStyle(
                        color: textoFraco,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: enviando ? null : () => enviarPendente(item),
                      icon: Icon(
                        enviando
                            ? Icons.hourglass_empty
                            : Icons.cloud_upload_outlined,
                      ),
                      label: Text(enviando ? 'Enviando...' : 'Enviar'),
                    ),
                  ),
                  botaoAcao(
                    icon: Icons.edit_outlined,
                    onTap: () => abrirEdicaoRascunho(item),
                    tooltip: 'Editar',
                    color: azul,
                  ),
                  botaoAcao(
                    icon: Icons.delete_outline,
                    onTap: () => excluirRascunho(item),
                    tooltip: 'Excluir',
                    color: const Color(0xFFDC2626),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borda),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(Icons.cloud_done_outlined, size: 46, color: Color(0xFF10B981)),
          SizedBox(height: 12),
          Text(
            'Tudo enviado',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: azulEscuro,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Nenhum diário pendente de envio no dispositivo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textoFraco, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget heroPendentes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C2D12), Color(0xFFF97316), Color(0xFFFFB020)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: Colors.white.withOpacity(0.22)),
            ),
            child: Icon(
              enviandoTodos ? Icons.sync : Icons.outbox_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Fila offline',
            style: TextStyle(
              color: Color(0xFFFFEDD5),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            rascunhos.isEmpty
                ? 'Nenhum pendente'
                : '${rascunhos.length} diário(s) aguardando envio',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            enviandoTodos
                ? 'Enviando diários e fotos em lotes. Não feche o app até concluir...'
                : 'Quando houver conexão, os diários serão enviados automaticamente.',
            style: const TextStyle(
              color: Color(0xFFFFF7ED),
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget botaoEnviarTodos() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: rascunhos.isEmpty || enviandoTodos
            ? null
            : enviarTodosPendentes,
        icon: Icon(
          enviandoTodos ? Icons.hourglass_empty : Icons.cloud_upload_outlined,
        ),
        label: Text(
          enviandoTodos ? 'Enviando... aguarde' : 'Enviar todos pendentes',
        ),
        style: FilledButton.styleFrom(
          backgroundColor: azulEscuro,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(title: const Text('Pendentes offline')),
      body: RefreshIndicator(
        onRefresh: carregarPendentes,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            heroPendentes(),
            const SizedBox(height: 16),
            botaoEnviarTodos(),
            const SizedBox(height: 14),
            if (carregando)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (rascunhos.isEmpty)
              emptyState()
            else
              ...rascunhos.map(cardRascunho),
          ],
        ),
      ),
    );
  }
}

class AppErrorHandler {
  AppErrorHandler._();

  static String mensagemLogin(DioException erro) {
    final data = erro.response?.data;
    final statusCode = erro.response?.statusCode;

    if (data is Map && data['erro'] != null) {
      final mensagem = data['erro'].toString();

      if (mensagem.toLowerCase().contains('senha') ||
          mensagem.toLowerCase().contains('credencia') ||
          mensagem.toLowerCase().contains('usu')) {
        return mensagem;
      }

      return mensagem;
    }

    if (statusCode == 401 || statusCode == 403) {
      return 'Usuário ou senha inválidos, ou sua sessão não tem permissão para acessar o app.';
    }

    if (statusCode == 404) {
      return 'Não foi possível validar o acesso. Atualize o app ou tente novamente.';
    }

    if (statusCode != null && statusCode >= 500) {
      return 'O sistema apresentou instabilidade. Tente novamente em alguns instantes.';
    }

    return _mensagemConexao(
      erro,
      contexto: 'Não foi possível conectar ao sistema para fazer login.',
    );
  }

  static String mensagemSincronizacao(DioException erro) {
    final data = erro.response?.data;
    final statusCode = erro.response?.statusCode;

    if (data is Map && data['erro'] != null) {
      return data['erro'].toString();
    }

    if (statusCode == 401) {
      return 'Sua sessão expirou. Faça login novamente quando estiver com conexão.';
    }

    if (statusCode == 403) {
      return 'Seu usuário não tem permissão para sincronizar estes dados.';
    }

    if (statusCode == 404) {
      return 'Não foi possível atualizar os dados. Atualize o app ou tente novamente.';
    }

    if (statusCode != null && statusCode >= 500) {
      return 'O sistema está com instabilidade. Tente atualizar novamente em alguns instantes.';
    }

    return _mensagemConexao(
      erro,
      contexto: 'Não foi possível sincronizar os diários.',
    );
  }

  static String mensagemModoOffline(DioException erro) {
    final base = _mensagemConexao(erro, contexto: 'Sem conexão no momento.');

    return '$base Usando os dados já salvos no dispositivo.';
  }

  static String _mensagemConexao(
    DioException erro, {
    required String contexto,
  }) {
    switch (erro.type) {
      case DioExceptionType.connectionTimeout:
        return '$contexto A conexão demorou demais. Verifique a VPN, sinal de internet e tente novamente.';
      case DioExceptionType.sendTimeout:
        return '$contexto O envio demorou demais. Tente novamente.';
      case DioExceptionType.receiveTimeout:
        return '$contexto A atualização demorou para responder. Tente novamente.';
      case DioExceptionType.connectionError:
        return '$contexto Verifique se o celular está com internet, se a VPN está conectada e tente novamente.';
      case DioExceptionType.badCertificate:
        return '$contexto Há um problema na conexão segura.';
      case DioExceptionType.cancel:
        return 'A operação foi cancelada.';
      case DioExceptionType.badResponse:
        return '$contexto O sistema respondeu de forma inesperada.';
      case DioExceptionType.unknown:
        final mensagem = erro.message?.toLowerCase() ?? '';

        if (mensagem.contains('failed host lookup') ||
            mensagem.contains('socket') ||
            mensagem.contains('network') ||
            mensagem.contains('connection refused')) {
          return '$contexto Verifique sua internet, VPN e tente novamente.';
        }

        return '$contexto Erro de conexão não identificado.';
    }
  }
}

class DiagnosticoPage extends StatefulWidget {
  final String nomeUsuario;
  final String nomeObra;
  final String apiBaseUrl;
  final int totalDiariosOffline;
  final String ultimaSincronizacao;
  final bool usandoDadosLocais;
  final int fotosSincronizadas;

  const DiagnosticoPage({
    super.key,
    required this.nomeUsuario,
    required this.nomeObra,
    required this.apiBaseUrl,
    required this.totalDiariosOffline,
    required this.ultimaSincronizacao,
    required this.usandoDadosLocais,
    required this.fotosSincronizadas,
  });

  @override
  State<DiagnosticoPage> createState() => _DiagnosticoPageState();
}

class _DiagnosticoPageState extends State<DiagnosticoPage> {
  final AuthService authService = AuthService();

  bool carregando = true;
  bool testandoApi = false;

  String tokenStatus = 'Verificando...';
  String resultadoApi = 'Não testado';
  String ultimoErro = '-';

  int fotosOffline = 0;
  int tamanhoCacheBytes = 0;

  @override
  void initState() {
    super.initState();
    carregarDiagnostico();
  }

  Future<void> carregarDiagnostico() async {
    setState(() {
      carregando = true;
    });

    final token = await authService.getToken();
    final totalFotos = await FotoCacheService.contarFotosSalvas();
    final tamanhoBytes = await FotoCacheService.calcularTamanhoCacheBytes();

    if (!mounted) {
      return;
    }

    setState(() {
      tokenStatus = token == null || token.isEmpty
          ? 'Não encontrado'
          : 'Salvo no dispositivo';
      fotosOffline = totalFotos;
      tamanhoCacheBytes = tamanhoBytes;
      carregando = false;
    });
  }

  String formatarTamanho(int bytes) {
    if (bytes <= 0) {
      return '0 MB';
    }

    final mb = bytes / (1024 * 1024);

    if (mb < 1) {
      final kb = bytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    }

    return '${mb.toStringAsFixed(1)} MB';
  }

  Future<void> testarConexaoApi() async {
    setState(() {
      testandoApi = true;
      resultadoApi = 'Testando...';
      ultimoErro = '-';
    });

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: widget.apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final response = await dio.get('/api/mobile/status');

      if (!mounted) {
        return;
      }

      setState(() {
        resultadoApi = 'Conectou com sucesso (${response.statusCode})';
        ultimoErro = '-';
      });
    } on DioException catch (e) {
      if (!mounted) {
        return;
      }

      final status = e.response?.statusCode;
      final mensagem = e.message ?? 'Erro de conexão';

      setState(() {
        resultadoApi = status == null
            ? 'Falhou ao conectar'
            : 'Falhou com status $status';
        ultimoErro = mensagem;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        resultadoApi = 'Falhou ao verificar';
        ultimoErro = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          testandoApi = false;
        });
      }
    }
  }

  String montarDiagnosticoTexto() {
    return [
      'DIAGNÓSTICO DO APP',
      'Usuário: ${widget.nomeUsuario}',
      'Obra: ${widget.nomeObra}',
      'Token: $tokenStatus',
      'Última sincronização: ${widget.ultimaSincronizacao}',
      'Status atual: ${widget.usandoDadosLocais ? 'dados salvos no aparelho' : 'dados atualizados'}',
      'Diários offline: ${widget.totalDiariosOffline}',
      'Fotos encontradas nos diários: ${widget.fotosSincronizadas}',
      'Fotos offline: $fotosOffline',
      'Tamanho cache fotos: ${formatarTamanho(tamanhoCacheBytes)}',
      'Verificação de conexão: $resultadoApi',
      'Último erro: $ultimoErro',
    ].join('\\n');
  }

  void copiarDiagnostico() {
    final texto = montarDiagnosticoTexto();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Diagnóstico pronto para copiar:\\n$texto',
          maxLines: 6,
          overflow: TextOverflow.ellipsis,
        ),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  Widget statusCard({
    required IconData icon,
    required String titulo,
    required String valor,
    Color color = const Color(0xFF1D4ED8),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  valor,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Text(
        titulo,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusAtual = widget.usandoDadosLocais
        ? 'Usando dados salvos no aparelho'
        : 'Dados atualizados';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Diagnóstico')),
      body: RefreshIndicator(
        onRefresh: carregarDiagnostico,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF111827), Color(0xFF334155)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.health_and_safety_outlined,
                    color: Colors.white,
                    size: 44,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Diagnóstico técnico',
                    style: TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Verifique conexão, sessão e dados offline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (carregando)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else ...[
              sectionTitle('Sessão'),
              statusCard(
                icon: Icons.person_outline,
                titulo: 'Usuário',
                valor: widget.nomeUsuario,
              ),
              statusCard(
                icon: Icons.business_outlined,
                titulo: 'Obra',
                valor: widget.nomeObra,
                color: const Color(0xFF0F766E),
              ),
              statusCard(
                icon: Icons.vpn_key_outlined,
                titulo: 'Token de acesso',
                valor: tokenStatus,
                color: tokenStatus == 'Salvo no dispositivo'
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF97316),
              ),
              sectionTitle('Atualização e dados offline'),
              statusCard(
                icon: Icons.sync,
                titulo: 'Última sincronização',
                valor: widget.ultimaSincronizacao,
              ),
              statusCard(
                icon: Icons.wifi_tethering,
                titulo: 'Status atual',
                valor: statusAtual,
                color: widget.usandoDadosLocais
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF10B981),
              ),
              statusCard(
                icon: Icons.description_outlined,
                titulo: 'Diários offline',
                valor: '${widget.totalDiariosOffline}',
                color: const Color(0xFF0F766E),
              ),
              statusCard(
                icon: Icons.collections_outlined,
                titulo: 'Fotos encontradas nos diários',
                valor: '${widget.fotosSincronizadas}',
                color: const Color(0xFF2563EB),
              ),
              statusCard(
                icon: Icons.photo_library_outlined,
                titulo: 'Fotos offline',
                valor:
                    '$fotosOffline foto(s) • ${formatarTamanho(tamanhoCacheBytes)}',
                color: const Color(0xFF7C3AED),
              ),
              statusCard(
                icon: Icons.cable_outlined,
                titulo: 'Resultado da verificação',
                valor: resultadoApi,
                color: resultadoApi.contains('sucesso')
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF97316),
              ),
              statusCard(
                icon: Icons.error_outline,
                titulo: 'Último erro',
                valor: ultimoErro,
                color: const Color(0xFFB91C1C),
              ),
            ],
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: testandoApi ? null : testarConexaoApi,
                icon: Icon(
                  testandoApi
                      ? Icons.hourglass_empty
                      : Icons.wifi_find_outlined,
                ),
                label: Text(
                  testandoApi ? 'Testando conexão...' : 'Verificar conexão',
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: copiarDiagnostico,
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copiar diagnóstico'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SincronizacaoPage extends StatefulWidget {
  final String nomeObra;
  final String apiBaseUrl;
  final int totalDiariosOffline;
  final String ultimaSincronizacao;
  final int limiteSincronizacao;
  final List<String> urlsFotosSincronizadas;
  final Future<void> Function(int limite) onAlterarLimiteSincronizacao;
  final Future<void> Function() onSincronizar;

  const SincronizacaoPage({
    super.key,
    required this.nomeObra,
    required this.apiBaseUrl,
    required this.totalDiariosOffline,
    required this.ultimaSincronizacao,
    required this.limiteSincronizacao,
    required this.urlsFotosSincronizadas,
    required this.onAlterarLimiteSincronizacao,
    required this.onSincronizar,
  });

  @override
  State<SincronizacaoPage> createState() => _SincronizacaoPageState();
}

class _SincronizacaoPageState extends State<SincronizacaoPage> {
  bool carregandoResumo = true;
  bool sincronizando = false;
  bool baixandoFotos = false;
  bool limpandoCache = false;

  late int limiteSelecionado;

  int fotosOffline = 0;
  int tamanhoCacheBytes = 0;
  int fotosBaixadas = 0;
  int totalFotosDownload = 0;
  String? mensagemDownloadFotos;

  final List<int> opcoesLimite = const [10, 50, 100, 300, 500];

  @override
  void initState() {
    super.initState();
    limiteSelecionado = widget.limiteSincronizacao;
    carregarResumo();
  }

  Future<void> carregarResumo() async {
    setState(() {
      carregandoResumo = true;
    });

    final totalFotos = await FotoCacheService.contarFotosSalvas();
    final tamanhoBytes = await FotoCacheService.calcularTamanhoCacheBytes();

    if (!mounted) {
      return;
    }

    setState(() {
      fotosOffline = totalFotos;
      tamanhoCacheBytes = tamanhoBytes;
      carregandoResumo = false;
    });
  }

  String formatarTamanho(int bytes) {
    if (bytes <= 0) {
      return '0 MB';
    }

    final mb = bytes / (1024 * 1024);

    if (mb < 1) {
      final kb = bytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    }

    return '${mb.toStringAsFixed(1)} MB';
  }

  Future<void> sincronizarAgora() async {
    setState(() {
      sincronizando = true;
    });

    try {
      await widget.onAlterarLimiteSincronizacao(limiteSelecionado);
      await widget.onSincronizar();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sincronização concluída com limite de $limiteSelecionado diário(s).',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível sincronizar agora. Verifique sua internet/VPN e tente novamente.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          sincronizando = false;
        });
        await carregarResumo();
      }
    }
  }

  Future<void> baixarTodasFotosSincronizadas() async {
    final urls = widget.urlsFotosSincronizadas;

    if (urls.isEmpty || baixandoFotos) {
      return;
    }

    setState(() {
      baixandoFotos = true;
      fotosBaixadas = 0;
      totalFotosDownload = urls.length;
      mensagemDownloadFotos = null;
    });

    int baixadasComSucesso = 0;

    for (final url in urls) {
      final arquivo = await FotoCacheService.obterOuBaixar(url);

      if (arquivo != null) {
        baixadasComSucesso++;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        fotosBaixadas++;
      });
    }

    if (!mounted) {
      return;
    }

    setState(() {
      baixandoFotos = false;
      mensagemDownloadFotos =
          '$baixadasComSucesso de ${urls.length} foto(s) preparadas para uso offline.';
    });

    await carregarResumo();
  }

  Future<void> limparCacheFotos() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Limpar fotos offline?'),
          content: const Text(
            'As fotos baixadas serão removidas do celular. Os diários continuam salvos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Limpar'),
            ),
          ],
        );
      },
    );

    if (confirmou != true) {
      return;
    }

    setState(() {
      limpandoCache = true;
    });

    await FotoCacheService.limparCache();

    if (!mounted) {
      return;
    }

    setState(() {
      limpandoCache = false;
    });

    await carregarResumo();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Fotos offline removidas.')));
  }

  Widget resumoCard({
    required IconData icon,
    required String titulo,
    required String valor,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  valor,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget etapaCard({
    required String numero,
    required String titulo,
    required String descricao,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFDBEAFE),
            child: Text(
              numero,
              style: const TextStyle(
                color: Color(0xFF1D4ED8),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: const Color(0xFF1D4ED8)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  descricao,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget painelSincronizacao() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.cloud_sync_outlined, color: Color(0xFF1D4ED8)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Plano de sincronização',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Antes de ir para campo, escolha a quantidade de diários, sincronize e baixe as fotos necessárias dentro de cada diário.',
              style: TextStyle(color: Color(0xFF64748B), height: 1.35),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              value: limiteSelecionado,
              decoration: InputDecoration(
                labelText: 'Diários recentes para manter offline',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
              ),
              items: opcoesLimite.map((limite) {
                return DropdownMenuItem<int>(
                  value: limite,
                  child: Text('Últimos $limite diário(s)'),
                );
              }).toList(),
              onChanged: sincronizando
                  ? null
                  : (valor) {
                      if (valor == null) {
                        return;
                      }

                      setState(() {
                        limiteSelecionado = valor;
                      });
                    },
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: sincronizando ? null : sincronizarAgora,
                icon: Icon(sincronizando ? Icons.hourglass_empty : Icons.sync),
                label: Text(
                  sincronizando
                      ? 'Sincronizando...'
                      : 'Atualizar últimos $limiteSelecionado',
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: limpandoCache ? null : limparCacheFotos,
                icon: Icon(
                  limpandoCache
                      ? Icons.hourglass_empty
                      : Icons.cleaning_services_outlined,
                ),
                label: Text(
                  limpandoCache ? 'Limpando...' : 'Limpar fotos offline',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Sincronização')),
      body: RefreshIndicator(
        onRefresh: carregarResumo,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.cloud_sync_outlined,
                    color: Colors.white,
                    size: 44,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Preparar dados para campo',
                    style: TextStyle(
                      color: Color(0xFFBFDBFE),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.nomeObra,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.ultimaSincronizacao,
                    style: const TextStyle(
                      color: Color(0xFFE0F2FE),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (carregandoResumo)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else ...[
              resumoCard(
                icon: Icons.description_outlined,
                titulo: 'Diários salvos offline',
                valor: '${widget.totalDiariosOffline}',
                color: const Color(0xFF0F766E),
              ),
              const SizedBox(height: 10),
              resumoCard(
                icon: Icons.photo_library_outlined,
                titulo: 'Fotos salvas offline',
                valor:
                    '$fotosOffline foto(s) • ${formatarTamanho(tamanhoCacheBytes)}',
                color: const Color(0xFF7C3AED),
              ),
              const SizedBox(height: 10),
              resumoCard(
                icon: Icons.collections_outlined,
                titulo: 'Fotos nos diários sincronizados',
                valor: '${widget.urlsFotosSincronizadas.length}',
                color: const Color(0xFF2563EB),
              ),
              const SizedBox(height: 10),
              resumoCard(
                icon: Icons.api_outlined,
                titulo: 'API atual',
                valor: widget.apiBaseUrl,
                color: const Color(0xFF475569),
              ),
            ],
            const SizedBox(height: 14),
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.download_for_offline_outlined,
                          color: Color(0xFF1D4ED8),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Baixar fotos sincronizadas',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.urlsFotosSincronizadas.isEmpty
                          ? 'Nenhuma foto encontrada nos diários sincronizados.'
                          : 'Foram encontradas ${widget.urlsFotosSincronizadas.length} foto(s) nos diários sincronizados. Baixe tudo antes de ir para campo.',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (baixandoFotos) ...[
                      LinearProgressIndicator(
                        value: totalFotosDownload == 0
                            ? 0
                            : fotosBaixadas / totalFotosDownload,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Baixando $fotosBaixadas de $totalFotosDownload foto(s)...',
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: widget.urlsFotosSincronizadas.isEmpty
                              ? null
                              : baixarTodasFotosSincronizadas,
                          icon: const Icon(Icons.download_for_offline_outlined),
                          label: Text(
                            widget.urlsFotosSincronizadas.isEmpty
                                ? 'Nenhuma foto para baixar'
                                : 'Baixar ${widget.urlsFotosSincronizadas.length} foto(s)',
                          ),
                        ),
                      ),
                      if (mensagemDownloadFotos != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          mensagemDownloadFotos!,
                          style: const TextStyle(
                            color: Color(0xFF166534),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            painelSincronizacao(),
            const SizedBox(height: 14),
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    etapaCard(
                      numero: '1',
                      titulo: 'Sincronize os diários',
                      descricao:
                          'Atualiza a lista de registros disponíveis no celular.',
                      icon: Icons.description_outlined,
                    ),
                    etapaCard(
                      numero: '2',
                      titulo: 'Abra os diários necessários',
                      descricao:
                          'Confira detalhes, serviços, materiais e equipamentos.',
                      icon: Icons.fact_check_outlined,
                    ),
                    etapaCard(
                      numero: '3',
                      titulo: 'Baixe as fotos',
                      descricao:
                          'Use o botão desta tela para baixar todas, ou baixe por diário na galeria.',
                      icon: Icons.download_for_offline_outlined,
                    ),
                    etapaCard(
                      numero: '4',
                      titulo: 'Teste sem internet',
                      descricao:
                          'Desligue a conexão e valide se os dados ficaram salvos.',
                      icon: Icons.signal_wifi_off_outlined,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfiguracoesPage extends StatefulWidget {
  final String nomeUsuario;
  final String nomeObra;
  final String apiBaseUrl;
  final int totalDiariosOffline;
  final bool usandoDadosLocais;
  final String ultimaSincronizacao;
  final int limiteSincronizacao;
  final List<String> urlsFotosSincronizadas;
  final Future<void> Function(int limite) onAlterarLimiteSincronizacao;
  final Future<void> Function() onSincronizar;
  final Future<void> Function() onSair;

  const ConfiguracoesPage({
    super.key,
    required this.nomeUsuario,
    required this.nomeObra,
    required this.apiBaseUrl,
    required this.totalDiariosOffline,
    required this.usandoDadosLocais,
    required this.ultimaSincronizacao,
    required this.limiteSincronizacao,
    required this.urlsFotosSincronizadas,
    required this.onAlterarLimiteSincronizacao,
    required this.onSincronizar,
    required this.onSair,
  });

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  bool carregando = true;
  bool sincronizando = false;
  bool limpandoCache = false;

  int fotosOffline = 0;
  int tamanhoCacheBytes = 0;
  late int limiteSelecionado;

  final List<int> opcoesLimiteSincronizacao = const [10, 50, 100, 300, 500];

  @override
  void initState() {
    super.initState();
    limiteSelecionado = widget.limiteSincronizacao;
    carregarResumo();
  }

  Future<void> carregarResumo() async {
    setState(() {
      carregando = true;
    });

    final totalFotos = await FotoCacheService.contarFotosSalvas();
    final tamanhoBytes = await FotoCacheService.calcularTamanhoCacheBytes();

    if (!mounted) {
      return;
    }

    setState(() {
      fotosOffline = totalFotos;
      tamanhoCacheBytes = tamanhoBytes;
      carregando = false;
    });
  }

  String formatarTamanho(int bytes) {
    if (bytes <= 0) {
      return '0 MB';
    }

    final mb = bytes / (1024 * 1024);

    if (mb < 1) {
      final kb = bytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    }

    return '${mb.toStringAsFixed(1)} MB';
  }

  Future<void> aplicarLimiteSincronizacao(int novoLimite) async {
    setState(() {
      limiteSelecionado = novoLimite;
      sincronizando = true;
    });

    try {
      await widget.onAlterarLimiteSincronizacao(novoLimite);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sincronizando últimos $novoLimite diário(s).')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível aplicar o novo limite.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          sincronizando = false;
        });
        await carregarResumo();
      }
    }
  }

  Future<void> sincronizarAgora() async {
    setState(() {
      sincronizando = true;
    });

    try {
      await widget.onSincronizar();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sincronização concluída.')));
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível sincronizar agora. Verifique sua internet/VPN e tente novamente.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          sincronizando = false;
        });
        await carregarResumo();
      }
    }
  }

  Future<void> confirmarLimpezaCache() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Limpar fotos offline?'),
          content: const Text(
            'Isso remove as imagens salvas no celular. Os diários continuam salvos. Você poderá baixar as fotos novamente quando estiver online.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Limpar'),
            ),
          ],
        );
      },
    );

    if (confirmou == true) {
      await limparCacheFotos();
    }
  }

  Future<void> limparCacheFotos() async {
    setState(() {
      limpandoCache = true;
    });

    await FotoCacheService.limparCache();

    if (!mounted) {
      return;
    }

    setState(() {
      limpandoCache = false;
    });

    await carregarResumo();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cache de fotos limpo.')));
  }

  Future<void> sairDoApp() async {
    await widget.onSair();
  }

  Widget infoCard({
    required IconData icon,
    required String titulo,
    required String valor,
    Color color = const Color(0xFF1D4ED8),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  valor,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget limiteSincronizacaoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune, color: Color(0xFF1D4ED8)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Quantidade de diários para atualizar',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Escolha quantos diários recentes o app deve manter disponíveis para consulta offline.',
            style: TextStyle(color: Color(0xFF64748B), height: 1.3),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: limiteSelecionado,
            decoration: InputDecoration(
              labelText: 'Quantidade de diários',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
            items: opcoesLimiteSincronizacao.map((limite) {
              return DropdownMenuItem<int>(
                value: limite,
                child: Text('Últimos $limite diário(s)'),
              );
            }).toList(),
            onChanged: sincronizando
                ? null
                : (valor) {
                    if (valor == null) {
                      return;
                    }

                    aplicarLimiteSincronizacao(valor);
                  },
          ),
        ],
      ),
    );
  }

  Future<void> abrirTelaDiagnostico() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DiagnosticoPage(
          nomeUsuario: widget.nomeUsuario,
          nomeObra: widget.nomeObra,
          apiBaseUrl: widget.apiBaseUrl,
          totalDiariosOffline: widget.totalDiariosOffline,
          ultimaSincronizacao: widget.ultimaSincronizacao,
          usandoDadosLocais: widget.usandoDadosLocais,
          fotosSincronizadas: widget.urlsFotosSincronizadas.length,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    await carregarResumo();
  }

  Future<void> abrirTelaSincronizacao() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SincronizacaoPage(
          nomeObra: widget.nomeObra,
          apiBaseUrl: widget.apiBaseUrl,
          totalDiariosOffline: widget.totalDiariosOffline,
          ultimaSincronizacao: widget.ultimaSincronizacao,
          limiteSincronizacao: limiteSelecionado,
          urlsFotosSincronizadas: widget.urlsFotosSincronizadas,
          onAlterarLimiteSincronizacao: widget.onAlterarLimiteSincronizacao,
          onSincronizar: widget.onSincronizar,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    await carregarResumo();
  }

  Widget actionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool danger = false,
    bool outlined = false,
  }) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Icon(icon), const SizedBox(width: 8), Text(label)],
    );

    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: onPressed,
          style: danger
              ? OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB91C1C),
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                )
              : null,
          child: child,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: danger
            ? FilledButton.styleFrom(backgroundColor: const Color(0xFFB91C1C))
            : null,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusLocal = widget.usandoDadosLocais
        ? 'Usando dados salvos no dispositivo'
        : 'Online / sincronizado com servidor';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Central do App')),
      body: RefreshIndicator(
        onRefresh: carregarResumo,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                    size: 42,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Configurações e controle',
                    style: TextStyle(
                      color: Color(0xFFBFDBFE),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.nomeUsuario,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.nomeObra,
                    style: const TextStyle(
                      color: Color(0xFFE0F2FE),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (carregando)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else ...[
              infoCard(
                icon: Icons.sync,
                titulo: 'Última sincronização',
                valor: widget.ultimaSincronizacao,
              ),
              infoCard(
                icon: Icons.description_outlined,
                titulo: 'Diários disponíveis offline',
                valor: '${widget.totalDiariosOffline}',
                color: const Color(0xFF0F766E),
              ),
              infoCard(
                icon: Icons.photo_library_outlined,
                titulo: 'Fotos salvas offline',
                valor:
                    '$fotosOffline foto(s) • ${formatarTamanho(tamanhoCacheBytes)}',
                color: const Color(0xFF7C3AED),
              ),
              infoCard(
                icon: Icons.collections_outlined,
                titulo: 'Fotos encontradas nos diários',
                valor: '${widget.urlsFotosSincronizadas.length}',
                color: const Color(0xFF2563EB),
              ),
              infoCard(
                icon: Icons.wifi_tethering,
                titulo: 'Status atual',
                valor: statusLocal,
                color: widget.usandoDadosLocais
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF10B981),
              ),
              limiteSincronizacaoCard(),
            ],
            const SizedBox(height: 6),
            actionButton(
              icon: Icons.cloud_sync_outlined,
              label: 'Abrir atualização de dados',
              onPressed: abrirTelaSincronizacao,
              outlined: true,
            ),
            const SizedBox(height: 10),
            actionButton(
              icon: Icons.health_and_safety_outlined,
              label: 'Abrir diagnóstico do app',
              onPressed: abrirTelaDiagnostico,
              outlined: true,
            ),
            const SizedBox(height: 10),
            actionButton(
              icon: sincronizando ? Icons.hourglass_empty : Icons.sync,
              label: sincronizando
                  ? 'Sincronizando...'
                  : 'Atualizar últimos $limiteSelecionado',
              onPressed: sincronizando ? null : sincronizarAgora,
            ),
            const SizedBox(height: 10),
            actionButton(
              icon: limpandoCache
                  ? Icons.hourglass_empty
                  : Icons.cleaning_services_outlined,
              label: limpandoCache ? 'Limpando...' : 'Limpar fotos offline',
              onPressed: limpandoCache ? null : confirmarLimpezaCache,
              outlined: true,
            ),
            const SizedBox(height: 10),
            actionButton(
              icon: Icons.logout,
              label: 'Sair da conta',
              onPressed: sairDoApp,
              danger: true,
              outlined: true,
            ),
            const SizedBox(height: 18),
            const Text(
              'Dica: antes de ir para campo, sincronize os diários e baixe as fotos necessárias ainda com internet.',
              style: TextStyle(color: Color(0xFF64748B), height: 1.35),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class FotoCacheService {
  FotoCacheService._();

  static final Dio _dio = Dio();

  static Future<Directory> _cacheDir() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${baseDir.path}/foto_cache_diarios');

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return dir;
  }

  static String _extensaoDaUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final last = uri.pathSegments.isEmpty ? '' : uri.pathSegments.last;
      final dotIndex = last.lastIndexOf('.');

      if (dotIndex >= 0 && dotIndex < last.length - 1) {
        final ext = last.substring(dotIndex).toLowerCase();

        if (ext.length <= 6) {
          return ext;
        }
      }
    } catch (_) {}

    return '.jpg';
  }

  static String _nomeArquivo(String url) {
    final hash = base64Url.encode(utf8.encode(url)).replaceAll('=', '');
    return '$hash${_extensaoDaUrl(url)}';
  }

  static Future<File> arquivoLocal(String url) async {
    final dir = await _cacheDir();
    return File('${dir.path}/${_nomeArquivo(url)}');
  }

  static Future<File?> obterOuBaixar(String url) async {
    if (url.trim().isEmpty) {
      return null;
    }

    final file = await arquivoLocal(url);

    if (await file.exists() && await file.length() > 0) {
      return file;
    }

    try {
      await _dio.download(
        url,
        file.path,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      if (await file.exists() && await file.length() > 0) {
        return file;
      }
    } catch (_) {
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
    }

    return null;
  }

  static Future<int> contarFotosSalvas() async {
    final dir = await _cacheDir();

    if (!await dir.exists()) {
      return 0;
    }

    final arquivos = await dir
        .list()
        .where((item) => item is File)
        .cast<File>()
        .toList();

    int total = 0;

    for (final arquivo in arquivos) {
      try {
        if (await arquivo.length() > 0) {
          total++;
        }
      } catch (_) {}
    }

    return total;
  }

  static Future<int> calcularTamanhoCacheBytes() async {
    final dir = await _cacheDir();

    if (!await dir.exists()) {
      return 0;
    }

    final arquivos = await dir
        .list()
        .where((item) => item is File)
        .cast<File>()
        .toList();

    int total = 0;

    for (final arquivo in arquivos) {
      try {
        total += await arquivo.length();
      } catch (_) {}
    }

    return total;
  }

  static Future<void> limparCache() async {
    final dir = await _cacheDir();

    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}

class FotoCacheImage extends StatefulWidget {
  final String url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color backgroundColor;
  final Color loadingColor;
  final bool errorDarkMode;
  final int? cacheWidth;
  final int? cacheHeight;

  const FotoCacheImage({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.backgroundColor = const Color(0xFFE2E8F0),
    this.loadingColor = const Color(0xFF1D4ED8),
    this.errorDarkMode = false,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  State<FotoCacheImage> createState() => _FotoCacheImageState();
}

class _FotoCacheImageState extends State<FotoCacheImage> {
  late Future<File?> arquivoFuture;

  @override
  void initState() {
    super.initState();
    arquivoFuture = FotoCacheService.obterOuBaixar(widget.url);
  }

  @override
  void didUpdateWidget(covariant FotoCacheImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.url != widget.url) {
      arquivoFuture = FotoCacheService.obterOuBaixar(widget.url);
    }
  }

  Widget _containerBase({required Widget child, Color? color}) {
    final content = Container(
      height: widget.height,
      width: widget.width,
      color: color ?? widget.backgroundColor,
      child: Center(child: child),
    );

    if (widget.borderRadius == null) {
      return content;
    }

    return ClipRRect(borderRadius: widget.borderRadius!, child: content);
  }

  Widget _erro() {
    final iconColor = widget.errorDarkMode
        ? Colors.white
        : const Color(0xFFEA580C);
    final textColor = widget.errorDarkMode
        ? Colors.white
        : const Color(0xFF9A3412);
    final bgColor = widget.errorDarkMode
        ? Colors.black
        : const Color(0xFFFFF7ED);

    return _containerBase(
      color: bgColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_not_supported_outlined, size: 42, color: iconColor),
          const SizedBox(height: 8),
          Text(
            'Imagem indisponível offline',
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _loading() {
    return _containerBase(
      child: CircularProgressIndicator(color: widget.loadingColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: arquivoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _loading();
        }

        final file = snapshot.data;

        if (file == null) {
          return _erro();
        }

        final image = Image.file(
          file,
          height: widget.height,
          width: widget.width,
          fit: widget.fit,
          cacheWidth: widget.cacheWidth,
          cacheHeight: widget.cacheHeight,
          filterQuality: FilterQuality.low,
        );

        if (widget.borderRadius == null) {
          return image;
        }

        return ClipRRect(borderRadius: widget.borderRadius!, child: image);
      },
    );
  }
}

class _SecaoCard extends StatelessWidget {
  final String titulo;
  final IconData icone;
  final List<Widget> children;

  const _SecaoCard({
    required this.titulo,
    required this.icone,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, color: const Color(0xFF1D4ED8)),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _LinhaInfo extends StatelessWidget {
  final String label;
  final String valor;

  const _LinhaInfo(this.label, this.valor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
