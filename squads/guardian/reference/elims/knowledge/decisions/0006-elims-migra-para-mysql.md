---
id: ADR-0006
title: "ELIMS adota MySQL como motor de banco de dados — divergência intencional de PostgreSQL (GeoCloud)"
status: aceito
superseded-partially-by: geocloud-ai-framework ADR-0006 (0006-geocloud-usa-mysql.md, 2026-08-15)
date: 2026-08-04
deciders: Chief Architect (framework) + Thiago e Victor (equipe de produto ELIMS, autores da branch de origem)
---

> **Nota de revisão (2026-08-23).** Duas correções neste documento:
>
> 1. Os nomes de produto estavam colapsados — um find/replace cego no commit
>    `dcac8e7` trocou `GeoCloud` por `ELIMS` em massa, produzindo frases
>    contraditórias ("MySQL é oficial do ELIMS; o ELIMS continua em
>    PostgreSQL"). O nome original foi recuperado do commit `3d19a6a`, cujo
>    título diz "divergência intencional de PostgreSQL (**GeoCloud**)".
> 2. **A premissa "o GeoCloud continua em PostgreSQL" não é mais verdadeira.**
>    O GeoCloud migrou para MySQL 8 em 2026-08-15 — ver
>    `geocloud-ai-framework/knowledge/decisions/0006-geocloud-usa-mysql.md`, e
>    a evidência no produto (`MySqlConnector 2.6.1`, `Port=3306`). A decisão
>    sobre o ELIMS registrada aqui segue válida; o que caducou é a comparação
>    com o GeoCloud. A "divergência intencional de motor" descrita abaixo
>    **não existe mais** — os dois produtos usam MySQL. Resolver isto exige um
>    ADR novo, não uma edição deste: por isso está marcado como parcialmente
>    superado em vez de reescrito.

## Contexto

Desde 2026-07-31, `knowledge/pendencias.md` e `knowledge/domain/equipe.md` registravam como pendência
**aguardando aviso do usuário** o fato de que Thiago e Victor vinham trabalhando, fora deste framework,
em uma branch própria do ELIMS (`ELIMS`, branch `elims-geocloud-padronization`) que incluía a
migração do motor de banco de dados de **PostgreSQL para MySQL**, entre outras alterações (tenant
isolation reforçado, hierarquia de identidade, `EntityDetail`).

O usuário autorizou o fetch/análise dessa branch e a replicação do trabalho em `ELIMS`. A porta foi
concluída: **211 arquivos alterados**, backend compilando (`dotnet build` sem erros) e suite de testes
unitários (`Back.Tests`) passando **66/66**. O produto de origem (`ELIMS`) já usa MySQL de fato —
não é uma proposta, é o estado real do código-fonte que está sendo portado.

Isso diverge da stack documentada até aqui para os dois produtos do framework
(`policies/banco-de-dados.md`, `FRAMEWORK_ARCHITECTURE.md`): PostgreSQL via Npgsql/Dapper, sem
framework de migration (ADR-0004). A pergunta em aberto desde a nota em `equipe.md` era se essa
divergência de motor é intencional (decisão de produto do ELIMS) ou deveria ser avaliada também para
o GeoCloud.

## Decisão

**MySQL passa a ser o motor de banco de dados oficial do ELIMS (`ELIMS/ELIMS`).** O GeoCloud
(`GeoCloud/GeoCloudAI`) continua em PostgreSQL. Esta é uma **divergência intencional de produto**,
não uma inconsistência a ser corrigida — os dois produtos evoluem com motores de banco diferentes,
mantendo o mesmo padrão de acesso a dados (Dapper, sem ORM completo, sem framework de migration —
ADR-0004 continua valendo para os dois).

Especificamente para o ELIMS:

- Driver .NET: **MySqlConnector** (não Npgsql).
- Servidor de desenvolvimento local: MySQL Community Server 8.0.46, `127.0.0.1:3306`.
- Scripts de schema/seed/migration em `ELIMS/ELIMS/backend/src/Back.API/Scripts/mysql/`, numerados
  sequencialmente (`001_schema.sql` … `011_functionality_permission_keys.sql` até o momento deste ADR),
  seguindo o mesmo princípio de idempotência do ADR-0004 (ver `Scripts/mysql/README.md` para a ordem de
  aplicação completa).
- Dump de referência (`ELIMS/ELIMS/db/elims.sql`) passa a ser gerado com `mysqldump`, não `pg_dump` — o
  dump PostgreSQL anterior foi preservado em `ELIMS/ELIMS/db/_postgres-legado/` como histórico, não é mais
  o ponto de partida.
- Conversão de dialeto (sintaxe PostgreSQL → MySQL: `SERIAL`→`AUTO_INCREMENT`, sem `RETURNING`/`ILIKE`,
  etc.) documentada e automatizável via `ELIMS/ELIMS/backend/scripts/convert_postgres_to_mysql.mjs`, já
  portado junto do restante do código.

## Consequências

- `policies/banco-de-dados.md` recebe uma seção específica "ELIMS usa MySQL" — o restante da policy
  (convenção de nomes, "migration = script SQL manual", nunca assumir que uma migration documentada foi
  de fato aplicada ao banco vivo) continua valendo para os dois motores; só o dialeto SQL e o
  provider .NET mudam para o ELIMS.
- `ELIMS/ELIMS/backend/docs/migrations.md` e `ELIMS/ELIMS/db/README.md` documentam o processo real em MySQL
  (ver commits desta mesma tarefa).
- A pendência em `knowledge/pendencias.md` sobre "Analisar e replicar o trabalho de Thiago e Victor" é
  encerrada como resolvida.
- A nota em `knowledge/domain/equipe.md` sobre a branch de Thiago/Victor é atualizada para refletir que a
  análise e a replicação já aconteceram, com este ADR como decisão formal.
- **GeoCloud não é afetado** — nenhuma mudança de motor de banco é proposta ou necessária para
  `GeoCloud` a partir desta decisão. Se no futuro houver motivo de negócio para unificar os motores,
  isso exige uma nova decisão explícita (não decorre automaticamente deste ADR).
- Toda alteração futura de schema no ELIMS segue a mesma disciplina do playbook `playbooks/migration.md`
  e do ADR-0004, apenas com sintaxe MySQL.
- A migration mais recente portada (`011_functionality_permission_keys.sql`, que adiciona as colunas
  `key`/`active`/`user_id`/`register` em `functionality` para suportar `[RequiredPermission]`/
  `PermissionService` — extensão exclusiva deste framework, sem equivalente em `ELIMS`) foi
  **validada com sucesso contra o MySQL local** (`127.0.0.1:3306`, schema `elims`) usando um teste xUnit
  temporário com `MySqlConnector` (removido antes do commit final): script idempotente aplicado sem
  erro, 4/4 colunas confirmadas via `information_schema.COLUMNS`, 110 linhas de `functionality` com
  `key` populada. Suite completa de `Back.Tests` seguiu em 66/66 após a remoção do teste temporário.

## Alternativas consideradas

- **Manter PostgreSQL no ELIMS e reescrever a branch de Thiago/Victor de volta para Postgres antes de
  portar**: rejeitada — o motor MySQL já é o estado real do produto ELIMS (decisão de equipe já tomada
  fora deste framework); reescrever o trabalho deles para o motor antigo geraria retrabalho sem
  benefício e divergiria do que a equipe de produto está de fato rodando.
- **Unificar GeoCloud também para MySQL** (ou ELIMS de volta para Postgres) para eliminar a divergência
  de stack entre os dois produtos: rejeitada por ora — nenhuma motivação de negócio foi apresentada para
  unificar; os dois produtos têm equipes/ritmos de evolução próprios e o padrão de acesso a dados
  (Dapper, sem ORM pesado) já é idêntico, o que era o requisito arquitetural que este framework realmente
  protege (não o motor de banco em si). Reavaliar se surgir necessidade concreta de infraestrutura
  compartilhada entre os dois.
