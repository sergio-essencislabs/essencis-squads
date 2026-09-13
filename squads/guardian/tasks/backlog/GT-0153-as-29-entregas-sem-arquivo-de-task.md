---
id: GT-0153
title: "As 29 entregas sem arquivo de task: a célula que o censo não tem"
status: backlog
type: documentation
achado_origem: "N/A — derivado por Otávio da varredura de commits da sprint 08–12/09, conferido contra amostras da Lívia"
auditor_origem: "Otávio (derivação e controle) — enquadramento taxonômico do próprio Otávio"
severidade: alta
produto: GeoCloudAI
camada: documentacao
run_origem: "N/A — despacho direto, fora de run de pipeline"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/666"
grupo_execucao: ""
depende_de: []
owner: Sergio
created_at: 2026-09-13
updated_at: 2026-09-13
affected_modules: [acervo-de-tasks]
related_adrs: []
contraparte: "GeoCloudAI/.agents/tasks/backlog/GT-0153-as-29-entregas-sem-arquivo-de-task.md"
---

# GT-0153 — as 29 entregas sem arquivo de task: a célula que o censo não tem

## Contexto

O censo da GT-0144 classificou o acervo em **três células**:

| célula | quantas |
|---|---|
| só no hub | 39 |
| só no produto | 31 |
| nos dois | 43 |

**Não há célula para "em nenhum dos dois", e não pode haver.** O censo enumera arquivos e cruza os
dois lados; uma entrega sem arquivo nenhum é **invisível para ele por construção**.

Existem **29** dessas.

## Achado original

Derivado por Otávio da varredura de commits da sprint, conferido contra as amostras da Lívia.

### O número, com o artefato removido

A derivação bruta deu **30**. Uma é artefato da própria heurística: **`GT-1440`**, que veio da frase
*"720 e nao 1440 (GT-0105)"* — a regra de lista abreviada leu `1440` como número solto. Removida:
**29**.

**Controle positivo:** `GT-0146`, `GT-0128` e `GT-0137` devolvem `1/1` nos dois lados. O detector
enxerga; os zeros são ausência medida.

### Não são menções — são entregas

Excluindo commits de acervo (`cunha|acervo|normaliza|roteamento|promover|divide a GT`), **29 de 29
continuam tendo commit de trabalho que as cita.** Em boa parte pelo nome da branch no merge sem
squash:

```
Merge pull request #474 from Essencis-Labs/fix/gt-0054-zoom-nos-cores-multiview
Merge pull request #544 from Essencis-Labs/fix/gt-0100-down-das-migrations-de-permissao
Merge pull request #552 from Essencis-Labs/chore/gt-0105-vida-do-token-de-volta
```

### Estão dentro da janela da sprint

| merge | quando | contra a âncora `8ef54558` (08/09 16:44) |
|---|---|---|
| `#474` (`9fa52cb7`) | 09/09 19:11 | depois |
| `#544` (`bfdbe562`) | 10/09 04:04 | depois |
| `#552` (`782007cb`) | 10/09 05:52 | depois |

Conferido por `git merge-base --is-ancestor` nos três, não só pelas datas. E conferido que
`GT-0054`, `GT-0100` e `GT-0105` **não têm arquivo em lado nenhum** — produto `8cbc67e2`, hub
`fcb581f`.

> *"Não é trabalho de fora que vazou: **são PRs mesclados nesta branch durante esta sprint, sem
> arquivo de task em lado nenhum**."*

## O que isto é, e por que é alta

Não é item faltando numa lista. É **categoria faltando na taxonomia**.

> *"Ponteiro quebrado é elo errado para **registro que existe**; aqui **o registro não existe, e o
> instrumento que deveria notar não tem onde pôr o resultado**."*

A consequência é a frase que esta GT existe para tornar regra:

> **Qualquer população derivada de arquivos de task está 29 abaixo, e nenhum predicado sobre
> `.agents/tasks/` vai revelar isso — porque a falta está no conjunto que ele varre.**

Isso contamina silenciosamente toda contagem de entrega, toda métrica de sprint e todo censo de
acervo já feito. É **alta** por isso: não porque 29 arquivos faltem, mas porque **o instrumento de
medida não consegue relatar a própria cegueira**.

É a mesma forma do controle positivo, um nível acima: lá, a peneira que não enxerga devolve zero e
parece resposta; aqui, o **enumerador** não tem célula onde pôr o que não viu.

## Objetivo

1. As 29 estão registradas, ou têm ausência declarada com motivo.
2. O censo ganha a **quarta célula**, e ela é parte permanente da taxonomia.
3. Quem enumerar por arquivo **declara**, no próprio resultado, que existe uma categoria fora do
   alcance dele.

## Fora de escopo

