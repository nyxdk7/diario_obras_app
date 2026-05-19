from pathlib import Path

MAIN = Path("lib/main.dart")
API = Path("lib/core/api/api_client.dart")
AUTH = Path("lib/features/auth/auth_service.dart")

for arquivo in [MAIN, API, AUTH]:
    if not arquivo.exists():
        raise SystemExit(f"ERRO: {arquivo} não encontrado. Rode este script na raiz do projeto Flutter.")

main = MAIN.read_text(encoding="utf-8")
api = API.read_text(encoding="utf-8")
auth = AUTH.read_text(encoding="utf-8")

if "Future<Response> solicitarEdicaoDiarioMobile" not in api:
    bloco_api = """

  Future<Response> solicitarEdicaoDiarioMobile(
    String token,
    int diarioId, {
    required String motivo,
  }) {
    return dio.post(
      '/api/mobile/diarios/$diarioId/solicitar-edicao',
      data: {
        'motivo': motivo.trim(),
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Future<Response> solicitarExclusaoDiarioMobile(
    String token,
    int diarioId, {
    required String motivo,
  }) {
    return dio.post(
      '/api/mobile/diarios/$diarioId/solicitar-exclusao',
      data: {
        'motivo': motivo.trim(),
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
    print("OK: ApiClient atualizado.")

if "Future<Map<String, dynamic>> solicitarEdicaoDiarioMobile" not in auth:
    bloco_auth = """

  Future<Map<String, dynamic>> solicitarEdicaoDiarioMobile(
    int diarioId, {
    required String motivo,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sessão mobile não encontrada. Faça login novamente.');
    }

    final response = await apiClient.solicitarEdicaoDiarioMobile(
      token,
      diarioId,
      motivo: motivo,
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> solicitarExclusaoDiarioMobile(
    int diarioId, {
    required String motivo,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sessão mobile não encontrada. Faça login novamente.');
    }

    final response = await apiClient.solicitarExclusaoDiarioMobile(
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
    print("OK: AuthService atualizado.")

if "Future<void> solicitarEdicaoDiario" not in main:
    marcador = "  Widget blocoAcoesRevisao(BuildContext context, String status) {"
    if marcador not in main:
        raise SystemExit("ERRO: não encontrei blocoAcoesRevisao no DiarioDetalhePage.")

    metodos = """  bool podeSolicitarAlteracao() {
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
                    const SnackBar(content: Text('Informe o motivo da solicitação.')),
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
      await AuthService().solicitarEdicaoDiarioMobile(
        id,
        motivo: motivo,
      );

      await AuthService().sync(limite: 300);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação de edição enviada.')),
      );

      Navigator.of(context).pop(true);
    } catch (erro) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagemErroAcao(erro))),
      );
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
      await AuthService().solicitarExclusaoDiarioMobile(
        id,
        motivo: motivo,
      );

      await AuthService().sync(limite: 300);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação de exclusão enviada.')),
      );

      Navigator.of(context).pop(true);
    } catch (erro) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagemErroAcao(erro))),
      );
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
                child: const Icon(
                  Icons.outgoing_mail,
                  color: azul,
                ),
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

"""
    main = main.replace(marcador, metodos + marcador, 1)
    print("OK: métodos de solicitações adicionados no DiarioDetalhePage.")

if "blocoSolicitacoesApontador(context)," not in main:
    alvo = "          blocoAcoesRevisao(context, status),\n"
    if alvo not in main:
        raise SystemExit("ERRO: não encontrei chamada do blocoAcoesRevisao.")
    main = main.replace(alvo, alvo + "          blocoSolicitacoesApontador(context),\n", 1)
    print("OK: bloco de solicitações inserido no detalhe.")

MAIN.write_text(main, encoding="utf-8")
print("OK: patch Flutter do Passo 4 aplicado.")
