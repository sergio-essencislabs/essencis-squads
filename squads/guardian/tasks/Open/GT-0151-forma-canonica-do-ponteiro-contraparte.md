---
id: GT-0151
title: "Forma canônica do ponteiro contraparte e os 34 campos do lado produto"
status: backlog
type: documentation
achado_origem: "N/A — achado na varredura final da GT-0144 (13/09/2026), adjudicado entre Vision, Lívia e Tomás Ticket"
auditor_origem: "Tomás Ticket (curadoria de acervo, Step 07) — divergência levantada pela Vision, terceira medição da Lívia"
severidade: media
produto: GeoCloudAI
camada: documentacao
run_origem: "N/A — despacho direto, fora de run de pipeline"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/663"
grupo_execucao: ""
depende_de: ["GT-0149"]
owner: Sergio
created_at: 2026-09-13
updated_at: 2026-09-13
affected_modules: [acervo-de-tasks]
related_adrs: []
contraparte: "GeoCloudAI/.agents/tasks/backlog/GT-0151-forma-canonica-do-ponteiro-contraparte.md"
---

# GT-0151 — forma canônica do ponteiro `contraparte:` e os 34 campos do lado produto

## Pareamento por número aposentado em 2026-09-22

O pareamento por número compartilhado com o lado produto (GeoCloudAI) foi aposentado em
2026-09-22, por decisão de Sergio (GT-0714 Fase 2 — reconciliação do passivo histórico). O lado
produto passou a **GT-0663**, o número da própria issue, sob a convenção que a GT-0714 define (GT
e issue com numeração idêntica). Este arquivo do hub mantém o número antigo, **GT-0151**, e o
resto do seu conteúdo, sem alteração — inclusive o `depende_de: ["GT-0149"]` acima, que continua
descrevendo a dependência **deste lado hub** sobre o GT-0149 do hub (também não renomeado).

## Contexto

A GT-0145 deixou o sentido **hub → produto** limpo. O sentido **produto → hub** nunca foi tocado, e
a varredura final da GT-0144 o mediu pela primeira vez.

Ao medir, **três janelas produziram dois números diferentes, todas de boa-fé**: **24 e 34**. A
adjudicação mostrou que os dois estão certos — sobre **duas perguntas diferentes**, nenhuma delas
escrita em lugar nenhum.

Esta GT existe por causa disso, não por causa dos números.

## Achado original

Medição lida de commit nos dois lados (produto `658ba708`, hub `origin/main` / `fcb581ff`), nunca
da árvore de trabalho. 98 arquivos `.md` em `.agents/tasks/`:

    sem campo contraparte ................ 18
    com ponteiro preenchido .............. 80
                                          ---
                                           98      (a soma fecha: 100% classificados)

    formas do ponteiro em uso:
      org/repo   (sergio-essencislabs/essencis-squads/...)  43
      absoluto   (C:/Software/EssencisSquads/...)           16
      relativo-repo                                         21

**As duas âncoras acima não são formalidade, e este par é a prova.** `contraparte:` é uma **relação
entre os dois repositórios**, não uma propriedade de um deles: o mesmo produto `658ba708` dá
**34** contra o hub `fcb581ff` e **35** contra `6b9e7d5`. O 35º é a própria GT-0144 — e quem a
tornou atrasada foi `6b9e7d5`, **a metade-hub deste mesmo par**, ao mover a GT-0144 para
`completed/`; o lado produto conserta o ponteiro no mesmo par e o número volta a 34.

O número saiu certo, ficou errado por um commit do próprio par, e voltou a ficar certo por outro
commit do próprio par. **Um número anotado de um lado só não é auditável** — quem remedir depois
lê outro valor e conclui que o documento está errado. É o que o CA-06 existe para impedir.

### Dois predicados entre três pessoas, nenhum deles declarado

| predicado | quem usou | não-conformes |
|---|---|---|
| normalizar `org/repo`, resolver por caminho | **Lívia e Vision** | **34** |
| normalizar `org/repo` **e** a forma absoluta | **Tomás** | **24** |
| literal puro — não reconhece nem o prefixo | **ninguém**; hipotético, medido só para descartar | 77 |

