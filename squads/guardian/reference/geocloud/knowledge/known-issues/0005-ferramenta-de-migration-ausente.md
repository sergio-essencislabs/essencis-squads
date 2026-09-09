---
id: KI-0005
title: Ferramenta de migration documentada mas não implementada
severidade: média
status: resolvida
produto: GeoCloud
---

## Descrição

`api/docs/migrations.md` do GeoCloud documenta o uso de FluentMigrator 6.2, mas o `.csproj` atual não referencia o pacote, não há pasta `Migrations/`, e não há chamada de runner em `Startup.cs`. O dump ainda tem a tabela `"VersionInfo"` (marca de FluentMigrator), sugerindo que já foi usado e depois abandonado sem atualizar a documentação.

## Ação recomendada (histórico — já executada, ver Resolução)

Database Architect + Chief Architect decidiriam via ADR: reintroduzir FluentMigrator, adotar scripts SQL versionados manualmente (padrão já usado), ou outra ferramenta — e atualizar `docs/migrations.md` para refletir a realidade escolhida.

## Resolução

A divergência original ("doc descreve FluentMigrator; código não tem") foi
fechada em duas etapas:

1. **30/07/2026 — [ADR-0004](../decisions/0004-sem-framework-de-migration.md):**
   formalizou scripts SQL manuais e mandou a documentação parar de descrever um
   runner que não existia.
2. **21/08/2026 — [ADR-0007](../decisions/0007-fluentmigrator-para-migrations.md)
   (supersede ADR-0004):** o código da `main`/`hallucination` passou a ter
   FluentMigrator 6.2 de fato (`M001`…`M027`, `ApplyPendingMigrations` no
   `Program.cs`). A policy, o playbook e o Database Architect foram realinhados
   a esse runner. A divergência doc×código desta KI não existe mais.

## Dono

Database Architect.
