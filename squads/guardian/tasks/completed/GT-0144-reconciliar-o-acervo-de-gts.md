---
id: GT-0144
title: "Reconciliar o acervo de GTs: 70 pares que nunca existiram"
status: completed
type: documentation
achado_origem: "N/A — achado durante a varredura de numeração da Frente 1 do despacho da Vision (12/09/2026)"
auditor_origem: "Tomás Ticket (varredura de numeração, Step 07)"
severidade: media
produto: GeoCloudAI
camada: documentacao
run_origem: "N/A — despacho direto, fora de run de pipeline"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/627"
grupo_execucao: nao-despachavel
depende_de: ["GT-0145", "GT-0146", "GT-0147"]
owner: Sergio
created_at: 2026-09-12
updated_at: 2026-09-13
affected_modules: [acervo-de-tasks]
related_adrs: []
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0144-reconciliar-o-acervo-de-gts.md"
---

# GT-0144 — reconciliar o acervo de GTs: 70 pares que nunca existiram


> ## 🛑 Esta GT virou guarda-chuva. Não despachar.
>
> **Em 12/09/2026 o Sergio dividiu este trabalho em três GTs.** Nenhum critério é executado aqui.
> Quem for executar, vá para a GT-0145, GT-0146 ou GT-0147 — a tabela de migração abaixo diz qual
> critério ficou com quem, e **nenhum ficou sem dono**.
>
> **Por que guarda-chuva e não substituída.** O que sobra aqui não é trabalho: é o **censo** — 82
> arquivos classificados, a decomposição por forma do campo, a linha do tempo, a hipótese do Grupo
> A com o que a sustenta, e o método de conferir. As três filhas **citam** isso e não copiam.
> Copiar seria criar três versões da mesma medição para divergirem entre si, que é literalmente o
> defeito que este documento existe para descrever. Substituir e arquivar perderia a narrativa de
> *por que* são três.
>
> O risco do guarda-chuva é virar GT ativa e vazia, que é o outro defeito daqui. Contra isso: este
> aviso, a tabela de migração, e a regra de que **esta GT só fecha quando as três filhas
> fecharem** — ela não tem critério próprio a marcar.
>
> **Um campo ficou para trás no lado produto e não é meu para mexer:** lá o front-matter traz
> `grupo_execucao: G1`, gravado pelo roteamento do Step 09 (#632) **antes** de a divisão existir.
> Numa GT que diz "não despachar", isso é convite para abrir janela para nada — mas
> `grupo_execucao` é campo do Step 09 e precisa ser limpo por lá.


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

**O que falta para virar fato:** isso explica a ausência por "o mecanismo não existia", mas não
exclui que pares tenham existido e sido apagados. Confirmar exige varrer arquivos removidos — com
o glob `'*GT-00*'`, **não** `'.agents/tasks/GT-00*'`, que não alcança subpasta e devolve zero por
cegueira. O comando e o controle positivo obrigatório estão no CA-07. Não foi feito.

Uma deleção já apareceu na revisão do #4 — `b8cafe8e`, que removeu
`.agents/tasks/backlog/GT-0043-rqd-real.md` ao movê-lo para `completed/`. Está **fora** da faixa
0001-0039 e não refuta nada; serve de controle de que a varredura corrigida enxerga.

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
2. **`docs/setup-local.md:39`** cita a baseline de testes `257 unit / 31 integration / 332 specs`,
   defasada. Número de baseline errado em documento de setup faz quem segue o documento concluir
   que quebrou alguma coisa.
   **Atenção ao terceiro número:** `332 specs` é do **frontend** (Karma), não do `Back.ApiTests` —
   a baseline correta tem quatro números, `509 unit / 91 integration / 196 de 274 api (78 skipped)
   / 561 specs` (run 34701237492). **A titularidade deste item é da GT-0142 (#622)**, não desta
   GT — ver a tabela de migração. ✅ **Resolvido pelo #629**, que aplicou os quatro números e
   acrescentou que são suítes diferentes e não se somam.

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

## Critérios de aceitação — migrados, nenhum órfão

**Esta GT não tem critério próprio.** Os dez originais foram distribuídos, e a numeração foi
**preservada** nas filhas de propósito: `CA-05` na GT-0145 é o mesmo `CA-05` que estava aqui, para
o rastro ser legível sem tradução.

| Critério original | Foi para | Por quê |
|---|---|---|
| CA-05 — ponteiros `contraparte:` | **GT-0145** (Higiene) | mesmo bloco de front-matter que o CA-10 |
| CA-10 — grafia do campo de issue | **GT-0145** | mesmos arquivos do CA-05; separar agendaria conflito da task consigo mesma |
| CA-09 — `_template.md` sem `contraparte:` | **GT-0145** | é a **porta** da GT-0147 |
| CA-07 — varredura de arquivos removidos | **GT-0146** (Grupo A) | **portão**, não trabalho: decide se o CA-01 é justificar ausência ou recuperar arquivo |
| CA-01 — as 39 do Grupo A | **GT-0146** | — |
| CA-03 — `contraparte:` do que for reconciliado | **GT-0146 e GT-0147** | escopo por grupo; cada uma escreve nos seus arquivos |
| CA-02 — as 31 do Grupo B | **GT-0147** (Grupo B) | — |
| CA-04 — GT-0109 e GT-0110 pendurados | **GT-0147** | são 2 dos 31; é o **mesmo campo, no mesmo arquivo** que o CA-03 escreve ao criar o par |
| CA-08 — linha no `README.md` do produto | **GT-0147** | único critério das três executável em janela de nuvem |
| CA-06 — baseline de `docs/setup-local.md:39` | **GT-0142** (#622) — ✅ **já cumprido** pelo #629 | ver abaixo |

### O CA-06 saiu do escopo, com titularidade e não com cortesia
Ele não foi para nenhuma das três: **a GT-0142 (#622) é dona dele**, porque é ela que escreve a
página de "como rodar a suíte localmente" e toca a mesma linha.

A redação anterior dizia *"quem chegar primeiro resolve e marca nos dois lugares"*. **Essa regra
era ela própria o risco que o parágrafo nomeava** — duas tasks com direito ao mesmo arquivo e
nenhuma com o dever. Agora há uma dona só.

**✅ Cumprido.** O PR **#629** (`79b42190`) entregou os dois critérios da GT-0142: criou
`docs/quality/rodar-a-suite-localmente.md`, ligou-a a partir de `docs/README.md` e de
`docs/quality/README.md`, e deixou a linha do `docs/setup-local.md` com os quatro números, com um
acréscimo melhor do que o que eu tinha escrito: *"quatro suítes diferentes, que não se somam; os
274 são backend e os 561 são frontend"*.

Ou seja: a titularidade funcionou como devia. **Nada volta como divergência.**

### Dependência entre as três
```
GT-0145 (Higiene) ──┬── corre desde o primeiro minuto
GT-0146 (Grupo A) ──┘   (paralelas entre si)
        │
        └── GT-0145/CA-09 fecha ──> GT-0147 (Grupo B) entra
```
A GT-0146 tem portão **interno**: CA-07 antes de CA-01.

### Onde nada disto roda
**Janela de nuvem não executa quase nada das três** — quase tudo escreve no hub
(`sergio-essencislabs/essencis-squads`), outro repositório, alcançável só da máquina do Sergio por
caminho absoluto. **A única exceção é o CA-08**, na GT-0147. Isto está escrito dentro das três, e
não só aqui, para o despachante ler no lugar onde decide.

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
Não há plano aqui: o trabalho está nas três filhas. Esta GT fecha quando as três fecharem.

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


---

## Fechamento — 13/09/2026

**Esta GT fecha.** A regra que ela mesma escreveu era *"esta GT só fecha quando as três filhas
fecharem"*, e a pré-condição está satisfeita — conferido, não presumido:

| filha | hub (`origin/main`) | produto (`8cbc67e2`) |
|---|---|---|
| GT-0145 | `completed/` | `completed/` |
| GT-0146 | `completed/` | `completed/` |
| GT-0147 | `completed/` | `completed/` |

### A pergunta desta GT foi respondida, e a resposta é melhor do que a hipótese

A GT nasceu chamando o problema de **"70 pares que nunca existiram"**. A varredura final mostrou que
esse título descreve o que foi encontrado no censo, mas **não** descreve o que sobrou:

    ponteiros preenchidos no produto ........... 80
      acham o par pelo NOME ..................... 80
      não acham par nenhum ....................... 0

**Nenhum par está faltando.** A reconciliação do acervo — que é a pergunta que esta GT existiu para
responder — está **inteira**. O que resta é defeito de **forma** (três grafias em uso, nenhuma
canônica) e de **estado de pasta** (ponteiro que ficou para trás quando o par andou para
`completed/`), e nada disso é acervo faltando.

**Ressalva, e ela não é decorativa.** Três ponteiros — `GT-0049`, `GT-0050`, `GT-0051` — apontam
para este mesmo repositório em vez de para o hub. Eles *resolvem*, então uma varredura por número
os marca como saudáveis, mas quem os seguir cai no arquivo de onde saiu. Então "nenhum par está
faltando" é verdade; **"todo ponteiro leva ao par" não é.** Achado da Lívia, registrado aqui porque
o fechamento desta GT o herda.

### O que esta GT não alcançou

- **O sentido produto → hub nunca esteve no escopo de nenhum dos critérios daqui.** A CA-05, que
  migrou para a GT-0145, cobria hub → produto. O outro sentido ficou sem dono até esta varredura
  final, e é por isso que ele aparece só agora — não porque tenha regredido.
- **A forma canônica do campo `contraparte:` não foi decidida aqui**, e não podia ser: decidir isso
  é decisão do Sergio, não medição.
- **Os 34 campos não foram corrigidos aqui.** Correção em massa de front-matter durante o
  fechamento de um guarda-chuva misturaria medição com edição, que é o que torna número não
  auditável depois.

### Para onde vai o que sobrou

**GT-0151** — forma canônica do ponteiro e os 34 campos do lado produto. Carrega os 24 atrasados, os
16 absolutos (6 são as duas coisas) e os 3 auto-ponteiros, com critério próprio para cada grupo.

O motivo pelo qual a GT-0151 existe **não é o número**: é que três janelas mediram este mesmo
acervo de boa-fé e chegaram a 24, 34 e 46, cada uma sob um predicado diferente e **nenhuma sabendo
estar medindo uma pergunta diferente das outras**. Enquanto não houver forma canônica declarada,
qualquer varredura futura escolhe sozinha o que conta como quebrado.

## Handoff
Cunhada e promovida no mesmo despacho. Decisão do Sergio, via Vision, em 12/09/2026: mapear agora,
reconciliar depois.
LLML: não consultada (branch de integração, não `main`).

**Fechada em 13/09/2026.** Continuação em **GT-0151**, que não roda em paralelo com a **GT-0149**.