**Os dois predicados usados são válidos e nenhum estava escrito em lugar nenhum.**

> *"A definição só apareceu quando os números discordaram."* — Lívia

**Uma versão anterior desta tabela dizia que eram três predicados**, atribuindo à Lívia um
*"caminho literal, sem normalizar nada"*. Era falso: o script dela ancora em
`squads/guardian/tasks/` e resolve dali, ou seja **normaliza o prefixo `org/repo`**, como o da
Vision. Reconferido por complemento sobre os 80 preenchidos — literal puro resolve `3` e acusa
`77`; normalizando `org/repo` resolve `46` e acusa `34`.

**O reparo não é cosmético.** Como estava, a tabela fazia o `34` aparecer duas vezes por caminhos
que pareciam independentes, o que se lê como **confirmação mútua**. Era o mesmo predicado medido
duas vezes — e duas medições do mesmo predicado **concordam por construção**, que é exatamente a
tese desta seção. A tabela oferecia como prova o que o texto ao lado diz não ser prova.

> *"Num documento cuja tese é 'o rótulo não bate com o número', o rótulo errado é **o defeito que
> ele existe para nomear, cometido nele**."* — Lívia

**A divergência real foi a minha contra a das duas**, 24 contra 34, e ela existiu. O que não houve
foi convergência independente. O desconforto da Lívia, que é método e não anedota, continua de pé:

> *"Se os números tivessem batido **por acaso**, ninguém teria descoberto que havia predicados
> diferentes. **A discordância foi o instrumento.** Uma varredura sozinha não teria produzido isso
> — é argumento a favor de medir em paralelo coisas que já parecem resolvidas."*

As contagens decompõem umas nas outras:

    A) quebrados depois de normalizar as duas formas ....... 27
    B) escritos como caminho absoluto ..................... 16
       A interseção B ..................................... 9
       A união B ......................................... 34   = 16 absolutos + 18 relativos
       A menos B ......................................... 18

E a decomposição dos 16 absolutos, medida pela Vision contra `fcb581ff`:

    absolutos ................................. 16
      auto-ponteiros (apontam para o produto) ..  3   <- também dentro de A
      resolvem no hub depois de normalizar .....  7   <- os únicos fora de A
      não resolvem .............................  6

Ficam fora de `A` os **7**, o que fecha `A menos B = 18` e `A união B = 34`.

> **Correção de 13/09/2026 — e ela é sobre a conferência, não sobre o número.** Este bloco publicava
> `A = 24` e `A ∩ B = 6`, excluindo de `A` os três auto-ponteiros sob a premissa — falsa, medida na
> ressalva abaixo — de que *"o arquivo existe"*. São **27** e **9**. Sob o predicado como ele está
> escrito (*"quebrados depois de normalizar as duas formas"*), o número é 27; o `24` é o
> **subconjunto que ancora no hub**, que é o que o CA-03 trata, e os 3 viram o CA-04. Os dois ficam,
> cada um com o predicado colado.
>
> E a frase que este bloco trazia — *"a aritmética está inteira nos três sentidos"* — era verdadeira
> e não provava nada. Os três auto-ponteiros estão **dentro de `B`**; logo `A união B` e
> `A menos B` são **invariantes** a eles pertencerem ou não a `A`, e eram exatamente esses dois que
> a frase exibia. **A conferência confirmou o que não podia desmentir.**
>
> *"Antes de usar uma identidade como prova de que uma partição está inteira, pergunte de que erro
> ela é função. Se o item suspeito está contido no outro operando, ela não o vê — e 'a soma fecha' é
> o controle mais barato de fabricar sem querer."* — Lívia
>
> `A união B = 34` não se mexeu: **o escopo desta GT continua o mesmo.**

**A causa, nas palavras da Vision:**

> *"Não foi decisão: foi a forma que eu conhecia quando escrevi o `case`. (...) Achei que estava
> medindo a sua pergunta e errando."*

**O campo `contraparte:` tem três formas em uso e nenhuma declarada canônica.** Enquanto for assim,
toda varredura escolhe sozinha o que conta como quebrado — e escolhe **sem saber que escolheu**.

