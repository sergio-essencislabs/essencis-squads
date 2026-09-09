---
tipo: Migration
produto: GeoCloud | GeoCloud | ambos (núcleo compartilhado)
---

# Migration: <descrição curta>

## Schema atual

<Tabelas/colunas envolvidas, estado antes da mudança.>

## Schema alvo

<Tabelas/colunas depois da mudança.>

## Script (idempotente)

```sql
-- caminho do arquivo real, ex.: Scripts/migration_<nome>.sql
```

## Plano de rollback

<Script de reversão, ou justificativa de por que a migration é seguramente idempotente/não-destrutiva.>

## Validação (Database Diff)

- [ ] Aplicado em ambiente de desenvolvimento
- [ ] `database-diff` confirma schema esperado
- [ ] Núcleo compartilhado avaliado (se aplicável, `sincronizacao-nucleo-compartilhado.md` seguido)
