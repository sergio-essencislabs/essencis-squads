---
id: GT-0051
title: "Escopo multi-tenant ausente em leituras do módulo geológico (#296, #297)"
status: completed
type: security
severidade: alta
owner: sergio-essencislabs
created_at: 2026-09-09
updated_at: 2026-09-09
origem: "issues #296 e #297, da auditoria da aba Metodos_Back de GeoCloud.xlsx"
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0051-escopo-multitenant-leituras-geologia.md"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/296"
                           # Esta GT fechou DUAS issues: a #296 e a #297.
                           # `issue_url` é campo de URL única, então guarda a primeira;
                           # as duas seguem nomeadas no `title:` e no `origem:` acima,
                           # que é onde já estavam. Nada se perdeu na conversão.
branch: fix/gt-0051-escopo-multitenant-leituras-geologia
affected_modules: ["Back.API"]
related_use_cases: []
related_adrs: []
---

# GT-0051 — Escopo multi-tenant nas leituras do módulo geológico

## Problema

**#296** — `StructureTypeController.Get` e `GetById` não checavam conta nenhuma. `Get` é a listagem
global e devolvia o catálogo de **todos** os tenants a qualquer um com a permissão funcional;
`GetById` devolvia qualquer linha por id. As classes irmãs `FractureType` e `AlterationStyle` já
barravam — a inconsistência entre análogas é o que torna isto descuido e não desenho.

**#297** — `GetByUser` de `AlterationStyle`, `TextureType` e `MineralizationType` passava o `userId`
da query direto ao service. O parâmetro é enumerável: bastava iterar para varrer os registros de
qualquer usuário de qualquer conta.

## Correção

Padrão das classes irmãs, conforme a regra em `.claude/rules/global.md` ("toda listagem
`getBy{Parent}` valida no controller"):

- `Get` → `EntityIdToken != 1 → Forbid()`, como `FractureTypeController.Get`.
- `GetById` → carrega e compara `result.AccountId != AccountIdToken → Forbid()`.
- `GetByUser` → resolve o dono do `userId` por `IUserService`, compara `user.Entity?.AccountId`
  com `AccountIdToken`, permite `EntityIdToken == 1`. É o padrão de `UserProfileController.GetByUserId`.

Cada recusa registra em `userlog` com `allowed: false`, como as demais.

## O que este escopo NÃO cobre

O `Update` destes mesmos quatro controllers tem um defeito **diferente e mais grave** — compara o
`accountId` do corpo da requisição em vez do da linha armazenada, permitindo sequestro de registro
entre contas. Ele atinge ~60 endpoints e foi separado na issue #467, porque a correção é outra e
misturar as duas tornaria ambas irrevisáveis.

## Critérios de aceitação

- [x] CA-01 — `StructureType.get` recusa quem não é a entidade dona do sistema.
- [x] CA-02 — `StructureType.getById` recusa id de outra conta **e devolve o da própria**.
- [x] CA-03 — `getByUser` das três classes recusa `userId` de outra conta.
- [x] CA-04 — `getByUser` com o próprio `userId` **não** é bloqueado (a guarda não custa o acesso legítimo).
- [x] CA-05 — Os testes ficam vermelhos sem a correção: verificado revertendo as guardas — 5 falhas, 8 verdes com elas.
- [ ] CA-06 — Teste manual das telas afetadas (Sergio/Matheus).

## Verificação

`TenantScopeReadApiTests` 8/8, sobre a suíte reparada na GT-0050. Todo caso negativo tem o par
positivo: um `Forbid()` indiscriminado passaria em qualquer teste que só verificasse o bloqueio.

## Auditoria (agente `geocloud-permission-auditor`)

As quatro guardas foram aprovadas linha a linha contra os padrões de referência, com a cadeia
verificada até o repositório e o seed de permissões — este último importa porque, sem a chave
concedida ao perfil, o 403 do teste viria do middleware e a guarda nova passaria verde sem ter
sido executada.

Quatro apontamentos aceitos e **não** corrigidos aqui, todos herdados dos próprios padrões de
referência. Corrigi-los neste PR criaria divergência unilateral com `UserProfileController` e
`FractureTypeController`, que é decisão maior que esta task:

- **Oráculo de enumeração no `getByUser`.** `userId` inexistente devolve 404; `userId` de outra
  conta devolve 403. A diferença permite enumerar ids de usuário válidos do sistema inteiro. Nenhum
  dado de negócio vaza. Herdado de `UserProfileController.GetByUserId`.
- **Assimetria da exceção do dono do sistema.** `getByUser` concede `EntityIdToken == 1`; `getById`
  não. Cada um é fiel à sua referência, e as duas referências discordam entre si.
- **Sem defesa em profundidade no repositório.** `GetByUser` filtra só por `userId`; toda a defesa
  está no controller.
- **Claim ausente vira 500, não bloqueio.** `AccountIdToken` usa `FindFirst(...)!.Value`; token sem
  a claim gera `NullReferenceException` capturada pelo `catch` do método. Fecha (nada vaza), mas é
  crash, não guarda avaliada.

Um apontamento **foi** corrigido: o caso de `StructureType.get` só afirmava o 403, e um `Forbid()`
incondicional — ou um 403 do middleware — passaria verde. Ele não podia ter o par positivo óbvio,
porque um chamador autorizado seria da entidade 1 e `ResetTransientState` a esvazia. Ganhou um
controle: o mesmo chamador em `getByAccount` não pode levar 403; se levar, o 403 do `get` não veio
da guarda.

---

## Reconciliacao - 21/09/2026 (GT-0156)

**Resolvido, prova dupla.** Commits `0e80eea6` + `5cfcce2e` (PR #468, merge `450d2ad0`). Issues
#296 e #297 ambas CLOSED. Codigo: `StructureTypeController.cs:144` (Get) e `:195` (GetById),
guarda por EntityIdToken/AccountIdToken. Teste versionado: `TenantScopeReadApiTests.cs`, sem
Skip=. Contraparte produto em completed/, 6/6 CAs [x] (CA-06 sincronizado agora). Os 4
apontamentos de auditoria aceitos-e-nao-corrigidos estao declarados fora de escopo no proprio GT -
nao tornam isto parcial.

Mesmo defeito de forma do GT-0049/GT-0050: auto-ponteiro, catalogado na GT-0151.

Evidencia completa no relatorio da reconciliacao GT-0156.
