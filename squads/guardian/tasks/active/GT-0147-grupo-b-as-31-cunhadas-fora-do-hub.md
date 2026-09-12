---
id: GT-0147
title: "Grupo B: as 31 GTs cunhadas fora do hub, e o caminho que continua aberto"
status: active
type: documentation
achado_origem: "Censo de acervo da GT-0144 (#627) — divisão em três decidida pelo Sergio em 12/09/2026"
auditor_origem: "Tomás Ticket (censo), divisão recomendada por Jarvis no Step 09 (PR #632)"
severidade: media
produto: GeoCloudAI
camada: documentacao
run_origem: "N/A — despacho direto, fora de run de pipeline"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/635"
grupo_execucao: G2
owner: Sergio
created_at: 2026-09-12
updated_at: 2026-09-12
affected_modules: [acervo-de-tasks]
related_adrs: []
guarda_chuva: "GT-0144 — o censo, o método e a evidência vivem lá e não são copiados aqui"
depende_de: ["GT-0145"]
contraparte: "GeoCloudAI/.agents/tasks/active/GT-0147-grupo-b-as-31-cunhadas-fora-do-hub.md"
---

# GT-0147 — Grupo B: as 31 GTs cunhadas fora do hub, e o caminho que continua aberto

## ⚠️ Não executável em janela de nuvem — com uma exceção
O CA-02, o CA-03 e o CA-04 **escrevem no hub** (`sergio-essencislabs/essencis-squads`), alcançável
só desta máquina por caminho absoluto `C:\Software\ClaudeCode\squads\guardian\`.

**A exceção é o CA-08**, que escreve em `.agents/tasks/README.md`, dentro do produto — esse sim
uma janela de nuvem faz. Se a Vision precisar destravar só o CA-08, ele é separável; o resto não.

## ⛔ Não começar antes do CA-09 da GT-0145
Esta task cria **31 arquivos de hub**. Criá-los a partir de um `_template.md` que não pede
`contraparte:` é fabricar o Grupo B de novo, à mão, 31 vezes. **Espere o CA-09 fechar.** Enquanto
não fechar, quem escrever um arquivo aqui põe o campo à mão e registra que o fez.

## Contexto
Uma das três em que a GT-0144 (#627) foi dividida — divisão mecânica: `grupo_execucao` é um campo
em uma task, e a `dispatcher` lê o campo por task, não lê Etapas.

**O censo, o método e a evidência estão na GT-0144 e não são copiados aqui.**

## Achado original
31 GTs têm par no produto e **nunca tiveram arquivo de hub** — o inverso do Grupo A: `GT-0064`-
`0066`, `0072`-`0075`, `0079`, `0083`-`0095`, `0097`, `0109`-`0117`.

Das 31, **29 não têm `contraparte:`** e **2 têm, apontando para arquivo inexistente** (GT-0109 e
GT-0110, para `C:/Software/ClaudeCode/squads/guardian/tasks/active/GT-0109.md` e `GT-0110.md`, que
não existem).

O `origem:` delas não aponta para run de auditoria do Guardian — `"issue #203, em TO DO"`,
`"rodar a campanha tipada depois das 45 PRs da noite"`, `"Sergio, na revisão da apresentação
semanal de 14/09 — print 2"`. A leitura mais simples é que foram criadas direto no repositório do
produto, por sessões que trabalhavam ali, usando o prefixo `GT-` sem passar pelo hub.

**É hipótese — e é a mais preocupante das duas do censo, porque descreve um caminho que continua
aberto hoje.** Nada impede que a próxima sessão faça igual. É o CA-08.

## Cinco das 31 têm nome de arquivo em minúscula — e isso esconde o tamanho do problema
`gt-0113` a `gt-0117`, todas em `completed/`, com `id: GT-0113` **maiúsculo** dentro do arquivo.
Uma varredura por `GT-` devolve **26 e parece completa**. Achado do Jarvis, que bateu 26 contra os
31 do censo e por alguns segundos achou ter encontrado erro no censo — o errado era o `grep`.

**Toda varredura desta task é case-insensitive.** É a armadilha do dia em forma de nome de arquivo.

