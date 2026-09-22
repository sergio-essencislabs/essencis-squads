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

## Pareamento por número aposentado em 2026-09-22

O pareamento por número compartilhado com o lado produto (GeoCloudAI) foi aposentado em
2026-09-22, por decisão de Sergio (GT-0714 Fase 2 — reconciliação do passivo histórico). O lado
produto passou a **GT-0666**, o número da própria issue, sob a convenção que a GT-0714 define (GT
e issue com numeração idêntica). Este arquivo do hub mantém o número antigo, **GT-0153**, e o
resto do seu conteúdo, sem alteração.

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

Excluindo commits de acervo (`cunha|acervo|normaliza|roteamento|promover|divide a GT`), **a
grande maioria continua tendo commit de trabalho que a cita.** Em boa parte pelo nome da branch no
merge sem squash:

```
Merge pull request #474 from Essencis-Labs/fix/gt-0054-zoom-nos-cores-multiview
Merge pull request #544 from Essencis-Labs/fix/gt-0100-down-das-migrations-de-permissao
Merge pull request #552 from Essencis-Labs/chore/gt-0105-vida-do-token-de-volta
```

**Uma versão anterior desta frase dizia "29 de 29", e é falso.** O revisor achou pelo menos uma
exceção e eu a confirmei: a **`GT-0096`** vem do merge **#536**, que traz um único commit —
`docs: alinhar registros de task ao que ja esta mesclado` — tocando **quatro arquivos de task e
nada mais**. É acervo pela definição desta própria GT, e *"alinhar registros"* **não casa com
nenhuma das seis palavras do filtro**.

**O número 29 não muda**: a `GT-0096` tem PR mesclado e nenhum arquivo em lado nenhum, que é
exatamente a definição da célula. O que estava errado era a frase de apoio — e o filtro, que deixa
passar acervo escrito com outras palavras. **O CA-01 herda isso:** a lista tem de dizer, por GT,
qual é o commit de trabalho **ou** que não há um.

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

### É alta porque o dano já se realizou, não porque a categoria importe

O argumento de taxonomia acima prova que a **categoria** existe. Não prova **urgência** — e quem lê
"alta" quer saber o que acontece se ficar para depois. A resposta é que **aconteceu anteontem**:

> O **#659** teve de ser bloqueado por conter *"nenhum par está faltando"*, **em negrito**, num
> documento que ia para a apresentação. A frase é **falsa sobre o universo** por causa destas 29 —
> ela só é verdadeira recortada aos 80 arquivos que a GT-0144 mediu. O PR hoje traz o recorte e um
> parágrafo dizendo *"sem ele a frase é falsa"*; o recorte existe porque a frase sem ele passou
> por várias revisões sem ninguém poder notar.

**Esse é o dano, e ele é reincidente por construção:** contamina silenciosamente toda contagem de
entrega, toda métrica de sprint e todo censo de acervo já feito. O argumento de que *o instrumento
de medida não consegue relatar a própria cegueira* explica **por que** ninguém pegou — não é o que
sustenta a prioridade, é o que explica a reincidência.

**Reparo declarado:** uma versão anterior desta seção sustentava "alta" só pelo argumento de
taxonomia. Está trocado pelo caso realizado, a pedido do revisor, e a razão dele fica escrita
porque vale além desta GT — *"quem lê 'alta' quer saber o que acontece se ficar para depois"*.

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
      de cada uma — **ou com a declaração de que não há commit de trabalho**, que é o caso de pelo
      menos uma (`GT-0096`, cujo único commit é de acervo). Lista, não contagem.

      A oração existe porque a versão anterior dizia só *"com o commit ou PR que as entregou"*, e
      isso **presume que toda linha tem um**. É a mesma forma que o CA-05 corrige logo abaixo — a
      consequência estava escrita na seção do achado, e **a seção do achado não é o que o executor
      lê para conferir critério**.
- [ ] **CA-02:** cada uma tem par criado **ou** ausência declarada com motivo, na forma
      `N/A — motivo` que já vale no acervo. Criar arquivo de task para trabalho já entregue é
      decisão do Sergio, não de quem executa — as duas saídas são legítimas, o silêncio não é.
- [ ] **CA-03:** **a taxonomia do censo ganha a quarta célula**, escrita nos dois READMEs. Um censo
      de três células volta a ser apresentado como completo no dia em que esta GT for esquecida.
- [ ] **CA-04:** **a declaração vive nos dois READMEs e nos dois `_template.md`** — os mesmos
      quatro arquivos do CA-03 —, redigida para ser **citada junto com o censo**, de modo que
      qualquer enumeração que se apoie nele herde a frase da fonte.

      **A declaração é redigida como afirmação auto-contida**, e esta é a regra que governa a
      redação dela:

      > **Em declaração de acervo, toda afirmação absoluta traz o conjunto na própria frase.
      > Antecedente em outro parágrafo não conta.**

      **A preposição inicial não é enfeite — a regra falhou no próprio teste sem ela.** Escrita como
      *"Toda afirmação absoluta traz o conjunto na própria frase"*, ela **é ela mesma uma afirmação
      absoluta cujo conjunto não está na frase**: o escopo morava no parágrafo deste CA. E como o
      formato de citação convida a levantar o bloco sozinho — que é exatamente o mecanismo que a
      regra prevê —, quem o levantasse receberia um **imperativo universal sobre toda a escrita do
      repositório**, que é a versão larga que este CA acabou de repelir.

      Achado do Otávio ao ler o texto em vez de julgar pela descrição dele. Fica registrado porque
      **é a evidência mais forte a favor da regra**: ela foi corrigida pelo defeito que ela nomeia,
      aplicado a si mesma, em uma rodada.

      A razão é operacional, não estilística: **slide, citação e resumo viajam por frase.** Uma
      sentença cujo escopo mora no parágrafo anterior chega ao leitor **sem ele** — que é
      exatamente como *"nenhum par está faltando"* atravessou três revisões e chegou em negrito a
      um documento de apresentação. Uma declaração que só funciona junto do parágrafo que a cerca
      não sobrevive à citação, e ser citada é o único jeito de ela alcançar quem não conhece esta
      GT.

      O que se declara aqui **não é alcance de peneira, é domínio de sentença** — a distinção é do
      Otávio, e é o que separa esta regra do princípio de declarar o que a verificação não alcança.

      **Reparo declarado, e a razão é boa.** A versão anterior obrigava *"todo documento que
      enumerar GTs por arquivo"* a declarar o limite. O revisor mostrou que isso é **inalcançável
      de dentro, pela tese desta própria GT**: quem escreve uma varredura não tem como saber que
      deve a declaração **a menos que já conheça esta GT** — e critério que só quem já sabe cumpre
      não muda o comportamento de quem não sabe, que são justamente os que produzem o defeito.
      Mirar o **lugar onde a enumeração nasce** põe o ônus em dois arquivos que o squad controla e
      deixa o conhecimento no caminho de quem vai precisar dele.
