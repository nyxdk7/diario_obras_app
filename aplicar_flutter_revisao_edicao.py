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

if "Future<Response> aprovarEdicaoDiarioMobile" not in api:
    api_insert = """

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
"""
    pos = api.rfind("\n}")
    if pos == -1:
        raise SystemExit("ERRO: não encontrei fim da classe ApiClient.")
    api = api[:pos] + api_insert + api[pos:]
    API.write_text(api, encoding="utf-8")
    print("OK: métodos de edição adicionados ao api_client.dart")
else:
    print("api_client.dart já possui métodos de edição.")

if "Future<Map<String, dynamic>> aprovarEdicaoDiarioMobile" not in auth:
    auth_insert = """

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
"""
    pos = auth.rfind("\n}")
    if pos == -1:
        raise SystemExit("ERRO: não encontrei fim da classe AuthService.")
    auth = auth[:pos] + auth_insert + auth[pos:]
    AUTH.write_text(auth, encoding="utf-8")
    print("OK: métodos de edição adicionados ao auth_service.dart")
else:
    print("auth_service.dart já possui métodos de edição.")

if "Future<void> aprovarSolicitacaoEdicao" not in main:
    marcador = """  Widget cardPendencia(Map<String, dynamic> diario) {
    final color = corStatus(filtro);
"""
    metodos = """
  int? idDiario(Map<String, dynamic> diario) {
    final valor = diario['id'];
    if (valor is int) return valor;
    return int.tryParse(valor?.toString() ?? '');
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

  Future<void> aprovarSolicitacaoEdicao(Map<String, dynamic> diario) async {
    final id = idDiario(diario);

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
            'O apontador será autorizado a editar este diário. Se já houver payload salvo, ele será aplicado.',
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

    if (confirmou != true) return;

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagemErroAcao(erro))),
      );
    }
  }

  Future<void> rejeitarSolicitacaoEdicao(Map<String, dynamic> diario) async {
    final id = idDiario(diario);

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
              style: FilledButton.styleFrom(
                backgroundColor: AppUI.red,
              ),
            ),
          ],
        );
      },
    );

    if (motivo == null) return;

    try {
      await authService.rejeitarEdicaoDiarioMobile(
        id,
        motivo: motivo,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação de edição rejeitada.')),
      );

      await carregarPendencias();
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagemErroAcao(erro))),
      );
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

"""
    if marcador not in main:
        raise SystemExit("ERRO: não encontrei cardPendencia da CentralPendenciasPage.")
    main = main.replace(marcador, metodos + marcador, 1)
    print("OK: métodos de ação de edição adicionados na CentralPendenciasPage.")
else:
    print("main.dart já possui métodos de ação de edição.")

if "botoesAcaoEdicao(diario)" not in main:
    marcador = """                    Wrap(
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
"""
    troca = marcador + "                    botoesAcaoEdicao(diario),\n"
    if marcador not in main:
        raise SystemExit("ERRO: não encontrei ponto para inserir botões no card de pendência.")
    main = main.replace(marcador, troca, 1)
    print("OK: botões Aprovar/Rejeitar edição adicionados no card.")
else:
    print("main.dart já possui botões de ação de edição.")

MAIN.write_text(main, encoding="utf-8")
print("OK: patch Flutter do Passo 2 aplicado.")
