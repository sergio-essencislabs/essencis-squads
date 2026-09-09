---
name: documentation-sync
description: Localiza todos os documentos vivos que mencionam uma área de código alterada e sinaliza quais precisam de atualização. Use ao final de qualquer tarefa que altere contrato, entidade, permissão, endpoint ou fluxo de negócio.
---

# Documentation Sync

## Objetivo

Impedir a dessincronização entre código e documentação já comprovada no ELIMS (`docs/testing.md`, `docs/migrations.md` desatualizados).

## Entradas

- Resumo da mudança de código (área, entidade, endpoint afetado).
- Produto(s) afetado(s).

## Saídas

- Lista de documentos que mencionam a área (`Documentation/Main/`, `docs/system/*`, `.agents/memory/*`, `knowledge/*` se cross-projeto).
- Sinalização de documentos que fazem afirmação factual que a mudança torna falsa.

## Fluxo

1. Buscar pelo nome da entidade/endpoint/fluxo em `Documentation/Main/` e nos demais arquivos `.md`/`.txt` de documentação do produto.
2. Para cada ocorrência, avaliar se o texto ainda é verdadeiro após a mudança.
3. Listar os que precisam de edição e os que podem ser removidos por estarem obsoletos além de correção simples.

## Limitações

- Sinaliza, não edita — a atualização é feita pelo Documentation Architect.
- Não cobre a planilha estrutural canônica (`Documentation/Main/Planilha_ELIMS_main.xlsx`)
  — essa é responsabilidade da skill `structural-spreadsheet-sync`, que deve ser executada em conjunto
  sempre que a mudança afetar entidade/DTO/controller/permissão.

## Exemplos

- Mudança em `[RequiredPermission]` de um endpoint → sinaliza a aba `Permissões` da planilha da branch
  (via `structural-spreadsheet-sync`) e qualquer `docs/system/permission-rules.md` restante.

## Quando usar

Ao final de qualquer tarefa que altere contrato, entidade, permissão, endpoint ou fluxo de negócio.

## Quando não usar

Para mudanças puramente internas sem efeito observável (ex.: renomear variável local).
