---
execution: subagent
agent: frontend-architect
inputFile: squads/guardian/output/roteamento.md
outputFile: squads/guardian/output/implementacao-frontend.md
model_tier: powerful
---

# Step 13: Implementação Frontend

Este step pode ser disparado sozinho (grupo sequencial) ou em paralelo com o
Step 11 (Backend) quando o Step 09/12 (Jarvis) classificou os grupos como
seguros para dispatch concorrente — nesse caso, o pipeline runner invoca os
dois steps como chamadas paralelas da ferramenta Agent na mesma mensagem,
cada uma em seu próprio branch/worktree; o conteúdo e o processo abaixo não
mudam entre os dois modos de disparo.

## Context Loading

Load these files before executing:
- `squads/guardian/output/roteamento.md` (versão mais recente — pode já
  refletir a Arbitragem Pós-Backend do Step 12) — plano de roteamento do
  Jarvis: quais tasks desta camada (frontend) devem ser implementadas, em
  qual grupo/ordem, e quais dependem de contrato de API confirmado com o
  backend
- As próprias `squads/guardian/tasks/active/GT-*.md` com `camada: frontend` —
  texto completo de cada task, fonte única de verdade da implementação
- `squads/guardian/agents/frontend-architect.agent.md` — persona/principles de Flávia Frontend: standalone components, reaproveitamento de Velzon/shared, @ngrx/signals, cache por chave
- `squads/guardian/agents/frontend-architect/tasks/implementar-frontend.md` — processo operacional de implementação frontend
- Codebase de produto relevante (`C:\Software\GeoCloud\GeoCloudAI` e/ou `C:\Software\ELIMS\ELIMS`, conforme a task roteada) — módulos Angular, shared/, shared-modules/, ui/
- `squads/guardian/output/implementacao-backend.md` (se disponível) — contrato de API real já implementado pelo Backend Architect para as tasks que dependem dele

## Instructions

> **Independência de `.claude`/`.cursor`:** `duplicate-detector` não é skill nativa deste squad — é a metodologia em `C:/Software/ClaudeCode/squads/guardian/reference/{geocloud|elims}/skills/duplicate-detector/SKILL.md` (caminho absoluto, conforme produto da task). Ler o `SKILL.md` correspondente e aplicar o método diretamente via Grep/Glob, sem depender do Skill tool nem de `.claude/`/`.cursor/` do repositório de produto.

### Process

1. Ler o plano de roteamento e filtrar apenas as tasks `active/` atribuídas à camada frontend nesta execução; para tasks que dependem de um contrato de API novo/alterado, confirmar o shape real do DTO com `implementacao-backend.md` ou diretamente no código — nunca assumir o contrato.
2. Antes de criar qualquer componente novo, rodar duplicate-detector em `shared/`, `shared-modules/` e `ui/` — se existe um componente Velzon/shared equivalente, reaproveitar em vez de duplicar.
3. Para cada task (ou pequeno lote de tasks relacionadas), criar uma branch dedicada `fix/{descrição-curta}` ou `refactor/{descrição-curta}`, implementar como componente standalone com rota lazy (`loadComponent`) e guard apropriado, e um service de API dedicado (nunca chamada HTTP direta do componente).
4. Respeitar a decisão de state management já feita para o produto (`@ngrx/signals`); se o componente lê dados via getter de template, aplicar cache por chave com guarda de in-flight; tratar erro de API cobrindo tanto JSON estruturado quanto texto plano.
5. Verificar que nenhuma validação de permissão do frontend é tratada como barreira de segurança real — a barreira real é sempre o backend; o frontend apenas reflete a permissão para UX.
6. Abrir um Pull Request por branch (NUNCA push direto em main/master), com título e descrição linkando a issue correspondente (`issue_url` da task); se o componente integra um fluxo já documentado, sinalizar para a Documentation Architect.
7. Atualizar, na própria `GT-NNNN.md` em `tasks/active/`, as seções "Registro de execução" e "Validação" — com comando e resultado reais.

> **Onde escrever o Registro de execução:** se a `GT-NNNN` tem `contraparte` no front-matter, o Registro de execução e a Validação vão **no par do repositório de produto** (`<repo>/.agents/tasks/active/GT-NNNN.md`) — é ele que viaja na branch e é revisado no mesmo PR do código. O GT do hub guarda o porquê (achado, evidência, severidade) e **não** recebe registro de execução. Sem `contraparte`, tudo no hub, como antes. Ver `agents/task-curator/tasks/gerar-tasks.md`, passo 5.
8. Consolidar o resultado de todas as tasks frontend implementadas nesta execução no arquivo de saída, um bloco por task.

