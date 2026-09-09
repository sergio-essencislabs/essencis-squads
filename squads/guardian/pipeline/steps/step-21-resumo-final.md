---
type: checkpoint
outputFile: squads/guardian/output/resumo-final.md
---

# Step 21: Resumo Final

## Context Loading

Load these files before presenting this checkpoint:
- `squads/guardian/output/issues-criadas.md` — issues abertas/comentadas no GitHub Project Essencis-Labs
- `squads/guardian/output/aprovacao-prs.md` — decisão final do usuário sobre quais PRs foram mesclados
- `squads/guardian/output/docs-atualizados.md` — fechamento de documentação e knowledge base por PR mesclado
- `squads/guardian/tasks/completed/` (arquivos movidos nesta execução pelo Step 17) e `squads/guardian/tasks/backlog/` (tasks que ficaram no Gate de Promoção, Step 08, sem promoção) — para reportar o estado final do hub de tasks

## Purpose

Este é o checkpoint final da execução. Não exige nenhuma decisão bloqueante do usuário — a run já está completa — mas é apresentado como checkpoint para que o usuário revise o ciclo completo (escopo → tasks → gate → roteamento → implementação → revisão → aprovação → documentação) antes de considerar a execução encerrada, e para dar oportunidade de apontar qualquer acompanhamento necessário na próxima execução.

## Instructions

Apresentar ao usuário um resumo consolidado com:

1. Link para cada issue criada ou comentada no GitHub Project Essencis-Labs nesta execução (de `issues-criadas.md`).
2. Link/referência para cada PR aberto, indicando se foi mesclado, rejeitado ou segue pendente para rework em uma próxima execução (de `aprovacao-prs.md`).
3. Lista de docs/system, planilhas estruturais e entradas de knowledge base atualizadas (de `docs-atualizados.md`).
4. Estado final do hub de tasks: quantas `GT-NNNN` foram movidas para `completed/` nesta execução, e quantas permanecem em `backlog/` (não promovidas) ou `active/` (promovidas mas com pendência de fechamento).
5. Confirmação explícita de que a execução está completa — informar o usuário, sem pedir aprovação adicional.

## Output Format

The output MUST follow this exact structure:
```markdown
# Resumo Final — {data da execução}

## Issues no Backlog
{lista com link/referência de cada issue criada ou comentada}

## PRs desta Execução
{lista com referência, status (mesclado/rejeitado/pendente para rework), e task original}

## Docs/Knowledge Atualizados
{lista dos arquivos de documentação/knowledge tocados}

## Estado do Hub de Tasks
**Movidas para completed/:** {lista de GT-NNNN}
**Permanecem em active/ (pendência de fechamento):** {lista de GT-NNNN + o que falta}
**Permanecem em backlog/ (não promovidas nesta execução):** {lista de GT-NNNN}

## Status da Execução
Execução do squad Guardian concluída em {data}.
{qualquer pendência explícita para a próxima execução, ou "nenhuma pendência aberta"}
```

## Output Example

```markdown
# Resumo Final — 2026-08-21

## Issues no Backlog
- GeoCloud - Corrigir AllowAnonymous sem justificativa em POST /Address/add (issue #322, nova)
- Comentário adicional na issue #208 (Geocloud - Bloqueio e tentativas de acesso) sobre achado relacionado

## PRs desta Execução
- PR #142 — GT-0001 — mesclado
- PR #144 — GT-0002 — mesclado
- PR #145 — GT-0003 — bloqueado por Otávio Review, retorna a Flávia Frontend na próxima execução

## Docs/Knowledge Atualizados
- docs/system/permission-rules.md
- docs/system/auth-overview.md
- docs/system/schema-testrequest.md
- Planilha_GEOCLOUD_permissoes.xlsx
- reference/geocloud/knowledge/known-issues/0002-address-add-allowanonymous.md (marcado resolvido)
- knowledge/patterns/permissao-explicita-por-endpoint.md (novo)
- .agents/memory/geocloud-ai/schema-legado.md (novo)

## Estado do Hub de Tasks
**Movidas para completed/:** GT-0001, GT-0002
**Permanecem em active/ (pendência de fechamento):** GT-0003 — falta rework de nomenclatura no PR #145
**Permanecem em backlog/ (não promovidas nesta execução):** nenhuma

## Status da Execução
Execução do squad Guardian concluída em 2026-08-21.
Pendência para a próxima execução: PR #145 (GT-0003, consolidação do modal de endereço) precisa de rework em nomenclatura antes de reentrar na revisão.
```

## Notes

- Não bloquear a conclusão do pipeline aguardando input adicional — este checkpoint é informativo por padrão. Só reabrir para input se o usuário explicitamente quiser corrigir algo no resumo apresentado.
- Se houver PRs pendentes de rework, deixá-los claramente registrados como ponto de partida da próxima execução do squad.
