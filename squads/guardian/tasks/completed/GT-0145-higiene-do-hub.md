---
id: GT-0145
title: "Higiene do hub: ponteiros, grafia da issue e o molde que não pede o par"
status: completed
type: documentation
achado_origem: "Censo de acervo da GT-0144 (#627) — divisão em três decidida pelo Sergio em 12/09/2026"
auditor_origem: "Tomás Ticket (censo), divisão recomendada por Jarvis no Step 09 (PR #632)"
severidade: media
produto: GeoCloudAI
camada: documentacao
run_origem: "N/A — despacho direto, fora de run de pipeline"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/633"
grupo_execucao: G1
depende_de: []
owner: Sergio
created_at: 2026-09-12
updated_at: 2026-09-12
affected_modules: [acervo-de-tasks]
related_adrs: []
guarda_chuva: "GT-0144 — o censo, o método e a evidência vivem lá e não são copiados aqui"
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0145-higiene-do-hub.md"
---

# GT-0145 — higiene do hub: ponteiros, grafia da issue e o molde que não pede o par

## ⚠️ Não executável em janela de nuvem
Praticamente tudo aqui escreve em `sergio-essencislabs/essencis-squads`, **outro repositório**,
alcançável só desta máquina por caminho absoluto (`C:\Software\ClaudeCode\squads\guardian\`, link
para `C:\Software\EssencisSquads\squads\guardian\`). Uma janela que só tem o GeoCloudAI clonado
**não consegue fazer nenhum dos três critérios desta task**. Despachar para nuvem é despachar para
um bloqueio.

## Contexto
Uma das três em que a GT-0144 (#627) foi dividida. A divisão não é de tamanho, é mecânica:
`grupo_execucao` é **um** campo em **uma** task, e a `dispatcher` lê o campo por task — roteamento
interno a uma GT, em Etapas, é roteamento que o despachante não enxerga.

**O censo, o método e a evidência estão na GT-0144 e não são copiados aqui.** Duplicá-los em três
arquivos é criar três cópias para divergirem — que é o defeito que a própria GT-0144 documenta.

Esta é a costura sem dependência nenhuma: **corre desde o primeiro minuto**, em paralelo com a
GT-0146 (Grupo A).

## Achado original
Três defeitos, todos no mesmo front-matter e nos mesmos arquivos do hub — é por isso que vêm
juntos. Separá-los agendaria conflito da task consigo mesma.

**1. Ponteiros `contraparte:` (CA-05).** Nove apontam para arquivo inexistente; cinco mais são
absolutos que resolvem; um (`GT-0052`) aponta para o próprio hub em vez do produto. **Quinze
campos**, dos quais só nove aparecem como quebrados.

**2. Duas grafias do campo de issue (CA-10).** `issue_url:` em 59 arquivos, `issue: NNN` em 23 —
dos quais 6 já convertidos no PR #3 do hub, restam **17**. Varredura por `issue_url` lê os 17 como
não promovidos, e eles estão.

**3. O `_template.md` do hub não tem `contraparte:` (CA-09).** Termina em `related_adrs: []`. Todas
as GTs carregam o campo à mão, e quem copiar o molde começa sem ele.

O CA-09 é o que faz esta task ser **porta**, e não só faxina: a GT-0147 (Grupo B) vai criar 31
arquivos de hub, e criá-los a partir de um molde que não pede `contraparte:` é fabricar o Grupo B
de novo, à mão. **A GT-0147 só entra quando o CA-09 fechar.**

## Objetivo
O front-matter do hub volta a ser legível por varredura: ponteiro que resolve, em caminho
relativo, com a grafia que o molde declara — e o molde passa a pedir o ponteiro.

## Fora de escopo
- Não criar par nenhum. Criar é Grupo A (GT-0146) e Grupo B (GT-0147).
- Não preencher buraco de numeração.
- Não renomear arquivo nenhum (ver a decisão de nomenclatura na GT-0147).

## Comportamento atual
15 campos `contraparte:` defeituosos, 17 arquivos com a grafia antiga do campo de issue, e um
molde que não pede o ponteiro.

## Comportamento esperado
Zero ponteiros quebrados, zero caminhos absolutos, uma só grafia do campo de issue, e o molde
pedindo `contraparte:`.

## Regras de negócio
- RN-01: converter `issue: NNN` para `issue_url:` é mecânico — o número já está lá. **Não inventar
  URL para arquivo sem número.**
- RN-02: caminho relativo sempre; `C:/Software/...` não resolve em janela de nuvem.
- RN-03: nenhum número reaproveitado, nenhum buraco preenchido.

## Critérios de aceitação
Herdados da GT-0144 com o texto completo — **a numeração original foi preservada de propósito**,
para que o rastro entre as duas seja legível sem tradução.

- [x] **CA-05** (da GT-0144): nenhum `contraparte:` do hub aponta para arquivo inexistente, **e
      nenhum usa caminho absoluto**. São duas cláusulas de alcances diferentes e a caixa só fecha
      com as duas:

      | Cláusula | Quantos |
      |---|---|
      | não aponta para arquivo inexistente | **9** — GT-0044, 0049, 0050, 0051, 0118, 0119, 0120, 0121, 0122 |
      | não usa caminho absoluto | **14** — os 9 acima + GT-0043, 0045, 0046, 0047, 0048 |

      Mais a décima de classe diferente: **`GT-0052` aponta para o próprio hub**
      (`C:\Software\EssencisSquads\squads\guardian\tasks\active\GT-0052-...`), não para o produto —
      ponteiro virado para o lado errado do par. **Total: 15 campos.**

      É possível consertar os nove, marcar a caixa e deixar cinco para trás cumprindo a letra da
      primeira cláusula e não da segunda. Os cinco resolvem hoje e ainda assim precisam virar
      relativos, pela razão que esta task já dá.

      **Conferir com o método, não com a lista** — lista envelhece, comando não: normalizar cada
      `contraparte:` e testar contra `git ls-tree -r --name-only <rev-do-produto> .agents/tasks`,
      com as **duas pontas ancoradas em commit**.

      **Dois casos que o método precisa tratar, e que não são defeito:**

      1. **Valor começando com `N/A`** — é a forma de "não há par" que o `_template.md` define
         (ex.: `"N/A — anterior à TASK-060"`). **Não é caminho e deve ser PULADO**, nunca contado
         como quebrado. Sem esta linha, os 39 do Grupo A apareceriam como 39 ponteiros quebrados
         nesta mesma varredura, e a próxima pessoa "consertaria" o que está certo.
         **Hoje isto não é pegável por teste:** o acervo tem **zero** valores `N/A`, então o ramo
         não é exercitado por nada. Ele existe para quando a GT-0146 escrever os 39 — que é
         exatamente quando errar sairia caro.
      2. **GT recém-cunhada cujo par ainda está em branch não mesclada** aparece quebrada e não
         está. Falso positivo legítimo, some quando o PR entra.

- [x] **CA-10** (da GT-0144): uma só grafia do campo de issue. Restam **17**: GT-0040-0043,
      0045-0052 e GT-0118-0122. Conversão mecânica, o número já está lá.

- [x] **CA-09** (da GT-0144): o `_template.md` do hub passa a trazer `contraparte: ""`. O
      `_template.md` do produto deve ser conferido no mesmo passo. **Este critério é a porta da
      GT-0147** — avise quando fechar.

## Impacto técnico
### Backend / Frontend / Banco de dados
Nenhum. Não há código.
### Integrações
`squads/guardian/tasks/` e `squads/guardian/tasks/_template.md`, no repositório do squad.
### Segurança
Indireto: boa parte dos arquivos com ponteiro quebrado são achados de permissão.

## Plano de implementação
- [x] Etapa 1 — CA-09 primeiro, porque destrava a GT-0147. É um campo num arquivo.
- [x] Etapa 2 — CA-05, as 15 correções, conferindo pelo método e não pela lista.
- [x] Etapa 3 — CA-10, os 17 restantes.

## Estratégia de testes
- [x] Unitários / Integração / E2E: N/A — não há código neste escopo.
- [x] Manual: varredura final com **controle positivo** — feita. Rodada a mesma consulta sem o
      filtro restritivo, para provar que ela enxerga antes de o vazio valer; a soma fecha em 85
      arquivos classificados. Resultado completo na Validação.

## Riscos e rollback
- **Risco:** marcar o CA-05 com a primeira cláusula cumprida e a segunda não. A tabela existe por
  isso.
- **Risco:** inventar `issue_url` para arquivo sem número no CA-10. RN-01 veta.
- **Rollback:** tudo é markdown; reverter é um revert.

## Registro de execução
### Alterações realizadas
**21 arquivos no hub**, todos em `squads/guardian/tasks/`. Nada no repositório de produto.

**CA-09 — o molde (`_template.md`).** Acrescentados `contraparte: ""` e `depende_de: []`, com a
**forma visível** e não só o nome. Duas correções ao que o despacho previa: o molde **já pedia**
`grupo_execucao` (linha 13), então eram dois campos e não três; e o `_template.md` do produto foi
conferido e **não muda** — os três são idênticos e são de `TASK-000`, convenção do orquestrador,
e `TASK-NNN` não tem par no hub por decisão da TASK-060.

O molde também passou a definir **a forma de "não há par"**, que faltava e bloqueava a GT-0146:
`contraparte: "N/A — <motivo curto>"`, nunca `""` nem `—` solto, com a justificativa longa no
corpo. E a regra que vem junto: **varredura de ponteiro deve pular valores que começam com `N/A`**
— sem isso, os 39 do Grupo A apareceriam como 39 ponteiros quebrados neste mesmo método.

**CA-05 — 17 campos `contraparte:`**, não os 15 previstos. O método achou **11 quebrados**, não 9:
`GT-0139` e `GT-0142` entraram na fila **hoje**, pelas nossas próprias entregas (#630 e #629), que
as moveram para `completed/` no produto e deixaram o ponteiro do hub em `active/`. Absorvidos por
autorização explícita da Vision — mesma classe, faixa livre, decisão do despachante registrada
aqui para quem ler depois ver que foi decidido e não que escorregou.

Havia **quatro formas** do mesmo defeito, e a lista só teria pego três: barra invertida sem aspas
(`GT-0043`, `0045`-`0052`), barra invertida dupla com aspas (`GT-0044`), barra normal com aspas
(`GT-0118`-`0122`), e a `GT-0052`, que apontava para **o próprio hub** em vez do produto.

**CA-10 — 17 conversões `issue:` → `issue_url:`.** Catorze mecânicas, com os números distintos
conferidos contra issues reais antes de converter. **Três não eram mecânicas** — e as três são
variações do mesmo defeito de fundo: o campo diz "não há registro" quando há.

- `GT-0045` trazia `issue: a criar`. **A issue existia:** a **#452** se chama
  *"[GT-0044/45/46] Auditoria do Guardian..."* e o corpo nomeia as três. Não foi invenção — foi
  leitura. A RN-01 proíbe fabricar URL, e não foi preciso.
- `GT-0051` trazia `issue: "296, 297"`, duas issues numa GT. `issue_url` é campo de URL única;
  ficou com a **#296**, e as duas seguem nomeadas no `title:` e no `origem:`, que é onde já
  estavam. **Nada se perdeu**, e a linha diz isso.

- `GT-0044` trazia `issue_url: ""` — grafia certa, **valor vazio**, mesmo efeito de ser lida como
  não promovida. É o caso que **mais** precisava de justificativa, e não de menos: a RN-01 proíbe
  inventar URL para arquivo sem número, e este **não tinha número nenhum**. O que autoriza
  preenchê-lo não é dedução, é leitura — o título da **#452** nomeia o `GT-0044`, junto do 45 e do
  46, e o corpo repete os três. Conferência independente: os `issue_url` vazios caíram de **11
  para 10**, consistente com ter preenchido exatamente um.

### Arquivos principais
`_template.md`; `GT-0040`-`0052`, `GT-0118`-`0122`, `GT-0139` e `GT-0142`.

### Decisões
1. **`N/A — motivo` para "não há par"**, não `""`. Motivo medido, não estético: `""` é o valor de
   campo **ainda não preenchido** e é o que o molde entrega, então serve para as duas coisas e a
   varredura não as distingue. A prova apareceu no próprio CA-10: dos 85 arquivos, **10 ficaram
   com `issue_url: ""`** e não há como dizer quais nunca tiveram issue e quais têm e não
   registraram — a `GT-0045` era uma dessas, e só se soube pelo título da issue. `N/A — motivo` já
   é a forma da casa em `achado_origem`, `auditor_origem` e `run_origem`.
2. **Absorver `GT-0139`/`GT-0142`** em vez de devolver: autorização da Vision, faixa livre
   (Marta em `GT-0001`-`0039`, Lívia nos 31 do Grupo B, e estas duas em nenhuma das duas), e o
   conserto é idêntico ao dos outros 15.
3. **`GT-0051` fica com uma URL só.** O campo é singular; inventar uma lista aqui criaria
   convenção nova num dia em que estamos consertando divergência de convenção.

### Divergências
- O despacho dizia que o molde não pedia `grupo_execucao`. **Pedia.**
- O critério dizia 15 campos; eram **17**, porque o acervo se moveu entre a medição e a execução.
  A nova âncora está na Validação.

### Pendências
1. **A torneira continua aberta, e mediu-se ela jorrando.** Cada GT implementada e movida para
   `completed/` no produto deixa o ponteiro do hub apontando para `active/`.

   A aritmética dos 17 mostra isso sem precisar de argumento: **14 absolutos + 1 virado para o hub
   + 2 que eram relativos e apontavam para `active/`**. Os dois últimos são `GT-0139` e `GT-0142`,
   cujos pares foram para `completed/` **hoje**, pelos PRs #630 e #629 — ou seja, **dois dos 17
   foram criados durante a execução da task que os conserta**, por entregas do próprio squad.

   Não é fila herdada que encolhe até zerar: é vazão. Consertar os 17 drena a pia sem fechar a
   torneira.
   Consertar os 17 drena a pia sem fechar a torneira. Encaminhado para ser irmão do CA-08 na
   GT-0147, que é onde a pergunta "o que impede isto de se repetir" já mora.
2. **Os 10 `issue_url: ""`** (`GT-0027`, `0028`, `0031`-`0038`) são a outra forma da mesma
   torneira: entrega feita, registro não atualizado. Fora do escopo deste CA, que era a **grafia**;
   quais deles têm issue não registrada é trabalho de conferência, um a um.
3. **O produto não tem molde de `GT-` nenhum.** Quem cria o lado de produto de uma GT não tem de
   onde partir — candidato à resposta do CA-08, encaminhado à GT-0147.

## Validação

**Método, não lista** — como o próprio CA-05 manda. As duas pontas ancoradas em commit, e **as
duas colunas também**:

| coluna | hub em | produto em |
|---|---|---|
| **antes** | `c9741bd` | `82f6c769` |
| **depois** | `b925492` | `82f6c769` |

O produto não se move entre as duas: **nada foi escrito nele por esta task.** Quem for reproduzir
o verde precisa do SHA do depois, e ele é o `b925492` — a primeira redação parava em `c9741bd`,
que é justamente onde a coluna *antes* se reproduz.

**VERMELHO — antes**
```
formas do campo: {'absoluto': 14, 'sem campo': 39, 'aponta-para-o-hub': 1, 'relativo': 31}
ponteiros que NAO resolvem: 11
absolutos que RESOLVEM (pasta certa, caminho de maquina): 5
campo de issue: issue_url=68   issue=17
```

**VERDE — depois**
```
formas do campo: {'relativo': 46, 'sem campo': 39}
ponteiros que NAO resolvem: 0
absolutos que RESOLVEM: 0
campo de issue: issue_url=85   issue=0
```

**Controle positivo.** Antes de aceitar o zero, rodei a mesma varredura sem o filtro restritivo:
ela devolvia 11 e continuou enxergando os 85 arquivos e classificando 100% deles — a soma fecha
em 46 + 39 = 85. Zero aqui é ausência medida, não peneira cega.

Os **39 sem campo** são exatamente `GT-0001`-`GT-0039`, o Grupo A, que é escopo da GT-0146 e não
deste critério: não têm ponteiro quebrado, **nunca tiveram o campo**.

## Handoff
Sem dependência de entrada — corre desde o primeiro minuto, em paralelo com a GT-0146.
**Tem dependente:** a GT-0147 espera o CA-09.
LLML: não consultada (branch de integração, não `main`).
