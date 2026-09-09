---
task: "Revisar PRs"
order: 1
input: |
  - implementacoes: PRs e evidências produzidas por Backend/Frontend/Database Architect (passos 8-10) para os achados roteados pelo Chief Architect
output: |
  - revisao: veredito (aprovado/bloqueado) por PR, com evidência citada e pendências não bloqueantes registradas
---

# Revisar PRs

Revisa todos os PRs abertos pelos especialistas (Backend, Frontend, Database Architect) antes do checkpoint de aprovação do usuário. Confirma que cada implementação cumpre o que o achado original exigia, com evidência real — nunca aprova ou bloqueia por impressão.


## Onde a task vive — o par `contraparte`

Desde 2026-09-09 (TASK-060 no GeoCloudAI), toda `GT-NNNN` gerada para um repositório de produto
que tenha `.agents/` versionado ganha um **par de mesmo número** lá, e o front-matter dos dois
aponta um para o outro em `contraparte:`.

Os dois têm papéis diferentes, e **não são cópia**:

| Arquivo | Responde | Quem escreve |
|---|---|---|
| `squads/guardian/tasks/…/GT-NNNN.md` (hub) | *por que isto entrou na fila* — achado, evidência, severidade, `run_origem` | Tomás, no Step 07 |
| `<repo-de-produto>/.agents/tasks/…/GT-NNNN.md` | *como será feito e como foi feito* — RN, CA, plano, **Registro de execução**, **Validação** | quem implementa e quem revisa |

**Regra operacional:** se a task tem `contraparte`, o Registro de execução, a Validação e o
fechamento acontecem **no par do repositório de produto** — é ele que viaja na branch e é revisado
no mesmo PR do código. O GT do hub não recebe registro de execução; ele guarda o porquê.

Se a task **não** tem `contraparte` (trabalho sobre o próprio squad, ou repositório de produto sem
`.agents/` versionado — hoje o E-LIMS), tudo acontece no hub, como antes.

Autoridade: `squads/guardian/agents/task-curator/tasks/gerar-tasks.md`, passo 5.

## Process

1. Reconstituir a cadeia da tarefa para cada PR: qual achado motivou a correção, qual agente implementou, e o que ele produziu (diff, testes, PR).
2. Verificar contra o checklist geral: impacto/duplicação analisados, testes passando, docs atualizados.
3. Verificar contra o checklist específico do agente envolvido (ex.: seed de permission key e teste de negação para Backend; contrato de API confirmado e cache/guard para Frontend; plano de rollback e database-diff para Database).
4. Se a tarefa tocou segurança, permissão ou o núcleo compartilhado de Conta/Identidade, confirmar evidência real de execução do playbook correspondente (fuzz de permissão, avaliação de impacto cross-produto) — não aceitar menção sem prova.
5. Registrar toda pendência não bloqueante com dono e prioridade; toda pendência bloqueante retorna o PR ao agente responsável em vez de ser aprovada com ressalva.
6. Emitir o veredito final — aprovado ou bloqueado — sempre com justificativa concreta citando evidência ou a policy violada.
7. Para todo PR **aprovado**, checar as 3 evidências de fechamento na `GT-NNNN.md` correspondente, nesta ordem: (a) código — "Registro de execução → Alterações realizadas" preenchido; (b) documentação — doc correspondente atualizado, ou justificativa explícita de por que não se aplica; (c) testes — "Validação" com comando e resultado reais. Se as três passam, mover a task para `tasks/completed/`. Se alguma faltar, registrar exatamente o que falta no campo "Pendências" da task e mantê-la em `active/`.

## Output Format

```yaml
revisoes:
  - pr: "#142"
    titulo: "fix: address-add-authorization"
    achado_origem: "SEC-01"
    agente_implementador: "backend-architect"
    checklist_geral:
      impacto_duplicacao_analisado: true
      testes_passando: true
      docs_atualizados: true
    checklist_especifico:
      seed_permission_key: true
      teste_permissao_negacao: true
    veredito: "aprovado"          # aprovado | bloqueado
    evidencia_citada: "seed da key address.create presente; teste AddressController_Add_Should_Deny_Without_Permission passando; docs/system/permission-rules.md atualizado"
    pendencias_nao_bloqueantes:
      - descricao: "falta teste de idempotência do seed"
        dono: "backend-architect"
        prioridade: "baixa"
    motivo_bloqueio: null
    fechamento_task:
      movida_para_completed: true
      pendencia: null      # preenchido só quando movida_para_completed é false
```

## Output Example

> Use como referência de qualidade, não como template rígido.

### Revisão — PR #142 (fix: address-add-authorization)
**Achado origem:** SEC-01, implementado por Breno Backend.
**Checklist geral:** impacto/duplicação analisados (dependency-mapper citado no PR), testes passando (CI verde), docs atualizados (docs/system/permission-rules.md).
**Checklist específico (Backend):** seed da key `address.create` presente em `PermissionSeeder.cs`; teste `AddressController_Add_Should_Deny_Without_Permission` presente e passando.
**Playbook de segurança:** evidência real de fuzz de permissão executado por Selma Security sobre o endpoint alterado — não apenas menção.
**Veredito: Aprovado.**
Pendência não bloqueante registrada: falta teste de idempotência do seed (dono: Breno Backend, prioridade baixa).

### Revisão — PR #145 (fix: consolidate-address-modal)
**Achado origem:** TD-03, implementado por Flávia Frontend.
**Checklist geral:** impacto/duplicação analisados (duplicate-detector citado), testes passando, docs não exigidos (mudança é puramente estrutural de frontend).
**Checklist específico (Frontend):** contrato de API não alterado; componente consolidado em `shared/components/`.
**Veredito: Bloqueado.**
Motivo: componente novo em `shared/components/` não segue convenção de nomenclatura de `policies/nomenclatura.md` (nome em PT usado em classe Angular, deveria ser em EN por convenção do produto — linha citada: `shared/components/address-modal/endereco-modal.component.ts:1`). Retornado a Flávia Frontend com a linha exata da violação; não é preferência estilística, é policy documentada.

## Quality Criteria

- [ ] Nenhum PR foi aprovado com pendência bloqueante ainda aberta.
- [ ] Toda aprovação ou bloqueio cita evidência concreta ou a policy documentada violada.
- [ ] Toda pendência não bloqueante está registrada com dono e prioridade antes do fechamento da revisão.

## Veto Conditions

Reject and redo if ANY are true:
1. Um veredito foi emitido como "parece bom" ou equivalente, sem evidência concreta citada.
2. Uma alteração de permissão ou segurança foi aprovada sem evidência de fuzz/teste do responsável por segurança.
3. Um bloqueio foi justificado por preferência estilística sem referência a uma policy documentada.
