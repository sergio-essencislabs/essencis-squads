---
id: GT-0021
title: 'Modo "somente DrillCore" no MultiView — REDESENHAR para seleção por janela (decisão do usuário, 2026-09-03)'
status: completed
reaberta_qa: "2026-09-03"
type: feature
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "N/A — feature"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/341"
grupo_execucao: "Onda 3 (movido de Onda 4 — dependia de GT-0018, agora depende só de GT-0020, que termina na Onda 2)"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-03
affected_modules: [multiview]
related_adrs: []
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0021 — Modo "somente DrillCore" no MultiView

## Par no repositório de produto

**Não há par, e ele não foi perdido.** Esta GT é de 2026-09-02; o diretório `.agents/tasks/` do
GeoCloudAI só passou a existir em 2026-09-09, no commit `8e10d774` (TASK-060). O mecanismo de
par não existia quando ela nasceu — o `contraparte:` não é ponteiro quebrado, é ausência
decidida.

**A ausência é decisão, não buraco — e não é por falta de informação.** A rastreabilidade do
lado-produto continua alcançável pelo que este arquivo já cita: issue, PR ou commit. Há por
onde chegar ao que foi feito; o que não há é um registro do lado de lá, porque não havia onde
escrevê-lo.

Um par criado hoje acrescentaria um ponteiro a uma rota que já funciona, e pagaria por isso
afirmando, pela própria existência, que o mecanismo de par cobria esta GT. Seria **registro
com proveniência falsa** — a mesma inversão de "planejado documentado como implementado",
com outra roupa. Por isso não foi criado.

