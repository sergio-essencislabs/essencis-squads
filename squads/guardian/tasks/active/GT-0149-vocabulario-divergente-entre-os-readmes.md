---
id: GT-0149
title: "Os dois READMEs discordam sobre o que dois campos podem conter"
status: active
type: documentation
achado_origem: "achado da Lívia ao executar a GT-0147 (CA-08); números conferidos pelo Otávio"
auditor_origem: "Lívia (execução da GT-0147, CA-08)"
severidade: media
produto: GeoCloudAI
camada: ""
run_origem: "N/A — despacho direto, fora de run de pipeline"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/647"
grupo_execucao: ""
depende_de: []
owner: Sergio
created_at: 2026-09-12
updated_at: 2026-09-12
affected_modules: []
related_adrs: []
contraparte: "GeoCloudAI/.agents/tasks/active/GT-0149-vocabulario-divergente-entre-os-readmes.md"
---

# GT-0149 — os dois READMEs discordam sobre o que dois campos podem conter

## Contexto
São **duas** divergências, e vêm juntas por uma razão declarada, não por conveniência.

O critério é da Lívia, e a formulação dela é o que ancora o escopo: **o README do produto governa
a relação entre os dois lados** — é ele que diz que todo `GT-NNNN` nasce em par e que o
`contraparte:` aponta nos dois sentidos. *"Dois READMEs discordando sobre o que um campo pode
conter é falha dessa relação."*

**A âncora é a competência do documento, não a jurisdição de quem executa.** Jurisdição expira na
próxima redistribuição de faixas; competência não.

## Problema

### 1. `issue_url` tem três estados e um só valor

Medido em `b99055f`, hub, conferido pelo Otávio e reconferido aqui lendo de commit:

| | |
|---|---|
| total de arquivos | **82** |
| com `issue_url` preenchido | **54** |
| com `issue_url` vazio | **11** |
| **sem o campo** | **17** |

São **três fatos distintos** — *"nunca teve issue"*, *"tem e não registrou"* e *"o campo nem
existe"* — e **nenhuma varredura os separa**. Os 11 vazios e os 17 sem campo respondem igual a
qualquer pergunta automática sobre promoção.

Isto já produziu erro real: a `GT-0045` dizia `issue: a criar` e **a issue existia** (#452,
*"[GT-0044/45/46]"*); a `GT-0044` tinha `issue_url: ""` pelo mesmo motivo. As duas foram
corrigidas na GT-0145 **por leitura do título da issue**, não por convenção — porque não havia
convenção que as distinguisse.

O `_template.md` do hub já ganhou, na GT-0145, a forma `N/A — <motivo>` para o `contraparte:`
quando não há par. **`issue_url` não tem equivalente**, e é o mesmo problema.

### 2. `status: blocked` é sancionado num README e ignorado no outro

`.agents/tasks/README.md:7` (produto):
```
backlog/ → active/ → completed/
                 ↘ blocked (ou um campo `status: blocked` no frontmatter)
```

O README do hub **não menciona `blocked`** — zero ocorrências.

Consequência medida: a Marta normalizou a `GT-0030` no lado do hub, e **estava certa ali** —
o vocabulário do hub não tem `blocked`. A mesma normalização no produto **estaria errada**, porque
lá o valor é sancionado. **O mesmo ato é certo de um lado e errado do outro, e nada no acervo diz
isso.**

### 3. E a terceira manifestação não é de campo — é de corpo

Achado da Lívia ao fechar o Registro do lado-hub da GT-0147, e **muda o que esta GT precisa
verificar**:

> *"As três primeiras manifestações eram sobre campos de **front-matter** — `contraparte`,
> `issue_url`. Esta é sobre o **corpo** do arquivo: Registro, Validação, caixas. **Uma trava que
> valide front-matter não pegaria esta.**"*

O caso concreto, **medido em 12/09/2026 com o hub em `9774f53`**: a GT-0146 e a GT-0147 tiveram o
trabalho feito e mesclado, e o **arquivo-task do lado do hub** ficou com **8 e 9 caixas abertas,
zero marcadas**, e o Registro dizendo *"não executada"*. Nenhum campo de front-matter estava
errado. Um validador de front-matter passaria **verde sobre um Registro vazio**.

> **A âncora não é formalidade: as duas estavam sendo consertadas enquanto isto era escrito.** Quem
> ler esta seção depois vai encontrar os dois arquivos fechados, concluir que o texto mente e
> duvidar do resto da task. O caso continua valendo como evidência **porque está datado** — não
> porque o estado persiste. Achado do Otávio ao revisar esta extensão, e é o defeito que esta
> própria GT documenta, aparecendo dentro dela.