- [ ] **CA-05:** a varredura de commits que produz a lista fica **versionada**, casa
      **insensível a caixa** (`[Gg][Tt]-`, nunca `GT-` só), traz **controle positivo** e documenta
      o **artefato conhecido**.

      **A exigência de caixa é critério e não prosa, de propósito.** Ela estava escrita só no lado
      produto, e o revisor apontou o buraco: **o hub é onde vivem os critérios**, e quem executar
      lendo os critérios podia versionar varredura maiúsculo-só **com o controle positivo
      passando** — porque `GT-0146`, `GT-0128` e `GT-0137` são maiúsculos nos nomes de arquivo — e
      perder justamente as entregas cujo rastro é `fix/gt-0054-...`. A exigência tinha ficado na
      cópia que o executor não usa para conferir critério.

      **O controle positivo é a `GT-0099`**, e o nome importa tanto quanto a regra. Medido na
      janela, ancorado em `f1f01214`:

          numeros distintos no assunto ... 101
            so MAIUSCULO ................. 32
            so minusculo .................  5   GT-0096 GT-0098 GT-0099 GT-0103 GT-0104
            os dois ...................... 64
                                          ---
                                           101   (a soma fecha)

      A `GT-0099` tem **dois rastros, os dois minúsculos** (`#541` e `#542`) — é o único dos cinco
      com mais de um, e por isso o controle mais forte: não depende de um único commit sobreviver.

      **Não use a `GT-0054` como controle.** Ela aparece nos dois modos — `gt-0054` no nome da
      branch e **`GT-0054` em dois assuntos de commit** —, então **uma varredura maiúsculo-só a
      encontra**. Um controle que passa igual sob os dois modos **não controla nada**, e a versão
      anterior desta GT exibia exatamente esse exemplo para ilustrar o risco: **o exemplo era imune
      ao risco que ilustrava**.

      **E o tamanho da aposta é o que torna isto sério:** uma varredura maiúsculo-só **não zera**
      esses cinco — ela **nunca os vê entrar** no conjunto, e a derivação devolve **24 em vez de
      29, sem sinal nenhum**. Não é um zero suspeito; é um total menor que parece completo.

      **Um terceiro modo de falha do detector, achado ao escolher o controle.** O rastro do `#542`
      é `gt-0099b` — **letra depois dos quatro dígitos**. Um padrão ancorado em `\b` no fim
      (`[Gg][Tt]-[0-9]{4}\b`) **descarta esse rastro**, e foi o que aconteceu na minha primeira
      medição: ela deu **um** rastro para a `GT-0099` quando são dois. A caixa não é o único eixo
      — **a âncora de fim também perde entrega**. O padrão que o CA exige não deve fechar em
      `\b` depois dos dígitos.

      **E o controle positivo sozinho não fecha este CA, porque o padrão erra nas duas
      polaridades.** Um padrão pode **perder** o que está lá — e um padrão pode **casar o que não
      está**. O artefato `GT-1440` documentado abaixo é precisamente o segundo caso: presença
      fabricada. **Um padrão que casa demais passa no controle positivo com louvor**, porque ele
      acha tudo o que se pede que ache.

      Então a verificação exige **três**, não um:

      | controle | o que prova | pega qual polaridade |
      |---|---|---|
      | **positivo** | o padrão acha o que sabidamente está lá (`GT-0099`, 2 rastros minúsculos) | ausência fabricada |
      | **controle negativo** | o padrão **não** acha algo que sabidamente **não** está | **presença fabricada** |
      | **cardinalidade crua** | para ausência, contar linhas em vez de filtrar | as duas, sem depender de entender o padrão |

      O terceiro é o único que **não depende de quem escreveu o padrão tê-lo entendido** — e por
      isso é o que vale quando o resultado for zero.

      Distinção do Otávio, e ela veio de um achado falso que ele quase reportou: uma varredura dele
      usou `\b` dentro de um ERE, onde vira **fronteira de palavra** e casa em toda linha. O filtro
      **não apagou evidência — fabricou**. Um controle positivo teria passado.

      O artefato: a regra de lista abreviada produz `GT-1440` a partir de *"720 e nao 1440
      (GT-0105)"*. Quem rodar de novo e obtiver 30 precisa saber disso antes de contar — **e saber
      também que o artefato depende do alcance**: uma varredura que case só em assunto de commit
      não o produz, porque aquela frase nunca entra.
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
