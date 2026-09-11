---
execution: inline
agent: librarian
inputFile: squads/guardian/output/docs-atualizados.md
outputFile: squads/guardian/output/llml-sincronizada.md
---

# Step 20: Sincronização da LLML

## Context Loading

Load these files before executing:
- `squads/guardian/output/docs-atualizados.md` — fechamentos por PR mesclado desta execução (Step 19), a única fonte do que sincronizar
- `squads/guardian/agents/librarian.agent.md` — persona/principles de Lívia Librarian: nunca decide sozinha o que é verdade, só traduz o que Marta Documentation já verificou
- `squads/guardian/agents/librarian/tasks/sincronizar-run.md` — processo operacional desta sincronização

## Instructions

Ler primeiro `audit-scope.md` desta run e aplicar o gate de branch:

- Se a branch alvo for semanal/de integração (ou uma branch de task derivada dela), **não invocar
  nenhuma skill `LLML-*`**. A Library representa a `main` e não pode receber nem fornecer verdade
  para uma execução cuja branch diverge dela. Gravar o output curto no formato "Sincronização
  omitida" abaixo e avançar sem abrir gate de aprovação da LLML.
- Somente se `audit-scope.md` registrar simultaneamente branch `main`/`master` e autorização
  explícita do usuário para atuação direta nela, executar `sincronizar-run.md` de Lívia Librarian:
  para cada bloco de `docs-atualizados.md`, invocar `LLML-ingest`, `LLML-sync-squads` e depois
  `LLML-approve`. Nunca escrever direto em `Library\`.
- Checkout em `main` sem autorização explícita é veto, não autorização implícita.

## Output Format

The output MUST follow this exact structure:
```markdown
# LLML Sincronizada — {data da execução}

## Propostas Geradas
{lista, uma por origem: bloco de docs-atualizados.md ou entrada de memória do Guardian, skill invocada, página afetada}

## Decisões do Usuário (via LLML-approve)
{lista: página, decisão (aprovado como está / aprovado com modificação / rejeitado / adiado)}

## Sem Ação na LLML
{itens de docs-atualizados.md que não geraram proposta, com justificativa breve — ex.: mudança puramente de frontend sem página correspondente na Library}
```

Para branch semanal/de integração, usar:

```markdown
# Sincronização LLML omitida — {data da execução}

**Branch alvo:** {nome}
**Motivo:** a LLML representa somente a `main`; esta execução atua em branch semanal/de integração.
**Skills LLML invocadas:** nenhuma.
```

## Output Example

```markdown
# LLML Sincronizada — 2026-08-30

## Propostas Geradas
- PR #142 (GT-0001, docs/system/permission-rules.md) → LLML-ingest → Library/Products/GeoCloudAI/S - GeoCloudAI - Reference Tables Map.md
- Memória do Guardian (memories.md, runs.md desta execução) → LLML-sync-squads → Library/Squads-Digest/Guardian/S - Guardian - Memories.md, S - Guardian - Runs Log.md

## Decisões do Usuário (via LLML-approve)
- Reference Tables Map.md: aprovado como está.
- Guardian Memories/Runs Log: adiado, revisão numa próxima sessão.

## Sem Ação na LLML
- PR #144 (GT-0002, mudança só de schema local sem página correspondente na Library ainda — candidato a página nova numa ingestão futura, não criada nesta rodada por não ter sido pedida).
```

## Veto Conditions

Reject and redo if ANY of these are true:
0. Alguma skill `LLML-*` foi invocada para uma execução em branch semanal/de integração, ou em
   `main`/`master` sem ordem explícita do usuário para atuação direta nela.
1. Uma proposta foi gerada sem citar o bloco exato de `docs-atualizados.md` (ou a entrada de memória) que a motivou.
2. Uma página da Library foi editada sem passar por `LLML-ingest`/`LLML-sync-squads` + `LLML-approve`.
3. A sincronização foi reportada como concluída antes da decisão do usuário via `LLML-approve`.

## Quality Criteria

- [ ] A branch alvo e a autorização explícita para atuação direta na main foram verificadas em
      `audit-scope.md` antes de qualquer acesso à LLML.
- [ ] Em branch semanal/de integração, nenhuma skill `LLML-*` foi invocada.
- [ ] Quando a sincronização foi autorizada na `main`, toda proposta cita a origem exata.
- [ ] Quando a sincronização foi autorizada na `main`, `LLML-sync-squads` foi invocada para a
      memória do próprio Guardian, não só para docs de produto.
- [ ] Quando a sincronização foi autorizada na `main`, nenhuma proposta virou Gold sem passar pelo
      gate.
