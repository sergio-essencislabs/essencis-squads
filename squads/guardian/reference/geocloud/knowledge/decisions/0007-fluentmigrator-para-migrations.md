---
id: ADR-0007
title: GeoCloud usa FluentMigrator para migrations de schema (supersede ADR-0004)
status: aceito
date: 2026-08-21
deciders: Luiz Angelo D'Amore (gerente do projeto)
---

## Contexto

O [ADR-0004](0004-sem-framework-de-migration.md) (30/07/2026) decidiu "não usar
framework de migration — todo schema muda por script SQL manual versionado", com
base no estado do código naquele momento (`Back.Persistence/Migrations/*.cs`
inexistente, sem pacote FluentMigrator no `.csproj`, tabela `VersionInfo` órfã
de uma ferramenta abandonada).

Esse estado **mudou**. Verificação no código real da `main` e da
`cursor/hallucination-full-61b7` (21/08/2026):

- `Back.Persistence/Back.Persistence.csproj` referencia `FluentMigrator 6.2.0` e
  `FluentMigrator.Runner.MySql 6.2.0`.
- `Program.cs` chama `ApplyPendingMigrations(...)` **antes** de aceitar tráfego,
  sob um lock nomeado MySQL (`GET_LOCK`) — ver `MigrationRunnerExtensions`.
- Existe uma suíte versionada `M001`…`M027` (`M0xx_*.cs`), com `[Tags("MySql")]`
  para seleção por motor e idempotência via `Schema.Table(...).Column(...).Exists()`.

Ou seja: o GeoCloud **já roda FluentMigrator de fato**. O ADR-0004 passou a
descrever um estado que não existe mais, e bloqueava novas tarefas de schema
(persistência de idioma, reset de senha, rename `imgLogo`) por ambiguidade sobre
o mecanismo.

Cópia de produto (mesma decisão, perto do código):
`GeoCloudAI/Documentation/Hallucination/adr/0007-fluentmigrator-para-migrations.md`
(PR [#265](https://github.com/Essencis-Labs/GeoCloudAI/pull/265)).

## Decisão

O GeoCloud usa **FluentMigrator** como mecanismo oficial de migrations de schema
(MySQL 8, `AddMySql8()`), aplicado no startup do `Back.API`. Este ADR **supersede
o ADR-0004**. Toda alteração de schema é uma migration `M0xx_*.cs`:

- Numeração `[Migration(YYYYMMDDNNNN, "…")]`, sequencial por data.
- `[Tags("MySql")]` (o runner roda apenas as migrations do motor ativo).
- Idempotente: `if (!Schema.Table(t).Column(c).Exists()) Execute.Sql(...)` para
  ALTER (MySQL 8 não suporta `ADD COLUMN IF NOT EXISTS` de forma portátil), ou
  `Schema...Exists()` para CREATE TABLE.
- SQL cru dentro da migration (consistente com o acesso a dados por Dapper — o
  espírito do ADR-0004 de "sem ORM completo" permanece; o que muda é a
  formalização do runner).

## Consequências

- Novas colunas/tabelas entram como migration `M0xx` (ex.: `M026` adicionou
  `users.layoutLanguage`; `M027` renomeou colunas de imagem para `imgLogo`/
  `imgBanner`; o reset de senha reutiliza a `M021 password_action_token`).
- `policies/banco-de-dados.md`, `playbooks/migration.md` e
  `agents/database-architect.md` deixam de afirmar "sem framework de migration"
  e passam a descrever o processo real (FluentMigrator + tags + idempotência).
- **Drift já observado (registrar):** a tabela `password_action_token` no banco
  vivo **não tem a coluna `created_at`** que a `M021` define — a `M021` foi
  criada antes dessa coluna e o guard `Exists()` pulou a recriação. Reforça a
  regra herdada do ADR-0004: nunca assuma que uma migration documentada foi
  aplicada ao banco vivo. O código de reset foi escrito para não depender de
  `created_at`.
- Migrations continuam **forward-only** na prática (vários `Down()` são no-ops
  de compatibilidade do baseline MySQL).
- [KI-0005](../known-issues/0005-ferramenta-de-migration-ausente.md) permanece
  resolvida: a divergência "doc descreve FluentMigrator inexistente" acabou —
  agora o código e a doc descrevem o mesmo runner.

## Alternativas consideradas

- **Manter o ADR-0004 (só SQL manual) e remover o FluentMigrator:** rejeitada —
  exigiria arrancar `M001..M027` + o runner do `Program.cs` e reescrever tudo
  como scripts SQL + bootstrap próprio; escopo grande, contra o que a `main`
  entrega e roda hoje, sem benefício real.
- **Deixar a ambiguidade:** rejeitada — doc que contradiz o código é exatamente
  o tipo de divergência que este framework existe para eliminar (ver
  `policies/documentacao.md`).
