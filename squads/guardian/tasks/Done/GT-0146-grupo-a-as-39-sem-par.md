---
id: GT-0146
title: "Grupo A: as 39 GTs do hub sem par no produto"
status: completed
type: documentation
achado_origem: "Censo de acervo da GT-0144 (#627) — divisão em três decidida pelo Sergio em 12/09/2026"
auditor_origem: "Tomás Ticket (censo), divisão recomendada por Jarvis no Step 09 (PR #632)"
severidade: media
produto: GeoCloudAI
camada: documentacao
run_origem: "N/A — despacho direto, fora de run de pipeline"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/634"
grupo_execucao: G1
depende_de: []
owner: Sergio
created_at: 2026-09-12
updated_at: 2026-09-12
affected_modules: [acervo-de-tasks]
related_adrs: []
guarda_chuva: "GT-0144 — o censo, o método e a evidência vivem lá e não são copiados aqui"
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0146-grupo-a-as-39-sem-par.md"
---

# GT-0146 — Grupo A: as 39 GTs do hub sem par no produto

## ⚠️ Não executável em janela de nuvem
O CA-07 lê o histórico deste repositório, mas o CA-01 e o CA-03 **escrevem no hub**
(`sergio-essencislabs/essencis-squads`), alcançável só desta máquina por caminho absoluto
`C:\Software\ClaudeCode\squads\guardian\`. Uma janela só com o GeoCloudAI clonado consegue rodar o
portão e trava logo depois.

## Contexto
Uma das três em que a GT-0144 (#627) foi dividida — divisão mecânica: `grupo_execucao` é um campo
em uma task, e a `dispatcher` lê o campo por task, não lê Etapas.

**O censo, o método e a evidência estão na GT-0144 e não são copiados aqui.**

Esta costura **não depende de outra task** e corre desde o primeiro minuto, em paralelo com a
GT-0145. A dependência dela é **interna**: o CA-07 é portão do CA-01.

## Achado original
`GT-0001` a `GT-0039` existem no hub e **não têm par** em `.agents/tasks/` do produto. Nenhuma das
39 tem sequer o campo `contraparte:` — não é ponteiro quebrado, o campo nunca existiu. O conjunto
foi conferido por **igualdade**, não por contagem: os 39 sem campo são exatamente GT-0001..GT-0039.

**Hipótese registrada como hipótese:** são anteriores à TASK-060, que versionou `.agents/tasks/`.
Sustentam-na: `.agents/tasks/` aparece pela primeira vez em 2026-09-09, commit `8e10d774`
(TASK-060); o corte é exato em 0039/0040 (GT-0037/38/39 de 08/09 sem o campo, GT-0040/41 de 09/09
com); e os dois commits logo após o da TASK-060 são GT-0040 e GT-0041.

## O CA-07 é portão, não trabalho — e muda o que as outras duas caixas significam
Dois `git log` e um parágrafo. **Abrir janela própria para ele custa mais do que ele.** Mas o
resultado dele decide qual trabalho o CA-01 é:

| Resultado do CA-07 | O que o CA-01 vira |
|---|---|
| **Confirmada** — nada foi apagado | escrever, em cada uma das 39, que o par nunca existiu porque o mecanismo não existia |
| **Refutada** — houve deleção na faixa | **recuperar arquivo do histórico**, que é outra tarefa, com outro custo e outro risco |

Por isso: **primeiro ato da janela, resultado publicado antes de qualquer um dos 39 ser escrito.**
Se sair refutada, pare e devolva para a Vision em vez de improvisar a recuperação.

## Objetivo
Cada uma das 39 alcançável dos dois lados, ou com a ausência justificada por escrito no hub.

## Fora de escopo
- Grupo B (as 31 só no produto) — é a GT-0147.
- Higiene do front-matter do hub — é a GT-0145.
- Reabrir ou reavaliar mérito técnico de qualquer das 39. É reconciliação de registro.
- Preencher buraco de numeração.

## Comportamento atual
39 GTs de hub sem par e sem o campo que apontaria para ele.

## Comportamento esperado
Par criado, ou ausência justificada — e, nos dois casos, `contraparte:` coerente.

## Regras de negócio
- RN-01: **criar o lado que falta a partir do que existe, nunca inventar conteúdo.** GT sem
  informação suficiente recebe um arquivo mínimo que diz isso, em vez de um arquivo plausível.
  Arquivo fabricado é pior que a ausência: a ausência é visível, a fabricação não.
- RN-02: severidade e `created_at` originais preservados no lado novo.
- RN-03: nenhum número reaproveitado, nenhum buraco preenchido.
- RN-04: o CA-07 é publicado antes de o primeiro par ser escrito.

## Critérios de aceitação
Numeração original da GT-0144 preservada, para o rastro ser legível sem tradução.

- [x] **CA-07** (portão): **hipótese CONFIRMADA** em 12/09/2026, e o resultado ficou escrito antes
      do CA-01 — ver "Resultado do CA-07" no Registro de execução. Comando já corrigido:

      ```bash
      MSYS_NO_PATHCONV=1 git log --oneline --diff-filter=D --all -- '*GT-00*'
      ```

      **E o controle positivo, obrigatório antes de acreditar em qualquer zero:**

      ```bash
      MSYS_NO_PATHCONV=1 git log --oneline --all -- '*GT-00*'   # tem de devolver > 0
      ```

      A redação original deste critério trazia `-- '.agents/tasks/GT-00*'`, que **não alcança
      subpasta** e devolve `0` mesmo sem o filtro — não dizia "nada foi apagado", dizia "não
      olhei". Um comando de verificação que pode falhar em silêncio tem de provar que enxerga
      antes de o vazio dele valer.

      **Resultado parcial já obtido:** a varredura corrigida acha **uma** deleção, `b8cafe8e`, que
      removeu `.agents/tasks/backlog/GT-0043-rqd-real.md` ao movê-lo para `completed/`. **Fora da
      faixa 0001-0039** — não refuta, e serve de controle de que a peneira enxerga.

- [x] **CA-01**: cumprido pelo segundo braço — **linha escrita no arquivo do hub dizendo por que
      não têm par**, nas 39. Nenhum par foi criado, que é o que o CA-07 determinou. A seção "Par no
      repositório de produto" separa **duas causas**: 35 citam issue, PR ou commit (a ausência não
      é falta de informação) e 4 não citam nada — `GT-0012`, `GT-0023`, `GT-0037`, `GT-0038` —,
      onde a RN-01 morde de verdade.

- [x] **CA-03** (escopo Grupo A): `contraparte:` presente nas 39, sem caminho absoluto. Todas na
      forma `N/A — <motivo>` que a GT-0145 fixou no molde.

      **Leitura declarada da cláusula "nos dois sentidos":** ela não tem segundo sentido neste
      grupo, por construção — não existe par do outro lado para apontar de volta. Cumprido o que
      era exercível: o campo existe, não aponta para arquivo inexistente e diz por que está vazio.
      Marcar `[x]` calada sobre uma cláusula que não foi exercida seria afirmar verificação que
      não houve.

## Impacto técnico
### Backend / Frontend / Banco de dados
Nenhum.
### Integrações
`squads/guardian/tasks/` no hub e, se houver par a criar, `.agents/tasks/` do produto.
### Segurança
Nenhum direto.

## Plano de implementação
- [x] Etapa 1 — CA-07, com o controle positivo, e publicar o resultado. **Portão.** Confirmada e
      publicada antes de qualquer um dos 39 ser tocado (RN-04).
- [x] Etapa 2 — justificativa nas 39 (CA-01) e `contraparte:` (CA-03). Entregue pelo PR #8.
- [ ] Etapa 2' — **não se aplica:** a hipótese foi confirmada, não refutada. Nenhuma recuperação de
      arquivo foi tentada, e não havia o que recuperar. Fica aberta de propósito — é o ramo que o
      portão descartou, não pendência.

## Estratégia de testes
- [x] Unitários / Integração / E2E: N/A — não há código.
- [x] Manual: varredura final executada. Saída real, medida contra `origin/main` = `9774f53` via
      `git show`, sem ler árvore de trabalho:

      ```
      GTs no commit: 116                      (controle positivo)
      dos 39: contraparte N/A ......... 39
              com justificativa ....... 39
              status incoerente ....... 0
      ```

      Nenhum `contraparte:` novo aponta para arquivo inexistente: as 39 são `N/A`, que por
      definição não apontam para lugar nenhum.

## Riscos e rollback
- **Risco principal:** inventar conteúdo para as 39. RN-01 existe por isso.
- **Risco:** tratar o CA-07 como formalidade, rodar o comando sem controle positivo e escrever
  "confirmada" em cima de um zero cego. Foi exatamente o que a revisão pegou na GT-0144.
- **Rollback:** markdown; um revert.

## Registro de execução

### Resultado do CA-07 — hipótese CONFIRMADA

Publicado em 12/09/2026, **antes de qualquer um dos 39 ser tocado** (RN-04), no lado do produto.

```
$ MSYS_NO_PATHCONV=1 git log --oneline --diff-filter=D --all -- '*GT-00*'
b8cafe8e feat: RQD e recuperacao medidos (GT-0043)      → 1 deleção, fora da faixa

