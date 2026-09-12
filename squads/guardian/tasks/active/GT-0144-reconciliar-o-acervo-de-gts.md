---
id: GT-0144
title: "Reconciliar o acervo de GTs: 70 pares que nunca existiram"
status: active
type: documentation
achado_origem: "N/A — achado durante a varredura de numeração da Frente 1 do despacho da Vision (12/09/2026)"
auditor_origem: "Tomás Ticket (varredura de numeração, Step 07)"
severidade: media
produto: GeoCloudAI
camada: documentacao
run_origem: "N/A — despacho direto, fora de run de pipeline"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/627"
grupo_execucao: ""
owner: Sergio
created_at: 2026-09-12
updated_at: 2026-09-12
affected_modules: [acervo-de-tasks]
related_adrs: []
contraparte: "GeoCloudAI/.agents/tasks/active/GT-0144-reconciliar-o-acervo-de-gts.md"
---

# GT-0144 — reconciliar o acervo de GTs: 70 pares que nunca existiram

## Contexto
A varredura de numeração feita em 12/09/2026 para cunhar a GT-0139 precisou ler o acervo inteiro —
hub e `.agents/tasks/` do produto, as três pastas, todas as branches remotas. Ao fazer isso,
apareceu uma lacuna que ninguém tinha medido: **70 GTs existem de um lado só.**

O modelo do par está escrito em `.agents/tasks/README.md`: o GT do **hub** responde *por que isto
entrou na fila*; o GT do **produto** responde *como será feito e como foi feito*; e o campo
`contraparte:` aponta nos dois sentidos. Setenta arquivos não obedecem a isso.

Esta task **mapeia** a lacuna e propõe como fechá-la. Não a fecha — reconciliar 70 arquivos é
trabalho próprio, provavelmente de mais de uma janela.

## Achado original

### Não é uma lacuna, são duas — com causas diferentes

Medido em 12/09/2026 sobre os 70 arquivos, não por amostra.

**Grupo A — 39 GTs só no hub, sem par no produto:** `GT-0001` a `GT-0039`.
**Dos 39, exatamente 0 têm o campo `contraparte:`.** Não é ponteiro quebrado: o campo nunca
existiu nesses arquivos.

**Grupo B — 31 GTs só no produto, sem arquivo no hub:** `GT-0064`-`0066`, `0072`-`0075`, `0079`,
`0083`-`0095`, `0097`, `0109`-`0117`.
**Dos 31, 29 não têm `contraparte:` e 2 têm — e os 2 apontam para arquivos que não existem.**

### Grupo A — hipótese: anterior à TASK-060

**É hipótese, não fato.** O que a sustenta:

1. `.agents/tasks/` aparece pela primeira vez no histórico do produto em **2026-09-09**, no commit
   `8e10d774` — *"refactor: versiona task e ADR, e passa a criacao de task ao Guardian
   (TASK-060)"*. Antes disso não havia onde pôr o par.
2. O corte é **exato** na fronteira 0039/0040:

   | GT | `created_at` | tem `contraparte:`? |
   |---|---|---|
   | GT-0037 | 2026-09-08 | não |
   | GT-0038 | 2026-09-08 | não |
   | GT-0039 | 2026-09-08 | não |
   | GT-0040 | 2026-09-09 | **sim** |
   | GT-0041 | 2026-09-09 | **sim** |

3. Os dois commits imediatamente seguintes ao da TASK-060 são `f9cecc26` (GT-0040) e `f12060bb`
   (GT-0041) — as duas primeiras GTs com par.

**O que falta para virar fato:** a hipótese explica a ausência por "o mecanismo não existia", mas
não exclui que pares tenham existido e sido apagados. Confirmar exige varrer o histórico do
produto por arquivos `GT-000*` removidos (`git log --diff-filter=D`). Não foi feito.

### Grupo B — causa diferente: cunhadas fora do hub

Estas têm par no produto e nunca tiveram o arquivo do hub — o inverso do Grupo A. O campo
`origem:` delas não aponta para run de auditoria do Guardian:

| GT | `origem:` |
|---|---|
| GT-0064 | `"issue #203, em TO DO"` |
| GT-0079 | `"leitura do contrato de armazenamento ao procurar cobertura de teste..."` |
| GT-0097 | `"rodar a campanha tipada depois das 45 PRs da noite..."` |
| gt-0113 | `"Sergio, na revisão da apresentação semanal de 14/09 — print 2"` |