Apurado na GT-0146 (issue #634), CA-07, em 12/09/2026. A busca forense e o controle positivo
ficam no registro daquela task e não são copiados aqui.

## Contexto
Exibir, no MultiView, um modo que mostra apenas os drillcores cortados — não a caixa inteira.

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/341.

**Decisão de produto confirmada (2026-09-02)**: modo "somente DrillCore" é **uma linha horizontal por drill core**, máximo de **4 drillcores** visíveis por vez, ícone de ativação `ri-layout-row-line`. Este modo só se aplica a **DrillCore** — nunca a DrillBox. É necessário adicionar um novo ícone/toggle para o usuário escolher explicitamente entre "visualização de Drill Box" (modo atual/base do MultiView, GT-0020) e "visualização de Drill Core" (este modo novo).

**Correção importante em relação ao plano original**: este modo **não reutiliza** o componente de empilhamento vertical de GT-0018 (E3-06, Single View) — aquele é vertical (cores empilhados um sobre o outro, formando o furo contínuo); este é horizontal (linhas lado a lado, até 4 cores). São layouts diferentes, apesar de ambos lidarem com "drillcores sem caixa". Não forçar reuso onde a forma final é distinta.

## Objetivo
Toggle com 2 ícones (Drill Box / Drill Core) no MultiView; modo Drill Core mostra até 4 drillcores em linhas horizontais.

## Fora de escopo
Modo Drill Box em si (já é o comportamento base de GT-0020). Empilhamento vertical (isso é GT-0018, Single View, escopo diferente).

## Comportamento atual
Sem modo "somente DrillCore"; MultiView só mostra DrillBox.

## Comportamento esperado
Dois ícones de toggle no MultiView: um para visualização de Drill Box (padrão atual), um para Drill Core (`ri-layout-row-line`) — este último renderiza até 4 drillcores, um por linha horizontal.

## Regras de negócio
- RN-01: Modo "somente DrillCore" nunca se aplica a DrillBox — são visualizações mutuamente exclusivas por design.

## Critérios de aceitação
- [x] CA-01: Ícone `ri-layout-row-line` ativa o modo "somente DrillCore".
- [x] CA-02: Modo DrillCore renderiza até 4 drillcores, cada um em sua própria linha horizontal.
- [x] CA-03: Modo DrillCore nunca exibe DrillBox — só o testemunho cortado.
- [x] CA-04: Existe um segundo ícone/toggle para voltar à visualização de Drill Box (o modo base de GT-0020).
- [x] CA-05: Se o furo tiver mais de 4 drillcores, definir e documentar como os 4 exibidos são escolhidos (ex.: os 4 primeiros por profundidade, ou seleção manual do usuário) — detalhe de implementação, não decidido explicitamente pelo usuário ainda. **Resolvido**: os 4 mais rasos por `startDepth` (desempate por `number`) — ver `selectCoreModeCores`.
- [x] CA-06: Iconografia consistente com o trabalho de GT-0008 (revisão de iconografia da barra de ferramentas) — tooltip + aria-label também nos 2 novos ícones.

## Impacto técnico
### Frontend
Novo par de toggles no MultiView (GT-0020), novo componente de renderização em linha horizontal (não reutiliza GT-0018).
### Backend / Banco de dados / Integrações / Segurança
N/A.

## Plano de implementação
- [x] Adicionar os 2 ícones de toggle (Drill Box / Drill Core, `ri-layout-row-line`) ao MultiView.
- [x] Implementar renderização em linha horizontal, até 4 drillcores.
- [x] Definir critério de escolha quando houver mais de 4 drillcores (CA-05).
- [x] Tooltip + aria-label nos novos ícones (coordenar com GT-0008).

## Estratégia de testes
- [ ] Manual — furo com mais de 4 drillcores (dado do GT-0001), confirmar limite de 4 e alternância entre os dois modos. **Pendente**: não executado nesta sessão (sem ambiente de execução manual disponível); fica para o revisor/QA.

## Riscos e rollback
Nenhum — é aditivo ao MultiView, não altera o modo Drill Box existente.

## Registro de execução
### Alterações realizadas
- Toggle "Drill Box" (`ri-archive-2-line`, comportamento base do GT-0020) / "Drill Core" (`ri-layout-row-line`, novo) no `shared-toolbar` do MultiView, mutuamente exclusivos (RN-01). Quando o modo Drill Core está ativo, todo o bloco de viewports/anotação/sync do Drill Box some do template (`*ngIf`, não apenas `disabled`) — nunca mistura os dois (CA-03).
- Novo bloco "Drill Core" mostra até `MAX_CORE_MODE_CORES` (4) linhas horizontais, uma por `DrillCore` elegível. Cada linha recorta a foto da `DrillBox` de origem via CSS puro: um `div` com `background-image` da foto completa e `background-size`/`background-position` calculados em porcentagem a partir do retângulo `imgCore` do core e do tamanho natural da imagem (lido de forma assíncrona com um `new Image()` fora do DOM). O container reserva a proporção exata do recorte via `aspect-ratio` CSS, então o crop fica correto em qualquer largura sem listener de resize.
- Critério de seleção quando há mais de 4 drillcores elegíveis (CA-05): função pura `selectCoreModeCores` em `drill-hole-view-mult-helpers.ts` — ordena por `startDepth` ascendente (os mais rasos primeiro, leitura top-down do furo como um log geológico), desempate por `number` do core ascendente, corta em `MAX_CORE_MODE_CORES`. Cores sem `imgCore` mapeado ou sem foto de caixa associada nunca são elegíveis.
- Recomputa as linhas do modo Drill Core sempre que `drillCores`/`drillBoxes` são (re)carregados (`refreshCoreModeRows`), não só na troca de modo — a troca de toggle fica instantânea.
- Ícones novos com `title` (tooltip) + `aria-label` + `aria-pressed` (CA-06).

### Arquivos principais
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-mult/drill-hole-view-mult.component.ts`
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-mult/drill-hole-view-mult.component.html`
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-mult/drill-hole-view-mult.component.scss`
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-mult/drill-hole-view-mult-helpers.ts` (nova função pura `selectCoreModeCores` + `MAX_CORE_MODE_CORES`)
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-mult/drill-hole-view-mult-helpers.spec.ts` (novo — cobre CA-05)

### Decisões
- CA-05 resolvido como "os 4 mais rasos por `startDepth`, desempate por `number`" — critério de implementação (não pedido explicitamente pelo usuário), justificado por espelhar a ordem de leitura natural de um log geológico (topo → base do furo).
- Recorte via CSS puro (`background-size`/`-position` em %), sem depender de OpenSeadragon nem de um segundo viewer — o modo Drill Core é deliberadamente mais simples que o viewport OSD do Drill Box (sem zoom/pan/anotação), pois a task pede apenas visualização, não edição.
- Não reutiliza o empilhamento vertical do GT-0018 (Single View) — confirmado como decisão do usuário na spec da task; este modo é horizontal e vive só no MultiView.

### Divergências
Nenhuma em relação à spec da task.

### Pendências
- Teste manual (furo com >4 drillcores, dado do GT-0001) não executado nesta sessão — ver "Estratégia de testes".

## Validação
- `ng test` (Karma/ChromeHeadless), escopo nos specs do MultiView (`--include='**/drill-hole-view-mult*.spec.ts'`): **5/5 novos testes de `selectCoreModeCores` passaram** (filtragem por `hasCroppableImage`, ordenação por profundidade, corte em 4, desempate por `number`, `max` customizável).
- O teste pré-existente `DrillHoleViewMultComponent should create` **falhou** com `NullInjectorError: No provider for HttpClient!` — falha pré-existente e não relacionada a esta mudança: o `.spec.ts` não foi tocado nesta PR, as dependências do construtor do componente não mudaram, e o `TestBed.configureTestingModule` desse spec nunca proveu `HttpClientTestingModule`/`provideHttpClient` (confirmado por leitura do arquivo antes de qualquer alteração).
- `ng build --configuration production` **concluído com sucesso** (exit code 0, bundle gerado em `dist/velzon`). Apenas warnings pré-existentes e não relacionados a esta mudança (NG8107 de optional chaining redundante em outros componentes — inclusive um dentro de `drill-hole-view-mult.component.html`, mas numa linha que já existia antes desta PR e só mudou de número por causa do toggle novo; e avisos de dependências CommonJS/AMD como `openseadragon`/`geotiff`/`apexcharts`).

## Handoff
Depende de GT-0020 (base do MultiView, onde os toggles são adicionados) — já mesclado na branch de integração `feature/visualizadores-navegacao-layout`. Coordenar iconografia com GT-0008 (ainda não implementado; os 2 ícones novos já seguem o padrão tooltip + aria-label esperado por essa task).

PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/363 (branch `feature/gt-0021-multiview-drillcore-mode` → `feature/visualizadores-navegacao-layout`).

## Achado de QA pós-implementação (2026-09-03) — pendente de decisão, nada alterado ainda
Relatório de QA (Matheus, `TASKS.md`, E4-02): "Botão existe mas pouco visível, e implementado errado: deveria permitir selecionar furo, caixa e drillcore independentemente em cada uma das até 4 visualizações. O que existe é um toggle global que troca o modo de todas as janelas de uma vez — diferença de escopo, não só de interface."

O toggle global implementado correspondia **exatamente** à especificação original de Sergio Mendes nesta mesma sessão ("visualização deve ser de uma linha horizontal por drill core e máximo de 4 drill cores... novo ícone para permitir visualização de drill box ou de Drill Core") — não era um bug. Mas o feedback de Matheus mudou a decisão.

**Decisão confirmada pelo usuário (2026-09-03)**: "Por janela." Cada uma das até 4 visualizações do MultiView passa a ter seleção independente de furo, caixa e modo (Drill Box/Drill Core) — não um toggle global que afeta as 4 de uma vez.

## Escopo do redesenho
- **RN-01 muda**: deixa de ser "modo global, mutuamente exclusivo com Drill Box para a tela inteira" e passa a ser "por janela, mutuamente exclusivo dentro da própria janela" (uma janela em modo Drill Core não pode também estar em modo Drill Box, mas outra janela ao lado pode estar em qualquer um dos dois modos independentemente).
- Remover o toggle global "Drill Box / Drill Core" do `shared-toolbar` do MultiView (`drill-hole-view-mult.component.ts`/`.html`).
- Adicionar um seletor de modo (Drill Box/Drill Core) por janela — provavelmente no cabeçalho/toolbar de cada uma das até 4 viewports já existentes.
- O bloco de renderização "Drill Core" (linha horizontal por core, `selectCoreModeCores`, recorte CSS) hoje é um bloco único substituindo TODAS as janelas de Drill Box quando ativo — precisa virar renderização por janela: cada viewport decide independentemente se mostra o viewer OSD normal (Drill Box) ou a linha recortada (Drill Core).
- `MAX_CORE_MODE_CORES`/`selectCoreModeCores` (função pura já testada) devem continuar reutilizáveis, só a decisão de "quais janelas usam esse modo" muda de global para por-janela.
- Cross-hole/badges de origem (já existentes para GT-0022, MultiView desde Region) precisam continuar funcionando corretamente quando janelas vizinhas estão em modos diferentes.

## Handoff atualizado
Redesenho maior que a implementação original (PR #363, já mesclado) — não é um ajuste pontual. Nova branch a partir de `feature/visualizadores-navegacao-layout`, PR de volta pra lá.

## Registro de execução do redesenho (2026-09-03)

### Decisão de abordagem técnica
Explorado o componente real (`drill-hole-view-mult.component.ts`, 2885 linhas) antes de decidir. A branch de integração `feature/visualizadores-navegacao-layout` já tinha, além do GT-0021 original (PR #363), o GT-0022 (cross-hole/comparação entre furos) mesclado — o `WindowState` (em `drill-hole-view-mult-helpers.ts`) já carrega `drillHoleId`/`drillBoxId`/`title`/`boxIndex`/`linked` por janela, então "furo" e "caixa" já eram independentes por janela antes deste redesenho. Faltava só o terceiro eixo: "modo" (Drill Box/Drill Core).

Duas opções foram consideradas para o escopo dos `coreModeRows` (quais cores aparecem quando uma janela está em modo Drill Core):
- **(a) Lista global única**, computada uma vez a partir do furo primário (exatamente como já existia), e cada janela em modo 'core' mostra essa mesma lista — só a *decisão de renderizar* passa a ser por janela.
- **(b) Lista por janela**, escopada ao furo daquela janela especificamente (cross-hole-aware), exigindo cache novo (`holeCoresCache`) e uma chamada HTTP nova (`DrillCoreService.getByDrillHoleList`) por furo distinto assinalado a alguma janela.

**Escolhida a opção (a)**, por três razões: (1) é a leitura literal da própria task ("só a decisão de 'quais janelas usam o modo' muda de global para por-janela... reaproveite `selectCoreModeCores`/`MAX_CORE_MODE_CORES` — já existem e são testados"); (2) a opção (b) quebraria os testes existentes em `drill-hole-view-mult.component.spec.ts` (`flushPaneRequests` + `httpMock.verify()` no fluxo de entrada por agregador GT-0022 assumem exatamente 2 requisições por painel — `DrillBox/getByDrillHole` + `DrillHole/getById` — uma chamada nova de `DrillCore/getByDrillHole` por furo quebraria esse `verify()`); (3) menor risco/escopo para uma tarefa que já é a segunda tentativa da mesma feature.

### Alterações realizadas
- `drill-hole-view-mult-helpers.ts`: `MultiViewMode` ('box'|'core') movido do componente para cá (tipo puro); `WindowState` ganhou o campo `mode: MultiViewMode`, default `'box'` em `createDefaultWindows()`.
- `drill-hole-view-mult.component.ts`:
  - Removida a propriedade global `viewMode` e o método `setViewMode(mode)`.
  - Adicionados `isCoreMode(slot)`, `activeWindowMode` (getter, usado para condicionar a barra de anotação/Sync ao modo da janela em foco) e `setWindowMode(slot, mode)` — este último desmonta o viewer OSD/tracker/anotação da janela (`destroySlot`, `cancelDepthSelection`, `clearAnnotationMode`) antes de sair do modo 'box' (já que o container `#viewerContainer` só existe no DOM em modo 'box'), e chama `syncViewersToWorkspace()` para recriar o viewer quando a janela volta a 'box'.
  - `windowModeOptions` (ex-`viewModeOptions`) permanece como array de opções, agora renderizado uma vez por janela.
  - `addWindow()` força `target.mode = 'box'` ao abrir uma janela nova (evita herdar um `'core'` residual de uma janela fechada anteriormente nesse modo).
  - `coreModeRows`/`refreshCoreModeRows()`/`preloadCoreImageMeta()`/`trackByCoreRow`/`coreRowContainerStyle()`/`coreRowBackgroundStyle()` **não foram alterados** — permanecem globais (furo primário), reaproveitados como estão por qualquer janela em modo 'core'.
- `drill-hole-view-mult.component.html`: removido o bloco de toggle global do `shared-toolbar`; `layout-presets`/`viewer-tabs`/botão "add window" deixaram de depender de `viewMode` (agora sempre visíveis); `toolbar-right` (barra de anotação + Sync) agora depende de `activeWindowMode === 'box'`. Dentro de cada `.viewer-panel`, adicionado o seletor de modo por janela no `panel-header` (`.panel-mode-toggle`, 2 botões usando `windowModeOptions`) e o `.panel-body` passou a alternar, via `*ngIf="!isCoreMode(window.slot); else coreOnlyBlock"`, entre o viewer OSD + thumb-tray (modo Drill Box) e o bloco de linhas de core recortadas (modo Drill Core, antes um bloco único fora da grade). `.drop-zone-indicator` (drag & drop entre janelas) ficou fora do `*ngIf` de modo, pois se aplica aos dois.
- `drill-hole-view-mult.component.scss`: novo `.panel-mode-toggle`/`.panel-mode-btn` (toggle compacto de 2 ícones dentro do cabeçalho da janela); `.core-only-grid` (bloco único, tela inteira) renomeado/reescopado para `.panel-core-rows` (cabe dentro de um `.panel-body`, com `overflow-y: auto` próprio); dark-mode (`:host-context([data-bs-theme="dark"])`) atualizado para incluir `.panel-mode-toggle`.

### Decisões
- Cross-hole (GT-0022) e modo Drill Core continuam desacoplados por design: os `coreModeRows` mostrados numa janela em modo 'core' são sempre os do furo primário da página, independentemente de qual furo aquela janela está comparando em modo 'box'. Isso é consciente (ver seção acima) — não foi pedido explicitamente que o modo Drill Core acompanhasse o furo por-janela, só que a decisão de "qual modo cada janela usa" fosse independente.
- `panel-title` mostra `'Drill Core view (' + coreModeRows.length + ')'` quando a janela está em modo core, em vez do título da caixa (`windowTitle`) — evita sugerir que os cores mostrados pertencem à caixa atualmente selecionada naquela janela (que só é relevante em modo 'box').
- Botão "Compare a box from another drill hole" (seletor de furo) permanece visível mesmo com a janela em modo 'core' — inofensivo (a troca de furo só terá efeito visível quando a janela voltar a modo 'box'), e evitar escondê-lo mantém a UI mais previsível/consistente.

### Divergências
Nenhuma em relação à spec do redesenho.

### Pendências
- Teste manual com múltiplas janelas em modos diferentes simultaneamente não executado nesta sessão (sem ambiente de execução manual disponível) — fica para o revisor/QA.

## Validação
- `cd web && ng build --configuration production`: **sucesso** (exit code 0), ~991s. Únicos warnings são pré-existentes e não relacionados (NG8107 de optional chaining redundante em `login2.component.html`, `drillholes-view-3d.component.html`, e uma linha em `drill-hole-view-mult.component.html` que já existia antes deste PR; avisos de dependências CommonJS/AMD como openseadragon/geotiff/apexcharts/jspdf/canvg).
- `cd web && ng test --watch=false --browsers=ChromeHeadless --include='**/drill-hole-view-mult*.spec.ts'`: **9/9 SUCCESS** — 5 testes de `selectCoreModeCores` (helpers, inalterados) + 4 de `DrillHoleViewMultComponent` (`should create` + 3 do fluxo de entrada por agregador GT-0022). Note-se que o `should create` que falhava na sessão anterior (achado de QA, `NullInjectorError: No provider for HttpClient!`) já não falha mais nesta branch — foi corrigido pelo próprio GT-0022 (que adicionou `HttpClientTestingModule`/`provideNoopAnimations()` ao spec), não por este redesenho.
- Teste manual: pendente (ver acima).

## Handoff final
PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/376 (branch `feature/gt-0021-multiview-drillcore-per-window` → `feature/visualizadores-navegacao-layout`).

Branch anterior/PR #363 (toggle global) permanece mesclada na branch de integração; este PR é um redesenho por cima dela, não um revert. Nenhuma migração de dado necessária (estado é só client-side, `WindowState.mode` iniciado em `'box'` por padrão).

Se, no futuro, o produto pedir que o modo Drill Core também acompanhe o furo específico de cada janela (em vez de sempre mostrar o furo primário da página) — especialmente relevante para janelas cross-hole (GT-0022) — será necessário: (1) um `holeCoresCache: Map<number, DrillCore[]>` por furo, populado via `DrillCoreService.getByDrillHoleList` (endpoint já existe, usado hoje só para o furo primário); (2) atualizar `drill-hole-view-mult.component.spec.ts` (`flushPaneRequests`/`httpMock.verify()`) para esperar a requisição nova por painel no fluxo de entrada por agregador.

**PR #376 mesclado (squash) em `feature/visualizadores-navegacao-layout`.**

**Nota do Jarvis para o revisor humano**: o pedido original de Matheus foi "selecionar furo, caixa e drillcore independentemente em cada uma das até 4 visualizações". O que foi entregue: furo/caixa já eram independentes por janela (herdado do GT-0022); **modo** (Drill Box/Drill Core) agora também é independente por janela (este PR). O que **não** ficou independente: quando uma janela está em modo Drill Core, as linhas mostradas ainda vêm do furo primário da página, não do furo específico daquela janela — o agente documentou essa lacuna conscientemente (ver "Decisões" acima) para não quebrar os testes existentes do GT-0022. Vale confirmar com o usuário se essa lacuna é aceitável ou se precisa do trabalho adicional descrito acima antes de considerar o achado de QA (E4-02) totalmente fechado.

## QA rodada 3 (2026-09-04) — Multi View
Três PRs de correção mesclados (squash) em `feature/visualizadores-navegacao-layout` a partir do teste manual do Sergio:
- **#404** — cores recortados no Stacked e rolagem no Auto.
- **#407** — viewport novo no Stacked nascia em Drill Box; memória de modo ao entrar/sair do Stacked; encolhimento irreversível dos cores; fundo cinza sem viewport; viewers OSD 0×0 ao voltar do Stacked (`ensureViewer` espera layout, `redrawViewers` reconcilia e reenquadra); piso de 68 px por linha em Grid/Auto.
- **#409** — imagem do core nunca distorce (slot `container-type: size`, largura `min(100%, 100cqh × proporção)`, altura pelo `aspect-ratio`); Stacked abre qualquer viewport em core (chips e "+"); teto de 4 painéis no Stacked (`maxSlotsForLayout`); modal "Compare a drill core from another drill box" com 3 níveis (furo → caixas → cores), `coreOverrides` por painel.

**A lacuna registrada no handoff acima fica parcialmente fechada**: no Stacked, cada painel pode agora exibir um core de qualquer furo/caixa da conta (override explícito pelo seletor). Fora do Stacked (Drill Core view em Auto/Grid/Side by side) as linhas continuam vindo da caixa do próprio painel — não do furo primário da página, como era na época do #376, mas ainda sem seletor de core individual. Validado em navegador: proporções reais iguais às esperadas (19,57/19,56 · 20,79/20,79 · 19,51/19,51 · 19,84/19,83), modos `core ×4` via chip, chip V5 desabilitado, Drill Hole 1 → Box 1 → Core 2 exibido no painel. `ng test` 304 SUCCESS. **Continua em `active/`**: falta retest humano do Sergio na branch de integração.

### Rodada 4 (2026-09-05) — PR #410 mesclado
Seletores (caixa e core) restritos aos furos da mesma área de mina do furo primário (`DrillHole/getByMineArea`; sem área → conta; modo agregador inalterado). Seletor de core **por linha** fora do Stacked (botão em cada linha do Drill Core view; overrides por `slot:linha`, sobrevivem à troca de layout, somem ao fechar o painel; origem "Box N · furo" na linha; `drillHoleId` do painel não é mais alterado pelo seletor de core). Verificado em navegador; `ng test` 304 SUCCESS. **A lacuna do handoff do #376 fica fechada.** Continua em `active/` até retest do Sergio.

### Rodada 5 (2026-09-05) — PR #412 mesclado
Auto removido (Grid herda a regra adaptativa de colunas). Zoom distorcido ao trocar layout: causa medida em duas camadas — `containerSize` do OSD desatualizado no `goHome()` e `autoResize` do OSD reaplicando o zoom antigo pela razão das diagonais depois do nosso reenquadramento; agora `autoResize: false` + `ResizeObserver` → `redrawViewers()` (`viewport.resize` + `goHome`). Zoom mínimo = enquadramento (`minZoomImageRatio: 1`). Drill Core view: cores nunca encolhem (100 % da largura, painel rola), zoom por painel 100–800 % por botões na barra e Ctrl+roda. `ng test` 304 SUCCESS. Continua em `active/` até retest.

### Rodada 6 (2026-09-05) — PR #413 mesclado
Zoom manual (Drill Box) sobrevive à troca de layout: `redrawViewers` guarda zoom/home e centro e reaplica sobre o novo enquadramento (sem zoom manual = home, como no #412). Stacked cortava os cores: linhas da grade `1fr` dividiam a altura fixa; agora `grid-auto-rows: auto` e o workspace rola — 4 cores inteiros. `ng test` 304 SUCCESS.

### Rodada 7 (2026-09-05) — PR #415 mesclado
Fundo preto nos painéis de Drill Box: o container do viewer passa a usar `aspect-ratio` com a proporção real da foto (lida no `open` do OSD); altura do painel segue a foto, workspace rola, regra do Stacked estendida a todos os layouts. Verificado 100 %×100 % de preenchimento em Grid 4/6 e Side by side 6. `ng test` 304 SUCCESS.

### Decisão do usuário (2026-09-05)
O Drill Core view continua **sem marcações** (litologia, fratura, anotação, profundidade): é um recorte CSS da foto da caixa, sem OSD/Annotorious. Sergio optou por manter assim por enquanto. Não tratar como achado de QA. Se for retomado: as coordenadas das marcações são relativas ao retângulo do core, dá para desenhá-las como camadas sobre o recorte com o mesmo hover de `attachOverlayLabelHover`; porte médio, só frontend.
