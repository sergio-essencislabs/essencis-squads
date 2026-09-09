---
id: KI-0012
title: "ELIMS: modelo misto de autorização após a porta de `elims-geocloud-padronization` — `TenantAuthorizationFilter` (global) coexiste com `PermissionMiddleware`/`[RequiredPermission]` (granular)"
severidade: média
status: aberta
produto: ELIMS
---

## Descrição

A porta da branch `elims-geocloud-padronization` (`ELIMS/ELIMS`) para `ELIMS`
(2026-08-04, ver [ADR-0006](../decisions/0006-elims-migra-para-mysql.md)) trouxe
`Back.API/Security/TenantAuthorizationFilter.cs`, registrado como **filtro global** de todos os
controllers (`Startup.cs`, `services.AddControllers(o => o.Filters.AddService<TenantAuthorizationFilter>())`).
Esse filtro, para toda requisição autenticada sem `[AllowAnonymous]`, valida o JWT via
`IAuthenticatedContextAccessor` e depois confirma — via reflexão sobre os argumentos da action —
que qualquer `entityId`/`projectId`/`profileId`/id de recurso referenciado pertence ao `accountId`
autenticado (proteção de BOLA/IDOR por design, não por controller individual).

Esse mecanismo não existe no framework antes desta porta; ele coexiste agora com
`Back.API.Middlewares.PermissionMiddleware`/`[RequiredPermission]` (extensão exclusiva deste
framework, ver KI-0001/KI-0009, suportada desde a migration `011_functionality_permission_keys.sql`),
que atua por permissão granular (`functionality.key`) e só age quando o atributo está presente no
endpoint.

Isso significa que os três Known Issues de autorização já catalogados para o ELIMS podem estar
**parcial ou totalmente resolvidos por este novo filtro global**, mas isso não foi re-testado nesta
tarefa (fora do escopo desta porta — o objetivo era portar o código, não re-rodar a campanha de fuzz
de permissão V7/V8):

- [KI-0002](0002-address-add-allowanonymous.md) — `Address/add` com `[AllowAnonymous]`: **não** é
  coberto pelo novo filtro (ele deliberadamente pula endpoints `[AllowAnonymous]`, linha 28-33 de
  `TenantAuthorizationFilter.cs`) — continua precisando de correção própria.
- [KI-0009](0009-elims-36-controllers-sem-authorize.md) — 36 controllers sem `[Authorize]`: o filtro
  global passa a autenticar/autorizar **todas** as actions por padrão (inclusive as desses 36
  controllers), então o vetor original (nenhuma checagem de identidade) pode já estar mitigado — mas
  isso precisa ser confirmado reexecutando `NoAuthSystemicRunner.cs`/`AuditTrailIntegrityRunner.cs`
  (`Back.ApiTests`) contra o código pós-porta antes de marcar como resolvido.
- [KI-0010](0010-elims-entity-getbyuser-idor-nao-corrigido.md) — `Entity.GetByUser` sem guarda de
  tenant: o filtro cobre `entityId` como referência direta (`AddDirectReference`), então este caso
  específico é candidato forte a já estar coberto — mesma ressalva de precisar reteste real.

## Ação recomendada

1. Security Architect: mapear, para cada um dos 36 controllers de KI-0009 e para o caso de KI-0010,
   se o `TenantAuthorizationFilter` de fato intercepta e bloqueia o cenário original documentado.
2. QA Architect: reexecutar `NoAuthSystemicRunner`/`AuditTrailIntegrityRunner`/os runners de
   `TestCenter/Elims/` contra o código pós-porta (branch atual de `ELIMS`) e comparar com os
   resultados da campanha V7 (`elims-noauth-systemic-fuzz.json`, `elims-audit-custody-integrity-fuzz.json`).
3. Para os casos confirmados como resolvidos, atualizar o `status` do KI correspondente para
   `resolvida`, citando este KI e o commit da porta como resolução.
4. Decidir (Chief Architect) se os dois mecanismos (`TenantAuthorizationFilter` global +
   `PermissionMiddleware`/`[RequiredPermission]` granular) devem permanecer coexistindo
   permanentemente (defesa em profundidade, camadas diferentes: identidade/tenant vs. permissão de
   funcionalidade) ou se um dos dois deveria ser unificado/aposentado — registrar a decisão em ADR se
   a resposta não for "manter os dois por design".

## Resolução

Em aberto.

## Dono

Security Architect (mapeamento/validação) + QA Architect (reteste) + Chief Architect (decisão final
sobre unificar ou manter os dois mecanismos).