### Por que o literal puro não é a resposta severa

Sem normalizar nada e sem sequer reconhecer o prefixo de repositório, um detector ingênuo acusa
**77**. Desses, **53 resolvem para arquivo real**. Um ponteiro que carrega
`sergio-essencislabs/essencis-squads/` é **correto-mas-não-normalizado**, não quebrado. O número
mais severo disponível é também o mais falso.

### Os 24 são atrasados, não pares faltando — com uma ressalva que não é decorativa

    causa dos 24:  24  atrasado — aponta para onde o arquivo JÁ SAIU
                    0  arquivo não existe em pasta nenhuma do hub

Os 24 erram só a pasta, e erram **sempre no mesmo sentido** — `backlog -> completed`,
`active -> completed`:

| ponteiro | aponta | está em |
|---|---|---|
| GT-0043-rqd-real.md | `backlog` | `completed` |
| GT-0044-fluxo-de-modulo-comportamento.md | `backlog` | `completed` |
| GT-0047-fronteira-do-visualizador-so-na-ui.md | `backlog` | `completed` |
| GT-0106-o-403-nao-navega.md | `active` | `completed` |
| GT-0118-conversas-salvas-nao-abrem.md | `active` | `completed` |
| GT-0119-chat-unico-em-tres-montagens.md | `active` | `completed` |

Pela assimetria que a Lívia formulou, **ponteiro atrasado nunca se auto-resolve** — ao contrário do
adiantado, que aponta para onde o arquivo ainda não chegou e se conserta sozinho quando chega. É a
torneira vista do lado do produto: cada GT que anda para `completed/` deixa o ponteiro do par
apontando para trás.

**A ressalva, e ela é da Lívia.** `GT-0049`, `GT-0050` e `GT-0051` apontam para
`C:/Software/GeoCloud/GeoCloudAI/.agents/tasks/active/...` — **o próprio produto, não o hub** — e
**não resolvem**. Os três arquivos estão em `completed/` no produto, medido nos três anchors
(`8cbc67e2`, `658ba708`, `a443432a`); não há arquivo naquele caminho, em repositório nenhum:

    GT-0049 -> .agents/tasks/active/GT-0049-vida-do-token-configuravel.md    existe? NÃO
       o arquivo vive em .agents/tasks/completed/GT-0049-vida-do-token-configuravel.md
    GT-0050 -> .agents/tasks/active/GT-0050-suite-de-api-...md               existe? NÃO
    GT-0051 -> .agents/tasks/active/GT-0051-escopo-multitenant-...md         existe? NÃO

> *"Os três estão quebrados sob as duas leituras, e a resolução por número marca os três como
> **saudáveis**."*

**Uma versão anterior deste parágrafo dizia que eles *"ficam fora dos 24 porque o arquivo existe"*.**
Não existe. Era essa frase que sustentava a exclusão dos três de `A`, e é o reparo de `A = 24` para
`27` do bloco acima.

Portanto **o mínimo não é zero sob nenhum predicado**, e a frase "nenhum par está faltando" só vale
com a ressalva: os pares existem, mas três ponteiros não apontam para eles. Isso não muda o escopo
desta GT — os 3 já estão entre os 16 absolutos —, muda o que a GT **afirma ter medido**.

**E o conserto dos três é o mais barato dos quatro defeitos, ao contrário do que o texto sugeria:**
no hub, `GT-0049`, `GT-0050` e `GT-0051` estão em **`active/`** — a mesma pasta que os ponteiros
nomeiam. Trocar a raiz pela do hub, e só isso, faz os três resolverem. O CA-04 não muda; muda a
descrição do estado que ele conserta.

### Não há consumidor automático hoje, e é por isso que urge

A Lívia buscou consumidor executável de `contraparte:` em `.sh .yml .yaml .py .ps1 .js .ts .cs`,
**nos dois repositórios: zero**. Com controle positivo — a mesma busca acha `RequiredPermission` em
`.cs` e `dotnet` em `ci.yml`, então a peneira enxerga.

O argumento do Rui, que é o que transforma isso em urgência em vez de em desculpa:

