---
id: KI-0006
title: Relatório de implementação #29 descreve sistema de auditoria que não existe no código
severidade: média
status: aberta
produto: ELIMS
---

## Descrição

`backend/docs/implementations/29-migrations-soft-delete-auditoria.md` descreve, com grande nível de
detalhe (arquivos, trechos de código, verificação end-to-end), a entrega de:

- Colunas de auditoria `created_at/by`, `updated_at/by` em toda tabela de domínio.
- `Back.Domain/Abstractions/ICurrentUserAccessor` + `Back.API/Auth/HttpContextCurrentUserAccessor`.
- `Back.Persistence/Auditing/AuditStamp.cs` (`ForInsert`/`ForUpdate`).
- Runner FluentMigrator (`M001_Baseline`, `M002_AuditColumns`, `M003_SoftDelete`).

Nenhum desses arquivos existe no código real (confirmado por busca recursiva: 0 ocorrências de
`ICurrentUserAccessor`, `_currentUser`, `AuditStamp`, `Migrations/*.cs`, e nenhuma referência a
FluentMigrator no `.csproj`).

O que **de fato existe** em `Back.Persistence/Repositories/RegionRepository.cs` (e presumivelmente
outros repositórios, não auditados individualmente) é **apenas** o soft-delete: SQL com
`deleted_at`/`deleted_by` escrito diretamente nas queries, sem colunas `created_at/by`/`updated_at/by`
e sem nenhuma abstração de usuário atual.

Ou seja: uma fração real do trabalho (soft-delete) foi implementada diretamente em SQL, mas o
relatório descreve uma entrega muito mais ampla (auditoria completa + migration runner) que nunca
chegou a existir no código — exatamente o padrão já visto em `KI-0005` (doc descreve mais do que o
código faz).

## Ação recomendada

- Confirmar, repositório por repositório (ou por amostragem), quais tabelas realmente têm
  `deleted_at`/`deleted_by` no banco vivo (skill `database-diff`) antes de assumir que o soft-delete
  está 100% aplicado como o relatório sugere ("89 de ~90 repositórios").
- Se colunas de auditoria (`created_at/by`, `updated_at/by`) forem desejadas, tratar como uma
  feature nova (playbook `nova-feature.md` / `migration.md`), não como algo "já entregue".
- Corrigir ou anotar `implementations/29-migrations-soft-delete-auditoria.md` para não induzir erro
  sobre o que está implementado (ver `policies/documentacao.md`).

## Dono

Backend Architect + Documentation Architect.
