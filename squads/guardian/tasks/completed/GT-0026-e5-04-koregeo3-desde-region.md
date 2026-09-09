---
id: GT-0026
title: "KoreGeo3 acessível desde Region — REVERTER (decisão do usuário, 2026-09-03: restringir a DrillHole)"
status: active
reaberta_qa: "2026-09-03"
type: feature
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "N/A — feature"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/336"
grupo_execucao: "Onda 3"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-03
affected_modules: [koregeo3, navegacao]
related_adrs: [GADR-0001]
---

# GT-0026 — KoreGeo3 desde Region

## Contexto
Guia KoreGeo3 disponível a partir de Region e níveis inferiores, conforme matriz de GT-0004.

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/336.

## Objetivo
Guia disponível a partir de Region, conforme a matriz.

## Fora de escopo
N/A.

## Comportamento atual
KoreGeo3 não acessível de Region.

## Comportamento esperado
Disponível a partir de Region e níveis inferiores.

## Regras de negócio
- RN-01: N/A.

## Critérios de aceitação
- [x] CA-01: Guia disponível a partir de Region e níveis inferiores, conforme matriz de GT-0004.

## Impacto técnico
### Frontend
Integração com config de GT-0004.
### Backend / Banco de dados / Integrações / Segurança
N/A.

## Plano de implementação
- [x] Consumir decisão de GT-0004/GADR-0001.
- [x] Implementar acesso desde Region.

## Estratégia de testes
- [x] Automatizado — `Koregeo3AggregatorComponent` (18 specs: leitura do sessionStorage por
  nível, roteamento para `DrillHole/getBy{Region,Deposit,Mine,MineArea}`, transição
  lista→visualizador, "voltar à lista").
- [ ] Manual — abrir KoreGeo3 a partir de Region (pendente validação do usuário no ambiente).

## Riscos e rollback
Nenhum.

## Registro de execução
### Alterações realizadas
Adicionada a guia "KoreGeo3" nas telas de Region, Deposit, Mine e MineArea (os 4 níveis
agregadores da matriz de GT-0004 acima de DrillHole), implementando o comportamento
`requireSelection` decidido em GADR-0001: a guia abre mostrando uma listagem paginada de
furos descendentes (via `DescendantDrillHolesLoaderService`, que já delega para
`DrillHole/getBy{Region,Deposit,Mine,MineArea}` — mesmo endpoint/paginação já usados por
`region-view-drill-holes` e equivalentes) e só abre o visualizador (o mesmo
`DrillHoleViewKoregeo3Component` já usado na guia KoreGeo3 de `DrillHoleView`) depois que o
usuário escolhe um furo, com um botão "Voltar à lista de furos" para trocar de furo sem sair
da aba.

DrillHole e DrillBox já tinham a guia (via `DrillHoleView`, implementada em onda anterior) —
não foram tocados por este PR.

### Arquivos principais
- `web/src/app/shared/entity-guides/koregeo3-aggregator/koregeo3-aggregator.component.ts`
  (+ `.html`, `.scss`, `.spec.ts`) — componente compartilhado novo, consumido pelos 4 níveis
  agregadores. Injeta `DescendantDrillHolesLoaderService` (GT-0004); lê o id da entidade do
  mesmo sessionStorage (`regionId`/`depositId`/`mineId`/`mineAreaId`) já usado pelas
  `-view.component.ts` correspondentes — não introduz um mecanismo de estado novo.
- `web/src/app/pages/geodata/regions/region-view/region-view.component.{ts,html}` — nova aba.
- `web/src/app/pages/geodata/deposits/deposit-view/deposit-view.component.{ts,html}` — nova aba.
- `web/src/app/pages/geodata/mines/mine-view/mine-view.component.{ts,html}` — nova aba.
- `web/src/app/pages/geodata/mine-areas/mine-area-view/mine-area-view.component.{ts,html}` —
  nova aba.

