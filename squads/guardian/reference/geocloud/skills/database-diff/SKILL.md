---
name: database-diff
description: Compara o schema esperado (scripts SQL/migrations do repositório) com o schema real de um banco (dump ou conexão), detectando colunas/tabelas ausentes. Use após aplicar uma migration, e periodicamente para auditar drift código×banco em GeoCloud.
---

# Database Diff

## Objetivo

Detectar a causa raiz de drift já documentada (ex.: `functionality.key` esperado pelo código mas ausente no banco vivo) antes que ela cause falha em runtime.

## Entradas

- Scripts de schema esperados (`create_all_tables_pg.sql`, `migration_*.sql`, `attribute-mapping.md`).
- Dump ou acesso ao banco real (`geocloud.sql` ou conexão viva).

## Saídas

- Lista de tabelas/colunas presentes nos scripts mas ausentes no banco real (e vice-versa).
- Classificação de risco: crítico (coluna usada por código em produção), informativo (coluna não referenciada).

## Fluxo

1. Extrair `CREATE TABLE`/`ALTER TABLE` esperados dos scripts do produto.
2. Extrair schema real (via dump ou `information_schema` se houver conexão).
3. Comparar tabela por tabela, coluna por coluna.
4. Cruzar cada divergência com o código (a coluna é referenciada em algum repository?) para classificar risco.

## Limitações

- Sem acesso a conexão viva, a análise fica limitada ao dump disponível (pode estar desatualizado).
- Não corrige a divergência — gera a migration corretiva é tarefa do Database Architect.

## Exemplos

- Rodar após aplicar `seed_functionality_keys.sql` para confirmar que `functionality.key` de fato existe e está populada no banco de destino, não só no script.

## Quando usar

Após qualquer migration aplicada; periodicamente como auditoria; ao investigar erro 500 relacionado a coluna ausente.

## Quando não usar

Em ambiente onde o schema é gerado do zero na mesma tarefa (nada para comparar ainda).
