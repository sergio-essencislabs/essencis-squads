---
id: GT-0049
title: "Vida do token JWT ignorava Auth:AccessTokenMinutes — 12h fixos em constante"
status: completed
type: bug
severidade: media
owner: sergio-essencislabs
created_at: 2026-09-09
updated_at: 2026-09-09
origem: "pedido direto do Sergio: estender a sessão para cobrir a épica noturna de 09/09 17:00 a 10/09 06:00"
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0049-vida-do-token-configuravel.md"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/463"
branch: chore/gt-0049-vida-do-token-configuravel
affected_modules: ["Back.Application", "Back.API"]
related_use_cases: []
related_adrs: ["ADR-001"]
---

# GT-0049 — Vida do token JWT configurável

## Contexto

Pedido operacional: estender a sessão para que o login feito às 17:00 de 09/09 sobreviva até as
06:00 de 10/09, cobrindo uma execução longa sem supervisão.

## Problema

`appsettings.json` declara `Auth:AccessTokenMinutes: 1440` desde o início. **Nada lê essa chave.**
Um `grep` por `AccessTokenMinutes` em todo o `api/` não devolve nenhum `.cs`.

A vida real do token era `private const int TokenLifetimeHours = 12` em `UserLoginService.cs:20`.

Duas consequências:

1. **A configuração mente.** Quem lê o `appsettings` conclui que a sessão dura 24 horas. Dura 12.
   Isso já valia antes deste pedido e valeria em produção, onde a diferença entre 12h e 24h de
   janela de credencial é decisão de segurança, não detalhe.
2. **Mudar o valor exige recompilar.** Não havia como esticar a sessão sem alterar código.

## Correção

`UserLoginService` passa a ler `Auth:AccessTokenMinutes` uma vez, na construção, em
`ResolveTokenLifetime`. O resultado alimenta os **dois** consumidores da vida do token — a expiração
em `GenerateToken` e a janela do backfill de logout inferido (ADR-001) — pelo mesmo campo, para que
não possam divergir.

Ausente, vazio, não numérico ou `<= 0` cai no padrão de 12h e registra `Warning`. Um valor
`<= 0` emitiria tokens já expirados, derrubando todo mundo sem nenhum erro apontando a causa; um
setting mal digitado não pode virar indisponibilidade.

`appsettings.json` passa de `1440` para `790` (13h10) **temporariamente**, só pela duração da épica
noturna.

## Divergência declarada entre o pedido e o estado real

O pedido foi "às 06:00 retorne ao normal de **1440** minutos". O normal em vigor nunca foi 1440 —
era 720 (12h). Restaurar 1440 **dobraria** a janela de credencial em relação ao comportamento atual,
que é o oposto de "voltar ao normal".

**Decisão:** às 06:00 o valor volta para **720**, que é o comportamento real de hoje, e a divergência
é reportada ao Sergio para que ele decida se quer 1440 de propósito. Um aumento de janela de
credencial é escolha dele, não efeito colateral de uma reversão.

## Critérios de aceitação

- [ ] CA-01 — `Auth:AccessTokenMinutes` presente e válido define a expiração do token emitido.
- [ ] CA-02 — Ausente, vazio, não numérico ou `<= 0` cai em 720 minutos e registra `Warning`.
- [ ] CA-03 — Expiração e janela do backfill de logout inferido (ADR-001) usam o mesmo valor.
- [ ] CA-04 — Verificação viva: token emitido nesta sessão expira ~790 min depois de emitido.
- [ ] CA-05 — Às 06:00 de 10/09 o `appsettings.json` volta a 720 e a API é reiniciada.

## Verificação

`dotnet build Back.sln && dotnet test Back.sln`, mais decodificação do `exp` de um token real
emitido pela API em execução.

---

## Reconciliacao - 21/09/2026 (GT-0156)

**Resolvido, prova dupla.** Commit `83f0b852` (PR #464, merge `fa9e3c1b`). Codigo:
`api/src/Back.Application/Helpers/AuthSettings.cs:18,24,37` (`ResolveAccessTokenLifetime`),
consumido em `UserLoginService.cs:56`. Teste versionado: `AuthSettingsTests.cs`, 5 casos. CA-05
confirmado: `appsettings.json:10 = 720`. Issue #463 CLOSED. Contraparte produto em completed/, 5/5
CAs [x].

Defeito de forma, nao corrigido aqui: o `contraparte:` do lado produto aponta para o proprio
repositorio do produto (`C:/Software/GeoCloud/GeoCloudAI/.agents/tasks/active/...`) em vez do hub -
e um dos auto-ponteiros que a GT-0151 ja cataloga, travada aguardando decisao do Sergio sobre a
forma canonica.

Evidencia completa no relatorio da reconciliacao GT-0156.
