---
execution: subagent
agent: task-curator
inputFile: squads/guardian/output/achados-selecionados.md
outputFile: squads/guardian/output/tasks-geradas.md
model_tier: fast
---

# Step 07: Geração de Tasks

Este step **nunca chama `gh`** — a criação de issue só acontece depois do
Gate de Promoção, no Step 10. Aqui, Tomás só transcreve achados/quebra por
camada em `.md` estruturados, prontos para revisão e, mais tarde, promoção.

Em **modo retomar-promocao** (ver `audit-scope.md`, Step 01), este step vira
stub: as `GT-*.md` selecionadas já existem, então gravar
`tasks-geradas.md` só com a nota "N/A — modo retomar-promocao, tasks já
existentes: [lista]" e avançar direto para o Gate (Step 08).

## Context Loading

Load these files before executing:
- `squads/guardian/output/achados-selecionados.md` — itens aprovados pelo
  usuário no Step 06: achados de auditoria (TD-NN/SEC-NN/DOC-NN) ou linhas da
  quebra por camada de `plano-implementacao.md` (modo implementacao-direta).
- `squads/guardian/output/audit-divida-tecnica.md`, `audit-seguranca.md`,
  `audit-documentacao.md` — os relatórios completos de origem (modo
  auditoria-nova); necessários para recuperar evidência (arquivo:linha),
  severidade e descrição integral de cada ID selecionado.
- `squads/guardian/output/plano-implementacao.md` — quebra por camada e GADR
  relacionado (modo implementacao-direta).
- `squads/guardian/tasks/_template.md` — template de task a preencher.
- `squads/guardian/agents/task-curator.agent.md` — persona de Tomás Ticket.
- `squads/guardian/agents/task-curator/tasks/gerar-tasks.md` — processo
  operacional desta etapa.

## Instructions

### Process

1. Para cada item aprovado em `achados-selecionados.md`:
   - **Modo auditoria-nova**: localizar o achado completo no relatório de
     origem (TD → `audit-divida-tecnica.md`, SEC → `audit-seguranca.md`, DOC
     → `audit-documentacao.md`) para recuperar evidência, severidade e
     descrição integral.
   - **Modo implementacao-direta**: localizar a linha correspondente em
     `plano-implementacao.md` (escopo da camada, dependências, GADR).
2. Determinar o próximo `GT-NNNN` livre escaneando `squads/guardian/tasks/{backlog,active,completed}/*.md` — nunca reaproveitar um número já usado.
3. Preencher o template (`tasks/_template.md`) com fidelidade total ao achado/
   plano original: nunca rebaixar severidade, nunca resumir a evidência a
   ponto de perdê-la, nunca inventar critério de aceite que o relatório não
   sustenta.
4. Salvar o arquivo em `squads/guardian/tasks/backlog/GT-NNNN-{achado-id-lower}-{slug}.md`
   (ou `GT-NNNN-feature-{slug}.md` em modo implementacao-direta), com
   `status: backlog` e `run_origem` apontando para esta execução.
5. Registrar o resultado — cada `GT-NNNN` gerada, achado/linha de origem, e
   caminho do arquivo — em `tasks-geradas.md`.

## Output Format

```markdown
# Tasks Geradas — Tomás Ticket

**Data:** YYYY-MM-DD

### [ID do achado, ou linha da quebra por camada] → GT-NNNN
**Arquivo:** `squads/guardian/tasks/backlog/GT-NNNN-{slug}.md`
**Título:** [título da task]
**Camada:** [Backend/Frontend/Database/Documentação — ainda provisória; Jarvis confirma no roteamento]

[repetir por item processado]

## Resumo
- Tasks geradas: N
```

## Output Example

```markdown
# Tasks Geradas — Tomás Ticket

**Data:** 2026-08-21

### SEC-01 → GT-0001
**Arquivo:** `squads/guardian/tasks/backlog/GT-0001-sec-01-allowanonymous-address-add.md`
**Título:** Corrigir AllowAnonymous sem justificativa em POST /Address/add
**Camada:** Backend (provisória)

## Resumo
- Tasks geradas: 1
```

## Veto Conditions

Reject and redo if ANY of these are true:
- Uma task foi gerada com severidade rebaixada em relação ao achado
  original do auditor.
- Um item aprovado em `achados-selecionados.md` não aparece no output (nenhuma
  `GT-NNNN` correspondente).
- Uma `GT-NNNN` reaproveitou um número já usado por outra task existente.
- Qualquer chamada `gh` foi feita neste step (issue/board só no Step 10).
- Uma task foi salva fora de `squads/guardian/tasks/backlog/`.

## Quality Criteria

- [ ] Toda task gerada preenche as seções obrigatórias do template (nenhuma
      omitida em silêncio — usar "N/A" explícito quando não aplicável).
- [ ] Toda task tem evidência concreta e critério de aceitação claro.
- [ ] Todo item de `achados-selecionados.md` foi processado — nenhum ficou
      de fora do output.
