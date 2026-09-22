---
id: GT-0155
title: "PR empilhada chega ao merge com verde velho: retarget da base não dispara o CI"
status: backlog
type: tech-debt
achado_origem: "achado pelo Rui em 13/09/2026 ao tentar produzir um verde novo para o #672 depois de a base andar; confirmado de forma independente pelo Vision, e remedido de forma independente nesta cunhagem"
auditor_origem: "Rui (o mecanismo, a tentativa de reabrir e o segundo sinal), Vision (confirmação independente)"
severidade: alta
produto: GeoCloudAI
camada: infraestrutura
run_origem: "run 34779743505, job 103784438421 — `HEAD is now at e7f953d Merge 6ea88b0290… into 691f0180868…`, com a base do PR já em 29d46de3"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/673"
grupo_execucao: ""
depende_de: []
owner: Sergio
created_at: 2026-09-13
updated_at: 2026-09-13
affected_modules: [ci]
related_adrs: []
contraparte: "GeoCloudAI/.agents/tasks/backlog/GT-0155-retarget-nao-dispara-o-ci.md"
---

# GT-0155 — PR empilhada chega ao merge com verde velho: retarget da base não dispara o CI

## Pareamento por número aposentado em 2026-09-22

O pareamento por número compartilhado com o lado produto (GeoCloudAI) foi aposentado em
2026-09-22, por decisão de Sergio (GT-0714 Fase 2 — reconciliação do passivo histórico). O lado
produto passou a **GT-0673**, o número da própria issue, sob a convenção que a GT-0714 define (GT
e issue com numeração idêntica). Este arquivo do hub mantém o número antigo, **GT-0155**, e o
resto do seu conteúdo, sem alteração.

## Contexto

Neste repositório, **uma PR empilhada chega ao merge com verde velho e nada avisa.**

O verde fica ancorado na base **antiga**. A base avança, o check continua verde, o botão de merge
continua verde, e **nenhum evento re-executa o CI**. Não é falha do CI: é o CI não sendo chamado.

Vale para **qualquer PR empilhada deste repositório**, não só para as da GT-0154. Mordeu em
13/09/2026.

## Achado original

### 1. O mecanismo, lido do `ci.yml`

```yaml
on:
  # Sem filtro de base de propósito: roda em TODO pull request, qualquer que seja a
  # branch de destino. […] CI que não se auto-testa não é CI, é intenção.
  pull_request:            # <- sem `types:` => opened, synchronize, reopened
  push:
    branches: [main, 'feature/**', 'feat/**']
```

Duas portas, e a situação passa por fora das duas:

- **mudar a base** de uma PR emite `edited`, que **não está** na lista padrão de `pull_request`;
- a base de uma PR empilhada é `fix/**` (ou `docs/**`, `chore/**`), que **não casa** nenhum padrão
  do `push`.

**Retarget não dispara re-run, e push na base também não.**

### 2. A ironia, que é o enquadramento e não um detalhe

O comentário do `ci.yml` diz, textualmente, *"sem filtro de base de propósito… CI que não se
auto-testa não é CI, é intenção"*. **A intenção estava certa e estava escrita.** O furo não é de
filtro de base — é de `types:`, que o comentário não cobre.

É a mesma forma do resto do dia: **a guarda existe, e o que ela mede é outra coisa.** Por isso o
conserto do texto do comentário é parte do trabalho, não enfeite: um comentário que descreve uma
proteção que o arquivo não tem é pior que comentário nenhum.

### 3. Fechar e reabrir a PR não resolve — medido, não suposto

O Rui tentou produzir um verde novo fechando e reabrindo a PR. O `reopened` **dispara** o workflow,
mas o `refs/pull/N/merge` **não é recomputado**:

```
HEAD is now at e7f953d Merge 6ea88b0290… into 691f0180868…
```

Conferido de forma independente nesta cunhagem, baixando o log da própria run:

