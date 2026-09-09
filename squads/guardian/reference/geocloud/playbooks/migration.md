---
playbook: Migration (banco de dados)
gatilho: necessidade de alterar schema (nova tabela, coluna, índice, relacionamento)
---

# Playbook — Migration

> "Migration" = classe FluentMigrator `M0xx_*.cs` em `Back.Persistence/Migrations/`,
> aplicada no startup do `Back.API`. Ver
> [ADR-0007](../knowledge/decisions/0007-fluentmigrator-para-migrations.md)
> (supersede ADR-0004). SQL cru dentro da classe; sem ORM.

1. **Database Architect** confirma que não existe coluna/tabela/relacionamento equivalente (`duplicate-detector`, `dependency-mapper`).
2. Se a mudança toca o núcleo compartilhado de Conta/Identidade → `sincronizacao-nucleo-compartilhado.md` primeiro.
3. Criar `M0xx_<Nome>.cs` com `[Migration(YYYYMMDDNNNN, "…")]` e `[Tags("MySql")]`. Guard `Schema.Table(...).Column(...).Exists()` antes de cada ALTER.
4. Subir a API em desenvolvimento (o runner aplica o pendente) e rodar **Database Diff** (skill) para confirmar que o schema real corresponde ao esperado — nunca assumir que "a classe existe" significa "foi aplicada no vivo".
5. **Security Architect** revisa se a mudança afeta `functionality`/`profilefunctionality`/qualquer coluna de permissão.
6. **Backend Architect** implementa a camada Persistence sobre o novo schema.
7. **Documentation Architect** atualiza `attribute-mapping.md`/schema documentado do produto.
8. Registrar a migration em `knowledge/known-issues/` se ela resolve um drift já catalogado (ex.: aplicar `seed_functionality_keys.sql` que estava pendente).

## Não fazer

- Migration destrutiva (`DROP COLUMN`/`DROP TABLE`) sem plano de rollback e aprovação do Chief Architect.
- Assumir que uma migration documentada em código já foi aplicada ao banco vivo sem confirmar.
- Reabrir o ADR-0004 para escrever só SQL solto em `Scripts/*.sql` — o runner oficial é o FluentMigrator.

---

## Evoluir schema no GeoCloud (absorvido da SOP `add-database-table`)

O runner é FluentMigrator 6.2 (`FluentMigrator` + `FluentMigrator.Runner.MySql` no
`.csproj` de `Back.Persistence`). `Program.cs` chama `ApplyPendingMigrations`
antes de aceitar tráfego, sob `GET_LOCK`. A suíte atual vai de `M001` a `M027`.

Convenções do motor (MySQL 8) estão em [policies/banco-de-dados.md](../policies/banco-de-dados.md).
Em resumo, ao adicionar tabela ou coluna:

- Colunas em camelCase (`accountId`, `userId`, `register`), tabelas em minúsculas.
  Módulo novo pode usar prefixo com underscore, no padrão já adotado por `finance_*` e
  `chat_*`.
- `userId` + `register datetime(6)` nas tabelas com dono; FK nomeada `fk_<tabela>_<ref>`.
- `ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci`.
- Idempotência: `if (!Schema.Table(t).Column(c).Exists()) Execute.Sql(...)`.
  O padrão `information_schema` + `PREPARE` continua válido para SQL avulso
  (seeds, dumps), não para schema novo.
- Depois de aplicar, confirme no banco vivo. Nunca assuma que uma `M0xx` versionada
  foi executada: é a causa raiz de drift já catalogada (`functionality.key`,
  `password_action_token.created_at`).
