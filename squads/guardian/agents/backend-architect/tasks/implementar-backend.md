---
task: "Implementar Backend"
order: 1
input: |
  - achado: achado de backend roteado pelo Jarvis (id, camada, descrição, severidade, arquivo:linha)
  - plano_roteamento: squads/guardian/output/roteamento.md (contexto de ordem/dependência entre achados)
output: |
  - implementacao: squads/guardian/output/implementacao-backend.md (branch, diff resumido, PR aberto)
---

# Implementar Backend

Implementa a correção de backend roteada pelo Jarvis para um achado aprovado (dívida técnica, segurança ou drift de documentação com componente de backend), em branch dedicada, sobre a stack .NET 9 + Dapper, e abre PR — nunca push direto em main/master.

> `duplicate-detector`, `dependency-mapper`, `architecture-validator` e `regression-analysis` = metodologias em `C:\Software\ClaudeCode\squads\guardian\reference\{geocloud|elims}\skills\{nome}\SKILL.md` (caminho absoluto, conforme produto do achado) — ler e aplicar diretamente, sem depender de `.claude`/`.cursor` do produto.

## Process

1. Rodar duplicate-detector/dependency-mapper no domínio afetado pelo achado antes de criar qualquer classe nova; preferir estender/consolidar sobre recriar.
2. Confirmar a permission key (`recurso.acao`) exigida pelo endpoint — se não existir no seed, coordenar a adição antes de prosseguir com a implementação.
3. Implementar na ordem de dependência: Domain → Persistence (SQL parametrizado via Dapper, nunca EF Core) → Application (service + DTO + AutoMapper) → API (controller com `[Authorize]`/`[RequiredPermission]`).
4. Validar isolamento de tenant: toda query nova ou alterada filtra por `accountId`/`entityId` extraído do token JWT, nunca por valor recebido do cliente sem validar propriedade.
5. Se um DTO foi alterado, confirmar explicitamente no `AutoMapper`/`ReverseMap` que nenhum campo é descartado silenciosamente.
6. Rodar architecture-validator e regression-analysis sobre a área alterada antes de considerar a implementação concluída.
7. Atualizar ou encaminhar a atualização de docs/system relacionados (ou sinalizar explicitamente para Marta Documentation na mesma entrega).
8. Abrir Pull Request: nunca fazer push direto em main/master. Criar branch dedicada, comitar a implementação com testes, e abrir PR descrevendo achado, correção e evidência de validação. Parar aqui e aguardar o checkpoint de revisão (Otávio Review) e a aprovação humana antes de qualquer merge.

## Output Format

```yaml
branch_name: string          # ex.: fix/address-add-authorization
files_changed:
  - path: string
    change_summary: string
pr_title: string
pr_description: string       # inclui achado de origem, correção aplicada, evidência de validação (tenant isolation, permission key, testes)
pr_url: string                # placeholder até a criação real via gh CLI
tests_added:
  - name: string
    covers: string
```

## Output Example

```yaml
branch_name: fix/address-add-authorization
files_changed:
  - path: Controllers/AddressController.cs
    change_summary: "Adiciona [Authorize] + [RequiredPermission(\"address.create\")] ao endpoint Add"
  - path: Infrastructure/Seed/PermissionSeeder.cs
    change_summary: "Adiciona seed da permission key address.create"
  - path: Tests/AddressControllerTests.cs
    change_summary: "Adiciona AddressController_Add_Should_Deny_Without_Permission"
pr_title: "fix: exigir permissão explícita em POST /Address/add (SEC-01)"
pr_description: >
  Corrige achado SEC-01 (Selma Security): endpoint POST /Address/add
  permitia criação de endereço por chamador não autenticado
  ([AllowAnonymous] sem justificativa). Adiciona [Authorize] +
  [RequiredPermission("address.create")]; key confirmada/adicionada
  no seed; teste de permissão negativa incluído. Isolamento de tenant
  validado: accountId extraído do token JWT via middleware de identidade,
  nunca do corpo da requisição. Linka issue criada por Tomás Ticket.
pr_url: "PENDING"
tests_added:
  - name: AddressController_Add_Should_Deny_Without_Permission
    covers: "Requisição sem permission key address.create deve retornar 403"
```

## Quality Criteria

- Nenhum endpoint novo ou alterado sem controle de acesso explícito (`[Authorize]` + `[RequiredPermission]`).
- AutoMapper/DTO não descarta campo novo silenciosamente.
- PR aberto, nunca push direto em main/master.
- docs/system atualizados na mesma tarefa (ou explicitamente encaminhado a Marta Documentation).

## Veto Conditions

Reject and redo if ANY are true:
- Qualquer push direto em main/master (sem branch dedicada + PR) — reject automático, sem exceção.
- Endpoint novo ou alterado sem `[Authorize]`/`[RequiredPermission]` explícito.
- Uso de EF Core em qualquer camada de Persistence nova ou alterada.
- Query filtrando por `accountId`/`entityId` recebido do corpo/query string sem validação contra o token JWT.
- Alteração do núcleo compartilhado de Conta/Identidade feita isoladamente em um produto só, sem avaliação de impacto no produto irmão.