A leitura mais simples é que foram criadas direto no repositório do produto, por sessões que
trabalhavam ali, usando o prefixo `GT-` sem passar pelo hub. **Também é hipótese** — e é a mais
preocupante das duas, porque descreve um caminho que continua aberto hoje: nada impede que a
próxima sessão faça igual.

### As duas exceções do Grupo B — ponteiros pendurados

`GT-0109` e `GT-0110` **têm** `contraparte:`, e apontam para arquivos inexistentes:

```yaml
# .agents/tasks/active/GT-0109-encolher-a-superficie-do-mvp.md
contraparte: "C:/Software/ClaudeCode/squads/guardian/tasks/active/GT-0109.md"
# .agents/tasks/completed/GT-0110-o-contrato-do-financeiro.md
contraparte: "C:/Software/ClaudeCode/squads/guardian/tasks/active/GT-0110.md"
```

O hub tem `GT-0106.md`, `GT-0107.md` e `GT-0108.md`, e **não** tem `GT-0109.md` nem `GT-0110.md`.
Além de pendurados, são caminhos absolutos de máquina — o par viaja na branch, não num caminho de
`C:/`.

### Os buracos que não sei explicar

Números que não existem em lado nenhum:

```
0053-0063   0067-0071   0076-0078   0080-0082   0096   0098-0105
```

Não tenho explicação para nenhum. Podem ser números cunhados e abandonados, podem nunca ter sido
cunhados. **Não foram preenchidos e não devem ser** — a cunhagem segue do máximo para cima.

**Sobre 0053-0062, um aviso deliberado para quem ler isto no futuro:** essa faixa coincide
exatamente com `TASK-053` a `TASK-062`, que existem. **É coincidência de faixa, não colisão.**
`TASK-NNN` pertence ao orquestrador `bootstrap-*` e `GT-NNNN` ao Guardian; os prefixos são
distintos justamente para que a mesma numeração dos dois lados seja impossível de confundir
(`.agents/tasks/README.md`: *"prefixo distinto torna impossível"*). Ninguém deve "descobrir" aqui
uma colisão que não existe.

### Dois itens menores do mesmo assunto

1. **`GT-0120`, `GT-0121` e `GT-0122`** (já commitadas no hub) têm `contraparte:` apontando para
   pasta errada — o par já vive em `completed/`.
2. **`docs/setup-local.md:39`** cita a baseline de testes `257 unit / 31 integration / 332 specs`.
   A suíte hoje é **509 / 91 / 274** (run de CI 34698146569). Número de baseline errado em
   documento de setup faz quem segue o documento concluir que quebrou alguma coisa.

## Objetivo
O acervo volta a ser fonte confiável: todo `GT-NNNN` existe dos dois lados, com `contraparte:`
correta nos dois sentidos, ou tem registrado por escrito por que não existe.

## Fora de escopo
- **Não preencher os buracos de numeração.** Número livre continua livre; cunhagem segue do máximo.
- Não reabrir, reimplementar nem reavaliar mérito de nenhuma das 70 — é reconciliação de registro,
  não revisão técnica.
- Não marcar caixa de critério de GT alheia. Se a verificação retroativa for desejada, é task
  própria (ver Pendências).

## Comportamento atual
70 GTs de um lado só; 2 ponteiros pendurados; 3 ponteiros para pasta errada; um número de baseline
errado em `docs/`.

## Comportamento esperado
Cada `GT-NNNN` alcançável dos dois lados, ou com ausência justificada por escrito.

## Regras de negócio
- RN-01: reconciliar é **criar o lado que falta a partir do que existe**, nunca inventar conteúdo.
  GT sem informação suficiente para gerar o par recebe um arquivo mínimo que diz isso, em vez de
  um arquivo plausível.
- RN-02: a severidade e o `created_at` originais são preservados no lado novo.
- RN-03: nenhum número é reaproveitado, e nenhum buraco é preenchido.
- RN-04: o Grupo A e o Grupo B têm causas diferentes e podem ser tratados em lotes separados — não
  é preciso fechar os dois juntos.