$ MSYS_NO_PATHCONV=1 git log --oneline --all -- '*GT-00*' | wc -l
44                                                      → a peneira enxerga
```

**Nenhum dos 39 foi apagado. Eles nunca existiram do lado do produto.** Os três fatos de apoio
foram conferidos na execução, não herdados do censo da GT-0144: `.agents/tasks/` nasce em
`8e10d774` (09/09) e os dois arquivos seguintes são GT-0040 e GT-0041; o corte por `created_at` é
exato (0037/38/39 em 08/09, 0040+ em 09/09); e os 39 sem o campo são, por igualdade de conjunto
sobre os 82 GTs do hub em `b99055f`, exatamente GT-0001..0039.

Uma sexta via, independente do histórico: no repositório de produto, `.agents/tasks/` não tem
nenhum GT-0001..0039 e tem 72 GTs começando exatamente em GT-0040 — o corte é visível na árvore
atual, sem `git log`.

**Limite declarado:** `--all` alcança as refs do clone. Um par que só tivesse vivido em branch
remota já apagada não apareceria. Estreito, e não muda a conclusão: sob um mecanismo que não
existia, não havia como criar par.

### Alterações realizadas

| Commit | O quê | Volume |
|---|---|---|
| PR #8 (`946510e` na `main`) | as 39 com `contraparte: "N/A — …"` e a seção de justificativa | 791 adições, **0 remoções** |
| idem | `status` espelhando a pasta em 23 das 39 | 23 arquivos, só a linha do `status` |

Os dois vieram em commits separados dentro do #8 — naturezas diferentes, e um é revertível sem o
outro.

### Arquivos principais
As 39 de `GT-0001` a `GT-0039` em `squads/guardian/tasks/{active,completed}/` — 7 em `active/`,
32 em `completed/`. Nenhum arquivo criado, nenhum movido de pasta.

### Decisões

1. **Nenhum par criado, e não por escassez.** 35 das 39 citam issue, PR ou commit: a
   rastreabilidade do lado-produto existe por outra rota. Um par criado agora acrescentaria um
   ponteiro a uma rota que já funciona e afirmaria, pela própria existência, que o mecanismo de
   par cobria tarefas de 02/09 a 08/09 — **registro com proveniência falsa**, a mesma inversão de
   "planejado documentado como implementado" com outra roupa. Nas 4 sem âncora é a RN-01 que veta.

2. **A forma do campo veio da GT-0145, não desta task.** A proposta inicial era `contraparte: ""`;
   foi recusada com evidência, porque `""` é o valor de campo ainda não preenchido e tornaria "não
   há par" indistinguível de "ninguém preencheu" — ambiguidade medida em 10 arquivos do hub ao
   fechar o CA-10. A execução **parou e esperou** a decisão do molde: as faixas eram disjuntas em
   arquivo mas acopladas em convenção, e varredura nenhuma compara forma.

3. **A direção do conserto de `status` veio do `README.md` deste diretório:** *"Mover o arquivo de
   pasta **é** a transição de estado. O campo `status:` só espelha a pasta atual."* A pasta manda.

4. **`GT-0030` foi a única das 23 cujo valor antigo era intencional** (`status: blocked`, por
   decisão explícita do dono em 03/09). `blocked` não é estado declarado aqui — o README só
   reconhece `backlog`, `active` e `completed` — e o arquivo está em `active/`. Normalizado sem
   perder o fato: o bloqueio está no corpo do próprio arquivo e a issue #373 segue Blocker.

   Nota para quem for espelhar isto: o `README.md` do **produto** sanciona `status: blocked`. A
   regra aplicada aqui é a do hub, e a mesma normalização do lado do produto estaria errada.

### Divergências

1. **Extensão de faixa autorizada, não escorregão.** O conserto de `status` nas 23 não estava no
   escopo desta task (*"fora de escopo: higiene do front-matter do hub — é a GT-0145"*) nem na
   faixa da GT-0145, cujo CA-10 nomeia só `GT-0040-0043`, `0045-0052` e `GT-0118-0122`. Caíam num
   vão entre as duas. Autorizado por escrito pela Vision em 12/09/2026, com commit separado.

2. **Duas autocorreções de fonte, ambas registradas.** O primeiro censo leu a árvore de trabalho
   compartilhada deste repositório, que estava na branch de outra janela, em vez de `main`. A
   segunda correção ainda foi parcial: o corte por `created_at` e os denominadores continuavam
   vindo da árvore. Refeitos lendo blobs de `b99055f` via `git show` — 85→**82** GTs, 46→**43** com
   o campo; os 39 e o corte não mudaram. O que estava errado era o denominador, e denominador
   medido em árvore compartilhada conta o trabalho não commitado dos outros.

### Pendências
Nenhuma. `grupo_execucao` preenchido pelo Step 09 em 12/09/2026: **G1**, sem predecessora.

## Validação

Medida contra `origin/main` = `9774f53`, via `git show`, sem ler árvore de trabalho — o repositório
tem worktrees de três janelas, e medição de acervo em árvore compartilhada mede o trabalho não
commitado das outras.

```
GTs no commit: 116                      (controle positivo — a leitura funciona)
dos 39: contraparte N/A ......... 39
        com justificativa ....... 39
        status incoerente ....... 0
```

O número de controle é o que torna os três resultados legíveis: sem ele, "39 de 39" poderia ser o
mesmo zero cego que o CA-07 existe para evitar, só que de cabeça para baixo.

## Handoff
Sem dependência de entrada — corre em paralelo com a GT-0145. Dependência **interna**: CA-07 antes
de CA-01.
LLML: não consultada — não houve autorização explícita do usuário para esta execução, e estar com
a `main` aberta não autoriza nada.
