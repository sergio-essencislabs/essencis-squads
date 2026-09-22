---
id: GT-0148
title: "O aviso de omissão não é gravado fora do modo relatório"
status: active
type: security
achado_origem: "achado da Flávia ao executar a GT-0140, com caso mínimo rodado — não é dedução"
auditor_origem: "Flávia (execução da GT-0140)"
severidade: media
produto: GeoCloudAI
camada: ""
run_origem: "N/A — despacho direto, fora de run de pipeline"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/646"
grupo_execucao: ""
depende_de: []
owner: Sergio
created_at: 2026-09-12
updated_at: 2026-09-12
affected_modules: []
related_adrs: []
contraparte: "GeoCloudAI/.agents/tasks/active/GT-0148-gravacao-condicional-do-omitted-kinds.md"
---

# GT-0148 — o aviso de omissão não é gravado fora do modo relatório

## Pareamento por número aposentado em 2026-09-22

O pareamento por número compartilhado com o lado produto (GeoCloudAI) foi aposentado em
2026-09-22, por decisão de Sergio (GT-0714 Fase 2 — reconciliação do passivo histórico). O lado
produto passou a **GT-0646**, o número da própria issue, sob a convenção que a GT-0714 define (GT
e issue com numeração idêntica). Este arquivo do hub mantém o número antigo, **GT-0148**, e o
resto do seu conteúdo, sem alteração.

