---
id: KI-0008
title: "UserPasswordReset — e-mail do código de verificação não é enviado (deliberado)"
severidade: média
status: aberta
produto: GeoCloud
---

## Descrição

`UserPasswordResetService.Add` gera o código de verificação (`Code`, via
`RandomNumberGenerator`) mas o envio de e-mail está **comentado
deliberadamente** — mesmo padrão (comentário citando um método que não
existe no `EmailService` real) hoje presente em
`UserInviteService.cs:111` (`EnviarEmailPadraoAsync` comentado — ver
KI-0010). **Correção nesta entrada** (2026-08-31): a citação original
apontava para `AccountInviteService`, que não existe mais no código —
foi substituído por `AccountRegistrationService`, que já não carrega
esse defeito. Sem o e-mail, o único jeito de o usuário obter o código é
uma consulta direta ao banco ou um endpoint administrativo — hoje não há
nenhum dos dois para este fluxo, então o `POST /UserPasswordReset/reset`
fica inatingível em produção enquanto isso não for resolvido.

Diferença importante em relação ao caso do convite: aqui a infraestrutura
de envio **já existe e funciona** —
`Back.Application.Services.EmailService.SendAsync(recipient, subject, htmlBody)`
e o template `Back.Application.Email.VerifyHtml.GetText(code, expiration)`
já são usados em outros fluxos de verificação. Ligar o envio real é uma
mudança de poucas linhas em `UserPasswordResetService.Add` (descomentar +
ajustar a assinatura da chamada) — o bloqueio não é técnico, é uma decisão
deliberada de escopo desta rodada.

## Evidência

```csharp
// api/src/Back.Application/Services/UserPasswordResetService.cs
// if (resultUserId != 0)
// {
//     var sent = await _emailService.SendAsync(
//         recipient: email,
//         subject: "Password reset verification code",
//         htmlBody: VerifyHtml.GetText(userPasswordReset.Code!, TimeSpan.FromDays(7)));
//     if (!sent) return ResultService<UserPasswordResetDto?>.Fail("Failed to send the verification code");
// }
```

## Ação recomendada

Antes de expor este fluxo a usuários reais: descomentar a chamada de
`EmailService.SendAsync` (nas duas ocorrências, envio inicial e reenvio),
confirmar `EmailSettings.Enabled=true` no ambiente de destino, e cobrir com
um teste de integração que force o envio (ou o mock de `IEmailService`)
antes de liberar o endpoint `add`/`reset` para tráfego real.

## Resolução

_Pendente._

## Dono

Backend Architect (Breno).