**Consequência para o escopo desta GT:** ela ia nascer cobrindo três quartos do problema. O que os
READMEs precisam governar não é só *o que um campo pode conter* — é também **o que torna um
arquivo fechado por dentro**, que vive no corpo e não no front-matter.

E o que justifica o esforço: **o defeito sobreviveu a ser documentado, por quatro janelas, no
mesmo dia.** Antes, isto podia ser lido como dívida histórica a drenar. Agora há caso nascido **no
intervalo entre escrever o diagnóstico e fechar a task** — é a diferença entre fila que encolhe e
vazão, com evidência produzida depois da documentação.

### 5. Ponteiro adiantado e ponteiro atrasado não são o mesmo defeito

Achado da Lívia ao fechar a GT-0147, e é o que **inverte** o que uma trava ingênua faria:

> *"Ponteiro **adiantado** se resolve sozinho quando o segundo merge entra; ponteiro **atrasado**
> não se resolve nunca sem alguém ir lá. **A fila do CA-08 é toda de ponteiros atrasados.**"*

| | aponta para | resolve sozinho? |
|---|---|---|
| **adiantado** | onde o par **vai estar** | **sim** — quando o segundo merge entra |
| **atrasado** | onde o par **estava** | **nunca**, sem alguém ir lá |

Os 17 ponteiros consertados na GT-0145 eram **todos atrasados**. Nenhum ia se resolver esperando.

**Consequência para qualquer trava que saia desta GT:** uma verificação que trate os dois como o
mesmo defeito **marca como quebrado um estado transitório que está correto** — e, nas palavras
dela, *"a primeira coisa que um alarme falso ensina é a ignorar o alarme"*. É o mesmo princípio que
o Otávio aplicou à caixa do `provision-env.sh`: **errar para o lado cauteloso ensina o operador a
desconfiar da caixa.**

**E a inversão:** o estado adiantado não é tolerado, é **o certo**. Como não há atomicidade entre
dois repositórios — *"não há commit que atravesse os dois"* —, o melhor alcançável é **cada lado já
mesclar apontando para o destino final do outro**. Quem faz isso produz, de propósito, uma janela
de ponteiro adiantado. Uma trava que a punisse estaria punindo a boa prática.

### 4. Quem pode marcar uma caixa — e por que a regra mora aqui

**A caixa marcada é a afirmação de que alguém verificou.** Disso decorre que **quem marca é quem
verificou**, e que critério alheio não se fecha por conveniência de fechamento.

Hoje essa regra **não está escrita em lugar nenhum**: existiu só em mensagens de despacho e em
recusas individuais — o Dante não opinou sobre a GT-0142 porque a escreveu; eu não fechei a
GT-0146 nem a GT-0147 porque não as executei. **Duas pessoas acertaram por julgamento, não por
regra**, e julgamento não sobrevive à próxima janela.

**Por que nos READMEs e não na `dispatcher`** — e o argumento é o defeito da própria `dispatcher`,
que a Vision encontrou em 12/09: a regra do veredito no PR *"também só existia nas mensagens de
despacho"*. Regra que mora no despacho **só existe no momento do despacho**. Quem fecha uma task
pode estar fazendo isso dias depois, fora de qualquer despacho, e o que essa pessoa lê é o README
de tasks.

**Uma casa só, e a outra aponta.** Se a `dispatcher` repetir o texto em vez de referenciá-lo,
nascem duas cópias para divergir — que é literalmente o defeito que esta GT documenta.

## Objetivo
Os dois READMEs concordam sobre o que cada um dos dois campos pode conter, ou declaram por escrito
onde e por que divergem de propósito.

## Fora de escopo
- Não converter nenhum dos 11 vazios nem dos 17 sem campo. **Descobrir quais têm issue não
  registrada é conferência um a um**, e é trabalho próprio — esta GT define o vocabulário que
  torna a conferência possível.
- Não renomear pasta, não mexer em `contraparte:` (feito na GT-0145).

## Comportamento atual
Três estados de `issue_url` sob dois valores; `blocked` válido de um lado e inexistente do outro.

## Comportamento esperado
Cada campo com vocabulário declarado nos dois READMEs — ou com a divergência declarada e
justificada, o que também é resposta válida.

## Regras de negócio
- RN-01: **divergência deliberada é resposta aceitável**, desde que escrita nos dois READMEs. O
  que não é aceitável é a diferença existir sem estar dita.
