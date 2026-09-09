# ADR-0006 — GeoCloud usa MySQL 8 como motor de banco

- **Status:** Aceito
- **Data:** 2026-08-15
- **Substitui:** ADR-0006 original ("ELIMS migra para MySQL"), removido junto com o
  conteúdo cross-produto quando o framework passou a ser exclusivo do GeoCloud.

## Contexto

A documentação do framework afirmava, até 2026-08-15, que o GeoCloud rodava sobre
**PostgreSQL via Npgsql**, e tratava o MySQL como uma divergência do produto irmão. Essa
premissa estava errada, e estava na porta de entrada do framework — README, visão geral
de arquitetura, policy de banco e três agentes.

A verificação no código do produto, feita em 2026-08-15, mostrou o contrário:

- `Back.Persistence` referencia o pacote **`MySqlConnector`**; não há `Npgsql` no
  `.csproj` de nenhum dos quatro projetos.
- `DbSession` instancia `MySqlConnection`.
- Os repositórios usam `SELECT LAST_INSERT_ID()` — sintaxe MySQL — e não `RETURNING`.
- O dump vivo `GeoCloudDB/geocloud.sql` tem cabeçalho `MySQL dump 10.13 Distrib 8.0.46`
  e nenhum marcador de PostgreSQL (`SERIAL`, `OWNER TO`, `pg_catalog`).
- Existe a branch `migracao-para-mysql` no repositório, já incorporada à `main`.

Ou seja: a migração aconteceu, e a documentação não acompanhou.

## Decisão

O GeoCloud usa **MySQL 8** com **MySqlConnector**. Toda policy, playbook, skill e agente
deste framework assume esse motor. Qualquer referência a PostgreSQL, Npgsql, `SERIAL`,
`RETURNING`, `ILIKE` ou `pg_dump` na documentação é resíduo e deve ser corrigida ao ser
encontrada.

## Consequências

**Positivas**

- O framework volta a descrever o produto que existe, e não o que existia em julho.
- Recursos que só o MySQL 8 oferece passam a ser usáveis sem ressalva — em especial as
  colunas `GEOMETRY SRID 4326` com índice `SPATIAL`, base do módulo espacial.

**Negativas e riscos**

- O suporte geoespacial do MySQL é mais pobre que o do PostGIS: sem raster, com menos
  funções e com reprojeção limitada. Área de sobreposição precisa ser calculada em SRS
  projetado (EPSG 31983), com verificação de tipo antes de `ST_Area`.
- O SRID 4326 no MySQL usa ordem de eixo **latitude primeiro**, contrária à das
  ferramentas GIS. É a armadilha de maior custo do motor, documentada em
  `policies/banco-de-dados.md`.
- Não existe importador nativo de shapefile (equivalente ao `shp2pgsql`); a conversão
  para GeoJSON/WKT é feita fora do banco.

## Alternativas consideradas

**Voltar para PostgreSQL + PostGIS.** Tecnicamente superior no eixo geoespacial, mas
exigiria reverter uma migração já concluída e testada, reescrever todos os repositórios
Dapper e refazer o dump de produção. O ganho não paga o custo enquanto a demanda
espacial couber no que o MySQL 8 entrega.

**Manter os dois motores atrás de uma abstração.** Rejeitada: o projeto usa SQL cru com
Dapper por decisão de arquitetura, e uma camada de compatibilidade de dialeto
contradiria essa escolha sem benefício real para um produto de motor único.
