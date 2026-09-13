---
id: GT-0154
title: "Intermitência do provisionamento do CI: 28 MB de log de erro num passo só"
status: backlog
type: tech-debt
achado_origem: "N/A — quedas observadas em 13/09/2026 no passo de provisionamento; os quatro achados foram medidos durante a revisão do PR #661"
auditor_origem: "Rui (o delta de 28 MB e a atribuição por leitura do topo), Dante (o delta e a transcrição ancorada), Flávia (a citação stale)"
severidade: alta
produto: GeoCloudAI
camada: infraestrutura
run_origem: "run 34745948062, tentativa 1 — bytes ancorados no commit 16b404a5 (PR #661)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/668"
grupo_execucao: ""
depende_de: []
owner: Sergio
created_at: 2026-09-13
updated_at: 2026-09-13
affected_modules: [ci, provisionamento]
related_adrs: []
contraparte: "GeoCloudAI/.agents/tasks/backlog/GT-0154-intermitencia-do-provisionamento-do-ci.md"
---

# GT-0154 — intermitência do provisionamento do CI: 28 MB de log de erro num passo só

## Contexto

O passo de provisionamento do CI cai de forma **intermitente** — 3 quedas no mesmo passo em cerca
de 3 horas em 13/09/2026. A GT-0143 fez a falha deixar de ser silenciosa; **não fez a falha parar**,
e a causa continua sem dono.

Esta GT nasce com **quatro achados medidos** em vez de com uma suspeita.

## Achado original

### 1. O achado que ninguém tinha olhado — 28 MB de log de erro

```
/var/log/mysql/error.log  --  antes: 0 bytes  |  depois: 28.554.975 bytes
```

**Vinte e oito megabytes e meio num único passo de provisionamento.**

> *"Um `mysqld --initialize-insecure` escreve alguns KB. Uma subida por `mysqld_safe`, alguns KB.
> Mesmo com o import do baseline, o normal é ficar na casa das centenas de KB — **isto é duas a
> três ordens de grandeza acima**."* — Rui

E a observação que explica por que ninguém tinha olhado:

> *"O número está lá desde que o delta foi medido e **passou como confirmação em vez de como
> dado**."*

**Hipótese, declarada como não medida:** tempestade de avisos por statement no import do baseline
— da ordem de 100 mil statements × ~250 bytes ≈ essa grandeza. **Não confirmada, e a GT não deve
tratá-la como se fosse.**

> *"Um passo que gera 28 MB de log de erro é um passo em que **muita coisa está dando errado
> silenciosamente**, e falha intermitente costuma morar exatamente aí."*

**Esta é a melhor pista que a GT tem e é a primeira coisa que ela deve medir.**

### 2. A atribuição, fechável por um comando

O delta, como foi medido, atribui a escrita **ao passo**, não ao `initialize` — e isso foi
declarado com honestidade por quem mediu. O `antes` ser **0 bytes** resolve isso de graça:

```bash
head -c 4000 /var/log/mysql/error.log
```

> *"Como o arquivo **começou vazio**, as primeiras linhas são necessariamente do **primeiro
> escritor da janela**. Não assume nada: **identifica** o escritor pelo conteúdo."*

O `--initialize-insecure` escreve linhas inconfundíveis (`root@localhost is created with an empty
password`). Se estiverem no topo, a atribuição deixa de ser inferência e vira medição. Se for outra
coisa — o `postinst` do pacote, por exemplo —, **aprendemos isso**, que também é resultado.

**Com a ressalva obrigatória:** se o `head` não puder ler, o passo tem de dizer **qual** das duas —
permissão ou ausência do arquivo. As duas falham igual e significam coisas opostas.

### 3. O degrau do guarda — ele pode trazer a resposta em vez de pedir que a procurem

Hoje o guarda manda o operador ir procurar o log. Ele pode **ler o `log_error` da configuração e
imprimir o `tail` do arquivo que ela nomear**.

