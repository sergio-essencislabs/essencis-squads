---
playbook: Migration (banco de dados)
gatilho: necessidade de alterar schema (nova tabela, coluna, índice, relacionamento)
---

# Playbook — Migration

> "Migration" = script SQL manual versionado. Não usamos framework/ferramenta de migration (ver
> [ADR-0004](../knowledge/decisions/0004-sem-framework-de-migration.md)).

1. **Database Architect** confirma que não existe coluna/tabela/relacionamento equivalente (`duplicate-detector`, `dependency-mapper`).
2. Se a mudança toca o núcleo compartilhado de Conta/Identidade → `sincronizacao-nucleo-compartilhado.md` primeiro.
3. Escrever o script idempotente (`IF NOT EXISTS`) ou com rollback explícito.
4. Aplicar em ambiente de desenvolvimento e rodar **Database Diff** (skill) para confirmar que o schema real corresponde ao esperado — nunca assumir que "o script existe" significa "foi aplicado".
5. **Security Architect** revisa se a mudança afeta `functionality`/`profilefunctionality`/qualquer coluna de permissão.
6. **Backend Architect** implementa a camada Persistence sobre o novo schema.
7. **Documentation Architect** atualiza `attribute-mapping.md`/schema documentado do produto.
8. Registrar a migration em `knowledge/known-issues/` se ela resolve um drift já catalogado (ex.: aplicar `seed_functionality_keys.sql` que estava pendente).

## Não fazer

- Migration destrutiva (`DROP COLUMN`/`DROP TABLE`) sem plano de rollback e aprovação do Chief Architect.
- Assumir que uma migration documentada em código já foi aplicada ao banco vivo sem confirmar.

---

## Evoluir schema no ELIMS (absorvido da SOP `add-database-table`)

Não existe ferramenta de migration no código — ver [ADR-0004](../knowledge/decisions/0004-sem-framework-de-migration.md).
O schema muda por script SQL versionado, aplicado à mão.

> **Atenção:** `backend/docs/migrations.md` no produto descreve um runner FluentMigrator 6.2
> com pasta `Back.Persistence.Migrations`. **Isso não está no código** — sem pacote no
> `.csproj`, sem pasta. Confirme a ausência antes de "criar uma migration" seguindo aquele
> documento.

Convenções do motor (MySQL 8) estão em [policies/banco-de-dados.md](../policies/banco-de-dados.md).
Em resumo, ao adicionar tabela ou coluna:

- Colunas em camelCase (`accountId`, `userId`, `register`), tabelas em minúsculas.
  Módulo novo pode usar prefixo com underscore, no padrão já adotado por `finance_*` e
  `chat_*`.
- `userId` + `register datetime(6)` nas tabelas com dono; FK nomeada `fk_<tabela>_<ref>`.
- `ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci`.
- Idempotência em MySQL não tem `ADD COLUMN IF NOT EXISTS` para toda versão — use o
  padrão com `information_schema` + `PREPARE` documentado na policy.
- Depois de aplicar, confirme no banco vivo. Nunca assuma que um script documentado foi
  executado: é a causa raiz de drift já catalogada em `knowledge/known-issues/`.
