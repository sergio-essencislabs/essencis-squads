---
execution: subagent
agent: backend-architect
inputFile: squads/guardian/output/roteamento.md
outputFile: squads/guardian/output/implementacao-backend.md
model_tier: powerful
---

# Step 11: Implementação Backend

Este step pode ser disparado sozinho (grupo sequencial) ou em paralelo com o
Step 13 (Frontend) quando o Step 09/12 (Jarvis) classificou os grupos como
seguros para dispatch concorrente — nesse caso, o pipeline runner invoca
Steps 11 e 13 como chamadas paralelas da ferramenta Agent na mesma mensagem,
cada uma em seu próprio branch/worktree; o conteúdo e o processo abaixo não
mudam entre os dois modos de disparo.

## Context Loading

Load these files before executing:
- `squads/guardian/output/roteamento.md` — plano de roteamento do Jarvis: quais tasks desta camada (backend) devem ser implementadas, em qual grupo/ordem, e quais tocam o núcleo compartilhado de Conta/Identidade
- As próprias `squads/guardian/tasks/active/GT-*.md` com `camada: backend` — texto completo de cada task (achado original, critérios de aceitação, impacto técnico), fonte única de verdade da implementação
- `squads/guardian/agents/backend-architect.agent.md` — persona/principles de Breno Backend: Dapper/SQL parametrizado, proibição de EF Core, ordem de dependência Domain → Persistence → Application → API
- `squads/guardian/agents/backend-architect/tasks/implementar-backend.md` — processo operacional de implementação backend
- Codebase de produto relevante (`C:\Software\GeoCloud\GeoCloudAI` e/ou `C:\Software\ELIMS\ELIMS`, conforme a task roteada) — controllers, services, DTOs, seed de permissões

## Instructions

> **Independência de `.claude`/`.cursor`:** `duplicate-detector`, `dependency-mapper`, `architecture-validator` e `regression-analysis` não são skills nativas deste squad — são as metodologias em `C:/Software/ClaudeCode/squads/guardian/reference/{geocloud|elims}/skills/{nome}/SKILL.md` (caminho absoluto, conforme produto da task). Ler o `SKILL.md` correspondente e aplicar o método diretamente via Grep/Glob/Bash/Read, sem depender do Skill tool nem de `.claude/`/`.cursor/` do repositório de produto.

### Process

1. Ler o plano de roteamento e filtrar apenas as tasks `active/` atribuídas à camada backend nesta execução; para cada uma, confirmar se ela toca o núcleo compartilhado de Conta/Identidade (se sim, tratar com a avaliação de impacto já sinalizada pelo Jarvis, e o GADR relacionado, antes de codificar).
2. Antes de criar qualquer classe/service/repository novo, rodar duplicate-detector e dependency-mapper no domínio afetado — se já existe algo equivalente, estender em vez de recriar.
3. Para cada task (ou pequeno lote de tasks relacionadas no mesmo componente), criar uma branch dedicada nomeada `fix/{descrição-curta}` ou `feature/{descrição-curta}`, implementar na ordem Domain → Persistence (Dapper, SQL parametrizado — nunca EF Core) → Application (service + DTO + AutoMapper, confirmando que nenhum campo é descartado silenciosamente) → API (controller com `[Authorize]` + `[RequiredPermission]` explícitos).
4. Confirmar que toda query nova filtra por `accountId`/`entityId` extraído do token JWT, nunca de valor recebido do corpo/query string sem validação — documentar como essa validação foi feita.
5. Rodar architecture-validator/regression-analysis antes de considerar a implementação concluída para aquela task.
6. Abrir um Pull Request por branch (NUNCA push direto em main/master), com título e descrição linkando a issue correspondente (`issue_url` da task); se a task altera contrato de API ou schema, sinalizar explicitamente para Flávia Frontend e/ou Rui Register no corpo do PR.
7. Atualizar, na própria `GT-NNNN.md` em `tasks/active/`, as seções "Registro de execução" (Alterações realizadas, Arquivos principais, Decisões, Divergências, Pendências) e "Validação" — com comando e resultado reais, nunca uma caixa marcada sem evidência.