- **Refazer as entregas.** O trabalho foi feito e mesclado; falta o registro, não o código.
- **A forma canônica do `contraparte:`** — GT-0151. Roda em paralelo sem conflito de decisão.
- **O campo de quem executou** — GT-0152. Idem.
- **Auditar sprints anteriores** com o mesmo método. Esta GT mede a janela 08–12/09; que o defeito
  exista antes é provável e não está medido.

## Comportamento atual

O censo tem três células e é apresentado como completo. Uma entrega sem arquivo não aparece em
nenhuma delas e não gera alarme.

## Comportamento esperado

O censo tem quatro células, e a quarta é explicitamente *"entregue, sem arquivo em lado nenhum —
não derivável de `.agents/tasks/`, exige varredura de commits"*.

## Regras de negócio

- RN-01: N/A — dívida de acervo/documentação, sem regra de negócio nova.

## Critérios de aceitação

- [ ] **CA-01:** as **29** estão enumeradas por número, com o commit ou PR que as entregou ao lado
      de cada uma. Lista, não contagem.
- [ ] **CA-02:** cada uma tem par criado **ou** ausência declarada com motivo, na forma
      `N/A — motivo` que já vale no acervo. Criar arquivo de task para trabalho já entregue é
      decisão do Sergio, não de quem executa — as duas saídas são legítimas, o silêncio não é.
- [ ] **CA-03:** **a taxonomia do censo ganha a quarta célula**, escrita nos dois READMEs. Um censo
      de três células volta a ser apresentado como completo no dia em que esta GT for esquecida.
- [ ] **CA-04:** **todo documento que enumerar GTs por arquivo declara, no próprio resultado, que a
      quarta categoria existe e está fora do alcance daquela varredura.** É a aplicação do
      princípio de que toda verificação declara o que não alcança — aqui obrigatória, porque a
      omissão não é detectável de dentro do método.
- [ ] **CA-05:** a varredura de commits que produz a lista fica **versionada**, com **controle
      positivo** (`GT-0146`, `GT-0128`, `GT-0137` devolvendo `1/1`) e com o **artefato conhecido
      documentado** — a regra de lista abreviada produz `GT-1440` a partir de *"720 e nao 1440
      (GT-0105)"*, e quem rodar de novo precisa saber disso antes de contar 30.
- [ ] **CA-06:** o registro declara **o que esta verificação não alcança** — em particular, que ela
      cobre a janela 08–12/09 e não diz nada sobre sprints anteriores.

## Impacto técnico

### Backend
Nenhum.
### Frontend
Nenhum.
### Banco de dados
Nenhum.
### Integrações
Nenhum.
### Segurança
Nenhum.

## Plano de implementação

- [ ] Etapa 1 — produzir a lista das 29 com evidência por número (CA-01, CA-05).
- [ ] Etapa 2 — o Sergio decide: criar par retroativo, ou declarar ausência com motivo (CA-02).
- [ ] Etapa 3 — executar a decisão.
- [ ] Etapa 4 — a quarta célula nos dois READMEs e a obrigação de declaração (CA-03, CA-04).

## Estratégia de testes

- [ ] Unitários — N/A.
- [ ] Integração — N/A.
- [ ] E2E — N/A.
- [ ] Manual — a varredura de commits é a verificação. Ela **não** pode ser substituída por
      varredura de `.agents/tasks/`: é precisamente o ponto desta GT que a segunda é cega para o
      conjunto medido.

## Riscos e rollback

Risco de acervo: criar 29 arquivos de task retroativos para trabalho já entregue produz registro
que **parece planejamento e é reconstrução**. Se for essa a decisão, os arquivos têm de dizer no
corpo que foram criados depois da entrega — senão o acervo passa a mentir sobre a própria ordem, e
a próxima medição de "quando a task nasceu" fica errada sem aviso.

Rollback é `git revert` — não há estado fora do repositório.

## Registro de execução
### Alterações realizadas
### Arquivos principais
### Decisões
### Divergências
### Pendências

## Validação

Comandos e resultados reais — nunca uma caixa marcada sem evidência ao lado.

## Handoff

**Achado sobre uma GT que acabou de fechar.** O censo da **GT-0144** ganha uma quarta célula por
causa desta GT. A GT-0144 fechou em 13/09/2026 com a conclusão de que a reconciliação estava
inteira — e continua correta **dentro do que ela media**: dos ponteiros que existem, nenhum par
falta. Esta GT diz que **o conjunto medido era menor do que o universo**, que é afirmação de outra
ordem e não contradiz aquela.

**Roda em paralelo com a GT-0149, a GT-0151 e a GT-0152** — é reconstrução de registro, não
canonização de forma, e não disputa decisão com nenhuma delas.