```
run 34779743505 (pull_request, success)  criada 2026-09-13T20:06:45Z
base do PR #672 hoje ...................  29d46de3
base dentro do merge ref daquela run ...  691f0180   <- a antiga
29d46de3 commitado em ..................  2026-09-13 16:55:11 -03  (19:55 UTC)
```

A base andou **onze minutos antes** da run, e a run ainda assim mergeou na base velha. **Não é
corrida:** é o merge ref não ser recomputado.

### 4. O segundo sinal, e ele vale mais que o primeiro

O Rui não descobriu isso pelo `HEAD is now at`. Descobriu porque **o próprio instrumento imprimiu o
rótulo da versão antiga**: o texto novo (`"NÃO é amostra"`) só existe a partir de `29d46de3`, e não
aparece na saída daquela run. Conferido aqui: `grep -c "NÃO é amostra"` no log do job **103784438421**
devolve **0**.

Uma ferramenta que **publica o proxy junto da resposta se identifica sozinha**, e vira uma segunda
medição independente do `HEAD is now at`. É o princípio que esta sprint cobrou a sprint inteira,
pegando desta vez o próprio autor dele.

**Registrar isto como método é metade do valor da GT.**

## O remédio candidato — HIPÓTESE, não conserto decidido

Acrescentar `edited` aos tipos:

```yaml
on:
  pull_request:
    types: [opened, synchronize, reopened, edited]
```

**Não está medido que isto resolva.** O que se sabe é que o `edited` é emitido no retarget. O que
**não** se sabe é se a run disparada por ele nasce com o `refs/pull/N/merge` **já recomputado** — e
o caso do `reopened` acima é a prova de que disparar e recomputar são coisas diferentes neste
repositório.

Quem implementar **tem de medir isso**, não assumir. Se a task sair afirmando o conserto sem a
medição, ela comete exatamente o defeito que descreve.

Um segundo efeito do `edited` precisa entrar na conta: ele também é emitido em **edição de título e
de corpo** da PR. Isso pode significar runs a mais — o que é custo, não defeito, mas é decisão a
declarar e não a descobrir depois.

## Objetivo

Que **nenhuma PR deste repositório chegue ao merge com verde ancorado numa base que já andou** — ou,
se não houver como garantir isso com os eventos disponíveis, que o limite esteja **escrito e
medido**, e que exista sinal para quem for mesclar.

## Fora de escopo

- **A GT-0154 e o PR #672.** São a ocasião do achado, não o escopo. O defeito é do workflow.
- **O conserto da intermitência do provisionamento** (GT-0154) — outra GT, outro mecanismo.
- **Rebase automático de PR empilhada.** Se a conclusão for que só `synchronize` recomputa de
  verdade, *o que fazer com isso* é decisão seguinte, não esta.

## Comportamento atual

A base avança; o check permanece verde contra a base antiga; nada no PR indica que o verde
envelheceu; fechar e reabrir não recomputa.

## Comportamento esperado

Um dos dois, e qual deles é resultado da investigação, não premissa:

1. o retarget (ou o avanço da base) produz **run nova com merge ref recomputado**, provada pelo
   `HEAD is now at`; ou
2. está **escrito e medido** que os eventos disponíveis não garantem isso, e o que fica no lugar é
   um sinal explícito — não a ausência de sinal de hoje.

## Regras de negócio

- RN-01: N/A — dívida de infraestrutura, sem regra de negócio nova.

## Critérios de aceitação

> Nenhuma caixa se marca antes de existir PR. Marcada, a caixa registra critério **cumprido** com a
> PR aberta; o **Done do board** é que espera o merge na `main`.

- [ ] **CA-01:** está **medido** se o evento `edited` produz run com o `refs/pull/N/merge`
      **recomputado** no momento do retarget. A evidência é o `HEAD is now at` daquela run, com o
      SHA da base nova. **Resultado negativo é resultado** e fecha o CA do mesmo jeito.
