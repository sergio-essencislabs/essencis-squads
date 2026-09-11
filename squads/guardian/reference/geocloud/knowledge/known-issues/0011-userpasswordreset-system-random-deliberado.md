---
id: KI-0011
title: "UserPasswordReset — código gerado com System.Random (fidelidade deliberada ao D'Amore)"
severidade: média
status: decidida (nao sera alterado)
produto: GeoCloud
---

## Descrição

`UserPasswordResetService.Add` gera o código de verificação com
`new Random().Next(0, 1_000_000).ToString("D6")` — igual, byte a byte, ao
arquivo de referência do D'Amore. **Decisão deliberada do usuário
(2026-08-31)**: manter fidelidade ao padrão dos arquivos usados para
planejamento nesta rodada, em vez de aplicar `RandomNumberGenerator`
(CSPRNG) como eu tinha feito numa primeira versão do port.

Isso significa que este código de verificação compartilha a fragilidade já
conhecida do sistema (comparar com KI-0010, o mesmo padrão em
`UserInviteService`).

**Correção de precisão (2026-09-10).** A versão anterior desta entrada dizia
"semente baseada em relógio". **Isso é falso no .NET 6+**: o `Random()` sem
parâmetros passou a ser semeado por fonte criptográfica, então o ataque
clássico de adivinhar a semente pelo horário não se aplica aqui. A fragilidade
real é outra e continua existindo: `System.Random` usa xoshiro256**, um PRNG
não criptográfico cujo estado interno é recuperável a partir de um punhado de
saídas observadas — quem consegue pedir vários códigos para a própria conta
pode, em princípio, prever o código emitido para outra. O espaço de 1 milhão
de combinações é atenuado por `VerificationAttempts`, que limita força bruta,
mas não atenua a previsão por recuperação de estado.

Registrar o risco certo importa porque **o risco foi aceito**: uma decisão
tomada sobre uma descrição errada não é a mesma decisão.

## Evidência

```csharp
// api/src/Back.Application/Services/UserPasswordResetService.cs
userPasswordReset.Code = new Random().Next(0, 1_000_000).ToString("D6");
```

## Ação recomendada

**Nenhuma. Esta entrada está fechada como decisão, não como pendência.**

Sergio confirmou em 2026-09-10, quando perguntei se valia abrir issue:
*"Sempre manter fidelidade ao código D'Amore. Ele é o CTO e definiu dessa
forma."* A fidelidade **não expira** e não depende de um ciclo de revisão
futuro. A redação anterior desta seção — "quando o D'Amore revisar/ajustar
este código, avaliar migrar as duas classes" — dizia o contrário, e foi
exatamente ela que fez a proposta ser levantada de novo em 2026-09-10.

O utilitário `Back.Application.Security.VerificationCodeGenerator`
(`.Generate()`, `RandomNumberGenerator` por dentro, coberto por
`VerificationCodeGeneratorTests.cs`) continua existindo, registrado no DI
(`Startup.cs`) e usado por `AccountRegistrationService`. Ele simplesmente
**não se aplica a código portado do D'Amore** — e o fato de estar ali,
pronto e a uma linha de distância, é o que torna esta entrada necessária:
sem ela, a próxima pessoa a ler o código vê uma correção óbvia por fazer.

## Resolução

**Fechada por decisão em 2026-09-10**: fica como está, permanentemente.
Fidelidade ao código do D'Amore é decisão do CTO, não prioridade temporária.
Não reabrir.

## Dono

CTO (Luiz Ângelo D'Amore) — decidido. Não é decisão de arquiteto de backend.