> **Onde escrever o Registro de execução:** se a `GT-NNNN` tem `contraparte` no front-matter, o Registro de execução e a Validação vão **no par do repositório de produto** (`<repo>/.agents/tasks/active/GT-NNNN.md`) — é ele que viaja na branch e é revisado no mesmo PR do código. O GT do hub guarda o porquê (achado, evidência, severidade) e **não** recebe registro de execução. Sem `contraparte`, tudo no hub, como antes. Ver `agents/task-curator/tasks/gerar-tasks.md`, passo 5.
8. Consolidar o resultado de todas as tasks backend implementadas nesta execução no arquivo de saída, um bloco por task.

## Output Format

The output MUST follow this exact structure:
```markdown
# Implementação Backend — {data da execução}

## Tasks Implementadas

### {GT-NNNN} — {título curto}
**Branch:** `{nome-da-branch}`
**Arquivos alterados:** {lista de arquivos}
**Resumo da implementação:** {o que foi feito, por camada — Domain/Persistence/Application/API}
**Validação de tenant isolation:** {como foi validado, ou "N/A"}
**PR:** {título do PR} — {url do PR, placeholder se ainda não disponível}
**Coordenação necessária:** {Frontend/Database/nenhuma}

(repetir bloco para cada task implementada)

## Tasks Não Implementadas / Bloqueadas
{lista de tasks roteadas para backend que não puderam ser implementadas nesta execução, com motivo}
```

## Output Example

```markdown
# Implementação Backend — 2026-08-21

## Tasks Implementadas

### GT-0001 — AllowAnonymous sem justificativa em POST /Address/add
**Branch:** `fix/address-add-authorization`
**Arquivos alterados:** `Controllers/AddressController.cs`, `Infrastructure/Security/PermissionSeeder.cs`, `Tests/AddressControllerTests.cs`
**Resumo da implementação:** Removido `[AllowAnonymous]` do método `Add`; adicionado `[Authorize]` + `[RequiredPermission("address.create")]`; key `address.create` adicionada ao seed de permissões (idempotente); adicionado teste `AddressController_Add_Should_Deny_Without_Permission`.
**Validação de tenant isolation:** `accountId` já era extraído do middleware de identidade nesse endpoint — confirmado, nenhuma alteração necessária.
**PR:** "fix: exigir permissão explícita em POST /Address/add (GT-0001)" — https://github.com/Essencis-Labs/GeoCloudAI/pull/000 (placeholder)
**Coordenação necessária:** nenhuma.

### GT-0002 — Campo JSON legado convivendo com tabela relacional nova
**Branch:** `fix/testrequest-drop-legacy-json-write`
**Arquivos alterados:** `Services/TestRequestService.cs`, `Repositories/TestRequestRepository.cs`
**Resumo da implementação:** Removida escrita no campo `testsjson` legado nos 2 fluxos identificados pelo Dante Debit; leitura de fallback mantida por 1 release conforme classificação original.
**Validação de tenant isolation:** N/A — mudança não altera filtro de acesso.
**PR:** "refactor: remover escrita legada em testrequest.testsjson (GT-0002)" — https://github.com/Essencis-Labs/GeoCloudAI/pull/000 (placeholder)
**Coordenação necessária:** Database (Rui Register já notificado sobre a coluna legada para eventual remoção futura).

## Tasks Não Implementadas / Bloqueadas
Nenhuma.
```

## Veto Conditions

Reject and redo if ANY of these are true:
1. Qualquer commit foi feito direto em main/master sem passar por PR.
2. Algum endpoint novo/alterado ficou sem `[Authorize]` + `[RequiredPermission]` explícitos, ou a permission key referenciada não existe no seed.
3. Foi introduzido uso de EF Core em qualquer camada de persistência.
4. Uma task de núcleo compartilhado (Account/Entity/Profile/Functionality/User) foi implementada isoladamente em um produto só, sem avaliação de impacto no produto irmão.
5. Uma exceção de segurança (ex.: manter `[AllowAnonymous]`) foi decidida pelo próprio Backend Architect em vez de escalada ao Security Auditor.
6. A `GT-NNNN.md` correspondente não foi atualizada com "Registro de execução" e "Validação" reais.

## Quality Criteria

- [ ] Toda task backend roteada nesta execução foi implementada ou explicitamente marcada como bloqueada com motivo.
- [ ] Cada implementação segue a ordem Domain → Persistence → Application → API.
- [ ] Nenhum campo é descartado silenciosamente no AutoMapper.
- [ ] Toda PR aberta linka a issue correspondente e sinaliza coordenação necessária com outras camadas.
- [ ] Toda `GT-NNNN.md` implementada tem "Registro de execução" e "Validação" preenchidos com evidência real.