- [ ] **CA-02:** a prova do CA-01 **não** é "ficou verde". Verde é o sintoma que o defeito produz;
      a prova é qual base entrou no merge ref.
- [ ] **CA-03:** se o `edited` não bastar, o que for adotado no lugar está medido pelo **mesmo**
      critério, e o que foi descartado está escrito com a evidência de por quê.
- [ ] **CA-04:** o comentário do `ci.yml` passa a cobrir `types:`. A intenção declarada ali está
      certa e não muda; o que falta é dizer **por qual porta** ela pode não valer.
- [ ] **CA-05:** o custo do `edited` em runs a mais (ele dispara também em edição de título e corpo)
      está **declarado** — medido ou explicitamente não medido —, não descoberto depois.
- [ ] **CA-06:** a interação com o `concurrency` por `github.ref` está **medida ou declarada não
      medida**. O agrupamento é por ref, com `cancel-in-progress: true`; mais eventos podem
      significar mais cancelamento silencioso, que é a forma de falha que este repositório já
      documentou uma vez.
- [ ] **CA-07:** o método do §4 — instrumento que publica a própria versão junto da resposta — fica
      registrado como **prática**, não como anedota deste caso.
- [ ] **CA-08:** o registro declara **o que esta investigação não alcança**.

## Impacto técnico

### Backend
Nenhum.
### Frontend
Nenhum.
### Banco de dados
Nenhum.
### Integrações
`.github/workflows/ci.yml` — bloco `on:` e o comentário que o descreve.
### Segurança
Nenhum achado de segurança. O risco é de **qualidade**: código mesclado sob verde que não o mediu.

## Plano de implementação

- [ ] Etapa 1 — reproduzir o defeito de propósito: PR empilhada, base andando, e ler o
      `HEAD is now at` da run que sair (ou a ausência de run). É o controle positivo.
- [ ] Etapa 2 — medir o `edited` (CA-01, CA-02).
- [ ] Etapa 3 — conforme o resultado da Etapa 2: adotar, ou medir a alternativa (CA-03).
- [ ] Etapa 4 — comentário do `ci.yml` (CA-04) e custo declarado (CA-05).
- [ ] Etapa 5 — `concurrency` (CA-06).
- [ ] Etapa 6 — registrar o método do segundo sinal (CA-07) e o que não foi alcançado (CA-08).

## Estratégia de testes

- [ ] Unitários — N/A.
- [ ] Integração — N/A.
- [ ] E2E — N/A.
- [ ] Manual — o teste **é** o CA-01, e o instrumento é o log da run. **Atenção ao viés:** run que
      dispara não é run que recomputa. Só o `HEAD is now at` separa as duas, e foi exatamente aí que
      o `reopened` enganou.

## Riscos e rollback

**Risco de método, e é o principal:** aceitar "disparou" como se fosse "recomputou". O `reopened` já
enganou uma vez, e enganaria de novo se a prova fosse o check verde.

**Risco do remédio:** `edited` é mais largo que o problema — pega edição de título e de corpo. Pode
sair caro em runner e, com `cancel-in-progress`, pode cancelar run útil. Daí o CA-05 e o CA-06.

Rollback é `git revert` do commit do workflow — não há estado persistente.

## O que NÃO foi medido, e precisa ficar dito

1. **Que o `edited` resolva.** Ninguém mediu. É hipótese, e o `reopened` é o precedente que
   desaconselha assumir.
2. **Se há outros eventos necessários** além do `edited` para cobrir todos os caminhos pelos quais
   uma base avança.
3. **Se o `concurrency` por `github.ref` interage com isso** — mais eventos, mais cancelamento.
4. **Qual é a exposição real:** não foi contado quantas PRs mescladas desta sprint estavam com verde
   ancorado em base velha. O defeito está provado numa; a frequência, não.

## Registro de execução
### Alterações realizadas
### Arquivos principais
### Decisões
### Divergências
### Pendências
