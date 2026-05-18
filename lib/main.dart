import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'core/api/api_client.dart';
import 'core/database/app_database.dart';
import 'features/auth/auth_service.dart';

void main() {
  runApp(const DiarioObrasApp());
}

class DiarioObrasApp extends StatelessWidget {
  const DiarioObrasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diário de Obras',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D4ED8),
        ),
        useMaterial3: true,
      ),
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
    final sessao = await authService.getSessaoLocal();

    if (!mounted) return;

    if (sessao == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomePage(
          nomeUsuario: sessao['nomeUsuario'] ?? 'Engenheiro',
          nomeObra: sessao['nomeObra'] ?? 'Obra vinculada',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Center(
        child: CircularProgressIndicator(),
      ),
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
              nomeUsuario: usuario?['nome_completo']?.toString() ??
                  usuario?['username']?.toString() ??
                  'Engenheiro',
              nomeObra: obra?['nome']?.toString() ?? 'Obra vinculada',
            ),
          ),
        );
      } else {
        mostrarMensagem(resposta['erro']?.toString() ?? 'Erro ao fazer login.');
      }
    } on DioException catch (erro) {
      mostrarMensagem(
        AppErrorHandler.mensagemLogin(erro),
      );
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.engineering,
                      size: 56,
                      color: Color(0xFF1D4ED8),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Diário de Obras',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Consulta offline para engenheiros',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: usuarioController,
                      decoration: const InputDecoration(
                        labelText: 'Usuário',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: senhaController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => fazerLogin(),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
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
                            : const Icon(Icons.login),
                        label: Text(carregando ? 'Entrando...' : 'Entrar'),
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

  const HomePage({
    super.key,
    required this.nomeUsuario,
    required this.nomeObra,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authService = AuthService();
  final buscaController = TextEditingController();

  bool carregando = true;
  bool usandoDadosLocais = false;
  String? erro;
  String? ultimaSincronizacao;
  String termoBusca = '';
  String filtroStatus = 'TODOS';
  String filtroPeriodo = 'TODOS';
  String ordenacao = 'RECENTES';
  String? obraSelecionada;
  int limiteSincronizacao = 50;
  List<dynamic> diarios = [];

  @override
  void initState() {
    super.initState();
    carregarDiarios();
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
    return obraSelecionada != null && obraSelecionada!.trim().isNotEmpty;
  }

  List<Map<String, dynamic>> get diariosDaObraSelecionada {
    if (!obraFoiSelecionada) {
      return [];
    }

    return diariosBase.where((diario) {
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

      final status = normalizarStatus(diario['status_aprovacao']);
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
    final base = obraFoiSelecionada ? diariosDaObraSelecionada : <Map<String, dynamic>>[];

    final resumo = {
      'TODOS': base.length,
      'PENDENTE': 0,
      'APROVADO': 0,
      'DEVOLVIDO': 0,
    };

    for (final diario in base) {
      final status = normalizarStatus(diario['status_aprovacao']);

      if (resumo.containsKey(status)) {
        resumo[status] = resumo[status]! + 1;
      }
    }

    return resumo;
  }

  List<String> get obrasDisponiveis {
    final nomes = <String>{};

    for (final diario in diariosBase) {
      final nome = nomeObraDoDiario(diario);

      if (nome.trim().isNotEmpty && nome != 'Obra não informada') {
        nomes.add(nome);
      }
    }

    final lista = nomes.toList()..sort();
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

  String labelObraSelecionada(String obra) {
    return obra;
  }

  void selecionarObra(String obra) {
    setState(() {
      obraSelecionada = obra;
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

  Future<void> carregarDiarios() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      ultimaSincronizacao = await authService.buscarUltimaSincronizacao();

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

        setState(() {
          diarios = listaApi;
          usandoDadosLocais = false;
          ultimaSincronizacao = DateTime.now().toIso8601String();
          carregando = false;
          erro = null;
        });
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
          SnackBar(
            content: Text(AppErrorHandler.mensagemModoOffline(e)),
          ),
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

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );
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
          onSincronizar: carregarDiarios,
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
    if (!obraFoiSelecionada || obraSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma obra antes de criar um diário offline.'),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NovoDiarioOfflinePage(
          obraNome: obraSelecionada!,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> abrirPendentesOffline() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PendentesOfflinePage(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  void limparBusca() {
    buscaController.clear();

    setState(() {
      termoBusca = '';
    });
  }

  String normalizarStatus(dynamic valor) {
    final status = valor?.toString().trim().toUpperCase() ?? '';

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
            color: filtroStatus == status
                ? color.withOpacity(0.14)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: filtroStatus == status
                  ? color
                  : const Color(0xFFE2E8F0),
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
                color: color,
                size: 22,
              ),
              const SizedBox(height: 7),
              Text(
                valor.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF64748B),
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

  @override
  Widget build(BuildContext context) {
    final filtrados = diariosFiltrados;
    final obras = obrasDisponiveis;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Diário de Obras'),
        actions: [
          IconButton(
            onPressed: carregarDiarios,
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar',
          ),
          IconButton(
            onPressed: abrirConfiguracoes,
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configurações',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: carregarDiarios,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.nomeUsuario,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.nomeObra,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      !obraFoiSelecionada
                          ? 'Selecione uma obra para visualizar os registros'
                          : termoBusca.trim().isEmpty && filtroStatus == 'TODOS'
                              ? 'Diários desta obra: ${diariosDaObraSelecionada.length}'
                              : 'Resultados encontrados: ${filtrados.length} de ${diariosDaObraSelecionada.length}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: usandoDadosLocais
                            ? const Color(0xFFFFFBEB)
                            : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: usandoDadosLocais
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF10B981),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            usandoDadosLocais
                                ? 'Modo offline: usando dados salvos no dispositivo'
                                : 'Online: dados sincronizados com o servidor',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatarUltimaSincronizacao(),
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                          Icons.business_outlined,
                          color: Color(0xFF1D4ED8),
                        ),
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
                    DropdownButtonFormField<String>(
                      value: obraSelecionada != null &&
                              obras.contains(obraSelecionada)
                          ? obraSelecionada
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
                      items: obras.map((obra) {
                        return DropdownMenuItem<String>(
                          value: obra,
                          child: Text(
                            labelObraSelecionada(obra),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (valor) {
                        if (valor == null) {
                          return;
                        }

                        selecionarObra(valor);
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
                          Icon(
                            Icons.edit_document,
                            color: Color(0xFF1D4ED8),
                          ),
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
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          height: 1.3,
                        ),
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
                              icon: const Icon(Icons.drafts_outlined),
                              label: const Text('Pendentes'),
                            ),
                          ),
                        ],
                      ),
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
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'TODOS',
                    'PENDENTE',
                    'APROVADO',
                    'DEVOLVIDO',
                  ].map((status) {
                    final selecionado = filtroStatus == status;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: selecionado,
                        label: Text(labelFiltroStatus(status)),
                        avatar: Icon(
                          iconeFiltroStatus(status),
                          size: 18,
                        ),
                        onSelected: (_) => selecionarFiltroStatus(status),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'TODOS',
                    '7_DIAS',
                    '30_DIAS',
                    '90_DIAS',
                  ].map((periodo) {
                    final selecionado = filtroPeriodo == periodo;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: selecionado,
                        label: Text(labelFiltroPeriodo(periodo)),
                        avatar: Icon(
                          periodo == 'TODOS'
                              ? Icons.calendar_month_outlined
                              : Icons.date_range_outlined,
                          size: 18,
                        ),
                        onSelected: (_) => selecionarFiltroPeriodo(periodo),
                      ),
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
                      Text(
                        erro!,
                        textAlign: TextAlign.center,
                      ),
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
                  child: Text('Nenhum diário encontrado para a obra selecionada.'),
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
                          setState(() { obraSelecionada = null; });
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Limpar filtros'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...filtrados.map((item) {
                final status = normalizarStatus(item['status_aprovacao']);
                final statusColor = corStatusCard(status);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withOpacity(0.14),
                      child: Icon(
                        Icons.description_outlined,
                        color: statusColor,
                      ),
                    ),
                    title: Text(
                      texto(item['data_diario'], padrao: 'Sem data'),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Obra: ${nomeObraDoDiario(item)}'),
                          Text('Equipe: ${texto(item['equipe'])}'),
                          Text('Serviço: ${texto(primeiroServico(item))}'),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: statusColor.withOpacity(0.35),
                              ),
                            ),
                            child: Text(
                              texto(item['status_aprovacao'], padrao: status),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DiarioDetalhePage(diario: item),
                        ),
                      );
                    },
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class DiarioDetalhePage extends StatelessWidget {
  final Map<String, dynamic> diario;

  const DiarioDetalhePage({
    super.key,
    required this.diario,
  });

  String texto(dynamic valor, {String padrao = '-'}) {
    if (valor == null) return padrao;
    final str = valor.toString().trim();
    return str.isEmpty ? padrao : str;
  }

  String primeiroServico() {
    final servicos = diario['servicos_executados_lista'];

    if (servicos is List && servicos.isNotEmpty) {
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

  String normalizarStatus(dynamic valor) {
    final status = valor?.toString().trim().toUpperCase() ?? '';

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
      case 'PENDENTE':
        return Icons.hourglass_empty;
      default:
        return Icons.info_outline;
    }
  }

  Widget statusPill(String status) {
    final color = corStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconeStatus(status),
            size: 18,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget infoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color: const Color(0xFF475569),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget contadorCard({
    required IconData icon,
    required String titulo,
    required String valor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF1D4ED8),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget miniCard({
    required IconData icon,
    required String titulo,
    required List<String> linhas,
    Color accentColor = const Color(0xFF1D4ED8),
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 22,
            ),
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
                  ),
                ),
                const SizedBox(height: 6),
                ...linhas
                    .where((linha) => linha.trim().isNotEmpty)
                    .map(
                      (linha) => Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          linha,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 13,
                          ),
                        ),
                      ),
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
    final obra = diario['obra'] is Map ? diario['obra'] as Map : {};
    final maoObra = lista('mao_obra_direta_lista');
    final equipamentos = lista('maquinas_equipamentos_lista');
    final materiais = lista('materiais_recebidos_utilizados_lista');
    final servicos = lista('servicos_executados_lista');
    final fotos = lista('fotos');

    final status = normalizarStatus(diario['status_aprovacao']);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Diário #${texto(diario['id'])}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1D4ED8),
                ],
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
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.22),
                        ),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Registro diário',
                            style: TextStyle(
                              color: Color(0xFFBFDBFE),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            texto(diario['data_diario'], padrao: 'Sem data'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
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
                  texto(obra['nome'], padrao: 'Obra não informada'),
                  style: const TextStyle(
                    color: Color(0xFFE0F2FE),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    statusPill(status),
                    infoChip(
                      icon: Icons.cloud_outlined,
                      label: texto(
                        diario['clima'],
                        padrao: 'Clima não informado',
                      ),
                    ),
                    infoChip(
                      icon: Icons.groups_outlined,
                      label: 'Equipe: ${texto(diario['equipe'])}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              contadorCard(
                icon: Icons.build_circle_outlined,
                titulo: 'Serviços',
                valor: servicos.length.toString(),
              ),
              const SizedBox(width: 10),
              contadorCard(
                icon: Icons.precision_manufacturing_outlined,
                titulo: 'Equipamentos',
                valor: equipamentos.length.toString(),
              ),
              const SizedBox(width: 10),
              contadorCard(
                icon: Icons.inventory_2_outlined,
                titulo: 'Materiais',
                valor: materiais.length.toString(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SecaoCard(
            titulo: 'Resumo do diário',
            icone: Icons.dashboard_outlined,
            children: [
              _LinhaInfo('Serviço principal', primeiroServico()),
              _LinhaInfo('KM inicial', texto(diario['km_inicial'])),
              _LinhaInfo('KM final', texto(diario['km_final'])),
              _LinhaInfo(
                'Distância',
                texto(diario['distancia_total_formatada']),
              ),
              _LinhaInfo('Condição', texto(diario['condicao_operacao'])),
            ],
          ),
          const SizedBox(height: 12),
          _SecaoCard(
            titulo: 'Serviços executados',
            icone: Icons.build_circle_outlined,
            children: servicos.isEmpty
                ? [
                    const Text('Nenhum serviço informado.'),
                  ]
                : servicos.map((item) {
                    final servico = item is Map ? item : {};
                    return miniCard(
                      icon: Icons.construction,
                      titulo: texto(
                        servico['tipo_servico'] ?? servico['tipo'],
                        padrao: 'Serviço',
                      ),
                      linhas: [
                        'KM: ${texto(servico['km_inicial'])} até ${texto(servico['km_final'])}',
                        'Lado: ${texto(servico['lado'])}',
                        'Distância: ${texto(servico['distancia_formatada'])}',
                        'Observação: ${texto(servico['observacao'] ?? servico['observacoes'])}',
                      ],
                    );
                  }).toList(),
          ),
          const SizedBox(height: 12),
          _SecaoCard(
            titulo: 'Mão de obra direta',
            icone: Icons.groups,
            children: maoObra.isEmpty
                ? [
                    const Text('Nenhuma mão de obra informada.'),
                  ]
                : maoObra.map((item) {
                    final mao = item is Map ? item : {};
                    return miniCard(
                      icon: Icons.person_outline,
                      titulo: texto(mao['funcao'], padrao: 'Função'),
                      linhas: [
                        'Quantidade: ${texto(mao['quantidade'])}',
                      ],
                      accentColor: const Color(0xFF0F766E),
                    );
                  }).toList(),
          ),
          const SizedBox(height: 12),
          _SecaoCard(
            titulo: 'Equipamentos',
            icone: Icons.precision_manufacturing_outlined,
            children: equipamentos.isEmpty
                ? [
                    const Text('Nenhum equipamento informado.'),
                  ]
                : equipamentos.map((item) {
                    final eq = item is Map ? item : {};
                    return miniCard(
                      icon: Icons.precision_manufacturing_outlined,
                      titulo: texto(eq['equipamento'], padrao: 'Equipamento'),
                      linhas: [
                        'Código/Placa: ${texto(eq['codigo_placa'])}',
                        'Horímetro/KM: ${texto(eq['horimetro_quilometragem'])}',
                      ],
                      accentColor: const Color(0xFF7C3AED),
                    );
                  }).toList(),
          ),
          const SizedBox(height: 12),
          _SecaoCard(
            titulo: 'Materiais',
            icone: Icons.inventory_2_outlined,
            children: materiais.isEmpty
                ? [
                    const Text('Nenhum material informado.'),
                  ]
                : materiais.map((item) {
                    final mat = item is Map ? item : {};
                    return miniCard(
                      icon: Icons.inventory_2_outlined,
                      titulo: texto(mat['material'], padrao: 'Material'),
                      linhas: [
                        'Quantidade: ${texto(mat['quantidade'])} ${texto(mat['unidade'], padrao: '')}',
                        'Placa: ${texto(mat['placa'])}',
                        'Ticket: ${texto(mat['ticket'])}',
                        'Hora chegada: ${texto(mat['hora_chegada'])}',
                        'Observação: ${texto(mat['observacao'])}',
                      ],
                      accentColor: const Color(0xFFEA580C),
                    );
                  }).toList(),
          ),
          const SizedBox(height: 12),
          _SecaoCard(
            titulo: 'Ocorrências e comentários',
            icone: Icons.notes_outlined,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFFDE68A),
                  ),
                ),
                child: Text(
                  texto(
                    diario['comentarios_ocorrencias'] ??
                        diario['ocorrencias'] ??
                        diario['descricao'],
                    padrao: 'Sem ocorrências informadas.',
                  ),
                  style: const TextStyle(
                    color: Color(0xFF713F12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SecaoCard(
            titulo: 'Fotos',
            icone: Icons.photo_library_outlined,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(18),
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
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFC7D2FE),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.photo_library_outlined,
                        color: Color(0xFF3730A3),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${fotos.length} foto(s) vinculada(s) a este diário.',
                          style: const TextStyle(
                            color: Color(0xFF3730A3),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF3730A3),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Toque para abrir a galeria. Download/cache offline das imagens será adicionado depois.',
                style: TextStyle(color: Color(0xFF64748B)),
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
  static const int fotosPorPagina = 40;

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

    return {
      'arquivo': item?.toString() ?? '',
    };
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
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
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
                Icon(
                  Icons.offline_pin_outlined,
                  color: Color(0xFF1D4ED8),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Fotos offline',
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
              'Baixe as fotos deste diário enquanto estiver online para consultar depois sem internet.',
              style: TextStyle(
                color: Color(0xFF64748B),
                height: 1.3,
              ),
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
          ),
          Positioned(
            left: 10,
            top: 10,
            child: badgeStatusOffline(url),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.58),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fullscreen,
                    color: Colors.white,
                    size: 17,
                  ),
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
      appBar: AppBar(
        title: const Text('Galeria de Fotos'),
      ),
      body: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1E1B4B),
                  Color(0xFF4338CA),
                ],
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
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
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
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.white,
          size: 64,
        ),
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
          style: const TextStyle(
            color: Colors.white,
          ),
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
                onPressed:
                    indiceAtual >= widget.fotos.length - 1 ? null : irParaProximaFoto,
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
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                ),
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
  final String obraNome;
  final RascunhosDiario? rascunhoExistente;

  const NovoDiarioOfflinePage({
    super.key,
    required this.obraNome,
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

  final List<String> opcoesLado = const [
    'Direito',
    'Esquerdo',
    'Ambos',
  ];

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

  final List<String> opcoesUnidade = const [
    'm²',
    'm³',
    'ton',
    'un',
    'viagem',
  ];

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

  String textoJson(Map<String, dynamic> dados, String chave, {String padrao = ''}) {
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

      dataController.text = textoJson(
        map,
        'data_diario',
        padrao: rascunho.dataDiario ?? dataController.text,
      );
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
        padrao: textoJson(map, 'observacoes', padrao: rascunho.observacoes ?? ''),
      );

      climaSelecionado = textoJson(map, 'clima', padrao: 'Bom');
      climaManhaSelecionado = textoJson(map, 'clima_manha', padrao: climaSelecionado);
      climaTardeSelecionado = textoJson(map, 'clima_tarde', padrao: 'Bom');

      final acidenteTexto = textoJson(map, 'acidente').toLowerCase();
      houveAcidente = acidenteTexto == 'houve' ||
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
          listaMap(
            map['mao_obra_direta'] ?? map['mao_obra_direta_lista'],
          ),
        );

      maoObraIndireta
        ..clear()
        ..addAll(
          listaMap(
            map['mao_obra_indireta'] ?? map['mao_obra_indireta_lista'],
          ),
        );

      final compareceu = map['compareceu_campo'] ?? map['compareceu_campo_dict'];

      if (compareceu is Map) {
        for (final chave in compareceuCampo.keys) {
          final valor = compareceu[chave]?.toString();

          if (valor == 'Sim' || valor == 'Não') {
            compareceuCampo[chave] = valor!;
          }
        }
      }

      final sinalizacao = map['material_sinalizacao'] ?? map['material_sinalizacao_dict'];

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

  @override
  void initState() {
    super.initState();

    final agora = DateTime.now();
    final dia = agora.day.toString().padLeft(2, '0');
    final mes = agora.month.toString().padLeft(2, '0');
    final ano = agora.year.toString();

    dataController.text = '$ano-$mes-$dia';
    condicaoOperacaoController.text = 'Praticável';

    carregarRascunhoExistente();
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

    final totalPessoal = totalQuantidadeLista(maoObra) +
        totalQuantidadeLista(maoObraIndireta);
    final totalEquipamentos = equipamentos.length;

    final dados = {
      'obra_nome': widget.obraNome,
      'data_diario': dataController.text.trim(),
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

      'tipo_servico': servicos.isNotEmpty ? servicos.first['tipo_servico'] : null,
      'km_inicial': servicos.isNotEmpty ? servicos.first['km_inicial'] : null,
      'km_final': servicos.isNotEmpty ? servicos.first['km_final'] : null,

      'descricao': observacoesController.text.trim().isEmpty
          ? 'Diário DNIT preenchido pelo app offline'
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
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
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
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
        {'campo': 'km_inicial', 'label': 'KM inicial', 'tipo': 'text', 'placeholder': 'Ex: 234,430'},
        {'campo': 'km_final', 'label': 'KM final', 'tipo': 'text', 'placeholder': 'Ex: 235,100'},
        {'campo': 'lado', 'label': 'Lado', 'tipo': 'select', 'opcoes': ['Direito', 'Esquerdo', 'Ambos']},
        {'campo': 'observacao', 'label': 'Observações', 'tipo': 'textarea', 'placeholder': 'Observações do serviço executado'},
      ],
      'DRENAGEM': [
        {'campo': 'km_localizacao', 'label': 'KM de localização do dreno', 'tipo': 'text', 'placeholder': 'Ex: 234,430'},
        {'campo': 'observacao', 'label': 'Observações', 'tipo': 'textarea', 'placeholder': 'Observações do serviço executado'},
      ],
      'PALIATIVO / ENROCAMENTO DE PEDRAS': [
        {'campo': 'km_inicial', 'label': 'KM inicial', 'tipo': 'text', 'placeholder': 'Ex: 234,430'},
        {'campo': 'km_final', 'label': 'KM final', 'tipo': 'text', 'placeholder': 'Ex: 235,100'},
        {'campo': 'lado', 'label': 'Lado', 'tipo': 'select', 'opcoes': ['Direito', 'Esquerdo', 'Ambos']},
        {'campo': 'observacao', 'label': 'Observações', 'tipo': 'textarea', 'placeholder': 'Observações do serviço executado'},
      ],
      'REPARO PROFUNDO / TROCA DE SOLO': [
        {'campo': 'numero_remendos', 'label': 'Número de remendos', 'tipo': 'number', 'placeholder': 'Ex: 5'},
        {'campo': 'km_inicial', 'label': 'KM inicial', 'tipo': 'text', 'placeholder': 'Ex: 233,540'},
        {'campo': 'km_final', 'label': 'KM final', 'tipo': 'text', 'placeholder': 'Ex: 233,890'},
        {'campo': 'lado', 'label': 'Lado', 'tipo': 'select', 'opcoes': ['Direito', 'Esquerdo', 'Ambos']},
        {'campo': 'area_total_escavada_m2', 'label': 'Área total escavada em m²', 'tipo': 'number', 'placeholder': 'Ex: 120,50'},
        {'campo': 'volume_pedra_3_m3', 'label': 'Volume de Pedra nº3 usado em m³', 'tipo': 'number', 'placeholder': 'Ex: 35,00'},
        {'campo': 'volume_bgs_m3', 'label': 'Volume de BGS usado em m³', 'tipo': 'number', 'placeholder': 'Ex: 18,00'},
        {'campo': 'area_total_escavada_dreno_m2', 'label': 'Área total escavada no dreno em m²', 'tipo': 'number', 'placeholder': 'Ex: 20,00'},
        {'campo': 'volume_pedra_3_dreno_m3', 'label': 'Volume de Pedra nº3 no dreno em m³', 'tipo': 'number', 'placeholder': 'Ex: 8,00'},
        {'campo': 'observacao', 'label': 'Observações', 'tipo': 'textarea', 'placeholder': 'Observações do serviço executado'},
      ],
      'RECICLAGEM': [
        {'campo': 'km_inicial', 'label': 'KM inicial', 'tipo': 'text', 'placeholder': 'Ex: 234,430'},
        {'campo': 'km_final', 'label': 'KM final', 'tipo': 'text', 'placeholder': 'Ex: 235,100'},
        {'campo': 'lado', 'label': 'Lado', 'tipo': 'select', 'opcoes': ['Direito', 'Esquerdo', 'Ambos']},
        {'campo': 'largura_m', 'label': 'Largura em m', 'tipo': 'number', 'placeholder': 'Ex: 3,50'},
        {'campo': 'observacao', 'label': 'Observações', 'tipo': 'textarea', 'placeholder': 'Observações do serviço executado'},
      ],
      'CORREÇÃO DE DEFEITOS COM CBUQ': [
        {'campo': 'km_inicial', 'label': 'KM inicial', 'tipo': 'text', 'placeholder': 'Ex: 234,430'},
        {'campo': 'km_final', 'label': 'KM final', 'tipo': 'text', 'placeholder': 'Ex: 235,100'},
        {'campo': 'lado', 'label': 'Lado', 'tipo': 'select', 'opcoes': ['Direito', 'Esquerdo', 'Ambos']},
        {'campo': 'observacao', 'label': 'Observações', 'tipo': 'textarea', 'placeholder': 'Observações do serviço executado'},
      ],
      'OUTROS': [
        {'campo': 'descricao_livre', 'label': 'Descrição do serviço', 'tipo': 'textarea', 'placeholder': 'Descreva o serviço executado'},
        {'campo': 'observacao', 'label': 'Observações', 'tipo': 'textarea', 'placeholder': 'Observações do serviço executado'},
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
              return DropdownMenuItem(
                value: opcao,
                child: Text(opcao),
              );
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
                            child: Text(
                              item,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                            ),
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
                    final item = <String, dynamic>{
                      'tipo_servico': tipo,
                    };

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
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (valor) {
                        if (valor == null) return;
                        setDialogState(() => material = valor);
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
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: unidade,
                      decoration: const InputDecoration(
                        labelText: 'Unidade',
                        border: OutlineInputBorder(),
                      ),
                      items: opcoesUnidade.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
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
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (valor) {
                        if (valor == null) return;
                        setDialogState(() => equipamento = valor);
                      },
                    ),
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
                    Navigator.of(context).pop({
                      'equipamento': equipamento,
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
                          child: Text(
                            item,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                    Navigator.of(context).pop({
                      'funcao': funcao,
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
    final pasta = Directory('${pastaBase.path}${Platform.pathSeparator}rascunhos_fotos');

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
      final fotos = await imagePicker.pickMultiImage(
        imageQuality: 82,
      );

      if (fotos.isEmpty) {
        return;
      }

      for (final foto in fotos) {
        final salva = await salvarArquivoFoto(foto);
        fotosOffline.add(salva);
      }

      setState(() {});
    } catch (_) {
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
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon == null ? null : Icon(icon),
          isDense: false,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFFCBD5E1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFF1D4ED8),
              width: 1.4,
            ),
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
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 14),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Icon(
          icon,
          color: const Color(0xFF1D4ED8),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
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
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              vazio,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          ...itens.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFDBEAFE),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitulo(item),
                          style: const TextStyle(
                            color: Color(0xFF64748B),
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
                  ),
                ],
              ),
            );
          }),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: adicionar,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar'),
          ),
        ),
      ],
    );
  }

  Widget seletorCompareceuCampo({
    required String chave,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: compareceuCampo[chave],
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: const [
          DropdownMenuItem(value: 'Sim', child: Text('Sim')),
          DropdownMenuItem(value: 'Não', child: Text('Não')),
        ],
        onChanged: (valor) {
          if (valor == null) return;
          setState(() {
            compareceuCampo[chave] = valor;
          });
        },
      ),
    );
  }

  Widget cardFotoOffline(int index, Map<String, dynamic> foto) {
    final caminho = foto['path']?.toString() ?? '';
    final nome = foto['nome']?.toString() ?? 'Foto ${index + 1}';
    final arquivo = File(caminho);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (arquivo.existsSync())
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.file(
                arquivo,
                width: double.infinity,
                height: 170,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 110,
              width: double.infinity,
              alignment: Alignment.center,
              child: const Icon(
                Icons.broken_image_outlined,
                size: 42,
                color: Color(0xFF94A3B8),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFDBEAFE),
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
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => removerFotoOffline(index),
                  icon: const Icon(Icons.delete_outline),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.rascunhoExistente == null
              ? 'Novo diário offline'
              : 'Editar pendente',
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1D4ED8),
                  ],
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
                    Icons.edit_document,
                    color: Colors.white,
                    size: 42,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.rascunhoExistente == null
                        ? 'Diário pendente'
                        : 'Editando diário pendente',
                    style: TextStyle(
                      color: Color(0xFFBFDBFE),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.obraNome,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Abra cada seção conforme for preenchendo. Se estiver offline, o diário fica pendente de envio.',
                    style: TextStyle(
                      color: Color(0xFFE0F2FE),
                      height: 1.3,
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
                campoTexto(
                  controller: dataController,
                  label: 'Data do diário',
                  hint: 'AAAA-MM-DD',
                  icon: Icons.calendar_month_outlined,
                  validator: obrigatorio,
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
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
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
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
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
                    value: opcoesCondicaoOperacao.contains(
                            condicaoOperacaoController.text)
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
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
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
                  titulo: (item) => item['tipo_servico']?.toString() ?? 'Serviço',
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
                  subtitulo: (item) => 'Quantidade: ${item['quantidade'] ?? '-'}',
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
                  subtitulo: (item) => 'Quantidade: ${item['quantidade'] ?? '-'}',
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
                  titulo: (item) => item['equipamento']?.toString() ?? 'Equipamento',
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
                    final temperatura = item['temperatura_cbuq']?.toString() ?? '';

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
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFBFDBFE),
                    ),
                  ),
                  child: const Text(
                    'As fotos ficam salvas no dispositivo junto com o rascunho. O envio para o Flask entra na etapa de sincronização.',
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
                if (fotosOffline.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                      ),
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
                else
                  ...fotosOffline.asMap().entries.map(
                        (entry) => cardFotoOffline(
                          entry.key,
                          entry.value,
                        ),
                      ),
              ],
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
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
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
            SizedBox(
              height: 54,
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
  List<RascunhosDiario> rascunhos = [];

  @override
  void initState() {
    super.initState();
    carregarPendentes();
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
    });
  }

  Future<void> abrirEdicaoRascunho(RascunhosDiario rascunho) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NovoDiarioOfflinePage(
          obraNome: rascunho.obraNome,
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
      await authService.enviarRascunhoDiario(item);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> enviarTodosPendentes() async {
    if (rascunhos.isEmpty || enviandoTodos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum diário pendente para enviar.'),
        ),
      );
      return;
    }

    setState(() {
      enviandoTodos = true;
      enviandoIds
        ..clear()
        ..addAll(rascunhos.map((item) => item.id));
    });

    int enviados = 0;
    int falhas = 0;

    for (final item in List<RascunhosDiario>.from(rascunhos)) {
      final ok = await enviarPendenteSilencioso(item);

      if (ok) {
        enviados++;
      } else {
        falhas++;
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
    });

    try {
      await authService.enviarRascunhoDiario(item);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Diário enviado com sucesso.'),
        ),
      );

      await carregarPendentes();
    } catch (erro) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagemErroEnvio(erro)),
        ),
      );
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
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmou != true) {
      return;
    }

    await authService.excluirRascunhoDiario(rascunho.id);
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

  Widget cardRascunho(RascunhosDiario item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => abrirEdicaoRascunho(item),
        child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFDBEAFE),
                  child: Icon(
                    Icons.edit_document,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.obraNome,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: enviandoIds.contains(item.id)
                      ? null
                      : () => enviarPendente(item),
                  icon: Icon(
                    enviandoIds.contains(item.id)
                        ? Icons.hourglass_empty
                        : Icons.cloud_upload_outlined,
                  ),
                  tooltip: 'Enviar',
                ),
                IconButton(
                  onPressed: () => abrirEdicaoRascunho(item),
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                ),
                IconButton(
                  onPressed: () => excluirRascunho(item),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Excluir',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Data: ${item.dataDiario ?? '-'}'),
            Text('Equipe: ${item.equipe ?? '-'}'),
            Text('Serviço: ${item.tipoServico ?? '-'}'),
            Text('Clima: ${item.clima ?? '-'}'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color(0xFFFDE68A),
                ),
              ),
              child: const Text(
                'Pendente de envio',
                style: TextStyle(
                  color: Color(0xFF92400E),
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Atualizado em ${formatarData(item.atualizadoEm)}',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Pendentes offline'),
      ),
      body: RefreshIndicator(
        onRefresh: carregarPendentes,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF78350F),
                    Color(0xFFF97316),
                  ],
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
                    Icons.drafts_outlined,
                    color: Colors.white,
                    size: 42,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Diários pendentes',
                    style: TextStyle(
                      color: Color(0xFFFFEDD5),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${rascunhos.length} diário(s) pendente(s)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Estes diários ficam aguardando conexão para serem enviados ao sistema.',
                    style: TextStyle(
                      color: Color(0xFFFFF7ED),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: rascunhos.isEmpty || enviandoTodos
                    ? null
                    : enviarTodosPendentes,
                icon: Icon(
                  enviandoTodos
                      ? Icons.hourglass_empty
                      : Icons.cloud_upload_outlined,
                ),
                label: Text(
                  enviandoTodos ? 'Enviando...' : 'Enviar pendentes',
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (carregando)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (rascunhos.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    'Nenhum diário pendente de envio.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
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
      return 'A API foi encontrada, mas a rota de login não existe. Verifique a versão do servidor.';
    }

    if (statusCode != null && statusCode >= 500) {
      return 'O servidor respondeu com erro. Tente novamente em alguns instantes.';
    }

    return _mensagemConexao(
      erro,
      contexto: 'Não foi possível conectar à API para fazer login.',
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
      return 'A rota de sincronização não foi encontrada na API. Verifique se o servidor está atualizado.';
    }

    if (statusCode != null && statusCode >= 500) {
      return 'O servidor está com instabilidade. Tente sincronizar novamente em alguns instantes.';
    }

    return _mensagemConexao(
      erro,
      contexto: 'Não foi possível sincronizar os diários.',
    );
  }

  static String mensagemModoOffline(DioException erro) {
    final base = _mensagemConexao(
      erro,
      contexto: 'Sem conexão com a API.',
    );

    return '$base Usando os dados já salvos no dispositivo.';
  }

  static String _mensagemConexao(
    DioException erro, {
    required String contexto,
  }) {
    switch (erro.type) {
      case DioExceptionType.connectionTimeout:
        return '$contexto A conexão demorou demais. Verifique a VPN, sinal de internet ou se o servidor está acessível.';
      case DioExceptionType.sendTimeout:
        return '$contexto O envio demorou demais. Tente novamente.';
      case DioExceptionType.receiveTimeout:
        return '$contexto O servidor demorou para responder. Tente novamente.';
      case DioExceptionType.connectionError:
        return '$contexto Verifique se o celular está com internet, se a VPN está conectada e se a API está acessível.';
      case DioExceptionType.badCertificate:
        return '$contexto Há um problema no certificado de segurança do servidor.';
      case DioExceptionType.cancel:
        return 'A operação foi cancelada.';
      case DioExceptionType.badResponse:
        return '$contexto O servidor respondeu de forma inesperada.';
      case DioExceptionType.unknown:
        final mensagem = erro.message?.toLowerCase() ?? '';

        if (mensagem.contains('failed host lookup') ||
            mensagem.contains('socket') ||
            mensagem.contains('network') ||
            mensagem.contains('connection refused')) {
          return '$contexto Verifique sua internet, VPN e endereço da API.';
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
      tokenStatus = token == null || token.isEmpty ? 'Não encontrado' : 'Salvo no dispositivo';
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
        resultadoApi = 'Falhou ao testar';
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
      'API: ${widget.apiBaseUrl}',
      'Token: $tokenStatus',
      'Última sincronização: ${widget.ultimaSincronizacao}',
      'Status atual: ${widget.usandoDadosLocais ? 'offline/local' : 'online/sincronizado'}',
      'Diários offline: ${widget.totalDiariosOffline}',
      'Fotos encontradas nos diários: ${widget.fotosSincronizadas}',
      'Fotos offline: $fotosOffline',
      'Tamanho cache fotos: ${formatarTamanho(tamanhoCacheBytes)}',
      'Teste API: $resultadoApi',
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
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
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
            child: Icon(
              icon,
              color: color,
            ),
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
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 10,
      ),
      child: Text(
        titulo,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusAtual = widget.usandoDadosLocais
        ? 'Usando dados locais/offline'
        : 'Online/sincronizado';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Diagnóstico'),
      ),
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
                  colors: [
                    Color(0xFF111827),
                    Color(0xFF334155),
                  ],
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
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
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
              sectionTitle('Sincronização e offline'),
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
                valor: '$fotosOffline foto(s) • ${formatarTamanho(tamanhoCacheBytes)}',
                color: const Color(0xFF7C3AED),
              ),
              sectionTitle('API'),
              statusCard(
                icon: Icons.api_outlined,
                titulo: 'Base URL',
                valor: widget.apiBaseUrl,
                color: const Color(0xFF475569),
              ),
              statusCard(
                icon: Icons.cable_outlined,
                titulo: 'Resultado do teste',
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
                  testandoApi ? Icons.hourglass_empty : Icons.wifi_find_outlined,
                ),
                label: Text(
                  testandoApi ? 'Testando conexão...' : 'Testar conexão com API',
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

  final List<int> opcoesLimite = const [
    10,
    50,
    100,
    300,
    500,
  ];

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
          content: Text('Sincronização concluída com limite de $limiteSelecionado diário(s).'),
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fotos offline removidas.'),
      ),
    );
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
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
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
            child: Icon(
              icon,
              color: color,
            ),
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
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
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
          Icon(
            icon,
            color: const Color(0xFF1D4ED8),
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
                  ),
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
                Icon(
                  Icons.cloud_sync_outlined,
                  color: Color(0xFF1D4ED8),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Plano de sincronização',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Antes de ir para campo, escolha a quantidade de diários, sincronize e baixe as fotos necessárias dentro de cada diário.',
              style: TextStyle(
                color: Color(0xFF64748B),
                height: 1.35,
              ),
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
                icon: Icon(
                  sincronizando ? Icons.hourglass_empty : Icons.sync,
                ),
                label: Text(
                  sincronizando
                      ? 'Sincronizando...'
                      : 'Sincronizar últimos $limiteSelecionado',
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
                  limpandoCache ? Icons.hourglass_empty : Icons.cleaning_services_outlined,
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
      appBar: AppBar(
        title: const Text('Sincronização'),
      ),
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
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF2563EB),
                  ],
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
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
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
                valor: '$fotosOffline foto(s) • ${formatarTamanho(tamanhoCacheBytes)}',
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
                      descricao: 'Atualiza a lista de registros disponíveis no celular.',
                      icon: Icons.description_outlined,
                    ),
                    etapaCard(
                      numero: '2',
                      titulo: 'Abra os diários necessários',
                      descricao: 'Confira detalhes, serviços, materiais e equipamentos.',
                      icon: Icons.fact_check_outlined,
                    ),
                    etapaCard(
                      numero: '3',
                      titulo: 'Baixe as fotos',
                      descricao: 'Use o botão desta tela para baixar todas, ou baixe por diário na galeria.',
                      icon: Icons.download_for_offline_outlined,
                    ),
                    etapaCard(
                      numero: '4',
                      titulo: 'Teste sem internet',
                      descricao: 'Desligue a conexão e valide se os dados ficaram salvos.',
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

  final List<int> opcoesLimiteSincronizacao = const [
    10,
    50,
    100,
    300,
    500,
  ];

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
        SnackBar(
          content: Text('Sincronizando últimos $novoLimite diário(s).'),
        ),
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sincronização concluída.'),
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache de fotos limpo.'),
      ),
    );
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
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
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
            child: Icon(
              icon,
              color: color,
            ),
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
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
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
              Icon(
                Icons.tune,
                color: Color(0xFF1D4ED8),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Quantidade de diários para sincronizar',
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
            'Escolha quantos diários recentes o app deve buscar e manter disponíveis offline.',
            style: TextStyle(
              color: Color(0xFF64748B),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: limiteSelecionado,
            decoration: InputDecoration(
              labelText: 'Limite de sincronização',
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
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(label),
      ],
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
            ? FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB91C1C),
              )
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
      appBar: AppBar(
        title: const Text('Central do App'),
      ),
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
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1D4ED8),
                  ],
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
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
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
                valor: '$fotosOffline foto(s) • ${formatarTamanho(tamanhoCacheBytes)}',
                color: const Color(0xFF7C3AED),
              ),
              infoCard(
                icon: Icons.collections_outlined,
                titulo: 'Fotos encontradas nos diários sincronizados',
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
              infoCard(
                icon: Icons.api_outlined,
                titulo: 'API configurada',
                valor: widget.apiBaseUrl,
                color: const Color(0xFF475569),
              ),
              limiteSincronizacaoCard(),
            ],
            const SizedBox(height: 6),
            actionButton(
              icon: Icons.cloud_sync_outlined,
              label: 'Abrir tela de sincronização',
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
              label: sincronizando ? 'Sincronizando...' : 'Sincronizar últimos $limiteSelecionado',
              onPressed: sincronizando ? null : sincronizarAgora,
            ),
            const SizedBox(height: 10),
            actionButton(
              icon: limpandoCache ? Icons.hourglass_empty : Icons.cleaning_services_outlined,
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
              style: TextStyle(
                color: Color(0xFF64748B),
                height: 1.35,
              ),
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

    return ClipRRect(
      borderRadius: widget.borderRadius!,
      child: content,
    );
  }

  Widget _erro() {
    final iconColor = widget.errorDarkMode ? Colors.white : const Color(0xFFEA580C);
    final textColor = widget.errorDarkMode ? Colors.white : const Color(0xFF9A3412);
    final bgColor = widget.errorDarkMode ? Colors.black : const Color(0xFFFFF7ED);

    return _containerBase(
      color: bgColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 42,
            color: iconColor,
          ),
          const SizedBox(height: 8),
          Text(
            'Imagem indisponível offline',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loading() {
    return _containerBase(
      child: CircularProgressIndicator(
        color: widget.loadingColor,
      ),
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
        );

        if (widget.borderRadius == null) {
          return image;
        }

        return ClipRRect(
          borderRadius: widget.borderRadius!,
          child: image,
        );
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
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
