---
id: KI-0010
title: "UserInviteService — código de convite com System.Random + e-mail comentado com método inexistente"
severidade: média
status: aberta
produto: GeoCloud
---

## Descrição

`UserInviteService.Add` (convite de usuário para uma conta já existente —
fluxo distinto do registro público) tem dois defeitos ao mesmo tempo:

1. **Código previsível**: `userInvite.Code = new Random().Next(0, 1000000).ToString("D6")`
   — `System.Random`, não `RandomNumberGenerator`. Já não existe mais em
   `AccountRegistrationService` (substituiu `AccountInviteService`, que
   carregava o mesmo bug antes de ser descontinuado). **Nota**: o port de
   `UserPasswordResetService` replica esse mesmo padrão deliberadamente,
   por decisão explícita do usuário (fidelidade ao D'Amore) — ver KI-0011;
   não tratar como "já corrigido em outro lugar".
2. **Envio de e-mail comentado, e quebrado se descomentado como está**: a
   linha comentada chama `_emailService.EnviarEmailPadraoAsync(...)`, método
   que não existe na classe real `Back.Application.Services.EmailService`
   (a assinatura real é `SendAsync(recipient, subject, htmlBody, cancellationToken)`).
   Ou seja, mesmo que alguém apenas descomente a linha sem revisar, o build
   quebra — não é um "descomentar e funciona".

Correção de enquadramento (2026-08-31, apontamento do usuário): isto **não
é um bug confirmado aguardando correção** — o fluxo de convite de usuário
ainda está em discussão/modelagem, então tratar isto como "defeito já em
produção" a corrigir de imediato seria prematuro. É um known-issue no
sentido correto do termo: uma observação de código com evidência, que
entra na discussão de modelagem em andamento, não uma ação bloqueante.

## Evidência

```103:111:C:\Software\GeoCloud\GeoCloudAI\api\src\Back.Application\Services\UserInviteService.cs
userInvite.Code = new Random().Next(0, 1000000).ToString("D6");
...
// var resultSender = await _emailService.EnviarEmailPadraoAsync(
```

## Ação recomendada

Nenhuma ação imediata — aguardar a modelagem/discussão em andamento do
fluxo de convite de usuário. Quando essa discussão fechar, avaliar junto:
substituir `new Random()` por
`Back.Application.Security.VerificationCodeGenerator` (já usado por
`AccountRegistrationService`, testado, `RandomNumberGenerator` por
dentro — ver KI-0011) e decidir se o convite deve efetivamente enviar
e-mail (religando via `EmailService.SendAsync`/`IEmailService` +
`VerifyHtml.GetText`, corrigindo a assinatura) ou permanecer
deliberadamente sem envio, documentado como tal.

## Resolução

_Pendente._

## Dono

Security Architect (Selma) + Backend Architect (Breno).

---

## Nota para Documentation Architect (Marta) — drift a corrigir

A *Onboarding Security Review* (Library/VaultS,
`S - GeoCloudAI - Onboarding Security Review.md`) cita
`EnviarEmailPadraoAsync comentado em AccountInviteService` como um dos
bloqueadores críticos. **`AccountInviteService` não existe mais no
código** — foi substituído por `AccountRegistrationService`, que já não
tem esse defeito (confirmado por grep, 2026-08-31). O defeito real e
ainda aberto está em `UserInviteService`, uma classe diferente
(convite de usuário para conta existente, não registro público) — esta
entrada (KI-0010).

Dois pontos a corrigir, sempre via `LLML-ingest`/`LLML-approve` (nunca
escrita direta na Library):
1. Atualizar a citação na Onboarding Security Review para apontar
   `UserInviteService`, não `AccountInviteService`.
2. `api/docs/implementations/36-email-unico-login-simplificado.md`
   descreve `AccountInviteService`/`AccountInvite/add` como o fluxo atual
   — hoje é histórico (a classe foi renomeada/substituída depois). Decidir
   se esse relatório numerado deve ganhar uma nota de "superado por
   refatoração posterior" ou se, por convenção deste repositório
   (relatórios de implementação são snapshots datados, não documentação
   viva), isso é aceitável como está — decisão de Marta, não aplicada aqui.
