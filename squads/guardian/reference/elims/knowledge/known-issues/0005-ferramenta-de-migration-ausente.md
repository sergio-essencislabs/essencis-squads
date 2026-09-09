---
id: KI-0005
title: Ferramenta de migration documentada mas não implementada
severidade: média
status: resolvida
produto: ELIMS
---

## Descrição

`backend/docs/migrations.md` do ELIMS documenta o uso de FluentMigrator 6.2, mas o `.csproj` atual não referencia o pacote, não há pasta `Migrations/`, e não há chamada de runner em `Startup.cs`. O dump ainda tem a tabela `"VersionInfo"` (marca de FluentMigrator), sugerindo que já foi usado e depois abandonado sem atualizar a documentação.

## Ação recomendada (histórico — já executada, ver Resolução)

Database Architect + Chief Architect decidiriam via ADR: reintroduzir FluentMigrator, adotar scripts SQL versionados manualmente (padrão já usado), ou outra ferramenta — e atualizar `docs/migrations.md` para refletir a realidade escolhida.

## Resolução

Decidido via [ADR-0004](../decisions/0004-sem-framework-de-migration.md) (gerente do projeto, Luiz Angelo D'Amore): não reintroduzir FluentMigrator. Todo schema muda por script SQL manual, versionado e idempotente — padrão que `policies/banco-de-dados.md` e `playbooks/migration.md` já assumiam. `ELIMS/backend/docs/migrations.md` foi reescrito para refletir a realidade (bootstrap via `baseline.sql` + scripts manuais), removendo a narrativa do runner M001–M003 que nunca existiu no código.

## Dono

Database Architect.