### Decisão de nomenclatura — escrita, não improvisada
**O arquivo novo do hub nasce `GT-NNNN` maiúsculo, seguindo o `id:`, mesmo quando o par no produto
é minúsculo.**

Três razões:
1. **O `id:` é o identificador canônico**, e nas cinco ele é maiúsculo. O nome do arquivo do
   produto é que diverge do próprio conteúdo.
2. **O hub é 100% maiúsculo** — **85 arquivos** em `sergio-essencislabs/essencis-squads` @
   `2e1fc9e`, nenhum `gt-`. (Eram 82 em `b99055f`, antes de as três GTs desta divisão entrarem na
   `main`; o que não muda é a proporção: **zero** minúsculos.) Seguir o nome do par importaria a
   grafia minúscula para um lugar que não a tem: espalharia o defeito em vez de contê-lo.
3. **O `contraparte:` carrega o caminho exato dos dois lados**, então a divergência de caixa entre
   os nomes **nunca quebra a resolução do par** — ela só quebra varredura ingênua, e a defesa
   contra isso é varrer case-insensitive, não renomear.

**Renomear os cinco arquivos do produto fica fora de escopo**, de propósito: mexe em histórico e em
qualquer link que aponte para eles, e o ganho é estético perto do risco. Fica registrado aqui como
divergência conhecida e deliberada — não como descuido.

## Objetivo
Cada uma das 31 com arquivo no hub, ou com a ausência justificada por escrito; e o README dizendo
o que impede o Grupo B de se repetir.

## Fora de escopo
- Grupo A (as 39 só no hub) — é a GT-0146.
- Higiene do front-matter do hub — é a GT-0145.
- **Renomear `gt-0113`..`gt-0117`** — ver a decisão acima.
- Reabrir ou reavaliar mérito técnico de qualquer das 31.
- Preencher buraco de numeração.

## Comportamento atual
31 GTs sem arquivo de hub, duas delas com ponteiro pendurado, e nada impedindo a próxima.

## Comportamento esperado
Arquivo de hub criado ou ausência justificada, ponteiros resolvendo, e o README dizendo a verdade
sobre o que impede a repetição.

## Regras de negócio
- RN-01: **criar o lado que falta a partir do que existe, nunca inventar conteúdo.** Sem
  informação suficiente, o arquivo novo diz isso em vez de ser plausível.
- RN-02: severidade e `created_at` originais preservados no lado novo.
- RN-03: nenhum número reaproveitado, nenhum buraco preenchido.
- RN-04: toda varredura desta task é **case-insensitive**.

## Critérios de aceitação
Numeração original da GT-0144 preservada, para o rastro ser legível sem tradução.

- [x] **CA-02**: as 31 têm arquivo no hub, ou justificativa escrita equivalente.

- [x] **CA-03** (escopo Grupo B): `contraparte:` correta nos dois sentidos, em caminho relativo —
      nunca `C:/...`.

- [x] **CA-04**: `GT-0109` e `GT-0110` deixam de apontar para arquivo inexistente.
      **Vem junto do CA-03 de propósito:** as duas são exatamente os 2 dos 31 com ponteiro
      pendurado, e consertá-las é o **mesmo campo, no mesmo arquivo** que o CA-03 escreve ao criar
      o par. Separar poria duas janelas no mesmo arquivo.

- [x] **CA-08**: `.agents/tasks/README.md` — o do **produto**, não o do hub — ganha uma linha
      dizendo **o que impede o Grupo B de se repetir**, ou, se nada impedir hoje, dizendo isso com
      essas palavras. É o do produto porque é o que uma sessão lê antes de criar um `GT-`, que é
      onde o Grupo B nasce.

      O README já afirma que **nascer em par é a regra, não o fim do ciclo** — o `GT` é criado
      *"automaticamente, junto do `GT` de mesmo número no repositório do squad"* (linha 19) e
      *"Todo `GT-NNNN` daqui tem um irmão de mesmo número"* (linha 27). **A regra está escrita; o
      que falta é o que a faz valer. Reenunciá-la não fecha este critério.**

      Frase mínima aceitável, se nada melhor aparecer — a saída honesta é válida aqui:
      > Hoje nada impede que um `GT-NNNN` nasça só neste repositório, sem o par no hub: a regra
      > acima é convenção, não verificação. Enquanto não houver checagem, conferir o par é passo
      > manual de quem cria.

      **É o único critério desta task que uma janela de nuvem consegue executar.**

