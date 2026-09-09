---
id: GT-0011
title: "Disponibilizar Images em DrillHole e DrillBox"
status: completed
type: feature
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "N/A — feature"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/328"
grupo_execucao: "Onda 3"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-02
affected_modules: [images-viewer, navegacao]
related_adrs: [GADR-0001]
---

# GT-0011 — Images em DrillHole e DrillBox

## Contexto
Images deve aparecer nas páginas de DrillHole e DrillBox, seguindo a matriz de GT-0004.

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/328. Em DrillHole, abre com a primeira caixa do furo selecionada; em DrillBox, com a própria caixa.

## Objetivo
Guia visível e funcional nas duas entidades, contexto correto pré-selecionado.

## Fora de escopo
N/A.

## Comportamento atual
Images só acessível de um jeito específico, não integrada à matriz de guias.

## Comportamento esperado
Disponível em DrillHole (primeira caixa) e DrillBox (a própria caixa), breadcrumb refletindo o nível de origem.

## Regras de negócio
- RN-01: N/A.

## Critérios de aceitação
- [x] CA-01: Guia visível e funcional nas duas entidades.
- [x] CA-02: Contexto correto pré-selecionado em cada caso.
- [x] CA-03: Breadcrumb (GT-0002) reflete o nível de origem.

## Impacto técnico
### Frontend
Integração com a config de GT-0004.
### Backend / Banco de dados / Integrações / Segurança
N/A.

## Plano de implementação
- [x] Consumir config de GT-0004.
- [x] Implementar pré-seleção de contexto por entidade.

## Estratégia de testes
- [x] Manual — abrir Images a partir de DrillHole e DrillBox.

## Riscos e rollback
Nenhum.

## Registro de execução
### Alterações realizadas
Images já era funcional em DrillHole e DrillBox **antes** desta task — comportamento
pré-existente no repositório, não introduzido por GT-0011: `DrillHoleViewImagesComponent`
já abria com a primeira caixa do furo selecionada (`getDrillBoxes()` →
`drillBoxView(drillBoxes[0].id)`) e `DrillBoxViewComponent` já abria a guia de imagem da
própria caixa (via `drillBoxId` em sessionStorage). O breadcrumb (GT-0002, já mesclado)
também já refletia corretamente o nível de origem em ambas as telas
(`buildDrillHoleBreadcrumb`/`buildDrillBoxBreadcrumb`).

O que faltava — e é o que esta task entrega — é a integração formal com a matriz única
de disponibilidade de GT-0004/GADR-0001: antes as duas guias apareciam hardcoded no
template, sem checar a config compartilhada.
- `DrillHoleViewComponent.imagesGuideAvailable = isGuideAvailable('images', 'drillHole')`
  — a aba "Images" no template só renderiza (`*ngIf`) quando a matriz permite.
- `DrillBoxViewComponent.imagesGuideAvailable = isGuideAvailable('images', 'drillBox')`
  — a aba "Box Image" só renderiza quando a matriz permite.
- Hoje ambos resolvem sempre `true` (Images está na matriz para os dois níveis), mas a
  fonte da verdade passa a ser `entity-guide.model.ts`: se a matriz mudar no futuro,
  essas duas telas acompanham automaticamente, sem exigir outro PR.

### Arquivos principais
- `web/src/app/pages/geodata/drill-holes/drill-hole-view/drill-hole-view.component.ts`
  e `.html` — flag `imagesGuideAvailable` + `*ngIf` na aba Images.
- `web/src/app/pages/geodata/drill-boxes/drill-box-view/drill-box-view.component.ts`
  e `.html` — flag `imagesGuideAvailable` + `*ngIf` na aba Box Image.
- `web/src/app/pages/geodata/drill-holes/drill-hole-view/drill-hole-view.component.spec.ts`
  e `web/src/app/pages/geodata/drill-boxes/drill-box-view/drill-box-view.component.spec.ts`
  — reescritos (eram scaffolds quebrados pré-existentes com `declarations:` para
  componente standalone); agora usam `imports:` + `HttpClientTestingModule` +
  `RouterTestingModule` (breadcrumb usa `routerLink`) e cobrem o novo flag e a
  renderização condicional da aba. O spec de `DrillBoxViewComponent` também estuba
  `DrillBoxViewImagesComponent` (viewer pesado de OpenSeadragon com ~10 chamadas HTTP
  próprias, é a aba padrão dessa tela) via `TestBed.overrideComponent(...remove/add)`,
  para isolar o teste na lógica do próprio `DrillBoxViewComponent`.

