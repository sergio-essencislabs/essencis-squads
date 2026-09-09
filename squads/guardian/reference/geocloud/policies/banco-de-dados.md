---
description: Convenções de schema MySQL e migrations para GeoCloud
globs: **/*.{sql,cs}
alwaysApply: false
---

# Banco de Dados

- **Migration de schema = classe FluentMigrator `M0xx_*.cs`** em
  `Back.Persistence/Migrations/`, aplicada no startup do `Back.API` via
  `ApplyPendingMigrations` (lock MySQL `GET_LOCK`). Ver
  [ADR-0007](../knowledge/decisions/0007-fluentmigrator-para-migrations.md)
  (supersede ADR-0004). SQL cru dentro da migration; sem ORM.
- `[Migration(YYYYMMDDNNNN, "…")]` + `[Tags("MySql")]`. Idempotência por
  `Schema.Table(...).Column(...).Exists()` — MySQL 8 não tem
  `ADD COLUMN IF NOT EXISTS` portátil. `Down()` costuma ser no-op
  (forward-only na prática).
- Tabelas e colunas em **minúsculas, sem aspas** (`account`, `entityid`) — nunca `CamelCase` ou `"Quoted"`.
- FK por **convenção de nome**: `{entidade}id` (ex.: `accountid`, `entityid`). Não há PK/FK/UNIQUE formais na maioria das tabelas — não assuma que o banco garante integridade; valide na camada de aplicação.
- Nunca assumir que uma migration documentada foi de fato aplicada ao banco vivo — confirme antes de construir sobre ela (causa raiz de drift: `functionality.key` ausente; `password_action_token.created_at` definido na `M021` mas ausente no vivo).
- Seeds de dados de referência (`seed_functionality_keys.sql`) devem ser re-executáveis sem duplicar linhas.

```csharp
// ✅ BOM — guard Exists() antes do ALTER
if (!Schema.Table("users").Column("layoutLanguage").Exists())
    Execute.Sql("ALTER TABLE `users` ADD COLUMN `layoutLanguage` VARCHAR(8) NULL");

// ❌ EVITAR — falha na segunda execução / no runner
Execute.Sql("ALTER TABLE `users` ADD COLUMN `layoutLanguage` VARCHAR(8) NULL");
```

## Motor: MySQL 8

O GeoCloud usa **MySQL 8** com o driver **MySqlConnector** — ver
[ADR-0006](../knowledge/decisions/0006-geocloud-usa-mysql.md). Não há Npgsql nem qualquer
resquício de PostgreSQL no código atual; documentação que ainda afirme o contrário está
desatualizada e deve ser corrigida, não contornada.

- Identificador reservado vai entre **crases** (`` `key` ``), nunca aspas duplas.
- `AUTO_INCREMENT` + `SELECT LAST_INSERT_ID()` para recuperar a chave gerada — não
  existe `RETURNING`.
- Não existe `ILIKE`; a collation padrão (`utf8mb4_0900_ai_ci`) já é case-insensitive,
  então `LIKE` basta.
- Dump de referência gerado com **`mysqldump`**; o dump vivo do produto está em
  `GeoCloudDB/geocloud.sql`. Use `--hex-blob` sempre que houver coluna geométrica —
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
-- ✅ BOM (MySQL) — só para SQL avulso (seed/dump). Schema novo vai na M0xx.
SET @has_col := (SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'functionality' AND COLUMN_NAME = 'key');
SET @sql := IF(@has_col = 0, 'ALTER TABLE `functionality` ADD COLUMN `key` VARCHAR(100) NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
```
