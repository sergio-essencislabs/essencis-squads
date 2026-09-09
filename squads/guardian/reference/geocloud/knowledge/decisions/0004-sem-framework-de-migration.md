---
id: ADR-0004
title: Não utilizar framework/ferramenta de migration — schema muda por script SQL manual versionado
status: superado por ADR-0007
date: 2026-07-30
deciders: Luiz Angelo D'Amore (gerente do projeto)
---

> **Superado em 21/08/2026 pelo [ADR-0007](0007-fluentmigrator-para-migrations.md).**
> O código passou a ter FluentMigrator 6.2 de fato (`M001`…`M027`, runner no
> `Program.cs`). Este arquivo permanece como registro histórico da decisão de
> 30/07/2026 e do espírito que ainda vale: SQL cru, sem ORM, nunca assumir que
> a migration documentada foi aplicada ao banco vivo.

## Contexto

O GeoCloud documenta em `api/docs/migrations.md` um runner completo baseado em **FluentMigrator 6.2**
(`M001_Baseline`, `M002_AuditColumns`, `M003_SoftDelete`, advisory lock, `VersionInfo`), descrito como
já wireado em `Startup.cs`/`Program.cs`.

Essa descrição não corresponde ao código real:

- Não existe nenhum arquivo em `Back.Persistence/Migrations/*.cs` no repositório.
- O `.csproj` de `Back.Persistence` não referencia o pacote `FluentMigrator`.
- A única menção a FluentMigrator no código é um comentário em
  `Back.IntegrationTests/Fixtures/MySQLTestDatabase.cs` explicando que os testes **evitam**
  o FluentMigrator justamente por "ordering problems" no `baseline.sql` legado.
- O dump do banco ainda tem a tabela `"VersionInfo"`, indicando que a ferramenta foi usada em algum
  momento e depois abandonada, sem atualizar a documentação (`KI-0005`).

Isso já havia sido catalogado como divergência aberta em
`knowledge/known-issues/0005-ferramenta-de-migration-ausente.md`, que recomendava decidir entre
reintroduzir FluentMigrator ou formalizar scripts SQL manuais — que já é o padrão descrito em
`policies/banco-de-dados.md` ("Toda migration é um script SQL versionado, idempotente") e em
`playbooks/migration.md`.

## Decisão

GeoCloud (e as bases `GeoCloud`/`GeoCloud`) **não usam nenhum framework/ferramenta de
migration** (FluentMigrator, EF Core Migrations, Flyway, Liquibase, etc.).

Toda alteração de schema é um **script SQL manual, versionado no repositório do produto e
idempotente** (`IF NOT EXISTS` / `IF EXISTS`, ou com plano de rollback explícito quando destrutiva),
seguindo exatamente o que já está descrito em `policies/banco-de-dados.md` e no playbook
`playbooks/migration.md` deste framework. Esses dois documentos já estavam corretos — o que faltava
era esta decisão explícita e a correção da documentação de produto que ainda descrevia a ferramenta
abandonada como se estivesse ativa.

## Consequências

- `KI-0005` é encerrada como resolvida (ver atualização no próprio arquivo), referenciando este ADR.
- `GeoCloudAI/api/docs/migrations.md` deixa de descrever um runner FluentMigrator inexistente e passa
  a documentar o processo real: bootstrap via `baseline.sql`/`init_db.sql` + scripts SQL manuais
  subsequentes em `Scripts/*.sql`, aplicados manualmente e conferidos com a skill `database-diff`.
- Nenhuma mudança de código é necessária no GeoCloud (não há runner ativo para remover) — o esforço é
  inteiramente de correção documental.
- `policies/banco-de-dados.md` e `playbooks/migration.md` recebem uma frase de desambiguação: o termo
  "migration" nestes documentos sempre significa "script SQL manual versionado", nunca uma
  ferramenta/lib de migration.
- Toda nova alteração de schema segue o playbook `migration.md` já existente (nenhuma mudança de
  processo — apenas confirmação formal de que ele é a única via).

## Alternativas consideradas

- **Reintroduzir FluentMigrator de fato** (implementar `M001`-`M003`, wiring em `Startup.cs`): rejeitada
  por decisão do gerente do projeto — preferência explícita por scripts SQL manuais, que já é o padrão
  de fato usado/GeoCloud fora da documentação aspiracional do `migrations.md`.
- **Manter a ambiguidade** (deixar `migrations.md` como está, sem decisão formal): rejeitada — doc que
  descreve algo não implementado como implementado é o tipo de divergência que este framework existe
  para eliminar (ver `policies/documentacao.md`).
