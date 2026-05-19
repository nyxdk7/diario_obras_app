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

# ============================================================
# api_client.dart
# ============================================================

if "Future<Response> aprovarExclusaoDiarioMobile" not in api:
    bloco_api = """

  Future<Response> aprovarExclusaoDiarioMobile(
    String token,
    int diarioId,
  ) {
    return dio.post(
      '/api/mobile/diarios/$diarioId/exclusao/aprovar',
      data: {},
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Future<Response> rejeitarExclusaoDiarioMobile(
    String token,
    int diarioId, {
    required String motivo,
  }) {
    return dio.post(
      '/api/mobile/diarios/$diarioId/exclusao/rejeitar',
      data: {
        'motivo': motivo.trim().isEmpty
            ? 'Solicitação de exclusão rejeitada.'
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
    api = api[:pos] + bloco_api + api[pos:]
    API.write_text(api, encoding="utf-8")
    print("OK: métodos de exclusão adicionados ao api_client.dart")
else:
    print("api_client.dart já possui métodos de exclusão.")

# ============================================================
# auth_service.dart
# ============================================================

if "Future<Map<String, dynamic>> aprovarExclusaoDiarioMobile" not in auth:
    bloco_auth = """

  Future<Map<String, dynamic>> aprovarExclusaoDiarioMobile(
    int diarioId,
  ) async {
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
"""
    pos = auth.rfind("\n}")
    if pos == -1:
        raise SystemExit("ERRO: não encontrei fim da classe AuthService.")
    auth = auth[:pos] + bloco_auth + auth[pos:]
    AUTH.write_text(auth, encoding="utf-8")
    print("OK: métodos de exclusão adicionados ao auth_service.dart")
else:
    print("auth_service.dart já possui métodos de exclusão.")

# ============================================================
# main.dart - métodos na CentralPendenciasPage
# ============================================================

if "Future<void> aprovarSolicitacaoExclusao" not in main:
    marcador = "  Widget cardPendencia(Map<String, dynamic> diario) {"
    if marcador not in main:
        raise SystemExit("ERRO: não encontrei cardPendencia().")

    metodos = """  Future<void> aprovarSolicitacaoExclusao(Map<String, dynamic> diario) async {
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
              style: FilledButton.styleFrom(
                backgroundColor: AppUI.red,
              ),
            ),
          ],
        );
      },
    );

    if (confirmou != true) {
      return;
    }

    try {
      await authService.aprovarExclusaoDiarioMobile(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação de exclusão aprovada. Diário excluído.')),
      );

      await carregarPendencias();
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagemErroRevisaoEdicao(erro))),
      );
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
              style: FilledButton.styleFrom(
                backgroundColor: AppUI.red,
              ),
            ),
          ],
        );
      },
    );

    if (motivo == null) {
      return;
    }

    try {
      await authService.rejeitarExclusaoDiarioMobile(
        id,
        motivo: motivo,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação de exclusão rejeitada.')),
      );

      await carregarPendencias();
    } catch (erro) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagemErroRevisaoEdicao(erro))),
      );
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

"""
    main = main.replace(marcador, metodos + marcador, 1)
    print("OK: métodos de ação de exclusão adicionados na CentralPendenciasPage.")
else:
    print("main.dart já possui métodos de ação de exclusão.")

# ============================================================
# main.dart - inserir botões no card
# ============================================================

if "botoesAcaoExclusao(diario)," not in main:
    if "botoesAcaoEdicao(diario)," in main:
        main = main.replace(
            "                    botoesAcaoEdicao(diario),",
            "                    botoesAcaoEdicao(diario),\n                    botoesAcaoExclusao(diario),",
            1
        )
        print("OK: botões de exclusão adicionados após botões de edição.")
    else:
        alvo = """                    Wrap(
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
        novo = alvo + "                    botoesAcaoExclusao(diario),\n"
        if alvo not in main:
            raise SystemExit("ERRO: não encontrei ponto para inserir botões no card.")
        main = main.replace(alvo, novo, 1)
        print("OK: botões de exclusão adicionados no card.")
else:
    print("main.dart já possui botões de exclusão.")

MAIN.write_text(main, encoding="utf-8")
print("OK: patch Flutter do Passo 3 aplicado.")
