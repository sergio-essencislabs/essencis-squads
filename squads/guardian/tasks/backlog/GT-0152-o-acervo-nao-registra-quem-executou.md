---
id: GT-0152
title: "O acervo não registra quem executou: procedência é reconstruída, não lida"
status: backlog
type: documentation
achado_origem: "N/A — achado em 13/09/2026 ao tentar conferir a tabela de procedência exigida pelo CA-00 da GT-0151"
auditor_origem: "Tomás Ticket (curadoria de acervo) — formulação do defeito pela Lívia"
severidade: media
produto: GeoCloudAI
camada: documentacao
run_origem: "N/A — despacho direto, fora de run de pipeline"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/667"
grupo_execucao: ""
depende_de: []
owner: Sergio
created_at: 2026-09-13
updated_at: 2026-09-13
affected_modules: [acervo-de-tasks]
related_adrs: []
contraparte: "GeoCloudAI/.agents/tasks/backlog/GT-0152-o-acervo-nao-registra-quem-executou.md"
---

# GT-0152 — o acervo não registra quem executou: procedência é reconstruída, não lida

## Contexto

O front-matter de toda GT traz `owner: Sergio`. **Nenhuma GT registra qual janela executou o
trabalho.** O `owner` responde *de quem é a decisão*; ninguém responde *quem fez*.

Isso passou despercebido por não ter consequência visível — até a GT-0151 precisar da informação e
descobrir que ela não existe em lugar nenhum.

## Achado original

O CA-00 da GT-0151 exige listar de onde veio cada forma do campo `contraparte:` e **quem a
executou**, antes de canonizar qualquer uma. A tabela ficou assim:

| forma | quem estabeleceu | onde |
|---|---|---|
| caminho relativo | Lívia | os 31 do Grupo B (GT-0147) |
| `N/A — motivo` | Marta | os 39 do Grupo A (GT-0146) |
| absoluta | ninguém — nasceu de uso | 16 campos |

**Tentei conferir as duas primeiras atribuições no acervo e não consegui.** Li a `GT-0146` e a
`GT-0147` em `fcb581f`: as duas trazem **só `owner: Sergio`** e nenhum campo que diga qual janela
executou. A tabela veio de quem se lembrava, não do registro.

O achado foi por acaso — eu estava conferindo a tabela, não auditando o esquema. Isso importa para
o dimensionamento: **ninguém foi procurar este defeito, e ele só apareceu porque uma task precisou
do dado.** Quantas outras informações do mesmo tipo faltam é desconhecido, e esta GT não descobre.

### A formulação, que é da Lívia

> **Precedente é autoria por outro caminho** — e a diferença é que a autoria tem assinatura e o
> precedente não. Por isso precisa de um passo que o reconstrua.

E a razão de o passo não bastar sozinho:

> *"Vira passo do processo em vez de honestidade individual. **Hoje funcionou porque eu declarei;
> na próxima pode não ocorrer a quem estiver no meu lugar.**"*

**O CA-00 da GT-0151 é o remendo certo para o caso concreto e o remendo errado para o problema.**
Ele obriga *aquela* task a reconstruir *aquelas* três procedências. Não faz a próxima reconstruir
as dela, e não transforma reconstrução em consulta.

### Por que isto é da família da GT-0149, e como

A GT-0149 cataloga **ausência que significa duas coisas**: um campo vazio que tanto pode dizer "não
se aplica" quanto "ninguém preencheu". Aqui a ausência é de outra ordem e a mesma família — **o
campo não existe**, então a ausência não pode nem ser interrogada:

| forma da ausência | o que não se consegue distinguir | onde |
|---|---|---|
| campo vazio | "não se aplica" contra "ninguém preencheu" | GT-0149 (`issue_url: ""`, `contraparte: ""`) |
| **campo inexistente** | **"ninguém executou" contra "ninguém registrou"** | **esta GT** |

**Não é dependência, é vizinhança — e a distinção é deliberada.** A GT-0149 reconcilia o
vocabulário de dois campos **que já existem**; esta GT propõe um campo **novo**. Nenhuma decide algo
de que a outra precise, então `depende_de: []`.

O que existe é **sobreposição de arquivos**: as duas mexem nos mesmos quatro documentos (os dois
READMEs e os dois `_template.md`), e a GT-0151 também. Isso é motivo para **não executar as três ao
mesmo tempo**, e não é motivo para encadeá-las. Sequenciamento é do roteamento (Step 09);
`depende_de` é para quando uma precisa do resultado da outra.

## Objetivo

Quem executou uma GT é **lido** do acervo, não reconstruído de memória. Uma lista de procedência
como a que o CA-00 da GT-0151 exige passa a ser uma consulta.

## Fora de escopo

- **Preencher retroativamente as 120 GTs existentes.** Quase todo o histórico não é recuperável de
  registro — só de memória, que é exatamente o que esta GT diz não servir. O que fazer com o
  passado é decisão, e está em "Comportamento esperado" como pergunta aberta, não como tarefa.