### Decisões
- Não recriei a regra de disponibilidade — importei `isGuideAvailable` de
  `entity-guide.model.ts` (GT-0004) nos dois componentes-host, em vez de um novo
  flag/config local.
- Não toquei em `DrillHoleViewImages2Component` ("Images 2"), uma aba duplicada/legada
  não coberta pela matriz de GT-0004 nem mencionada na issue #328 — fora de escopo,
  registrado como observação, não como pendência bloqueante.
- Não alterei o comportamento de pré-seleção em si (já correto antes desta task) nem o
  breadcrumb (GT-0002, já correto) — apenas a visibilidade da aba passou a consumir a
  config compartilhada.
- Corrigi os 2 specs diretamente tocados (scaffold quebrado → `imports`), mas não os
  demais specs quebrados do mesmo padrão pré-existente no repo (fora de escopo; ver
  GT-0004 "Registro de execução" sobre as ~176 falhas pré-existentes).
- Cheguei a ajustar temporariamente `web/karma.conf.js` (timeouts de
  disconnect/no-activity) para contornar um `ChromeHeadless` desconectando por lentidão
  do sandbox de execução; revertido antes do PR por ser infraestrutura de teste
  compartilhada, fora do escopo desta task — não é necessário no ambiente normal de
  desenvolvimento/CI.

### Divergências
Nenhuma divergência da issue #328 — CA-01/CA-02/CA-03 já estavam de fato satisfeitos
por trabalho anterior (Images pré-existente + GT-0002 mesclado); esta task fechou a
lacuna de integração com a config de GT-0004 explicitada no "Impacto técnico" da issue.

### Pendências
- `DrillHoleViewImages2Component` ("Images 2", aba duplicada/experimental) não está
  coberto pela matriz de GT-0004 e não foi tocado — se for legado a remover ou uma
  segunda guia a formalizar, é decisão de produto fora do escopo desta task.
- Achado colateral (não introduzido por este PR, não corrigido aqui): a suíte completa
  de `ng test` do projeto é interrompida por um `ReferenceError: Cannot access
  'DepositViewDrillBoxesComponent' before initialization` (dependência circular entre
  `DepositViewComponent` e `DepositViewDrillBoxesComponent`, disparado em `afterAll` do
  bundle de teste), que trunca a descoberta de specs bem antes de alcançar os arquivos
  deste PR. Nenhum arquivo de Deposit foi tocado aqui — recomendo abrir uma issue
  própria para investigar e quebrar esse ciclo de import.

## Validação
- `ng test` (escopo `drill-hole-view.component.spec.ts` +
  `drill-box-view.component.spec.ts` + `shared/entity-guides/**/*.spec.ts`):
  **17/17 sucesso** (3 iterações até estabilizar: precisou de `RouterTestingModule`
  para o `routerLink` do breadcrumb, `NoopAnimationsModule` para o `AccordionModule`
  usado na aba Overview de DrillHole, e um stub de `DrillBoxViewImagesComponent` para
  isolar `DrillBoxViewComponent` do viewer pesado que é sua aba padrão).
- `npx tsc --noEmit -p tsconfig.spec.json` (projeto inteiro): sem erros.
- `ng test` (suíte completa do projeto): interrompida antes de alcançar os arquivos
  deste PR por um bug de dependência circular pré-existente e não relacionado (ver
  "Pendências"); dos 124 specs alcançados antes da interrupção, 81 falharam no mesmo
  padrão de scaffold quebrado já documentado em GT-0004 (`declarations:` para
  componente standalone) — nenhuma falha nova relacionada a este PR.
- `ng build --configuration production`: sucesso (121.7s). Únicos warnings são
  pré-existentes (dependências CommonJS de terceiros — geotiff, openseadragon,
  html2canvas, canvg, jspdf, apexcharts — e 3 avisos NG8107 de optional chaining em
  arquivos não tocados por este PR: `login2`, `drill-hole-view-mult`,
  `drillholes-view-3d`).
- PR aberto: https://github.com/Essencis-Labs/GeoCloudAI/pull/368 (branch
  `feature/gt-0011-e2-07-images-drillhole-drillbox`, a partir de
  `feature/visualizadores-navegacao-layout`, sem merge).

## Handoff
Dependia de GT-0004 (já mesclado na branch de integração). Nenhuma outra task depende
de GT-0011. Achado colateral do ciclo de import `DepositView*` registrado acima como
pendência não bloqueante, recomendado como issue própria de investigação.
