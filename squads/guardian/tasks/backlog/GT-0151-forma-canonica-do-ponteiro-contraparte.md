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

## Contexto

A GT-0145 deixou o sentido **hub → produto** limpo. O sentido **produto → hub** nunca foi tocado, e
a varredura final da GT-0144 o mediu pela primeira vez.

Ao medir, **três janelas chegaram a três números diferentes, todas de boa-fé**: 24, 34 e 46. A
adjudicação mostrou que os três estão certos — sobre **três perguntas diferentes**, nenhuma delas
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

### Três predicados, três números, nenhum deles declarado

| quem | predicado | não-conformes |
|---|---|---|
| Lívia | resolve pelo **caminho literal**, sem normalizar nada | **34** |
| Vision | normaliza `org/repo`, **não** normaliza o absoluto | **34** |
| Tomás | normaliza `org/repo` **e** o absoluto | **24** |

**Os três predicados são válidos e nenhum estava escrito em lugar nenhum.** A formulação da Lívia,
que é a frase mais curta do assunto:

> *"Três pessoas mediram a mesma coisa com três definições tácitas, e **a definição só apareceu
> quando os números discordaram**."*

E o desconforto dela, que fica registrado aqui porque é método e não anedota:

> *"Se os três tivessem batido **por acaso**, ninguém teria descoberto que havia três predicados.
> **A discordância foi o instrumento.** Uma varredura sozinha não teria produzido isso — é
> argumento a favor de medir em paralelo coisas que já parecem resolvidas."*

As contagens decompõem umas nas outras, e isso foi conferido nos dois sentidos:

    A) quebrados depois de normalizar as duas formas ....... 24
    B) escritos como caminho absoluto ..................... 16
       A interseção B ..................................... 6
       A união B ......................................... 34   = 16 absolutos + 18 relativos
       A menos B ......................................... 18   = 24 − 6

E a decomposição dos 16 absolutos, medida pela Vision contra `fcb581ff`:

    absolutos ................................. 16
      auto-ponteiros (apontam para o produto) ..  3
      resolvem no hub depois de normalizar .....  7
      não resolvem .............................  6   <- a interseção A ∩ B

`7 + 3 = 10` ficam fora de A, o que fecha `A menos B = 18` e `A união B = 34`. A aritmética está
inteira nos três sentidos.

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
`C:/Software/GeoCloud/GeoCloudAI/.agents/tasks/active/...` — **o próprio produto, não o hub**. Eles
ficam fora dos 24 porque o arquivo existe, mas existem no lugar errado:

> *"Os três estão quebrados sob as duas leituras, e a resolução por número marca os três como
> **saudáveis**."*

Portanto **o mínimo não é zero sob nenhum predicado**, e a frase "nenhum par está faltando" só vale
com a ressalva: os pares existem, mas três ponteiros não apontam para eles. Isso não muda o escopo
desta GT — os 3 já estão entre os 16 absolutos —, muda o que a GT **afirma ter medido**.

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
| a declaração canônica, as três formas | **Rui** | único sem precedente em jogo |
| escopo, os 34 campos, os três predicados, os auto-ponteiros | **Lívia** | com o conflito declarado na abertura |

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
      para o próprio produto. Este CA existe separado do CA-02 de propósito: os três resolvem, e
      uma varredura por número os marca como saudáveis.
- [ ] **CA-04b:** a correção trata os **quatro defeitos separadamente** — barra, direção, estado
      de pasta e forma —, porque têm consertos diferentes e zero dos 16 falha por absolutez.
- [ ] **CA-05:** varredura produto → hub devolve **0 não-conformes sob os três predicados** —
      literal, normalizando só `org/repo`, e normalizando as duas formas. Um número que só fecha
      sob o predicado mais permissivo não fecha este CA.
- [ ] **CA-06:** a varredura lê de **commit nos dois lados** (`git ls-tree` / `git show`), nunca da
      árvore de trabalho, e passa os argumentos por **lista ao subprocess, sem shell** — que é como
      a Lívia mediu, e faz o mangling de caminho do Git Bash **não se aplicar** em vez de precisar
      ser contornado.
- [ ] **CA-07:** **controle positivo** junto do resultado: a mesma varredura, sem o filtro
      restritivo, mostra quantos ponteiros ela enxerga. Um zero sem controle não fecha este CA.
- [ ] **CA-08:** **prestação de contas:** os 98 arquivos aparecem classificados 100% e a soma
      fecha. Reportar *quantos*, não só *quais*.
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
- [ ] Etapa 4 — varredura final sob os três predicados, com controle positivo e prestação de contas
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