> *"Escolher o predicado permissivo agora significa que a trava, no dia em que nascer, reporta
> **34 falhas preexistentes**. E a primeira coisa que uma trava nova reportando 34 falhas antigas
> ensina é **a ignorar a trava**."*

É caro discutir e barato fazer. Esta GT limpa o terreno **antes** de a trava da GT-0149 nascer.

## A pergunta sobre a forma absoluta estava enquadrada errada

O reenquadramento é do Rui, e ele o fez **antes de medir qualquer coisa**, de propósito.

*"A forma absoluta é canônica?"* pressupõe que o defeito dos 16 tenha a ver com eles serem
absolutos. **Medido, nenhum tem.**

    causa de cada um dos 16 (produto 8cbc67e2, hub fcb581f):
       7  só barra invertida — resolvem ao normalizar `\` para `/`
       6  estado de pasta — o par existe, noutra pasta (os mesmos "atrasados" dos 24)
       3  direção — auto-ponteiros, apontam para o próprio produto
      --
       0  falham PORQUE são absolutos

Os seis que "não resolviam nem normalizados", e cuja causa ninguém tinha medido, são
`GT-0043`, `GT-0044`, `GT-0047`, `GT-0106`, `GT-0107` e `GT-0108` — **todos** apontando para
`backlog/` ou `active/` quando o par está em `completed/`. É o mesmo defeito de estado dos outros
24, e não um defeito da forma.

> *"Dez dos dezesseis falham por defeitos que a forma relativa não conserta, porque não são
> defeitos de forma. Um ponteiro relativo com barra invertida quebra igual; um auto-ponteiro
> relativo aponta errado igual."* — Rui

Com a medição, são **dezesseis de dezesseis**. A forma absoluta estava sendo condenada por
**co-ocorrência**: é a companhia em que os outros três defeitos aparecem, não a causa de nenhum.

**Esta medição não é um quarto predicado.** Os seis falham sob os **três** predicados já nomeados;
caracterizar a causa deles não recontou nada. Foi medida assim de propósito — o Rui recusou-se a
trazer números antes de a forma canônica estar escrita:

> *"Medir antes da forma canônica ser declarada não produz confirmação — produz o quarto número, e
> aí a revisão vira reconciliação de novo. Eu mesmo te disse isso sobre a mão única; vale contra
> mim."*

### Isso não absolve a forma absoluta — muda o argumento contra ela

O argumento real é outro, e é suficiente: **ela embute caminho de máquina**. E a medição o reforça
por um lado que ninguém tinha olhado — os 16 usam **duas raízes diferentes para o mesmo lugar**:

    C:\Software\EssencisSquads\squads\guardian\tasks\...
    C:\Software\ClaudeCode\squads\guardian\tasks\...      (link para a de cima)

Duas grafias de máquina para o mesmo destino, numa forma que já era uma de três. **Não é uma forma;
são duas.**

> *"`C:\Software\EssencisSquads\` só existe numa máquina — continua sendo argumento real e
> suficiente. Mas é **um** argumento, e um que se aplica a caminho absoluto **de máquina**; não a
> caminhos absolutos em geral, e não a caminho absoluto **de repositório**, que é outra coisa."*
> — Rui

**Escreva a proibição assim: caminho absoluto _de máquina_.** Uma GT que proíbe uma forma pelo
motivo errado convida a próxima pessoa a reintroduzi-la quando o motivo errado não se aplicar — e
"caminho absoluto de repositório" é justamente o caso em que não se aplica.

E a autocrítica do Rui, que dá peso ao ponto e fica registrada:

> *"É a mesma confusão que eu cometi no #628, agora um nível acima: eu apliquei ao conjunto um
> argumento que valia para um subconjunto; aqui corre-se o risco de aplicar **à forma** um
> argumento que vale para uma **instância** dela."*

### Três defeitos, três consertos — não um

| defeito | quantos | conserta com |
|---|---|---|
| convenção de barra (`\` contra `/`) | 7 | normalizar a barra; independe de a forma ser absoluta ou relativa |
| direção do ponteiro (aponta para o próprio lado) | 3 | apontar para o hub; independe da forma |
| estado de pasta (o par andou) | 6 dos 16, + 18 outros = **24** | apontar para a pasta real |
| absolutez de máquina | **0 falhas**, 16 ocorrências | a forma canônica, por portabilidade — não por quebra |

Tratar os quatro como um só produz uma correção que conserta um e deixa os outros três de pé.

## Procedência das formas — antes de canonizar qualquer uma

Critério novo, e a razão dele é da Lívia. O `contraparte:` tem **três precedentes**, não um:

| forma | quem estabeleceu | onde |
|---|---|---|
| caminho relativo | **Lívia** | os 31 do Grupo B (GT-0147) |
| `N/A — motivo` | **Marta** | os 39 do Grupo A (GT-0146) |
| absoluta | **ninguém** — nasceu de uso | 16 campos |

> **CA novo — CA-00, porque vem antes de todos:** antes de canonizar uma forma, esta task lista de
> onde cada forma veio e quem a executou, e **a lista é artefato da task, produzida antes da
> escolha do revisor.**

A razão, que é a mesma do CA-10 e vale escrita junto:

> *"Vira passo do processo em vez de honestidade individual. **Hoje funcionou porque eu declarei;
> na próxima pode não ocorrer a quem estiver no meu lugar.**"* — Lívia

E a formulação que nomeia a coisa: **precedente é autoria por outro caminho**, e a diferença é que
a autoria tem assinatura e o precedente não — por isso precisa de um passo que o reconstrua.

**Uma nota de honestidade sobre a tabela acima.** A atribuição vem da Vision e da Lívia; **não é
verificável no acervo**. Procurei nas GT-0146 e GT-0147 em `fcb581f` e nenhuma das duas registra
qual janela executou — as duas trazem só `owner: Sergio`. Isso não põe a tabela em dúvida; **é a
evidência do ponto da Lívia**, encontrada por acaso enquanto eu tentava conferi-la. Se o acervo
registrasse execução, o CA-00 seria uma consulta em vez de uma reconstrução.

### Quem revisa o quê

| parte | quem | por quê |
|---|---|---|
| a declaração canônica, as três formas | **Rui** | sem precedente executado; advocacia declarada no #628 |
| escopo, os 34 campos, os dois predicados usados, os auto-ponteiros | **Lívia** | com o conflito declarado na abertura |

Eu não reviso: escrevi a GT. A Vision não revisa: adjudicou a divergência que a originou.

> *"'Ninguém a defende' não é o mesmo que 'está errada'."* — Lívia, sobre a forma absoluta ser a
> única das três sem autor para defendê-la.

## Objetivo

1. Existe **uma** forma canônica declarada para `contraparte:`, nos dois READMEs e nos dois
   `_template.md`.
2. Os 34 campos do lado produto estão na forma canônica e resolvem **para o hub**.
3. Uma varredura futura, escrita por quem não participou desta, chega ao mesmo número que outra.

## Fora de escopo

- **O sentido hub → produto.** A GT-0145 entregou exatamente o que o critério dela dizia; isto não
  é reabertura dela, e nada aqui a contradiz.
- **O catálogo mais amplo de vocabulário divergente entre os READMEs** — isso é a GT-0149. Esta GT
  é uma instância dele; a GT-0149 continua dona do conjunto.
- **A forma abreviada `(GT-0111, 0113, 0114, 0115)`** em assunto de PR e em corpo de GT, e o
  **`gt-0145` minúsculo** no hub. Achados separados, já devolvidos à Vision.
- **Criar a trava automática.** Esta GT deixa o acervo em condição de a trava nascer sem ruído; a
  trava em si é da GT-0149.

> **Nota de alcance, e ela limita o que esta GT pode prometer.** Os dois achados acima não são
> vizinhos do `contraparte:` por acaso. O identificador de GT aparece hoje em **três superfícies**,
> e a nomenclatura falha nas três:
>
> | superfície | como falha | onde apareceu |
> |---|---|---|
> | nome de arquivo | `gt-0113`–`gt-0117` minúsculos | detector da Marta |
> | assunto de commit/PR | forma abreviada `(GT-0111, 0113, ...)` | achado do Otávio |
> | **nome de branch** | `fix/gt-0054-...` minúsculo no merge sem squash | achado ao cunhar a GT-0153 |
>
> **O defeito não é do campo `contraparte:` — é de toda superfície que carrega identificador de
> GT.** Canonizar a forma do ponteiro conserta **uma das três superfícies**. As outras duas
> continuam de pé, e uma varredura maiúsculo-só continuará perdendo entrega em cada uma.
>
> **Não são três terços, e a diferença importa:** as três superfícies não são do mesmo tipo. O
> `contraparte:` é a única cujo valor seria **consumido por um mecanismo**; nome de arquivo e nome
> de branch são superfícies que uma varredura **lê**; assunto de commit é **prosa**. Dizer "um
> terço" reivindicaria um denominador que ninguém mediu — que é a forma de afirmação que o resto
> deste documento passa o tempo a desmontar.
>
> **E as três são independentemente consertáveis.** Esta GT não fica à espera das outras duas: o
> conserto do ponteiro está correto sozinho e não depende de nenhuma delas. A nota existe para a
> GT não reivindicar o que não entrega — **não** para sugerir que entregar menos que o conjunto
> seja insuficiente.

## Comportamento atual

Três formas convivem no campo. Nenhum documento diz qual é a certa. O `_template.md` do hub diz
"caminho RELATIVO (...) nunca C:/...", mas isso está no lado do hub: o lado produto não tem a
instrução equivalente, e é lá que estão os 16 absolutos. **A instrução existe em um sentido só, e o
defeito apareceu exatamente no sentido sem instrução.**

## Comportamento esperado

Uma forma, escrita uma vez, com exemplo, nos dois lados e nos dois sentidos. Qualquer varredura que
a siga chega ao mesmo conjunto.

## Regras de negócio

- RN-01: N/A — dívida de acervo/documentação, sem regra de negócio nova.

## Critérios de aceitação

- [ ] **CA-00:** a **lista de procedência das três formas** — de onde cada uma veio e quem a
      executou — existe como artefato desta task, produzida **antes** da escolha do revisor e antes
      de qualquer forma ser canonizada.
- [ ] **CA-01:** a forma canônica está declarada em `.agents/tasks/README.md` **e** em
      `squads/guardian/tasks/README.md` **e** nos dois `_template.md`, com um exemplo literal em
      cada. A declaração cobre os **dois** sentidos, porque foi a assimetria da instrução que
      produziu as 16 formas absolutas.
- [ ] **CA-02:** os **16** ponteiros em forma absoluta no produto estão na forma canônica.
- [ ] **CA-03:** os **24** ponteiros atrasados apontam para a pasta real do par.
- [ ] **CA-04:** os **3** auto-ponteiros (GT-0049, GT-0050, GT-0051) apontam para o **hub**, não
      para o próprio produto. Este CA existe separado do CA-02 de propósito: uma varredura **por
      número** os marca como saudáveis, porque o número existe no hub — e é a única classe de
      defeito a que esse predicado é cego. O conserto é a troca de raiz, e só ela: no hub os três
      estão em `active/`, a mesma pasta que os ponteiros nomeiam.
- [ ] **CA-04b:** a correção trata os **quatro defeitos separadamente** — barra, direção, estado
      de pasta e forma —, porque têm consertos diferentes e zero dos 16 falha por absolutez.
- [ ] **CA-05:** a varredura produto → hub devolve **0 não-conformes sob as três resoluções** —
      literal puro, normalizando só `org/repo`, e normalizando as duas formas. As duas últimas
      são os predicados que foram de fato usados; a primeira entra porque um número que só fecha
      sob a resolução mais permissiva não prova nada sobre as outras.
- [ ] **CA-06:** a varredura lê de **commit nos dois lados** (`git ls-tree` / `git show`), nunca da
      árvore de trabalho, e passa os argumentos por **lista ao subprocess, sem shell** — que é como
      a Lívia mediu, e faz o mangling de caminho do Git Bash **não se aplicar** em vez de precisar
      ser contornado. **O script existe e está versionado no produto:**
      `scripts/acervo/medir-contraparte.py`, com as duas revisões como argumento obrigatório e sem
      valor padrão. Herdar o predicado é o ponto; reinventá-lo foi o que produziu os números
      divergentes.
- [ ] **CA-07:** **controle positivo** junto do resultado: a mesma varredura, sem o filtro
      restritivo, mostra quantos ponteiros ela enxerga. Um zero sem controle não fecha este CA.
- [ ] **CA-08:** **prestação de contas:** **todos** os arquivos de `.agents/tasks/` aparecem
      classificados 100% e a soma fecha, contra o total medido na revisão em que a varredura rodar.
      Eram **98** no censo; com esta GT cunhada já são **99**, e por isso o denominador é medido,
      não copiado daqui. Reportar *quantos*, não só *quais*.
- [ ] **CA-09:** a varredura pula valores que começam com `N/A` — não são caminho e não contam como
      quebrados.
- [ ] **CA-10:** o registro de execução declara **o que esta verificação não alcança**.

## Impacto técnico

### Backend
Nenhum.
### Frontend
Nenhum.
### Banco de dados
Nenhum.
### Integrações
Nenhum — e isso foi **medido**, não presumido: zero consumidores executáveis de `contraparte:` nos
dois repositórios, com controle positivo.
### Segurança
Nenhum.

## Plano de implementação

- [ ] Etapa 0 — produzir a **lista de procedência** das três formas (CA-00), antes de escolher
      revisor e antes de canonizar.
- [ ] Etapa 1 — decidir a forma canônica. **Decisão do Sergio**, não de quem executa. Esta etapa
      vem **antes** da correção dos campos, e a razão é da Lívia: *"consertar 34 campos sem
      declarar a forma é consertar hoje e recomeçar amanhã."* A rejeição da forma absoluta
      escreve-se como **caminho absoluto de máquina**, nunca como "caminho absoluto" — zero dos
      16 falha por absolutez, e o motivo errado convida a reintrodução.
- [ ] Etapa 2 — declarar nos quatro documentos (CA-01).
- [ ] Etapa 3 — corrigir os 34 campos (CA-02, CA-03) e os 3 auto-ponteiros (CA-04).
- [ ] Etapa 4 — varredura final sob as três resoluções, com controle positivo e prestação de contas
      (CA-05 a CA-10).

> **Aviso a quem executar a Etapa 3:** não use `sed` cego no front-matter. Um `/^contraparte:/`
> acerta também o bloco ```yaml citado dentro do corpo de outras GTs — inclusive o desta. Confira o
> diff inteiro, não o ponto esperado.

