from pathlib import Path

MAIN = Path("lib/main.dart")
API = Path("lib/core/api/api_client.dart")
AUTH = Path("lib/features/auth/auth_service.dart")

for arquivo in [MAIN, API, AUTH]:
    if not arquivo.exists():
        raise SystemExit(f"ERRO: {arquivo} não encontrado. Rode este script na raiz do projeto Flutter.")

api = API.read_text(encoding="utf-8")
auth = AUTH.read_text(encoding="utf-8")
main = MAIN.read_text(encoding="utf-8")

if "Future<Response> pendenciasMobile" not in api:
    api_insert = """

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
"""
    pos = api.rfind("\n}")
    if pos == -1:
        raise SystemExit("ERRO: não encontrei fim da classe ApiClient.")
    api = api[:pos] + api_insert + api[pos:]
    API.write_text(api, encoding="utf-8")
    print("OK: pendenciasMobile adicionado ao api_client.dart")
else:
    print("api_client.dart já possui pendenciasMobile.")

if "Future<Map<String, dynamic>?> listarPendenciasMobile" not in auth:
    auth_insert = """

  Future<Map<String, dynamic>?> listarPendenciasMobile({
    int limite = 100,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    final response = await apiClient.pendenciasMobile(
      token,
      limite: limite,
    );

    return Map<String, dynamic>.from(response.data);
  }
"""
    pos = auth.rfind("\n}")
    if pos == -1:
        raise SystemExit("ERRO: não encontrei fim da classe AuthService.")
    auth = auth[:pos] + auth_insert + auth[pos:]
    AUTH.write_text(auth, encoding="utf-8")
    print("OK: listarPendenciasMobile adicionado ao auth_service.dart")
else:
    print("auth_service.dart já possui listarPendenciasMobile.")

if "Future<void> abrirCentralPendencias()" not in main:
    marcador = """  Future<void> abrirPendentesOffline() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PendentesOfflinePage(),
      ),
    );

    if (!mounted) {
      return;
    }

    await carregarDiarios(tentarEnviarPendentes: true);
  }
"""
    metodo = marcador + """

  Future<void> abrirCentralPendencias() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CentralPendenciasPage(),
      ),
    );

    if (!mounted) {
      return;
    }

    await carregarDiarios(tentarEnviarPendentes: true);
  }
"""
    if marcador not in main:
        raise SystemExit("ERRO: não encontrei o método abrirPendentesOffline no main.dart.")
    main = main.replace(marcador, metodo, 1)
    print("OK: método abrirCentralPendencias adicionado.")
else:
    print("main.dart já possui abrirCentralPendencias.")

if "tooltip: 'Pendências da obra'" not in main:
    marcador = """        actions: [
          IconButton.filledTonal(
            onPressed: carregarDiarios,
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar',
          ),
"""
    troca = """        actions: [
          IconButton.filledTonal(
            onPressed: abrirCentralPendencias,
            icon: const Icon(Icons.rule_folder_outlined),
            tooltip: 'Pendências da obra',
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: carregarDiarios,
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar',
          ),
"""
    if marcador not in main:
        raise SystemExit("ERRO: não encontrei a AppBar da Home para inserir o botão de pendências.")
    main = main.replace(marcador, troca, 1)
    print("OK: botão Pendências adicionado na Home.")
else:
    print("main.dart já possui botão Pendências.")

if "class CentralPendenciasPage extends StatefulWidget" not in main:
    classe = """
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

    return int.tryParse(valor?.toString() ?? '') ?? listaCategoria(chave).length;
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

    return texto(diario['obra_nome'] ?? diario['nome_obra'], padrao: 'Obra não informada');
  }

  String motivoPendencia(String chave, Map<String, dynamic> diario) {
    if (chave == 'diarios_devolvidos') {
      return texto(
        diario['observacao_aprovacao'],
        padrao: 'Diário devolvido para correção.',
      );
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
                    colors: [
                      color,
                      color.withOpacity(0.78),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selecionado ? null : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selecionado ? color : AppUI.border,
            ),
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
              Icon(
                icon,
                color: selecionado ? Colors.white : color,
              ),
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
                  color: selecionado ? Colors.white.withOpacity(0.86) : AppUI.muted,
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
      MaterialPageRoute(
        builder: (_) => DiarioDetalhePage(diario: diario),
      ),
    );

    if (atualizou == true && mounted) {
      await carregarPendencias();
    }
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
                child: Icon(
                  iconeStatus(filtro),
                  color: color,
                ),
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
                        chipInfo(
                          diario['status_aprovacao']?.toString() ?? 'PENDENTE',
                          color,
                        ),
                        if (texto(diario['equipe'], padrao: '').isNotEmpty)
                          chipInfo('Equipe: ${texto(diario['equipe'])}', AppUI.blue),
                      ],
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
          Icon(
            Icons.task_alt_outlined,
            color: AppUI.green,
            size: 46,
          ),
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
            style: TextStyle(
              color: AppUI.muted,
              fontWeight: FontWeight.w700,
            ),
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
                      Text(
                        erro!,
                        textAlign: TextAlign.center,
                      ),
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
                child: Row(
                  children: categorias.map(cardCategoria).toList(),
                ),
              ),
              const SizedBox(height: 16),
              if (lista.isEmpty)
                emptyState()
              else
                ...lista.map(cardPendencia),
            ],
          ],
        ),
      ),
    );
  }
}

"""
    marcador = "class DiarioDetalhePage extends StatelessWidget"
    if marcador not in main:
        raise SystemExit("ERRO: não encontrei a classe DiarioDetalhePage para inserir CentralPendenciasPage.")
    main = main.replace(marcador, classe + "\n" + marcador, 1)
    print("OK: tela CentralPendenciasPage adicionada.")
else:
    print("main.dart já possui CentralPendenciasPage.")

MAIN.write_text(main, encoding="utf-8")
print("OK: patch Flutter da Central de Pendências aplicado.")
