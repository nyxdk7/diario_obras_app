import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'core/api/api_client.dart';
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
      final data = erro.response?.data;

      if (data is Map && data['erro'] != null) {
        mostrarMensagem(data['erro'].toString());
      } else {
        mostrarMensagem('Não foi possível conectar à API.');
      }
    } catch (_) {
      mostrarMensagem('Erro inesperado ao fazer login.');
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

  List<Map<String, dynamic>> get diariosFiltrados {
    final termo = termoBusca.trim().toLowerCase();

    final lista = diarios
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    final filtradosPorStatus = lista.where((diario) {
      if (filtroStatus == 'TODOS') {
        return true;
      }

      final status = normalizarStatus(diario['status_aprovacao']);
      return status == filtroStatus;
    }).toList();

    if (termo.isEmpty) {
      return filtradosPorStatus;
    }

    return filtradosPorStatus.where((diario) {
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
      ].map((valor) => valor?.toString().toLowerCase() ?? '').join(' ');

      return conteudo.contains(termo);
    }).toList();
  }

  Future<void> carregarDiarios() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      ultimaSincronizacao = await authService.buscarUltimaSincronizacao();

      final locais = await authService.listarDiariosLocais(limite: 50);

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

      final resposta = await authService.sync(limite: 10);

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
      final data = e.response?.data;

      setState(() {
        erro = diarios.isEmpty
            ? data is Map && data['erro'] != null
                ? data['erro'].toString()
                : 'Sem conexão. Nenhum diário local encontrado.'
            : null;
        usandoDadosLocais = diarios.isNotEmpty;
        carregando = false;
      });
    } catch (_) {
      setState(() {
        erro = diarios.isEmpty ? 'Erro inesperado ao carregar diários.' : null;
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

  void selecionarFiltroStatus(String status) {
    setState(() {
      filtroStatus = status;
    });
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

  @override
  Widget build(BuildContext context) {
    final filtrados = diariosFiltrados;

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
            onPressed: sair,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
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
                      termoBusca.trim().isEmpty && filtroStatus == 'TODOS'
                          ? 'Últimos diários: ${diarios.length}'
                          : 'Resultados encontrados: ${filtrados.length} de ${diarios.length}',
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
            else if (diarios.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('Nenhum diário encontrado para esta obra.'),
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
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.description_outlined),
                    ),
                    title: Text(
                      texto(item['data_diario'], padrao: 'Sem data'),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Equipe: ${texto(item['equipe'])}'),
                          Text('Serviço: ${texto(primeiroServico(item))}'),
                          Text('Status: ${texto(item['status_aprovacao'])}'),
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