## Impacto técnico
### Backend / Frontend / Banco de dados
Nenhum.
### Integrações
`squads/guardian/tasks/` no hub (CA-02, CA-03, CA-04) e `.agents/tasks/README.md` no produto
(CA-08).
### Segurança
Indireto: boa parte das 31 são achados de permissão (0083-0095, 0109-0110), e acervo em que não se
confia é acervo que não se consulta.

## Plano de implementação
- [x] Etapa 0 — **confirmar que o CA-09 da GT-0145 fechou.** Se não fechou, ou espere, ou ponha
      `contraparte:` à mão e registre que o molde ainda não pedia.
- [x] Etapa 1 — CA-08, que é independente do resto e o único fazível em nuvem.
- [x] Etapa 2 — CA-02 + CA-03 + CA-04, os 31 arquivos, em lote, varrendo case-insensitive.

## Estratégia de testes
- [x] Unitários / Integração / E2E: N/A — não há código.
- [x] Manual: varredura final **case-insensitive** confirmando que as 31 têm hub ou justificativa,
      e que nenhum `contraparte:` aponta para arquivo inexistente. Rodar o **controle positivo**
      antes de aceitar qualquer zero.

## Riscos e rollback
- **Risco principal:** inventar conteúdo para 31 arquivos. RN-01 existe por isso, e o volume torna
  a tentação maior aqui do que na GT-0146.
- **Risco:** começar antes do CA-09 e fabricar 31 arquivos sem `contraparte:`.
- **Risco:** varrer com `grep GT-` e achar que são 26. RN-04 existe por isso.
- **Rollback:** markdown; um revert.

## Registro de execução
### Alterações realizadas
- **CA-02** — 31 arquivos novos neste repositório, em `squads/guardian/tasks/{active,completed}/`,
  cada um na pasta que espelha a do par. PR #7, mesclado em `00a0ce3`. Nenhuma das 31 precisou de
  justificativa de ausência: todas tinham par honesto do qual derivar.
- **CA-03** — `contraparte:` nos dois sentidos, em caminho relativo. Do lado do produto, 29
  inserções e 2 correções, em Essencis-Labs/GeoCloudAI#641.
- **CA-04** — `GT-0109` e `GT-0110` deixaram de apontar para
  `C:/Software/ClaudeCode/.../GT-0109.md` e `GT-0110.md`, que nunca existiram. Eram também os dois
  únicos ponteiros absolutos do lado do produto: os dois defeitos morriam no mesmo campo, que é
  por que o CA-04 veio junto do CA-03.
- **CA-08** — `.agents/tasks/README.md` do produto ganhou a seção "O que faz essa regra valer:
  hoje, nada", com a frase mínima e três verificações que a sustentam. Commit `cfb3d2a5` no #641.