- RN-02: a forma de "não se aplica" segue a convenção já estabelecida na GT-0145 —
  `N/A — <motivo>`, nunca `""` —, porque `""` é o valor de campo ainda não preenchido.
- RN-03: nenhuma conversão de dado nesta GT. Só vocabulário.

## Critérios de aceitação
- [ ] CA-01: os dois READMEs declaram o vocabulário de `issue_url`, distinguindo **os três
      estados**: promovida, nunca promovida, e campo ausente.
- [ ] CA-02: os dois declaram o vocabulário de `status`, incluindo se `blocked` vale nos dois
      lados ou só num — **e, se só num, por quê**.
- [ ] CA-03: a justificativa de cada divergência remanescente está escrita **nos dois** READMEs,
      não só naquele a que ela favorece.
- [ ] CA-04: o `_template.md` de cada lado reflete o vocabulário declarado.
- [ ] CA-05: existe uma frase dizendo **qual dos dois documentos governa** quando eles
      discordarem, para a próxima divergência ter onde ser resolvida sem nova GT.
- [ ] CA-06: os READMEs declaram **o que torna um arquivo fechado por dentro** — Registro
      preenchido, Validação com saída real, caixas marcadas ou `- [ ]` com motivo ao lado. É a
      parte que vive no **corpo**, e que um validador de front-matter não alcança.
- [ ] CA-07: os READMEs declaram que **quem marca uma caixa é quem verificou**, e que critério
      alheio não se fecha por conveniência de fechamento — com a razão: *a caixa marcada é a
      afirmação de que alguém verificou*.
- [ ] CA-08: se alguma trava automática for proposta a partir desta GT, ela **declara o que não
      alcança**. Validador de front-matter não vê corpo vazio; dizer isso evita que o verde dele
      seja lido como "fechado por dentro".
- [ ] CA-09: os READMEs distinguem **ponteiro adiantado de ponteiro atrasado**, e declaram que o
      adiantado é **o estado correto** durante a janela entre os dois merges — não um defeito
      tolerado. Como não há commit que atravesse os dois repositórios, **cada lado deve mesclar já
      apontando para o destino final do outro**.
- [ ] CA-10: qualquer trava proposta **não acusa ponteiro adiantado**. Acusar o transitório correto
      treina quem lê a ignorar o alarme, e aí ela deixa de valer para o atrasado, que é a fila
      real.

## Impacto técnico
### Backend / Frontend / Banco de dados
Nenhum.
### Integrações
`.agents/tasks/README.md` e `_template.md` no produto; `squads/guardian/tasks/README.md` e
`_template.md` no hub.
### Segurança
Nenhum direto.

## Plano de implementação
- [ ] Etapa 1 — CA-05 primeiro: sem saber quem governa, as outras viram negociação.
- [ ] Etapa 2 — `issue_url` (CA-01), com os três estados nomeados.
- [ ] Etapa 3 — `status`/`blocked` (CA-02), decidindo se converge ou diverge declaradamente.
- [ ] Etapa 4 — moldes (CA-04).
- [ ] Etapa 5 — as regras de corpo: CA-06, CA-07 e a ressalva do CA-08.

## Estratégia de testes
- [ ] Unitários / Integração / E2E: N/A — não há código.
- [ ] Manual: reler os dois READMEs lado a lado e confirmar que não resta afirmação sobre campo
      que só um deles faça.

## Riscos e rollback
- **Risco:** resolver a divergência convergindo o vocabulário **sem** perguntar se ela era
  deliberada — `blocked` pode existir só no produto por um motivo que ninguém escreveu. A RN-01
  existe para isso: declarar é resposta.
- **Risco:** aproveitar a GT para converter os 11 vazios. A RN-03 veta; é conferência um a um.
- **Risco, e é o que mata a utilidade:** uma trava que acuse ponteiro adiantado. Ela estaria
  punindo a única prática possível sem atomicidade entre repositórios, e o custo não é o
  falso-positivo — é que **quem aprende a ignorar o alarme deixa de ver o verdadeiro**.
- **Rollback:** markdown; um revert.

## Registro de execução
### Alterações realizadas
Pendente — cunhada em 12/09/2026, não executada.
### Arquivos principais
Pendente.
### Decisões
Pendente.
### Divergências
Nenhuma.
### Pendências
`grupo_execucao` não preenchido: é do Step 09.

## Validação
Pendente. Os números do `issue_url` (82 / 54 / 11 / 17) foram medidos em `b99055f` lendo de
commit, não da árvore; o `blocked` foi conferido em `.agents/tasks/README.md:7` e por contagem
zero no README do hub.

## Handoff
Sem dependência de entrada.