## Estratégia de testes

- [ ] Unitários — N/A, não há código de produto.
- [ ] Integração — N/A.
- [ ] E2E — N/A.
- [ ] Manual — a varredura dos CA-05 a CA-10 é a verificação, e o script dela fica **versionado**,
      não em scratchpad: o próximo a medir precisa herdar o predicado, não reinventá-lo.

## Riscos e rollback

Risco: correção em massa de front-matter atingir bloco citado (ver aviso na Etapa 3). Rollback é
`git revert` do commit — não há estado fora do repositório.

Risco de processo: se a forma canônica for decidida aqui e a GT-0149 decidir outra depois, o acervo
volta a ter duas formas. Por isso o `depende_de`.

## Registro de execução
### Alterações realizadas
### Arquivos principais
### Decisões
### Divergências
### Pendências

## Validação

Comandos e resultados reais — nunca uma caixa marcada sem evidência ao lado.

## Handoff

**Esta GT não roda em paralelo com a GT-0149.** A forma canônica é decisão que a GT-0149 precisa
conhecer; se as duas rodarem juntas, o acervo pode terminar com duas formas canônicas declaradas em
documentos diferentes — que é o defeito que as duas existem para eliminar.

**Por que esta GT importa para a GT-0149.** Ela é a quarta instância da família que a GT-0149
cataloga, e a primeira em que a ambiguidade não produziu um alarme falso: produziu **três pessoas
medindo o mesmo acervo de boa-fé, chegando a três números, sem que nenhuma soubesse estar medindo
uma pergunta diferente**. É a evidência mais forte que a GT-0149 tem, e é por isso que está escrita
aqui por extenso em vez de resumida.