### Arquivos principais
- 31 arquivos novos aqui (PR #7)
- 31 pares no produto, só o campo `contraparte:`, uma linha cada (#641)
- `.agents/tasks/README.md` no produto (CA-08)

### Decisões
- **O arquivo do hub não duplica o par.** O README do produto define que o hub responde *por que
  entrou na fila* e o par *como foi feito*. Como nenhuma das 31 veio de auditoria, cada arquivo
  daqui transcreve a origem real do par e aponta para lá. Copiar critérios, plano e registro teria
  produzido a "mesma coisa duas vezes" que o README proíbe.
- **`## Objetivo`:** nenhuma das 31 traz essa seção — são escritas à mão, fora do molde. Deduzir um
  objetivo do título seria inventar, e a RN-01 veta. Cada arquivo lista as seções que o par
  realmente traz. Conferido depois pelo revisor, nome por nome nos 31: todas verbatim.
- **Base do PR #7:** `origin/main` (`b99055f`), não `acervo/gt-0145-0147`, para não empilhar PR em
  branch que mescla por squash. Como `b99055f` é anterior ao CA-09, o molde de lá ainda não pedia
  `contraparte:` — os 31 campos foram escritos deliberadamente, na forma do molde corrigido em
  `c3b5320`, não copiados do molde velho.
- **Worktree, não troca de branch:** o checkout compartilhado deste repositório estava na branch do
  Tomás com trabalho não commitado. `git worktree add`; a árvore dele não foi tocada.

### Divergências
- **`GT-0064`** tem `status: partial` no par, valor que o molde daqui não prevê (`backlog |
  active | completed`). O arquivo do hub espelha a pasta (`active`), como o molde manda, e grava
  `partial` no corpo. Dois valores registrados, nenhum inventado.
- **Os cinco nomes minúsculos** do produto (`gt-0113`..`gt-0117`) continuam minúsculos lá, por
  decisão registrada acima. Aqui nasceram maiúsculos, e o hub segue sem nenhum minúsculo.

### Pendências
- `camada:` e `grupo_execucao:` ficaram `""` nos 31: são campos do Step 09, e nenhuma das 31 passou
  por roteamento. `""` aqui significa "não preenchido", que é a verdade.
- `GT-0073` e `GT-0079` ficaram com `issue_url: ""` porque o par não registra issue. Pelo molde,
  `issue_url` vazio é o sinal de "não promovida pelo Step 10", que é o caso das duas.
- **O fechamento move os dois lados juntos.** Enquanto o #641 não mesclar, mover só este lado para
  `completed/` deixaria o ponteiro do outro apontando para `active/` — exatamente a fila que o
  CA-08 documenta.

### Este arquivo foi, ele próprio, o oitavo caso
Os 31 arquivos mesclaram no `00a0ce3` e **este arquivo-task ficou para trás**, com zero caixas
marcadas e o Registro dizendo "Pendente — não executada", enquanto o trabalho que ele descreve já
estava na `main`.

É a mesma forma que o CA-08 documenta — **entrega feita, registro não atualizado** — manifestada
num **campo diferente**: não o ponteiro, o Registro. E aconteceu **depois** de o CA-08 ser escrito,
o que é a evidência mais forte que a task podia ter: a fila não é acervo histórico, é produção
corrente, e escrever sobre ela não a interrompe.

Acrescenta uma quarta manifestação às três já mapeadas (par ausente no nascimento; ponteiro que
envelhece ao mover para `completed/`; `issue_url` vazio depois de a issue existir). As quatro têm a
mesma causa e nenhuma tem quem a feche no fluxo.

## Validação
Revalidado contra **commit**, não contra árvore de trabalho — três janelas ainda têm worktree neste
repositório, e medir a árvore mede o trabalho não commitado dos outros.

Âncoras: hub em `origin/main` (`9774f53`), produto em `7d0799d1` (head do #641).

```
hub @ 9774f53: 116 arquivos | produto @ 7d0799d1: 77 arquivos

CA-02 as 31 com arquivo no hub : 31/31 (faltam nenhuma)
CA-03 hub -> produto resolve   : 31/31
CA-03 produto -> hub resolve   : 31/31
CA-04/05 caminho absoluto      : 0 (esperado 0)
controle positivo minusculos   : hub=0 (esp. 0) | produto=5 (esp. 5)
```

O controle positivo é o que autoriza aceitar os zeros: o detector de minúsculo acha os cinco do
produto, então o zero do hub é ausência real, não cegueira do instrumento.

Três zeros falsos foram rejeitados durante a execução:

1. Ponteiro desatualizado no hub voltou **0** — a árvore compartilhada estava com consertos não
   commitados que mascaravam cinco dos sete. Em `b99055f` são **7**.
2. Contagem de `## Objetivo` voltou **0 de 31** por `os.path.join` ter produzido barra invertida que
   o grep do MSYS não resolve. Refeita com barra normal e controle positivo (`Critérios de
   aceitação` em 20/31), o zero se confirmou real.
3. Uma suspeita de front-matter corrompido (`pr: affected_modules: [...]` em onze arquivos) era bug
   do extrator — `\s*` atravessando a quebra de linha. Os arquivos estão íntegros.

## Handoff
**Depende da GT-0145 (CA-09).** O CA-08 é separável e não depende de nada.
LLML: não consultada (branch de integração, não `main`).
