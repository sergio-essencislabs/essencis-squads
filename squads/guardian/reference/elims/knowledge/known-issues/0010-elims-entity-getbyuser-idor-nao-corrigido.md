---
id: KI-0010
title: "ELIMS: `Entity.GetByUser` sem guarda de tenant (IDOR) — correção já aplicada no ELIMS não foi replicada"
severidade: alta
status: aberta
produto: ELIMS
---

## Descrição

`EntityController.GetByUser` (`ELIMS/ELIMS/backend/src/Back.API/Controllers/EntityController.cs`) recebe `userId` como query param do próprio chamador e devolve as entities desse usuário sem comparar a conta do usuário-alvo a `AccountIdToken`/`EntityIdToken` do chamador — qualquer usuário autenticado com a permissão `entity.getByUser` consegue listar as entities de QUALQUER outro usuário/conta trocando o `userId` na URL.

O ELIMS já identificou e corrigiu exatamente este padrão no seu próprio `EntityController.GetByUser` (carregando o usuário-alvo e comparando `AccountId` antes de listar — ver comentário no código do ELIMS e `RELATORIO_BUGS_PARA_CORRECAO_V7.md`, achado "Padrão sistêmico #3"). Como o ELIMS herda o mesmo núcleo de Conta/Identidade do ELIMS, mas por um fork/cópia anterior à correção, o bug persiste no ELIMS.

## Evidência

- `ELIMS/ELIMS/backend/src/Back.API/Controllers/EntityController.cs`, método `GetByUser` — sem nenhuma comparação de `AccountId`/`AccountIdToken`.
- Teste dinâmico real: `ELIMS/ELIMS/backend/src/Back.ApiTests/Endpoints/EntityFuzzRunner.cs`, caso `Field:UserId:CrossTenantNoGuard` — HTTP 200 com a lista de entities de OUTRA conta, autenticado apenas com um token válido de um usuário qualquer (não o dono). Resultado em `v7-results/elims-entity-fuzz.json`.

## Ação recomendada

Aplicar a mesma correção já feita no ELIMS: carregar o usuário-alvo (`_userService.GetById(userId)`) e comparar `targetUser.AccountId` a `AccountIdToken` (ou exigir `EntityIdToken == 1` para acesso irrestrito) antes de listar — mesmo padrão já usado corretamente nos `getById`/`getByAccount` do próprio `EntityController`.

## Dono

Security Architect + QA Architect (comparar demais controllers do núcleo compartilhado ELIMS↔ELIMS por divergência semelhante — sugerido como padrão reutilizável, ver `ai-framework/knowledge/patterns/`).
