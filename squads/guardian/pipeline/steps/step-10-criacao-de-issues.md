---
execution: subagent
agent: task-curator
inputFile: squads/guardian/output/roteamento.md
outputFile: squads/guardian/output/issues-criadas.md
model_tier: fast
---

# Step 10: Criação de Issues

Só processa as `GT-IDs` que o Gate de Promoção (Step 08) aprovou e que
Jarvis já roteou (Step 09) — a issue nasce já sabendo camada e GADR
relacionado, em vez de nascer antes do roteamento como na versão anterior
deste pipeline.

## Context Loading

Load these files before executing:
- `squads/guardian/output/gate-promocao.md` — `GT-IDs` aprovadas para
  promoção.
- `squads/guardian/output/roteamento.md` — camada, grupo de execução e GADR
  relacionado (se houver) de cada `GT-ID` aprovada.
- As próprias `squads/guardian/tasks/backlog/GT-*.md` aprovadas — conteúdo
  completo da task, fonte única de verdade da issue.
- `squads/guardian/agents/task-curator.agent.md` — persona de
  Tomás Ticket: sempre busca duplicata antes de criar, nunca rebaixa
  severidade, sempre cita a fonte do achado.
- `squads/guardian/agents/task-curator/tasks/criar-issues-de-tasks.md` —
  processo operacional a seguir para buscar duplicata, redigir a issue a
  partir da task, e mover o arquivo `backlog/ → active/`.

Esta etapa usa a **`gh` CLI (já autenticada, scopes: project, repo,
read:org)** contra o GitHub Project **"Essencis-Labs"** (org
**Essencis-Labs**, repositórios **Essencis-Labs/GeoCloudAI** e
**Essencis-Labs/ELIMS**), que já tem **322+ itens** no board.

## Instructions

### Process

1. Para cada `GT-ID` aprovada em `gate-promocao.md`, ler a task completa em
   `tasks/backlog/` e a linha correspondente em `roteamento.md` (camada,
   grupo, GADR).
2. Determinar o repositório de destino (`Essencis-Labs/GeoCloudAI` ou
   `Essencis-Labs/ELIMS`) a partir do campo `produto` da task. Com a `gh`
   CLI, buscar no repositório (`gh issue list --search ...` / `gh search
   issues ...`) por issue já aberta cobrindo o mesmo componente/endpoint/
   tabela — obrigatório antes de qualquer criação.
3. Se encontrar equivalente aberta: **não duplicar**. Comentar na issue
   existente (`gh issue comment`) com a task como evidência adicional,
   atualizando severidade/labels via `gh issue edit` se a task for mais grave
   que o registrado; ainda assim, preencher `issue_url` no frontmatter da
   task apontando para a issue existente e mover `backlog/ → active/`.
4. Se não houver equivalente: redigir a issue a partir do conteúdo da task
   (Contexto → Achado com evidência arquivo:linha → Severidade → Critério de
   aceitação → Camada/produto, citando o GADR relacionado quando houver) e
   título seguindo a convenção `"GeoCloud - <título>"` ou `"ELIMS - <título>"`.
   Criar com `gh issue create`, etiquetar com produto/camada/origem, e
   adicionar ao Project #7 (Essencis-Labs) via `gh project item-add`
   preenchendo Status/Priority/Stack.
5. Preencher `issue_url` no frontmatter da task e mover o arquivo de
   `tasks/backlog/` para `tasks/active/` — este é o momento em que a task
   deixa de ser backlog e passa a ser execução.
6. Vincular a issue (nova ou comentada) ao known-issue correspondente na
   knowledge base do material de referência (`reference/{geocloud|elims}/knowledge/known-issues/`), se existir uma referência mapeada na task.
7. Registrar o resultado de cada `GT-ID` processada — issue criada (com
   número/URL) ou comentário adicionado a issue existente (com número/URL) —
   em `issues-criadas.md`.

## Output Format

```markdown
# Issues Criadas — Tomás Ticket

**Data:** YYYY-MM-DD

### GT-NNNN → [Issue nova #N | Comentário em issue existente #N]
**Repositório:** Essencis-Labs/[GeoCloudAI|ELIMS]
**Busca de duplicata:** [resultado da busca — encontrada #N | nenhuma equivalente encontrada]
**Título/Ação:** [título da issue nova, ou resumo do comentário adicionado]
**Labels/Project:** [labels aplicadas], Project #7 — Status/Priority/Stack
**Task movida para:** `squads/guardian/tasks/active/GT-NNNN-{slug}.md`

[repetir por GT-ID processada]

## Resumo
- Issues novas: N
- Comentários em issues existentes: N
```

## Output Example

```markdown
# Issues Criadas — Tomás Ticket

**Data:** 2026-08-21

### GT-0001 → Issue nova #341
**Repositório:** Essencis-Labs/GeoCloudAI
**Busca de duplicata:** nenhuma equivalente encontrada (`gh search issues
"Address/add authorization"` — 0 resultados).
**Título/Ação:** "GeoCloud - Corrigir AllowAnonymous sem justificativa em
POST /Address/add"
**Labels/Project:** `security`, `backend`, `geocloud`; Project #7 —
Status: Backlog, Priority: Crítica, Stack: Backend
**Task movida para:** `squads/guardian/tasks/active/GT-0001-sec-01-allowanonymous-address-add.md`

## Resumo
- Issues novas: 1
- Comentários em issues existentes: 0
```

## Veto Conditions

Reject and redo if ANY of these are true:
- Uma issue foi criada sem busca de duplicata comprovada (sem resultado da
  busca citado no output).
- Uma issue foi criada com severidade rebaixada em relação à task original.
- Uma `GT-ID` aprovada em `gate-promocao.md` não aparece no output (nem como
  issue nova, nem como comentário).
- Uma issue nova não segue o template fixo (Contexto → Achado → Severidade →
  Critério de aceitação → Camada) ou a convenção de título.
- Uma task processada não foi movida de `backlog/` para `active/`, ou não
  teve `issue_url` preenchido.

## Quality Criteria

- [ ] Nenhuma issue criada sem busca de duplicata comprovada (resultado
      citado no output).
- [ ] Toda issue (nova ou comentário) tem evidência concreta e critério de
      aceitação claro.
- [ ] Toda issue nova tem severidade, camada e produto etiquetados
      corretamente e foi adicionada ao Project #7.
- [ ] Toda `GT-ID` de `gate-promocao.md` foi processada e movida para
      `tasks/active/` — nenhuma ficou de fora.
