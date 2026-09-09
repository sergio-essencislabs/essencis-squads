---
description: Convenções de schema MySQL e migrations para ELIMS
globs: **/*.sql
alwaysApply: false
---

# Banco de Dados

- **"Migration" aqui sempre significa script SQL manual versionado — nunca uma ferramenta/lib de
  migration** (FluentMigrator, EF Core Migrations, Flyway, etc.). Ver
  [ADR-0004](../knowledge/decisions/0004-sem-framework-de-migration.md).
- Tabelas e colunas em **minúsculas, sem aspas** (`account`, `entityid`) — nunca `CamelCase` ou `"Quoted"`.
- FK por **convenção de nome**: `{entidade}id` (ex.: `accountid`, `entityid`). Não há PK/FK/UNIQUE formais na maioria das tabelas — não assuma que o banco garante integridade; valide na camada de aplicação.
- Toda migration é um script SQL versionado, **idempotente** (`IF NOT EXISTS`) ou acompanhado de rollback explícito.
- Nunca assumir que uma migration documentada foi de fato aplicada ao banco vivo — confirme antes de construir sobre ela (causa raiz de um drift já documentado: `functionality.key` esperado pelo código mas ausente no banco vivo).
- Seeds de dados de referência (`seed_functionality_keys.sql`) devem ser re-executáveis sem duplicar linhas.

```sql
-- ✅ BOM — idempotente
ALTER TABLE functionality ADD COLUMN IF NOT EXISTS key VARCHAR(100);

-- ❌ EVITAR — falha na segunda execução
ALTER TABLE functionality ADD COLUMN key VARCHAR(100);
```

## Motor: MySQL 8

O ELIMS usa **MySQL 8** com o driver **MySqlConnector** — ver
[ADR-0006](../knowledge/decisions/0006-elims-migra-para-mysql.md). Não há Npgsql nem qualquer
resquício de PostgreSQL no código atual; documentação que ainda afirme o contrário está
desatualizada e deve ser corrigida, não contornada.

- Identificador reservado vai entre **crases** (`` `key` ``), nunca aspas duplas.
- `AUTO_INCREMENT` + `SELECT LAST_INSERT_ID()` para recuperar a chave gerada — não
  existe `RETURNING`.
- Não existe `ILIKE`; a collation padrão (`utf8mb4_0900_ai_ci`) já é case-insensitive,
  então `LIKE` basta.
- Dump de referência gerado com **`mysqldump`**; o dump vivo do produto está em
  `ELIMS DB/elims.sql`. Use `--hex-blob` sempre que houver coluna geométrica —
  sem isso a geometria corrompe no dump.
- Coluna geométrica exige MySQL 8: `GEOMETRY SRID 4326` com índice `SPATIAL` (que
  obriga a coluna a ser `NOT NULL`).

### Armadilha de eixo em SRID 4326

O SRID 4326 no MySQL segue a definição EPSG, que põe **latitude primeiro** — o inverso
do que praticamente toda ferramenta GIS usa. Escreva por `ST_GeomFromGeoJSON(...,1,4326)`
e leia por `ST_AsGeoJSON`, que trafegam em lon/lat conforme a RFC 7946. WKT cru só com
`'axis-order=long-lat'` explícito.

Área planar deve ser calculada em SRS projetado (SIRGAS 2000 / UTM 23S, EPSG 31983),
nunca em 4326 direto. E `ST_Intersection` sobre SRS geográfico devolve
`GEOMETRYCOLLECTION` quando as bordas apenas se tocam — confira `ST_GeometryType` antes
de passar o resultado para `ST_Area`, que recusa esse tipo.

```sql
-- ✅ BOM (MySQL) — idempotente via information_schema
SET @has_col := (SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'functionality' AND COLUMN_NAME = 'key');
SET @sql := IF(@has_col = 0, 'ALTER TABLE `functionality` ADD COLUMN `key` VARCHAR(100) NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
```
