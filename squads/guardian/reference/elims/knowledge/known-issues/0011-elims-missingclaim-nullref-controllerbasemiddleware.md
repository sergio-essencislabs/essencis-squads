---
id: KI-0011
title: "ELIMS: JWT sem claim `accountId` derruba `ControllerBaseMiddleware` com `NullReferenceException` (500 em vez de 401) — recorrência do mesmo bug já catalogado no ELIMS"
severidade: média
status: aberta
produto: ELIMS
---

## Descrição

`Back.API/Middlewares/ControllerBaseMiddleware.cs` do ELIMS assume que a claim `accountId` sempre existe no JWT (`int.Parse(User.FindFirst("accountId")!.Value)`, com `!` null-forgiving). Se a claim estiver ausente, o `!` deixa passar `null` e `.Value` lança `NullReferenceException`, virando um HTTP 500 com stack trace exposto em vez do 401 esperado.

Este é o **mesmo bug de infraestrutura já confirmado 3x no ELIMS** (Account/Entity/User, ver relatório V7 do ELIMS, achado "Vazamento de erro cru — claim JWT ausente derruba a request com NullReferenceException") — o ELIMS herdou o mesmo `ControllerBaseMiddleware` (fork/cópia do núcleo de Conta/Identidade) e reproduz a mesma classe de bug. Não é uma regressão nova, é uma recorrência esperada do compartilhamento de código entre os dois produtos.

## Evidência

- `ELIMS/ELIMS/backend/src/Back.API/Middlewares/ControllerBaseMiddleware.cs` (mesmo padrão de leitura de claim com `!` do ELIMS).
- Teste dinâmico real: `ELIMS/ELIMS/backend/src/Back.ApiTests/Endpoints/AccountFuzzRunner.cs`, caso `Auth:MissingClaim` — HTTP 500, corpo `"Error when trying to recover account. Error: Object reference not set to an instance of an object."`. Resultado em `v7-results/elims-account-fuzz.json`.

## Ação recomendada

Mesma recomendação já registrada para o ELIMS (não corrigida lá também, por ser mudança em middleware compartilhado — decisão de escopo maior): trocar a leitura direta com `!` por uma versão defensiva/nullable (`CurrentAccountIdToken` ou equivalente) e tratar 401 explicitamente quando a claim faltar. Como o código é compartilhado/herdado entre os dois produtos, avaliar corrigir nos dois de uma vez, e não separadamente.

## Dono

Security Architect (decisão de quando corrigir o middleware compartilhado, coordenando ELIMS + ELIMS).
