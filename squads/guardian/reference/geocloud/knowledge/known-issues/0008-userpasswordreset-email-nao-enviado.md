---
id: KI-0008
title: "UserPasswordReset — e-mail do código de verificação não é enviado (deliberado)"
severidade: média
status: resolvida
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

**28/09/2026 — issue #870, PR #919 (mesclado, commit de merge `c58ce682`).** O envio
real do e-mail do código foi ligado em `UserPasswordResetService`: o serviço monta o
corpo com `PasswordResetHtml` (botão para
`{EmailSettings.AppBaseUrl}/auth/forgot-password?email=…&code=…`, que abre a tela já
no passo do código, com o código também no corpo) e chama `IEmailService.SendAsync`.
O envio roda em segundo plano e a resposta de `Add` continua genérica mesmo quando o
provedor falha (a falha vai para o log), para não revelar pelo tempo de resposta quais
e-mails têm conta.

Evidência:

- Teste de API: `UserPasswordResetEmailApiTests` (PR #919; ApiTests 1119 aprovados,
  0 falhas na época).
- Verificação ao vivo pelo Sergio em 28/09/2026, com a API e o front da branch: o
  e-mail de "Esqueci minha senha" chegou, o link abriu a tela certa, a senha foi
  definida e o login funcionou (comentário na #870).
- Estado em 30/09/2026 na `main` (`21021faf`): `UserPasswordResetService.cs:69-77`
  com o envio ativo; o trecho comentado citado em "Evidência" acima não existe mais.

Requisito de ambiente que continua valendo: `EmailSettings.Enabled=true` e
`EmailSettings__AppBaseUrl` definida (URL pública do front); sem a segunda, o link
do e-mail não pode ser montado. O gerador do código segue `System.Random` por decisão
do CTO (KI-0011), não é parte deste item.

## Dono

Backend Architect (Breno).