Mesma ressalva, e ela é o ponto: **a falha do `tail` tem de dizer qual das duas** — não existe o
arquivo, ou não há permissão.

> *"Senão reintroduzimos o silêncio apresentado como diagnóstico, **um nível acima**."*

### 4. A citação stale do `setup-cloud-env.sh` — e por que o conserto óbvio a estraga

Um parágrafo cita `setup-cloud-env.sh` como exemplo do que o CI faz. **O CI usa o
`provision-env.sh` desde a GT-0143** (conferido: `.github/workflows/ci.yml:120` chama
`scripts/cloud/provision-env.sh --skip-verify`).

A precisão da Flávia muda o conserto:

> *"As linhas 113-127 fazem exatamente o que o parágrafo diz — **a citação está correta sobre o
> arquivo que nomeia**. Quem consertar trocando o nome vai **estragar uma citação correta**; o que
> falta é dizer **de quem é** aquele script."*

Os dois existem e fazem coisas diferentes, e o cabeçalho do `ci.yml` já distingue: o
`setup-cloud-env.sh` cola no campo *"Setup script"* do ambiente web e roda **antes de o repositório
existir**; o `provision-env.sh` roda **de dentro do repositório**. **O conserto é acrescentar a
atribuição, não trocar o nome.**

## O que já se sabe, e que poupa a primeira semana desta GT

```
mysqld --initialize-insecure  ->  código de saída 2, stderr VAZIO

o log_error vai para /var/log/mysql/error.log
  (mysqld.cnf:62, sob [mysqld], em diretório incluído pelo my.cnf raiz)

mysqld --verbose --help NÃO serve como instrumento:
  reporta o default COMPILADO, ignora o arquivo de configuração
  E ignora o --log-error passado na própria linha de comando

ERROR 1045 do root aparece em TODA run, inclusive nas verdes
  -> o datadir é sempre reinicializado; o initialize roda toda vez e falha às vezes

frequência observada: 3 quedas no mesmo passo em ~3 horas (13/09/2026)

error.log da imagem: 0 bytes, mtime 5,4 dias
  -> o MySQL pré-instalado nunca subiu
```

