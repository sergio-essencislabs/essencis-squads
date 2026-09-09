---
id: KI-0011
title: "UserPasswordReset — código gerado com System.Random (fidelidade deliberada ao D'Amore)"
severidade: média
status: aberta
produto: GeoCloud
---

## Descrição

`UserPasswordResetService.Add` gera o código de verificação com
`new Random().Next(0, 1_000_000).ToString("D6")` — igual, byte a byte, ao
arquivo de referência do D'Amore. **Decisão deliberada do usuário
(2026-08-31)**: manter fidelidade ao padrão dos arquivos usados para
planejamento nesta rodada, em vez de aplicar `RandomNumberGenerator`
(CSPRNG) como eu tinha feito numa primeira versão do port.

Isso significa que este código de verificação tem a mesma fragilidade já
conhecida do sistema (comparar com KI-0010, o mesmo padrão em
`UserInviteService`, esse sim já em produção e não deliberado): sequência
previsível pela semente baseada em relógio do `System.Random`, num espaço
de apenas 1 milhão de combinações.

## Evidência

```csharp
// api/src/Back.Application/Services/UserPasswordResetService.cs
userPasswordReset.Code = new Random().Next(0, 1_000_000).ToString("D6");
```

## Ação recomendada

Já existe um utilitário pronto e testado para isso —
`Back.Application.Security.VerificationCodeGenerator` (`.Generate()`,
usa `RandomNumberGenerator` internamente, cobertura em
`VerificationCodeGeneratorTests.cs`), já adotado por
`AccountRegistrationService`. Quando o D'Amore revisar/ajustar este
código (ciclo já conhecido — ver planilha interna, "Revisão código
D'Amore"), avaliar junto com KI-0010 migrar as duas classes para injetar
e usar esse gerador em vez de reimplementar `RandomNumberGenerator`
inline — é o padrão que o próprio projeto já estabeleceu em outro fluxo.

## Resolução

_Pendente._

## Dono

Backend Architect (Breno) — decisão de quando aplicar depende do D'Amore/usuário, não é bloqueador para este PR.
