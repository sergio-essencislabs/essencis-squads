---
id: GT-0052
title: "Sequestro de registro entre contas: a guarda decidia pelo corpo da requisicao"
status: completed
type: security
severidade: critica
owner: sergio-essencislabs
created_at: 2026-09-09
updated_at: 2026-09-10
origem: "campanha de autorizacao (Back.ApiTests/Campaign), depois que a GT-0050 a fez produzir veredito real"
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0052-sequestro-de-registro-entre-contas.md"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/467"
branch: fix/gt-0052-sequestro-de-registro-entre-contas
affected_modules: ["Back.API", "Back.Persistence"]
related_use_cases: []
related_adrs: []
---

# GT-0052 — Sequestro de registro entre contas

## Como isto apareceu

A GT-0050 consertou a suíte de API, que estava dando 403 em tudo por defeito de fixture. Com ela
funcionando, a campanha de autorização passou a produzir veredito de verdade pela primeira vez:
**85 reprovados, 83 travessias entre contas bem-sucedidas**, cada uma com prova no banco.

A campanha já gerava essa evidência antes — em JSON, a cada execução, sem nunca reprovar a build.

## O caso concreto

Conta atacante 136, `PUT /api/StructureType/update`, `id=19` (linha da conta 1), corpo com
`accountId=136`:

```
antes  : 19|1  |CAMP_ALVO_60befe98  |1  |2026-02-05
depois : 19|136|CAMP_HIJACK_9c97f093|165|2026-09-09
```

O registro não foi só alterado: **mudou de dono**.

## A causa, em uma frase

**A autorização era decidida a partir do corpo da requisição, nunca da linha armazenada.**

```csharp
if (AccountIdToken != structureTypeDto.AccountId)   // o accountId do CORPO
    return Forbid();
```

A guarda confere se o *payload* afirma a conta do chamador, não se a *linha alvo* pertence a ele.
O `delete` do mesmo controller sempre acertou — carrega a linha por `id` antes de decidir. A
assimetria dentro do mesmo arquivo é o que torna isto descuido, e não desenho.

## Quatro eixos, uma frase

| Eixo | Endpoints | O que a guarda fazia de errado |
|---|---|---|
| Sequestro direto | 36 | comparava o `accountId` do corpo |
| Confused deputy | 28 | resolvia a conta pelo **pai** enviado no corpo |
| Omissão de objeto | 3 | era condicional a um `entity` que bastava **não enviar** |
| Leitura por id | 17 | não existia |

O eixo de omissão é o mais desconfortável de ler: a autorização não era contornada, era **pulada** —
`dto.Entity?.AccountId != null && ...` vira falso inteiro quando o objeto não vem. Foi assim que a
campanha alterou o usuário id 1 no clone.

## Correção

Uniforme: **carregar o alvo por `id`, resolver a conta dele no servidor e comparar com
`AccountIdToken`.** Nenhum campo do corpo participa da decisão.

Para os aninhados, a mesma resolução que já existia passa a rodar a partir do registro armazenado.
A resolução pelo pai enviado **continua** logo depois, agora como verificação adicional: sem ela,
seria possível empurrar um registro próprio para a árvore de outra conta. Há um teste só para esse
caso.

## Um bug de produto encontrado junto

`Company/update` respondia **500 para todo mundo**, inclusive o dono legítimo: `GetByName`, chamada
no caminho de update, declarava quatro tipos no multi-map do Dapper e projetava três — a coluna de
`CompanyType` estava no `JOIN` e ausente do `SELECT`, faltando o terceiro marcador `split`. Foi o
único `Controle:Baseline` vermelho da campanha, e vermelho desde a primeira execução, antes de
qualquer alteração minha.

## Critérios de aceitação

- [x] CA-01 — Nenhuma decisão de autorização usa campo do corpo como fonte única.
- [x] CA-02 — `update` recusa `id` de outra conta, e a linha **não muda** no banco.
- [x] CA-03 — `update` na própria conta continua funcionando (par positivo).
- [x] CA-04 — `update` não consegue empurrar registro próprio para outra conta.
- [x] CA-05 — `User/update` sem o objeto `entity` não pula a guarda.
- [x] CA-06 — `getById` recusa linha de outra conta e devolve a da própria.
- [x] CA-07 — `Company/update` volta a funcionar para o dono.
- [x] CA-08 — Campanha: **429 aprovados, 0 reprovados** em 73 relatórios (era 85 reprovados).
- [x] CA-09 — Os testes ficam vermelhos sem a correção: revertendo 6 controllers, 8 de 11 falham.
- [ ] CA-10 — Teste manual das telas de edição (Sergio/Matheus).

## O que ficou de fora, e por quê

A varredura universal (683 ações, 96 controllers) encontrou **mais 47** leituras entre contas —
`getByUser` sem guarda em 28 controllers e `get` global sem a checagem de entidade dona em ~19.
É a mesma classe de #296/#297, espalhada. Fica em issue própria: a correção é outra (guarda de
leitura, não de escrita) e misturá-la aqui tornaria os dois lotes irrevisáveis.

## Verificação

- Campanha de autorização: **429 aprovados / 0 reprovados**, 73 relatórios.
- `TenantHijackApiTests` 11/11, versionado — a campanha não é versionada e não pode ser a única
  rede.
- `Back.UnitTests` 287/287, `Back.IntegrationTests` 53/53, `Back.ApiTests` 114/115 (a que falta é
  a varredura universal, que exige `CAMPANHA_INVENTORY` no ambiente).

---

## Reconciliacao - 21/09/2026 (GT-0156)

**Resolvido - a deriva anunciada (hub active x produto completed) esta confirmada e agora
corrigida.** Commits `0bba7088` + `3507143f` (PR #469, merge `f53e9e90`). Issue #467 CLOSED. Codigo
que demonstra a condicao satisfeita: `StructureTypeController.cs:70-75` (compara
`registroExistente.AccountId != AccountIdToken` antes de checar o corpo);
`UserController.cs:164-166` (eixo de omissao). Teste versionado: `TenantHijackApiTests.cs`, 11
metodos sem Skip=. Contraparte produto em completed/, CA-10 sincronizado agora (era [ ] no
hub, [x] no produto).

Este e o unico dos quatro (GT-0049/50/51/52) cujo `contraparte:` do lado produto ja apontava
corretamente para o hub.

Evidencia completa no relatorio da reconciliacao GT-0156.