**Os bytes da run estão ancorados no commit `16b404a5`** (PR #661): o log da tentativa 1 sumiu no
rerun e a única cópia estava em scratchpad. **Aponte para lá — não copie.** Duas cópias do mesmo
artefato são duas fontes e nenhuma canônica.

## Objetivo

Saber **por que** o provisionamento falha às vezes, com a causa medida e não inferida. O caminho
mais curto conhecido passa pelos 28 MB.

## Fora de escopo

- **O conserto do guarda que a GT-0143 já entregou.** Ela fez a falha deixar de ser silenciosa;
  esta GT trata de a falha existir.
- **O PR #661.** Ele já cresceu cinco vezes e **declara o próprio limite com honestidade**. Fechar
  a lacuna do `head -c 4000` ali seria melhoria, não conserto — e os 28 MB são claramente escopo
  próprio.
- **Reescrever o import do baseline.** Se a hipótese da tempestade de avisos se confirmar, o que
  fazer com ela é decisão seguinte, não esta.

## Comportamento atual

O passo cai às vezes, sem causa conhecida. Quando cai, o guarda avisa alto — e manda procurar.

## Comportamento esperado

A causa da intermitência é conhecida e está escrita. O passo, quando falha, traz o diagnóstico em
vez de pedir que o procurem.

## Regras de negócio

- RN-01: N/A — dívida de infraestrutura, sem regra de negócio nova.

## Critérios de aceitação

- [ ] **CA-01:** os **28 MB estão explicados por medição**, não por hipótese. O que escreve, quanto
      escreve, e por quê. Se a tempestade de avisos se confirmar, com contagem; se for outra coisa,
      com a evidência do que é.
- [ ] **CA-02:** a atribuição da escrita está **medida pelo conteúdo do topo do arquivo**
      (`head -c 4000`), não inferida do delta. O resultado nomeia o primeiro escritor da janela.
- [ ] **CA-03:** **toda leitura de arquivo neste caminho distingue "não existe" de "sem
      permissão"** — no `head` do CA-02 e no `tail` do guarda. Uma falha de leitura que não diz qual
      das duas é silêncio apresentado como diagnóstico, e é o defeito que a GT-0143 consertou um
      nível abaixo.
- [ ] **CA-04:** o guarda **traz** o `tail` do arquivo que o `log_error` da configuração nomear, em
      vez de mandar procurar.
- [ ] **CA-05:** a citação do `setup-cloud-env.sh` ganha **atribuição** — de quem é o script e
      quando roda —, e **não** troca de nome. A citação está correta sobre o arquivo que nomeia; o
      conserto óbvio a estragaria.
- [ ] **CA-06:** a causa da intermitência está **escrita**, ou está escrito **o que foi descartado
      e com que evidência**. Fechar sem causa é resultado legítimo; fechar sem dizer o que se
      olhou, não.
- [ ] **CA-07:** o registro declara **o que esta investigação não alcança** — em particular, se a
      correção reduz a frequência sem eliminar a causa, isso tem de ficar dito, não medido como
      sucesso.

## Impacto técnico

### Backend
Nenhum — o defeito é do provisionamento, não do código de produto.
### Frontend
Nenhum.
### Banco de dados
O MySQL do ambiente de CI: inicialização do datadir e import do baseline.
### Integrações
O workflow de CI (`.github/workflows/ci.yml`) e `scripts/cloud/provision-env.sh`.
### Segurança
O `ERROR 1045` do root aparece em toda run. **Não é achado de segurança** — é ambiente efêmero de
CI com senha vazia por desenho —, mas é o sinal que prova que o datadir é reinicializado sempre.

## Plano de implementação

- [ ] Etapa 1 — rodar `head -c 4000` no `error.log` e **nomear o primeiro escritor** (CA-02, CA-03).
- [ ] Etapa 2 — medir o que produz os 28 MB (CA-01). Esta é a etapa que provavelmente responde a GT.
- [ ] Etapa 3 — o guarda passa a trazer o `tail` (CA-04, CA-03).
- [ ] Etapa 4 — atribuição na citação do `setup-cloud-env.sh` (CA-05).
- [ ] Etapa 5 — escrever a causa, ou o que foi descartado e com que evidência (CA-06, CA-07).

## Estratégia de testes

- [ ] Unitários — N/A.
- [ ] Integração — N/A.
- [ ] E2E — N/A.
- [ ] Manual — observar o passo em runs sucessivas. **Atenção ao viés:** a falha é intermitente, e
      3 quedas em ~3 horas significa que **uma run verde não prova conserto**. Qualquer afirmação
      de que parou precisa dizer sobre quantas runs, senão mede sorte.

## Riscos e rollback

**Risco de método, e é o principal:** com falha intermitente, é fácil declarar vitória sobre ruído.
O CA-07 existe por isso.

**Risco de instrumento:** `mysqld --verbose --help` **não** serve para saber onde o log vai — já
medido. Quem usar isso como instrumento vai concluir errado com confiança.

Rollback é `git revert` dos commits de script — não há estado persistente fora do CI.

## Registro de execução
### Alterações realizadas
### Arquivos principais
### Decisões
### Divergências
### Pendências

## Validação

Comandos e resultados reais — nunca uma caixa marcada sem evidência ao lado.

## Handoff

**Roda em paralelo com as GT-0149, 0151, 0152 e 0153** — é infraestrutura, não acervo, e não
disputa arquivo com nenhuma delas.

**A evidência que decidiu a correção da GT-0143 mora em `16b404a5`**, não em anexo desta GT e não em
scratchpad. Se esta GT precisar citá-la, cita o commit.
