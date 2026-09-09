---
id: KI-0001
title: Permissões inertes em runtime
severidade: crítica
status: aberta
produto: ELIMS
---

## Descrição

O código (branch `Testando-multi-tenet`) assume que `functionality.key` existe e que `functionality`/`profilefunctionality` estão populados. No banco vivo, isso pode não ter sido aplicado (`seed_functionality_keys.sql` não executado), causando endpoints com `[RequiredPermission]` retornando 500 (coluna ausente) ou 403 (sem permissão vinculada).

## Evidência

- `seed_base.sql` L179-205 deixa `functionality`/`profilefunctionality` vazios de propósito, esperando `seed_functionality_keys.sql` depois.
- `FunctionalityRepository.GetByActivesUser` depende de `functionality.key`.

## Ação recomendada

`playbooks/migration.md` — aplicar `seed_functionality_keys.sql` (+ migrations de paridade) no banco vivo, validar com `skills/database-diff`.

## Dono

Database Architect + Security Architect.