## Critérios de aceitação
- [ ] CA-01: as 39 do Grupo A têm par no produto, ou uma linha escrita no arquivo do hub dizendo
      por que não têm.
- [ ] CA-02: as 31 do Grupo B têm arquivo no hub, ou justificativa escrita equivalente.
- [ ] CA-03: `contraparte:` correta nos dois sentidos em tudo que for reconciliado, em caminho
      relativo — nunca `C:/...`.
- [ ] CA-04: `GT-0109` e `GT-0110` deixam de apontar para arquivo inexistente.
- [ ] CA-05: `GT-0120`, `GT-0121` e `GT-0122` apontam para `completed/` **e deixam de usar caminho
      absoluto**. Hoje são `C:/Software/GeoCloud/GeoCloudAI/...`, apontando para o checkout
      compartilhado — pasta errada e caminho de máquina são dois defeitos no mesmo campo, e este CA
      cobre os dois. O par viaja na branch; caminho relativo é o que o CA-03 exige.
- [ ] CA-06: `docs/setup-local.md:39` traz a baseline real, com cada número rotulado pela suíte a
      que pertence, ou deixa de citar número se a decisão for que baseline não pertence a documento
      de setup. Baseline proposta, com a run citada:
      **`509 unit / 91 integration / 196 de 274 api (78 skipped) / 561 specs`** (run 34701237492).

      **O `332 specs` da linha atual é do frontend, não do backend** — e é por isso que este
      critério precisa de quatro números, não três. A primeira redação deste CA mandava trocar por
      `509 / 91 / 274`, o que teria causado três estragos de uma vez: pôr um número de backend
      (`Back.ApiTests`) sob o rótulo "specs", que é do Karma; **sumir com o número do frontend** de
      um parágrafo que manda subir backend **e** frontend; e esconder que 78 dos 274 não rodam.
      Quem seguisse o setup e visse `561` concluiria que quebrou alguma coisa — exatamente o mal
      que este CA existe para curar.

      A desambiguação é por contagem histórica: em `f3d33580` (09/09, o commit que criou a linha) o
      frontend tinha **329** `it(` — praticamente os 332 — e o `Back.ApiTests` tinha **12**
      `[Fact]/[Theory]`. Hoje são 548 `it(` e 96. Achado do Rui na revisão do #628.

      **Sobreposição declarada:** a Etapa 6 da GT-0142 (#622) também prevê corrigir essa linha, ao
      escrever a página de "como rodar a suíte localmente". Quem chegar primeiro resolve e marca
      nos dois lugares; o risco aqui não é o trabalho dobrado, é cada uma supor que a outra fez.
- [ ] CA-07: a hipótese do Grupo A é confirmada ou refutada por
      `git log --diff-filter=D -- '.agents/tasks/GT-00*'`, e o resultado fica escrito.
- [ ] CA-08: o `README.md` de tasks ganha uma linha dizendo **o que impede o Grupo B de se
      repetir** — ou, se nada impedir hoje, dizendo isso com essas palavras.
      O README já afirma que **nascer em par é a regra, não o fim do ciclo**: o `GT` é criado
      *"automaticamente, junto do `GT` de mesmo número no repositório do squad"* (linha 19) e
      *"todo `GT-NNNN` daqui tem um irmão"* (linha 27). A regra está escrita; o que falta é o que a
      faz valer. Enunciar de novo não fecha este critério.

## Impacto técnico
### Backend
Nenhum.
### Frontend
Nenhum.
### Banco de dados
Nenhum.
### Integrações
`.agents/tasks/` do produto, `squads/guardian/tasks/` do hub, `docs/setup-local.md`.
### Segurança
Indireto. Acervo em que não se confia é acervo que não se consulta, e boa parte dessas 70 são
achados de permissão (0083-0095, 0109-0110).

## Plano de implementação
- [ ] Etapa 1 — confirmar ou refutar a hipótese do Grupo A (CA-07). Muda o texto do lado que for
      criado para as 39.
- [ ] Etapa 2 — os cinco itens pontuais, que são baratos e independentes: CA-04, CA-05, CA-06.
- [ ] Etapa 3 — Grupo B (31 arquivos de hub a criar a partir do par existente).
- [ ] Etapa 4 — Grupo A (39 pares de produto, ou a justificativa do CA-01).
- [ ] Etapa 5 — CA-08, a linha no README.

## Estratégia de testes
- [ ] Unitários: N/A — não há código.
- [ ] Integração: N/A.
- [ ] E2E: N/A.
- [ ] Manual: varredura final conferindo que todo `GT-NNNN` de um lado tem o outro, e que nenhuma
      `contraparte:` aponta para arquivo inexistente. É o mesmo script da varredura de numeração,
      invertido.

## Riscos e rollback
- **Risco principal: inventar conteúdo para preencher lado que falta.** Um arquivo de hub plausível
  mas fabricado é pior do que a ausência, porque a ausência é visível e a fabricação não. A RN-01
  existe por isso.
- **Risco:** duas janelas reconciliando lotes que se sobrepõem. Os grupos A e B são disjuntos e
  servem de fronteira natural.
- **Rollback:** tudo é arquivo markdown; reverter é um revert.

## Registro de execução
### Alterações realizadas
Pendente — esta GT foi cunhada e mapeada, não executada.
### Arquivos principais
Pendente.
### Decisões
Tratar a lacuna como **duas**, com causas distintas, em vez de uma lista de 70 — porque a correção
de cada grupo é diferente, e porque só o Grupo B descreve um caminho que continua aberto hoje.
### Divergências
Nenhuma.
### Pendências
- A verificação retroativa das caixas de critério das GTs que foram para `completed/` sem marcação
  não está aqui e continua sem dono. É assunto vizinho, não o mesmo.
- `grupo_execucao` vazio de propósito (Step 09).

## Validação

**Censo, não amostragem.** Os números foram medidos sobre os 70 arquivos em 12/09/2026.

**As duas pontas do censo, datadas juntas** — e esta é a correção mais importante desta revisão:

| Lado | Referência |
|---|---|
| Produto | `feature/fix/refactor-08_09-11_09` @ `d75d0bdf` (12:04:52) |
| Hub | `sergio-essencislabs/essencis-squads` @ `8867236` (11:49:38) + `7a8fdb2` (12:05:53) |

A primeira redação datava **só o lado produto**, em `4cea0a87` (11:03:12) — um commit anterior ao
próprio trabalho que este documento descreve. **Censo que fixa um lado e deixa o outro flutuar não
é reproduzível**, e produz artefato: comparar hub-às-11:49 com produto-às-11:03 faz `GT-0139` a
`GT-0143` aparecerem como se existissem só no hub, inflando o Grupo A de 39 para 44. Achado do Rui
na revisão do #628; a regra que fica é **fixar os dois lados no mesmo instante antes de contar**.

**Os números não mudam: Grupo A = 39, total = 70, pendurados = 2.** Em qualquer instante
*consistente* — antes do trabalho, quando as cinco não existiam de lado nenhum; ou depois do merge,
quando existem dos dois — `GT-0139`-`GT-0143` não são Grupo A. A linha do tempo mostra por quê:

```
11:47:44  4b821485  lado PRODUTO das cinco, commitado
11:49:38  8867236   lado HUB das cinco, commitado
12:04:52  d75d0bdf  #624 mesclado na branch de integração
```

**O lado produto veio primeiro, por dois minutos.** As cinco nunca foram só-hub; se algo, foram
brevemente só-produto. E os cinco `contraparte:` do lado hub resolvem hoje na branch de integração
— conferido por `git ls-tree`, não por `git show <rev>:<caminho>`, que no Git Bash desta máquina é
destruído pela conversão de path do MSYS e devolve "não existe" para arquivo que existe.

Por isso o mecanismo do Grupo A — *arquivo de hub sem par no produto, permanentemente* — **não se
reproduziu nesta jornada**. A disciplina do par valeu: os dois lados nasceram, foram commitados e
mesclados. O que a revisão encontrou foi um defeito de datação no meu documento, não uma
recorrência do defeito que ele documenta. A distinção importa porque é a diferença entre "a regra
falhou de novo" e "minha medição estava mal ancorada" — e só a segunda é verdade.

## Handoff
Cunhada e promovida no mesmo despacho. Decisão do Sergio, via Vision, em 12/09/2026: mapear agora,
reconciliar depois.
LLML: não consultada (branch de integração, não `main`).
