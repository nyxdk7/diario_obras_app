import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

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

  bool carregando = true;
  bool usandoDadosLocais = false;
  String? erro;
  String? ultimaSincronizacao;
  List<dynamic> diarios = [];

  @override
  void initState() {
    super.initState();
    carregarDiarios();
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
        erro = diarios.isEmpty
            ? 'Erro inesperado ao carregar diários.'
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

      return 'Última sincronização: $dia/$mes/$ano às $hora:$min';
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
                      'Últimos diários: ${diarios.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
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
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
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
            else
              ...diarios.map((diario) {
                final item = diario as Map<String, dynamic>;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.description_outlined),
                    ),
                    title: Text(
                      texto(item['data_diario'], padrao: 'Sem data'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
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

  @override
  Widget build(BuildContext context) {
    final obra = diario['obra'] is Map ? diario['obra'] as Map : {};
    final maoObra = lista('mao_obra_direta_lista');
    final equipamentos = lista('maquinas_equipamentos_lista');
    final materiais = lista('materiais_recebidos_utilizados_lista');
    final servicos = lista('servicos_executados_lista');
    final fotos = lista('fotos');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Diário #${texto(diario['id'])}'),
      ),
      body: ListView(
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
                    texto(diario['data_diario'], padrao: 'Sem data'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    texto(obra['nome']),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.verified_outlined, size: 18),
                        label: Text(texto(diario['status_aprovacao'])),
                      ),
                      Chip(
                        avatar: const Icon(Icons.cloud_outlined, size: 18),
                        label: Text(texto(diario['clima'])),
                      ),
                      Chip(
                        avatar: const Icon(Icons.groups_outlined, size: 18),
                        label: Text('Equipe: ${texto(diario['equipe'])}'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SecaoCard(
            titulo: 'Serviço principal',
            icone: Icons.construction,
            children: [
              _LinhaInfo('Serviço', primeiroServico()),
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
                    return _MiniCard(
                      titulo: texto(
                        servico['tipo_servico'] ?? servico['tipo'],
                        padrao: 'Serviço',
                      ),
                      linhas: [
                        'KM: ${texto(servico['km_inicial'])} até ${texto(servico['km_final'])}',
                        'Lado: ${texto(servico['lado'])}',
                        'Distância: ${texto(servico['distancia_formatada'])}',
                        'Obs: ${texto(servico['observacao'] ?? servico['observacoes'])}',
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
                    return _LinhaInfo(
                      texto(mao['funcao'], padrao: 'Função'),
                      texto(mao['quantidade']),
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
                    return _MiniCard(
                      titulo: texto(eq['equipamento'], padrao: 'Equipamento'),
                      linhas: [
                        'Código/Placa: ${texto(eq['codigo_placa'])}',
                        'Horímetro/KM: ${texto(eq['horimetro_quilometragem'])}',
                        'Quantidade: ${texto(eq['quantidade'])}',
                      ],
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
                    return _MiniCard(
                      titulo: texto(mat['material'], padrao: 'Material'),
                      linhas: [
                        'Quantidade: ${texto(mat['quantidade'])} ${texto(mat['unidade'], padrao: '')}',
                        'Placa: ${texto(mat['placa'])}',
                        'Ticket: ${texto(mat['ticket'])}',
                        'Hora chegada: ${texto(mat['hora_chegada'])}',
                        'Obs: ${texto(mat['observacao'])}',
                      ],
                    );
                  }).toList(),
          ),
          const SizedBox(height: 12),
          _SecaoCard(
            titulo: 'Ocorrências e comentários',
            icone: Icons.notes_outlined,
            children: [
              Text(
                texto(
                  diario['comentarios_ocorrencias'] ??
                      diario['ocorrencias'] ??
                      diario['descricao'],
                  padrao: 'Sem ocorrências informadas.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SecaoCard(
            titulo: 'Fotos',
            icone: Icons.photo_library_outlined,
            children: [
              Text('${fotos.length} foto(s) vinculada(s) a este diário.'),
              const SizedBox(height: 6),
              const Text(
                'A visualização/download das fotos será adicionada na próxima etapa.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ],
          ),
        ],
      ),
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

class _MiniCard extends StatelessWidget {
  final String titulo;
  final List<String> linhas;

  const _MiniCard({
    required this.titulo,
    required this.linhas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
          Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          ...linhas.map(
            (linha) => Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                linha,
                style: const TextStyle(
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}