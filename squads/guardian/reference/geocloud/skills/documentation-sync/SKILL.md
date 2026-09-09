---
name: documentation-sync
description: Localiza todos os documentos vivos que mencionam uma área de código alterada e sinaliza quais precisam de atualização. Use ao final de qualquer tarefa que altere contrato, entidade, permissão, endpoint ou fluxo de negócio.
---

# Documentation Sync

## Objetivo

Impedir a dessincronização entre código e documentação já comprovada em ambos os produtos (`docs/testing.md`, `docs/migrations.md` desatualizados no GeoCloud).

## Entradas

- Resumo da mudança de código (área, entidade, endpoint afetado).
- Produto(s) afetado(s).

## Saídas

- Lista de documentos que mencionam a área (`Documentation/Main/`, `api/docs/*`, `.agents/memory/*`).
- Sinalização de documentos que fazem afirmação factual que a mudança torna falsa.

## Fluxo

1. Buscar pelo nome da entidade/endpoint/fluxo em `Documentation/` e nos demais arquivos `.md`/`.txt` de documentação do produto.
2. Para cada ocorrência, avaliar se o texto ainda é verdadeiro após a mudança.
3. Listar os que precisam de edição e os que podem ser removidos por estarem obsoletos além de correção simples.

## Limitações

- Sinaliza, não edita — a atualização é feita pelo Documentation Architect.
- Não cobre a planilha estrutural canônica (`docs/estrutura/Account_<Produto>_resumo_estrutural.csv`)
  — essa é responsabilidade da skill `structural-spreadsheet-sync`, que deve ser executada em conjunto
  sempre que a mudança afetar entidade/DTO/controller/permissão.

## Exemplos

- Mudança em `[RequiredPermission]` de um endpoint → sinaliza `docs/system/permission-rules.md`; o
  agente/playbook que invocou esta skill também roda `structural-spreadsheet-sync` para atualizar a
  aba `Permissões` da planilha estrutural do produto correspondente (as duas skills não se chamam
  entre si — a orquestração é do agente, ver `MASTER_PROMPT.md` §6).

## Quando usar

Ao final de qualquer tarefa que altere contrato, entidade, permissão, endpoint ou fluxo de negócio.

## Quando não usar

Para mudanças puramente internas sem efeito observável (ex.: renomear variável local).