### Decisões
- **Carga do visualizador sob demanda (`import()` dinâmico + `NgComponentOutlet`), não import
  estático.** Motivo duplo: (1) fidelidade ao próprio espírito do `requireSelection` do
  GADR-0001 — nada pesado (OpenSeadragon/Annotorious) deve carregar antes da escolha do furo;
  (2) achado durante a validação — importar `DrillHoleViewKoregeo3Component` estaticamente em
  `Koregeo3AggregatorComponent` e este em cada um dos 4 `-view.component.ts` mudou a ordem de
  avaliação de módulos do bundle de teste (Karma/webpack) o suficiente para expor um ciclo de
  módulos **pré-existente** entre cada `-view.component.ts` e seus filhos de aba (ex.
  `deposit-view-drill-boxes.component.ts` importa `DepositViewComponent` só para tipar
  `public msApp: DepositViewComponent`, enquanto `deposit-view.component.ts` importa o filho
  de volta para o `imports` do `@Component`) — resultando em
  `ReferenceError: Cannot access 'DepositViewDrillBoxesComponent' before initialization` na
  suíte completa de testes (reproduzido; não reproduz em bundle isolado de `deposits/**`,
  confirmando ser um efeito de ordenação do grafo completo, não um bug local). O `import()`
  dinâmico remove essa aresta estática e resolveu o crash (confirmado por reexecução da suíte
  completa antes/depois da mudança). Não foi feita nenhuma tentativa de "consertar" o ciclo
  pré-existente em si (fora de escopo — afeta todas as 4 famílias de `-view`/`-view-*`, não é
  específico do KoreGeo3).
- **Escopo dos 4 níveis agregadores (Region/Deposit/Mine/MineArea) numa única task/PR**,
  seguindo o texto da própria issue #336 ("Region e níveis inferiores") e o padrão já usado
  por GT-0019 ("Region e níveis intermediários") — evita 4 PRs quase idênticos reimplementando
  a mesma lógica.
- **DrillBox deliberadamente fora de escopo**: nenhuma das 3 guias (Single View, MultiView,
  KoreGeo3) tem aba em `drill-box-view` hoje — é um gap pré-existente comum às 3, não
  introduzido nem específico deste PR. Tratar isso exigiria decidir também o comportamento de
  Single View/MultiView nesse nível, fora do escopo de uma issue só de KoreGeo3.

### Divergências
Nenhuma divergência da decisão de GADR-0001/GT-0004.

### Pendências
- Validação manual no ambiente (abrir a aba KoreGeo3 a partir de Region/Deposit/Mine/MineArea,
  selecionar um furo, conferir que o visualizador abre e "Voltar à lista" funciona) — não
  executada nesta sessão (sem acesso a ambiente rodando); marcada como pendente no plano de
  testes.
- Gap de DrillBox para as 3 guias (Single View/MultiView/KoreGeo3) permanece em aberto — não é
  uma pendência desta task especificamente, mas vale registrar para quem for revisar a matriz
  de GT-0004 no futuro.

## Validação
- `ng test --include='**/entity-guides/**/*.spec.ts'` (escopo do componente novo, mais os specs
  já existentes de GT-0004): **18/18 SUCCESS**.
- `ng test` (suíte completa do projeto, `web/`): **73 SUCCESS / 179 FAILED**. Todas as 179
  falhas são o mesmo padrão pré-existente já documentado por GT-0004 (specs de scaffold do
  Angular CLI declarando componentes `standalone` no array `declarations` do `TestBed`,
  incluindo componentes não tocados por este PR, ex. `ProfileFunctionalitiesComponent`) — sem
  nenhuma falha nova atribuível aos arquivos deste PR (confirmado por busca textual pelos nomes
  dos componentes tocados e pelo nome do componente novo no log completo).
  - Durante a primeira tentativa (antes da correção de import dinâmico descrita em
    "Decisões"), a suíte completa não chegava a rodar todos os specs: abortava em
    `Executed 131 of 131 ... ERROR` com
    `ReferenceError: Cannot access 'DepositViewDrillBoxesComponent' before initialization`.
    Após a correção, a suíte completa voltou a rodar os 252 specs (73+179) até o fim, sem
    nenhum `ReferenceError`/crash de módulo.
- `ng build --configuration production`: sucesso (exit 0), sem erros, nas duas rodadas (antes
  e depois da correção de import dinâmico). Únicos warnings são os já pré-existentes
  (dependências CommonJS de terceiros — canvg, jspdf, apexcharts, geotiff — e 3 avisos
  `NG8107` em arquivos não tocados por este PR: `login2`, `drill-hole-view-mult`,
  `drillholes-view-3d`).
- PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/369 (branch
  `feature/gt-0026-koregeo3-desde-region`, a partir de
  `feature/visualizadores-navegacao-layout`). **Mesclado (squash) por Jarvis** após resolução
  manual de um conflito real de merge: os 4 arquivos `region-view`/`deposit-view`/`mine-view`/
  `mine-area-view` (`.ts`+`.html`) colidiam com GT-0022 (#366, já mesclado), que adiciona a aba
  "Multi View" nos mesmos 4 componentes. Além da união simples de imports/`imports:` (padrão já
  usado em GT-0009×GT-0010), houve uma colisão real de **ID de `ngbNavItem`** — os dois PRs
  numeraram sua nova aba com o próximo índice disponível, então "Multi View" e "KoreGeo3"
  reivindicavam o mesmo número em cada tela (ex. `[ngbNavItem]="7"` em `region-view`). Resolvido
  renumerando a aba KoreGeo3 para o próximo índice livre em cada tela (Region: 7→8, Deposit:
  6→7, Mine: 5→6, MineArea: 4→5), mantendo o número original do Multi View intacto (já mesclado
  primeiro). `ng build --configuration development` confirmado limpo no worktree antes do push.

## Handoff
Depende de GT-0004, GT-0023 (KoreGeo3 já decidido como padrão) — ambos já mesclados.
Nenhuma outra task depende diretamente de GT-0026. Fica registrado para futura referência: o
gap de Single View/MultiView/KoreGeo3 em DrillBox (ver "Pendências") e o ciclo de módulos
pré-existente entre cada `-view.component.ts` e seus filhos de aba (ver "Decisões") — nenhum
dos dois é bloqueante, mas ambos são relevantes para quem mexer nessas telas novamente.

**PR #369 mesclado em `feature/visualizadores-navegacao-layout`.** Com isto, a Onda 3 do
projeto está 100% mesclada (9/9 tasks).

## Achado de QA pós-implementação (2026-09-03) — decisão confirmada, task reaberta para reverter
Relatório de QA (Matheus, `TASKS.md`, E5-04): "Acessível, mas restringir a partir de DrillHole, como no E5-01."

**Decisão confirmada pelo usuário (2026-09-03)**: "Só a partir de DrillHole." Ver GADR-0001, "Revisão" (entrada 2026-09-03) e GT-0023 (CA-02 atualizado).

## Escopo da reversão
1. `web/src/app/shared/entity-guides/entity-guide.model.ts` — `koreGeo3.levels`: `ALL_LEVELS` → `['drillHole', 'drillBox']` (mesmo padrão de `images`). Atualizar também a tabela markdown na doc do arquivo e `entity-guide.model.spec.ts` (specs que hoje esperam KoreGeo3 disponível nos 6 níveis).
2. Remover a aba "KoreGeo3" adicionada por esta task nos 4 templates agregadores: `region-view`, `deposit-view`, `mine-view`, `mine-area-view` (`.html` — bloco `<li [ngbNavItem]>` — e `.ts` — import + entrada em `imports:` de `Koregeo3AggregatorComponent`).
3. `web/src/app/shared/entity-guides/koregeo3-aggregator/` (componente criado só para esta feature) — como nada mais o referencia depois da reversão, remover o diretório inteiro (diferente do padrão "comentar" usado em GT-0027: aquele era sobre simplificação deliberada de menu, mantendo o código para religar fácil; isto é a reversão de uma decisão de produto que não deve voltar sem um novo pedido — dead code sem utilidade não deve ficar no repositório).
4. Reverter a renumeração de `[ngbNavItem]` feita durante a resolução de conflito com GT-0022 (Multi View) nas 4 telas — como a aba KoreGeo3 sai, o índice que ela ocupava fica livre; não é obrigatório renumerar de volta (não há problema em ter um "buraco" na sequência), mas confirmar que nenhum outro código depende do número específico antes de decidir.

## Handoff atualizado
Task reaberta para reverter o próprio trabalho (PR #369, já mesclado). Nova branch a partir de `feature/visualizadores-navegacao-layout`, PR de volta pra lá — mesmo fluxo das demais correções desta rodada.

## Registro de execução da reversão (2026-09-03)
### Alterações realizadas
Reversão aplicada exatamente conforme "Escopo da reversão" acima:
1. `entity-guide.model.ts`: `koreGeo3.levels` de `ALL_LEVELS` para `['drillHole', 'drillBox']`;
   `aggregatorStrategy` de `'requireSelection'` para `'notApplicable'` (mesmo padrão de
   `images`, que também não é agregador). Tabela markdown do header e
   `entity-guide.model.spec.ts` atualizados (specs que esperavam KoreGeo3 nos 6 níveis
   reescritos para esperar `['drillHole', 'drillBox']`, igual a `images`).
2. Aba "KoreGeo3" (`<li [ngbNavItem]>` + `<app-koregeo3-aggregator>`) removida dos 4
   templates agregadores (`region-view`, `deposit-view`, `mine-view`, `mine-area-view`);
   import e entrada em `imports:` de `Koregeo3AggregatorComponent` removidos dos 4 `.ts`.
   `DrillHoleViewMultComponent`/`DrillHoleViewUnicComponent` (Multi View/Single View) não
   tocados.
3. Diretório inteiro `web/src/app/shared/entity-guides/koregeo3-aggregator/` removido
   (`.ts`, `.html`, `.scss`, `.spec.ts`) — confirmado via busca textual que nada mais no
   repo referenciava `Koregeo3AggregatorComponent`/`koregeo3-aggregator` fora desse
   diretório antes da remoção. `DescendantDrillHolesLoaderService` (GT-0004, usado também
   por Single View/MultiView) não foi tocado.
4. Numeração dos `[ngbNavItem]` restantes **mantida como estava** (não renumerada) —
   confirmado via grep que nenhum `activeId` fixo ou navegação por índice depende do
   número específico das abas nessas 4 telas. Fica um "buraco" onde estava KoreGeo3:
   Region (era 8), Deposit (era 7), Mine (era 6), MineArea (era 5); "Single View" mantém
   seu número original em cada tela.
5. DrillHole e DrillBox não foram tocados — a guia KoreGeo3 desses 2 níveis (via
   `DrillHoleView`/`drill-hole-view-koregeo3`, anterior a GT-0026) permanece intacta.

### Validação
- `ng test --include='**/entity-guides/**/*.spec.ts'`: **11/11 SUCCESS** (era 18/18 antes —
  a diferença são os specs de `Koregeo3AggregatorComponent`, removido junto com o
  componente; `entity-guide.model.spec.ts` e `descendant-drill-holes-loader.service.spec.ts`
  continuam passando). Na primeira tentativa a suíte falhou por completo com `TS7016`
  (module resolution de `html2canvas`/`maplibre-gl`) — investigado e confirmado como
  flakiness transitória do builder Karma sob concorrência pesada (~30 worktrees paralelos
  no ambiente), não uma regressão real: `npx tsc -p tsconfig.spec.json --noEmit` deu 0
  erros, `ng build` compilou os mesmos arquivos sem problema, e uma segunda execução do
  mesmo comando (`ng test --include=...`) passou limpo.
- `npx tsc -p tsconfig.spec.json --noEmit`: 0 erros.
- `ng build --configuration development`: exit 0. Únicos warnings são os 3 já
  pré-existentes (`NG8107` em `login2`, `drill-hole-view-mult`, `drillholes-view-3d` — não
  tocados por este PR), idênticos aos já documentados na validação original do PR #369.
- `ng test` (suíte completa): continua quebrada, por 2 causas pré-existentes e **não
  relacionadas a esta reversão** (confirmado via `git log` nos arquivos envolvidos — última
  alteração vem de GT-0010/GT-0015/GT-0017/GT-0018/GT-0019, todas já mescladas antes desta
  task):
  - `region-view.component.spec.ts`, `deposit-view.component.spec.ts`,
    `mine-view.component.spec.ts`, `mine-area-view.component.spec.ts` — os 4 specs dos
    próprios componentes agregadores usam o padrão antigo de scaffold do Angular CLI
    (`declarations: [X]` em vez de `imports: [X]` para componente `standalone`), mesmo
    padrão de falha pré-existente já documentado por GT-0004/GT-0026 original. Nenhum dos
    4 arquivos foi tocado por esta reversão (não fazem parte do diff).
  - Suíte completa aborta em "Executed 137 of 137" com
    `ReferenceError: Cannot access 'DrillHoleViewDeviationsComponent' before initialization`
    — ciclo de módulos pré-existente entre `drill-hole-view.component.ts` e um filho de
    aba, já registrado como risco conhecido no Handoff do PR #369 original ("ciclo de
    módulos pré-existente entre cada `-view.component.ts` e seus filhos de aba"). Não
    introduzido por esta reversão.
- PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/382 (branch
  `fix/gt-0026-revert-koregeo3-desde-region`, a partir de
  `feature/visualizadores-navegacao-layout`).
- **Conflito de merge real (não o antecipado com GT-0002/GT-0004) resolvido por rebase**:
  entre a abertura do PR e a validação final, o PR #379 (GT-0004, mesclado no mesmo dia)
  reordenou as guias e renomeou labels nos mesmos 4 templates agregadores e em
  `entity-guide.model.ts` (`KoreGeo3` → label `"Core View"`, `Images` → label `"Box View"`;
  ordem `Single View -> MultiView -> Core View -> Box View`). A própria mensagem de commit
  do #379 já previa este conflito ("a reversão que restringe [KoreGeo3] a DrillHole/DrillBox
  é um GT-0026 novo, ainda não despachado"). GT-0002/GT-0004 (antecipados originalmente)
  não geraram conflito real — quem gerou foi essa reordenação/renomeação já mesclada do
  próprio #379. Branch rebaseada sobre o `feature/visualizadores-navegacao-layout` atual
  (inclui #378, #379, #380, #381); conflitos resolvidos mantendo a reordenação/renomeação
  de #379 intacta e removendo apenas o bloco (agora rotulado "Core View") desta reversão,
  aplicando a restrição de `levels`/`aggregatorStrategy` sobre a versão já renomeada de
  `entity-guide.model.ts`. `mergeStateStatus: CLEAN` / `mergeable: MERGEABLE` confirmado via
  `gh pr view` após o rebase; `ng test --include='**/entity-guides/**/*.spec.ts'` (11/11),
  `tsc --noEmit` (0 erros) e `ng build --configuration development` (exit 0) reconfirmados
  no estado rebaseado.

### Divergências
Nenhuma do escopo combinado. Observação: a matriz de disponibilidade final (após esta
reversão) tem `koreGeo3.aggregatorStrategy = 'notApplicable'` (não `'requireSelection'`
com `levels` vazio de agregadores) — mais consistente com o padrão já usado por `images`
(também restrito a DrillHole/DrillBox) do que manter `'requireSelection'` sem nenhum nível
agregador em `levels` para acioná-lo. `getAggregatorStrategy()` já retornava
`'notApplicable'` de qualquer forma nesse caso (guarda em `!guide.levels.includes(level)`),
então o comportamento observável não muda — é só a fonte de verdade ficando mais clara.

### Pendências
- Os 4 specs `*-view.component.spec.ts` (Region/Deposit/Mine/MineArea) com o padrão antigo
  de scaffold (`declarations:`) permanecem quebrados — pré-existente, não é desta task,
  mas seria um bom próximo alvo para quem retomar o trabalho de TestBed.declarations
  (mesma frente de PR #356, que já corrigiu 161 specs mas aparentemente não cobriu estes
  4 arquivos).
- Ciclo de módulos pré-existente (`drill-hole-view.component.ts` ×
  `DrillHoleViewDeviationsComponent`) que aborta a suíte completa permanece em aberto —
  já era uma pendência conhecida do PR #369 original, não desta reversão.

## Handoff final
PR #382 **mesclado (squash)** em `feature/visualizadores-navegacao-layout`, já rebaseado sobre a
ponta atual dessa branch (inclui #378-#381), sem conflito de merge. Com este merge, todas as
correções da rodada de QA pós-implementação (2026-09-03) que já tinham decisão confirmada estão
mescladas — só faltam GT-0028 (fast-follow de invalidação de cache, em execução) e a
investigação de GT-0031 (deslocamento no duplo clique, ainda a despachar).