- **A reconciliação de vocabulário dos campos existentes** — GT-0149.
- **A forma canônica do `contraparte:`** — GT-0151.
- **Descobrir que outros campos faltam.** Este achado apareceu por acaso; uma auditoria de esquema
  é outro trabalho e não está sendo pedida aqui.

## Comportamento atual

`owner: Sergio` em toda GT. Nenhum campo de execução. A `GT-0146` e a `GT-0147` — de onde vêm dois
dos três precedentes do `contraparte:` — não dizem quem as executou.

## Comportamento esperado

O front-matter registra quem executou. As decisões que ficam para o Sergio, e que esta GT
**não** toma:

1. **Nome e forma do campo.** `executado_por:` é o candidato óbvio; a lista ou o valor único
   dependem de uma GT poder ter mais de um executor, o que acontece (a GT-0145 teve execução e
   revisão de janelas diferentes).
2. **Quem preenche, e quando.** No Step 09 pelo roteamento, ou por quem executa ao fechar. A
   segunda é mais fiel e mais fácil de esquecer.
3. **O que fazer com o passado.** Deixar ausente e declarar por quê é uma resposta legítima — e é
   coerente com a regra da GT-0149 de que ausência decidida se escreve `N/A — motivo`, nunca `""`.

## Regras de negócio

- RN-01: N/A — dívida de acervo/documentação, sem regra de negócio nova.

## Critérios de aceitação

- [ ] **CA-01:** o campo de execução está declarado nos dois `_template.md` e nos dois READMEs, com
      a mesma grafia e o mesmo significado nos quatro. Divergência entre os dois lados é o defeito
      que a GT-0149 cataloga, e esta GT não pode criá-lo enquanto o corrige.
- [ ] **CA-02:** o campo distingue **"não se aplica"** de **"não preenchido"**, pela regra que já
      vale no acervo: ausência decidida escreve `N/A — motivo`, nunca `""`.
- [ ] **CA-03:** o tratamento do histórico está **escrito e justificado** — seja preencher, seja
      deixar ausente com motivo. Um acervo em que o campo existe para as novas e cala para as
      antigas, sem dizer qual é o caso, reintroduz a ambiguidade da GT-0149 num campo novo.
- [ ] **CA-04:** uma varredura demonstra que o campo é **legível por máquina** nas GTs que o têm —
      com **controle positivo** ao lado do resultado, e **prestação de contas** (quantas têm,
      quantas não têm, e a soma fechando com o total do acervo).
- [ ] **CA-05:** o registro de execução declara **o que esta verificação não alcança** — em
      particular, que ela não diz nada sobre a fidelidade do que foi preenchido, só sobre a
      presença e a forma.

## Impacto técnico

### Backend
Nenhum.
### Frontend
Nenhum.
### Banco de dados
Nenhum.
### Integrações
Nenhum — não há consumidor executável do front-matter das GTs hoje, medido na GT-0151 com controle
positivo. Um campo novo não quebra nada; também não é validado por nada.
### Segurança
Nenhum.

## Plano de implementação

- [ ] Etapa 1 — o Sergio decide as três perguntas de "Comportamento esperado". Não é trabalho de
      quem executa.
- [ ] Etapa 2 — declarar nos quatro documentos (CA-01, CA-02).
- [ ] Etapa 3 — resolver o histórico conforme a decisão (CA-03).
- [ ] Etapa 4 — varredura com controle positivo e prestação de contas (CA-04, CA-05).

> **Aviso a quem executar a Etapa 3:** se a decisão for escrever nos arquivos existentes, não use
> `sed` por padrão no front-matter. Um `/^owner:/` acerta também blocos ```yaml citados dentro do
> corpo de outras GTs. Confira o diff inteiro, não o ponto esperado.

## Estratégia de testes

- [ ] Unitários — N/A, não há código de produto.
- [ ] Integração — N/A.
- [ ] E2E — N/A.
- [ ] Manual — a varredura do CA-04 é a verificação, e o script fica **versionado**, não em
      scratchpad.

## Riscos e rollback

Risco: edição em massa de front-matter atingir bloco citado (ver aviso na Etapa 3). Rollback é
`git revert` — não há estado fora do repositório.

Risco de acervo: criar o campo e preenchê-lo de memória para o histórico produziria um registro
**que parece lido e é lembrado** — pior que a ausência, porque a ausência é honesta. Se o passado
for preenchido, o critério tem que dizer de que fonte.

## Registro de execução
### Alterações realizadas
### Arquivos principais
### Decisões
### Divergências
### Pendências

## Validação

Comandos e resultados reais — nunca uma caixa marcada sem evidência ao lado.

## Handoff

**Caso concreto que originou esta GT, e que serve de teste de aceitação informal:** quando ela
estiver feita, a tabela de procedência do CA-00 da GT-0151 deve poder ser refeita **consultando o
acervo**, sem perguntar a ninguém. Hoje não pode — e a linha da forma absoluta continuará dizendo
"ninguém", que é uma resposta legítima e verificável, não uma lacuna.

**Não executar ao mesmo tempo que a GT-0149 e a GT-0151:** as três escrevem nos mesmos quatro
documentos. Não é dependência de resultado, é conflito de arquivo — e é do roteamento resolver.
