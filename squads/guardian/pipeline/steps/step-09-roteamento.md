---
execution: inline
agent: chief-architect
inputFile: squads/guardian/output/gate-promocao.md
outputFile: squads/guardian/output/roteamento.md
---

# Step 09: Roteamento

## Context Loading

Load these files before executing:
- `squads/guardian/output/gate-promocao.md` — `GT-IDs` aprovadas para
  promoção pelo usuário no Step 08; base para determinar o que precisa ser
  roteado para implementação.
- As próprias `squads/guardian/tasks/backlog/GT-*.md` aprovadas — texto
  completo de cada task (achado original, impacto técnico, critérios de
  aceitação), para classificar camada/severidade com precisão além do título.
- `squads/guardian/agents/chief-architect.agent.md` — persona
  do Jarvis: roteia cada task aprovada para o especialista de
  camada correto e arbitra decisões cross-cutting, sem repetir a análise dos
  auditores.
- `squads/guardian/agents/chief-architect/tasks/rotear-achados.md`
  — processo operacional a seguir para classificar por camada e montar o
  plano de execução, incluindo grupos de execução paralela/sequencial.
- `squads/guardian/agents/chief-architect/tasks/redigir-gadr.md` — processo
  para redigir um `GADR` quando o achado toca o núcleo compartilhado ou exige
  arbitragem estruturalmente relevante.
- `C:/Software/ClaudeCode/squads/guardian/reference/geocloud` e `C:/Software/ClaudeCode/squads/guardian/reference/elims` —
  necessários apenas para confirmar, quando uma task for ambígua, se ela
  toca o núcleo compartilhado de Conta/Identidade (Account, Entity, Profile,
  Functionality, User) entre GeoCloudAI e E-LIMS.

Esta é uma execução **inline** (persona switching, não subagente) — o
Jarvis monta o plano diretamente na conversa principal, sem
disparar um agente em background.

## Instructions

### Process

1. Ler cada `GT-NNNN` aprovada em `gate-promocao.md` (o texto completo da
   task, não só o título) e classificar por camada dominante: Backend,
   Frontend, Database, ou combinação de camadas quando a task exigir mais de
   uma. Preencher o campo `camada` no frontmatter da própria task.
2. Verificar, para cada task, se ela toca o núcleo compartilhado de Conta/
   Identidade (Account, Entity, Profile, Functionality, User). Se tocar,
   sinalizar tratamento especial — o roteamento deve exigir avaliação de
   impacto nos dois produtos (GeoCloudAI e E-LIMS) antes de rotear para um
   especialista de um produto só, e redigir um `GADR` em
   `squads/guardian/decisions/` (usar `redigir-gadr.md`), preenchendo
   `related_adrs` na(s) task(s) envolvida(s).
3. Priorizar: tasks de segurança crítica sempre antes de dívida técnica no
   mesmo componente/endpoint. Registrar essa prioridade explicitamente na
   ordem do plano.
4. Montar **grupos de execução**: cada grupo é um conjunto de tasks que podem
   rodar concorrentemente sem violar nenhuma regra de veto (mesmo arquivo/
   endpoint nunca no mesmo grupo; núcleo compartilhado nunca isolado a um
   produto só; segurança crítica antes de dívida técnica no mesmo
   componente). Tasks com dependência declarada (schema → backend →
   frontend) ficam em grupos sequenciais distintos. Preencher `grupo_execucao`
   no frontmatter de cada task.
5. Nunca paralelizar tasks que tocam o mesmo arquivo/endpoint — isso gera
   conflito de merge previsível; declarar a ordem sequencial nesse caso.
6. Registrar o plano de roteamento completo em `roteamento.md` — este
   arquivo é o `inputFile` dos Steps 11, 13 e 15 (Backend/Frontend/Database
   Architect), então cada especialista precisa conseguir identificar, só
   lendo este arquivo, quais tasks são dele, em que ordem executar e se o
   grupo dele pode ser disparado em paralelo com outro.

## Output Format

```markdown
# Plano de Roteamento — Jarvis

**Data:** YYYY-MM-DD

| Task | Camada | Grupo | Ordem | Núcleo compartilhado? | Observação |
|---|---|---|---|---|---|
| [GT-NNNN + título curto] | [Backend/Frontend/Database] | [id do grupo] | [N] | [Sim/Não] | [dependência, paralelismo ou justificativa de ordem] |

## Tasks de núcleo compartilhado (tratamento especial)
- [GT-NNNN] — [impacto avaliado em GeoCloudAI e E-LIMS antes de rotear] — GADR: [GADR-NNNN, ou "nenhum necessário"]

## Grupos de execução paralela segura
- Grupo [id]: [GT-IDs] — [por que é seguro paralelizar: camadas independentes, sem dependência declarada, sem arquivo/endpoint em comum]

## Grupos sequenciais
- [GT-IDs] — [motivo: dependência de schema, mesmo arquivo/endpoint, ou núcleo compartilhado]

## Ordem de merge sugerida
[ordem final de merge, mesmo que a implementação tenha rodado em paralelo — a integração é sempre sequencial]
```

## Output Example

```markdown
# Plano de Roteamento — Jarvis

**Data:** 2026-08-21

| Task | Camada | Grupo | Ordem | Núcleo compartilhado? | Observação |
|---|---|---|---|---|---|
| GT-0001 — AllowAnonymous sem justificativa em POST /Address/add | Backend | A | 1 | Não | Bloqueante — trata antes da task de dívida no mesmo controller |
| GT-0002 — Duplicação de lógica de endereço em 2 controllers | Backend | A | 2 | Não | Depende da correção de segurança acima estar mesclada primeiro |
| GT-0003 — Ajuste de tela de endereço (Angular) | Frontend | B | 1 | Não | Independente do backend — não consome o endpoint alterado |

## Tasks de núcleo compartilhado (tratamento especial)
- (nenhuma nesta rodada)

## Grupos de execução paralela segura
- Grupo A (Backend) e Grupo B (Frontend) podem rodar em paralelo — camadas
  independentes, sem dependência declarada, nenhum arquivo em comum.

## Grupos sequenciais
- Dentro do Grupo A: GT-0001 antes de GT-0002 — mesmo controller, conflito de
  merge previsível se paralelizados.

## Ordem de merge sugerida
1. GT-0001 (Backend) → 2. GT-0002 (Backend) → 3. GT-0003 (Frontend, pode
   mesclar a qualquer momento após aberto, é independente).
```

## Veto Conditions

Reject and redo if ANY of these are true:
- Alguma task aprovada em `gate-promocao.md` não aparece no plano de
  roteamento.
- Uma task de núcleo compartilhado foi roteada para um único produto sem
  nota de avaliação de impacto no produto irmão e sem `GADR` associado.
- Duas tasks que tocam o mesmo arquivo/endpoint foram colocadas no mesmo
  grupo de execução paralela.
- Uma task de segurança crítica foi ordenada depois de uma task de dívida
  técnica no mesmo componente.

## Quality Criteria

- [ ] Toda task aprovada aparece no plano de roteamento, nenhuma é
      esquecida.
- [ ] Tasks de núcleo compartilhado estão explicitamente marcadas, com GADR
      quando aplicável.
- [ ] Dependências entre tasks do mesmo componente estão declaradas.
- [ ] Tasks de segurança crítica aparecem antes de dívida técnica no mesmo
      componente.
- [ ] Todo grupo marcado como paralelo respeita as regras de veto.