## Output Format

The output MUST follow this exact structure:
```markdown
# Implementação Frontend — {data da execução}

## Tasks Implementadas

### {GT-NNNN} — {título curto}
**Branch:** `{nome-da-branch}`
**Arquivos alterados:** {lista de arquivos}
**Resumo da implementação:** {componente/rota/service criado ou consolidado, e por quê}
**Contrato de API confirmado com:** {implementacao-backend.md / revisão direta de código}
**PR:** {título do PR} — {url do PR, placeholder se ainda não disponível}
**Coordenação necessária:** {Backend/Documentation/nenhuma}

(repetir bloco para cada task implementada)

## Tasks Não Implementadas / Bloqueadas
{lista de tasks roteadas para frontend que não puderam ser implementadas nesta execução, com motivo — ex.: contrato de API ainda não confirmado pelo backend}
```

## Output Example

```markdown
# Implementação Frontend — 2026-08-21

## Tasks Implementadas

### GT-0002 — Duplicação de modal de endereço em 2 pontos de uso
**Branch:** `fix/consolidate-address-modal`
**Arquivos alterados:** `shared/components/address-modal/*` (novo), `features/accounts/account-edit.component.ts`, `features/entities/entity-edit.component.ts`
**Resumo da implementação:** removidas 2 implementações duplicadas de modal de endereço; consolidado em `shared/components/address-modal` como standalone component; atualizados os 2 pontos de uso para consumir o componente compartilhado via `AddressModalService`.
**Contrato de API confirmado com:** revisão direta de código (nenhuma mudança de contrato envolvida).
**PR:** "refactor: consolidar modal de endereço duplicado (GT-0002)" — https://github.com/Essencis-Labs/GeoCloudAI/pull/000 (placeholder)
**Coordenação necessária:** nenhuma.

### GT-0001-FE — Reflexo de permissão no formulário de endereço
**Branch:** `fix/address-form-permission-guard`
**Arquivos alterados:** `features/addresses/address-create.component.ts`, `core/guards/permission.guard.ts`
**Resumo da implementação:** adicionado guard de rota lazy baseado na permission key `address.create` (já implementada pelo Backend Architect no PR de GT-0001); botão de submit desabilitado com mensagem clara quando a permissão não está presente — tratado explicitamente como UX, não como barreira de segurança real.
**Contrato de API confirmado com:** implementacao-backend.md (GT-0001) — key `address.create` confirmada no seed.
**PR:** "fix: refletir permissão address.create no formulário (GT-0001)" — https://github.com/Essencis-Labs/GeoCloudAI/pull/000 (placeholder)
**Coordenação necessária:** Documentation Architect (fluxo de criação de endereço é documentado em docs/system/address-flow.md).

## Tasks Não Implementadas / Bloqueadas
Nenhuma.
```

## Veto Conditions

Reject and redo if ANY of these are true:
1. Qualquer commit foi feito direto em main/master sem passar por PR.
2. Um componente novo duplica um componente shared/Velzon já existente em vez de reaproveitá-lo.
3. Alguma chamada HTTP foi feita direto de um componente, sem passar por um service dedicado.
4. A validação de permissão no frontend foi tratada como barreira de segurança real (ex.: dado sensível exposto no client confiando apenas no guard de UI).
5. O contrato de API foi assumido sem confirmação real com o Backend Architect ou com o código, e a implementação não corresponde ao DTO real.
6. A `GT-NNNN.md` correspondente não foi atualizada com "Registro de execução" e "Validação" reais.

## Quality Criteria

- [ ] Toda task frontend roteada nesta execução foi implementada ou explicitamente marcada como bloqueada com motivo.
- [ ] Toda rota nova é lazy (`loadComponent`) e tem guard apropriado quando aplicável.
- [ ] Nenhum componente novo duplica um shared existente.
- [ ] Toda PR aberta linka a issue correspondente e sinaliza coordenação necessária com outras camadas.
- [ ] Toda `GT-NNNN.md` implementada tem "Registro de execução" e "Validação" preenchidos com evidência real.
