# Índice de Decisões Arquiteturais (ADRs do framework)

Decisões arquiteturais do próprio `geocloud-ai-framework`. Para decisões arquiteturais do produto, ver `docs/implementations/` no GeoCloud — este índice não as duplica.

Use `scripts/new-adr.ps1` para criar uma nova entrada (numeração sequencial, template em `templates/adr.md`).

| ID | Título | Status | Data |
|---|---|---|---|
| [ADR-0001](knowledge/decisions/0001-skills-e-rules-nativas-do-cursor.md) | Adotar Skills e Rules nativas do Cursor como camada de execução | Aceito | 2026-07-30 |
| [ADR-0002](knowledge/decisions/0002-knowledge-base-federada.md) | Knowledge base federada (não centralizada) | Aceito | 2026-07-30 |
| [ADR-0003](knowledge/decisions/0003-agentes-como-personas-de-prompt.md) | Agentes como personas de prompt, não como motor de orquestração | Aceito | 2026-07-30 |
| [ADR-0004](knowledge/decisions/0004-sem-framework-de-migration.md) | Não utilizar framework/ferramenta de migration — schema muda por script SQL manual versionado | Superado por ADR-0007 | 2026-07-30 |
| [ADR-0005](knowledge/decisions/0005-chief-e-documentation-architect-sempre-ativos.md) | Chief Architect e Documentation Architect sempre ativos via policy `alwaysApply`, não como agentes model-invoked | Aceito | 2026-07-31 |
| [ADR-0006](knowledge/decisions/0006-geocloud-usa-mysql.md) | GeoCloud usa MySQL 8 com MySqlConnector — correção da premissa PostgreSQL que constava na documentação | Aceito | 2026-08-15 |
| [ADR-0007](knowledge/decisions/0007-fluentmigrator-para-migrations.md) | GeoCloud usa FluentMigrator para migrations de schema (supersede ADR-0004) | Aceito | 2026-08-21 |