## Contexto
A GT-0140 (#620) consertou as três camadas que faziam o aviso de omissão sumir ao recarregar a
conversa: a query de releitura, o DTO e a remontagem do turno. **Com as três corrigidas, o aviso
continua sumindo numa classe de caso** — e some porque nunca chegou a ser gravado.

Achado da Flávia durante a execução da GT-0140, **com caso mínimo executado**. Não há dedução
aqui: ela rodou.

## Problema
A gravação de `omitted_kinds` está **condicionada ao modo relatório**.

`api/src/Back.Application/Services/ChatService.cs:438`
```csharp
var temCobertura = ctx.CoveredPermissionKeys.Count > 0;
var summaryKind = dto.ReportMode && temCobertura ? "drillbox_ai_summary_seed" : null;
```

`api/src/Back.Application/Services/ChatService.cs:600-606`
```csharp
if (summaryKind != null)
{
    assistantMsg.AccountId    = accountId;
    assistantMsg.DrillBoxId   = dto.DrillBoxId;
    assistantMsg.CoveredKeys  = System.Text.Json.JsonSerializer.Serialize(coveredKeys ?? new List<string>());
    assistantMsg.OmittedKinds = System.Text.Json.JsonSerializer.Serialize(ctx.OmittedKinds);
}
```

**Pergunta comum ao chat da caixa** — `ReportMode = false` — **feita por quem não enxerga
fraturas: o aviso aparece ao vivo e a coluna é gravada nula.** Reaberta a conversa, não há aviso,
porque não há o que ler.

Saída do `[Theory]` da Flávia, registrado na GT-0140:
```
Quem_grava_a_omissao(reportMode: False) [FAIL]
  Expected assistente.OmittedKinds not to be <null> because reportMode=False: coluna gravada = NULL.
```

**O teste não foi deixado no repositório, e o motivo é bom:** como está escrito, ele afirma que a
coluna deve ser gravada sempre — que é exatamente a decisão que **esta** GT precisa tomar.
*"Teste que afirma defeito o transforma em contrato."* O harness dela deve ser copiado para cá e
só virar teste versionado depois da decisão de escopo abaixo.

## Isto não é "acrescentar uma linha"
`AccountId`, `DrillBoxId` e `CoveredKeys` estão **no mesmo `if`**, e existem para o resumo
durável — são o que faz a linha se sustentar sozinha como candidata a resumo (GT-0126).

**Separar `OmittedKinds` dos outros três, ou levar os quatro juntos, é decisão de escopo desta
GT** e precisa estar escrita antes de a implementação começar.

O dado que barateia a segunda opção, medido pelo Breno: **gravar em toda resposta não faz a linha
virar candidata a resumo durável**, porque `ListDurableDrillBoxSummaries` filtra por `account_id`,
`drill_box_id` **e** `metadata.kind` — sem o `kind` de resumo, a linha não entra na seleção.

## Objetivo
O aviso de omissão sobrevive ao recarregamento **em toda resposta do chat da caixa**, não só nas
que são o resumo durável.

## Fora de escopo
- Não mostrar nem preencher o conteúdo omitido — a regra da GT-0128/0138 continua: declara-se
  **que**, nunca **o quê**.
- Não alterar a seleção de resumo durável da GT-0126, nem o veto de cobertura vazia da GT-0123.
- Não retroagir sobre linhas já gravadas com `omitted_kinds` nulo.

## Comportamento atual
`ReportMode = false` grava `omitted_kinds` nulo; o aviso existe só enquanto o turno está na tela.

## Comportamento esperado
A coluna reflete o que o contexto omitiu, independentemente de a resposta ser ou não o resumo.

## Regras de negócio
- RN-01: a decisão de escopo (só `OmittedKinds` ou os quatro campos) é **escrita antes** de
  implementar, com o motivo.
- RN-02: gravar mais não pode fazer linha comum virar candidata a resumo durável. O filtro por
  `metadata.kind` é o que garante isso hoje — **se o escopo escolhido mexer nele, a RN cai e vira
  risco**.
- RN-03: o teste só entra versionado depois da decisão, para não congelar o defeito como contrato.

## Critérios de aceitação
- [ ] CA-01: a decisão de escopo está escrita nesta task, com o motivo, **antes** do primeiro
      commit de implementação.
- [ ] CA-02: resposta com `ReportMode = false` e contexto podado grava `omitted_kinds` não nulo.
- [ ] CA-03: reaberta a conversa, o aviso aparece — fecha o buraco que a GT-0140 deixou.
- [ ] CA-04: resposta sem omissão continua gravando lista vazia ou nulo, sem poluir a UI.
- [ ] CA-05: **nenhuma linha comum passa a ser devolvida por `ListDurableDrillBoxSummaries`** —
      teste explícito, porque é o risco que o escopo "levar os quatro juntos" introduz.
- [ ] CA-06: o veto da GT-0123 (cobertura vazia não vira resumo) continua valendo.
- [ ] CA-07: o harness da Flávia entra versionado **com a asserção ajustada à decisão**, não como
      está.

## Impacto técnico
### Backend
`ChatService.SendDrillBoxMessage`, o bloco `:596-607`.
### Frontend
Nenhum — a GT-0140 já lê o campo nas três camadas.
### Banco de dados
Nenhum schema novo: a coluna existe.
### Integrações
N/A.
### Segurança
É o ponto: sem o aviso, o leitor não sabe que a resposta saiu sobre contexto podado.

## Plano de implementação
- [ ] Etapa 1 — decidir o escopo (CA-01) e escrever o motivo.
- [ ] Etapa 2 — implementar.
- [ ] Etapa 3 — o teste da Flávia, ajustado (CA-07), mais o CA-05.

## Estratégia de testes
- [ ] Unitários: CA-02, CA-04, CA-06.
- [ ] Integração: CA-03 (releitura) e CA-05 (seleção de resumo durável).
- [ ] E2E: N/A.
- [ ] Manual: pergunta comum sem permissão de fraturas, reabrir a conversa.

## Riscos e rollback
- **Risco principal:** levar os quatro campos juntos e mexer, sem perceber, na seleção de resumo
  durável. O CA-05 é a defesa; a RN-02 diz de onde vem a garantia atual.
- **Risco:** versionar o teste como a Flávia o escreveu, congelando "gravar sempre" como contrato
  antes de a decisão existir.
- **Rollback:** o bloco é local; reverter é um commit.

## Registro de execução
### Alterações realizadas
Pendente — cunhada em 12/09/2026, não implementada.
### Arquivos principais
Pendente.
### Decisões
Pendente — o CA-01 é a primeira.
### Divergências
Nenhuma.
### Pendências
`grupo_execucao` não preenchido: é do Step 09.

## Validação
Pendente. A evidência do achado foi conferida em `f1ffdfce`: `ChatService.cs:438` e `:600-606`.

## Handoff
Sem dependência de entrada. Sucessora direta da GT-0140 (#620), que consertou a leitura e deixou
a gravação.
