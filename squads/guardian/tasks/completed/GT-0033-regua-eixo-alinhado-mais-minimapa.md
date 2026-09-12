---
id: GT-0033
title: "Régua do Single View: eixo de profundidade alinhado às caixas + minimapa do furo (substitui o minimapa isolado do GT-0015)"
status: active
type: feature
achado_origem: "QA-Sergio-2026-09-03: 'Em Mine Area régua' + 'A régua precisa acompanhar a caixa'"
auditor_origem: "Sergio Mendes (teste manual) — investigado por Jarvis"
severidade: "Média-Alta — a escala mais visível da tela não corresponde ao que está sendo exibido"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-jarvis-qa-2026-09-03-rodada-2"
issue_url: ""
grupo_execucao: "Correção pós-QA rodada 2"
owner: ""
created_at: 2026-09-03
updated_at: 2026-09-03
affected_modules: [single-view]
related_adrs: []
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0033 — Régua alinhada às caixas + minimapa

## Par no repositório de produto

**Não há par, e ele não foi perdido.** Esta GT é de 2026-09-03; o diretório `.agents/tasks/` do
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

## Achado original
Sergio (2026-09-03), sobre o Single View aberto a partir de Mine Area: "Em Mine Area régua" e, em seguida, "**A régua precisa acompanhar a caixa**".

## Causa raiz (confirmada por leitura de código, Jarvis)
Hoje existem **duas escalas de profundidade simultâneas** na tela, com comportamentos diferentes:

1. **Marcadores dentro do canvas** — `addDepthMarker(xBase, y, row.startMeters)` (`drill-hole-view-unic.component.ts:1923` e `:2092`), desenhados em coordenadas de mundo do OpenSeadragon, na coluna reservada por `xBase = 0.20`. **Esses acompanham as caixas** (dão zoom/pan junto).
2. **Componente `app-depth-ruler`** (GT-0015) — régua fixa fora do canvas, que mapeia o furo **inteiro** na altura disponível, com uma faixa indicando a janela visível. **Esse não acompanha as caixas.**

Resultado: as duas discordam visualmente (ex.: régua mostrando 0–30 m enquanto o canvas exibe 4–16 m), e a mais proeminente é justamente a que não acompanha o conteúdo.

**Não é bug de implementação do GT-0015** — é conflito de requisito. O CA-01 do GT-0015 pedia explicitamente "furo de 200 m+ tem a régua inteira visível sem scroll", ou seja, comportamento de minimapa. O pedido atual é o oposto.

## Decisão do usuário (2026-09-03)
**"Eixo alinhado + minimapa pequeno"**: a régua principal vira um eixo de profundidade alinhado às caixas (a marca de 8 m fica fisicamente ao lado da caixa de 8 m, acompanhando zoom/pan), **mais** um minimapa estreito do furo inteiro ao lado, com indicador da janela visível — preservando a navegação rápida em furos longos que motivou o GT-0015.

## Objetivo
Uma escala de profundidade confiável, alinhada ao que está sendo exibido, sem perder a navegação por furo longo.

## Critérios de aceitação
- [x] CA-01: A régua principal acompanha as caixas: em qualquer nível de zoom/pan, a marca de profundidade fica alinhada à caixa correspondente.
- [x] CA-02: Densidade das marcas se adapta ao zoom (não fica nem poluída ao afastar, nem vazia ao aproximar).
- [x] CA-03: Minimapa estreito do furo inteiro presente, com faixa indicando a janela visível, e clique nele navega para a profundidade (comportamento útil do GT-0015 preservado).
- [x] CA-04: **Uma única escala percebida** — resolver a duplicidade atual: ou os marcadores in-canvas viram a régua alinhada, ou são removidos em favor dela. Não deixar duas escalas concorrentes na tela.
- [x] CA-05: Vale tanto no Single View aberto de um DrillHole quanto no aberto de nível agregador (Mine Area etc.), com mais de um furo selecionado — definir e documentar o comportamento quando há múltiplos furos lado a lado (cada um com sua própria origem de profundidade; ver "Decisões" do GT-0015).
- [ ] CA-06: Validação visual real em navegador, com furo longo (SEED-DH-10, 320 m) e furo curto. **Não executada nesta sessão** — ver Pendências.

## Fora de escopo
Régua do KoreGeo3/Core View (implementação própria, `ts-rulers`/`ngx-slider-v2`) — avaliar reuso depois, não nesta task.

## Riscos e rollback
`buildHoleLayout`/`depthAtWorldY`/`worldYAtDepth` (GT-0015) são compartilhados com o modo vertical do GT-0018 — qualquer mudança na matemática de mapeamento precisa rodar as suítes de regressão de ambos.

## Registro de execução
### Alterações realizadas
- **Removidos** os marcadores por-linha `addDepthMarker` (um marcador fixo por caixa/core, overlay `Rect` do OpenSeadragon — escalava visualmente com o zoom, texto minúsculo ao afastar e enorme ao aproximar). Chamadas removidas nos dois modos de renderização (`renderViewerLayout` — horizontal/box, e `renderViewerLayoutVertical` — GT-0018/cores empilhados); método antigo removido.
- **Criado o "eixo alinhado"**: `rebuildDepthAxis`/`addDepthAxisTick` (novos métodos privados em `drill-hole-view-unic.component.ts`). Em cada `pan`/`zoom`/`resize` do viewer, recalcula a profundidade visível (`depthAtWorldY` nos limites do viewport), escolhe um passo "redondo" de marcação a partir do intervalo **visível** (reaproveita `niceTickStep`, já exportado por `shared/depth-ruler/depth-ruler.component.ts` — não duplicado) e desenha uma marca por valor redondo, cada uma como overlay do OpenSeadragon **ancorado a um Point** (não a um Rect) com `placement: OpenSeadragon.Placement.RIGHT` — mesma técnica já usada em `drill-hole-view-mult.component.ts` (`addCoreLabel`). Overlay ancorado a Point não escala com o zoom (confirmado lendo `Overlay.prototype._init`/`.adjust` no bundle instalado do OpenSeadragon): só a posição do ancora é recalculada, o tamanho do texto fica sempre legível, e a posição continua correta mesmo com o viewport rotacionado (o toggle de rotação já existente usa `viewport.setRotation`).
- CA-02 resolvido pela própria natureza do algoritmo: como o passo de marcação é escolhido a partir do intervalo **atualmente visível** (não do furo inteiro, e não por número de linhas), o número de marcas na tela fica sempre limitado (~8), tanto com o furo inteiro visível (furo com muitas caixas/cores não amontoa mais uma marca por linha) quanto com um zoom bem próximo (não fica mais vazio que ~1 marca).
- CA-04 resolvido: o eixo alinhado é agora a **única** escala de profundidade desenhada dentro do canvas; o antigo `app-depth-ruler` (GT-0015) foi mantido, mas rebaixado a um papel de **minimapa estreito** (classe renomeada de `.unic-depth-ruler` para `.unic-depth-minimap`; `--depth-ruler-width` reduzido de 64px → 40px via override CSS local), preservando overview do furo inteiro + clique para navegar (`onRulerDepthSelected`, inalterado).
- CA-05: comportamento não mudou em relação ao GT-0015 — eixo e minimapa continuam espelhando apenas o **primeiro furo selecionado** (`rulerRows`/`axisAnchorX` só são atualizados no `holeIdx === 0`), documentado tanto no GT-0015 quanto reforçado nos novos comentários de código; múltiplos furos lado a lado continuam sem uma "profundidade única de tela" (cada painel tem sua própria origem y=0), decisão explicitamente fora do escopo de resolver aqui (mesma decisão pragmática do GT-0015).
- Novo campo `axisAnchorX`: o eixo ancora no `xBase` do primeiro painel (0.20 unidades de mundo, capturado no momento do render), não no `bounds.x` (borda esquerda atual do viewport) — garante que as marcas fiquem coladas à margem reservada da primeira caixa mesmo com pan horizontal, em vez de flutuar sobre a imagem.
- Handler `resize` adicionado ao viewer (além dos já existentes `pan`/`zoom`) — necessário porque os overlays do eixo não escalam com o zoom (ver acima): arrastar o divisor do `as-split` muda o tamanho em pixels do container sem disparar `pan`/`zoom`, o que deixaria os ticks desalinhados até o próximo pan/zoom manual.

### Arquivos principais
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.ts` — toda a lógica (remoção de `addDepthMarker`, novo `rebuildDepthAxis`/`addDepthAxisTick`/`clearDepthAxisOverlays`/`syncDepthOverlays`, campo `axisAnchorX`, handler `resize`).
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.html` — classe do `app-depth-ruler` renomeada para `unic-depth-minimap` + comentário explicando o novo papel.
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.scss` — `.unic-depth-ruler` → `.unic-depth-minimap`, override de `--depth-ruler-width: 40px`.
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.spec.ts` — 4 testes novos contra uma instância real do OpenSeadragon (não mock): densidade de marcas limitada em zoom-out e zoom-in (CA-02), posição de cada marca batendo exatamente com `worldYAtDepth` (CA-01), ausência de marcas duplicadas entre recomputações (CA-04), e nenhuma marca desenhada sem furo selecionado.
- `single-view-metric-layout.ts`/`single-view-metric-layout.spec.ts` — **não alterados** (reutilizadas as funções puras já existentes do GT-0015/GT-0018 sem tocar sua matemática, exatamente o cuidado pedido nos "Riscos e rollback").
- `shared/depth-ruler/depth-ruler.component.ts` — **não alterado**; apenas `niceTickStep` (já exportado) passou a ser importado também pelo Single View.

### Decisões
- Optei por **overlays do OpenSeadragon ancorados a Point** (dentro do próprio canvas) em vez de um novo componente Angular de "eixo" posicionado fora do canvas e sincronizado via `viewport.pixelFromPoint`. Motivo: o viewer já suporta rotação (`viewport.setRotation`, toggle existente na toolbar) — um overlay em coordenada de mundo do próprio OSD herda a correção de rotação de graça; uma camada DOM externa precisaria reimplementar esse cálculo. Também evita um componente novo inteiro quando o padrão Point+placement já existe e é usado em `drill-hole-view-mult.component.ts`.
- Optei por **manter dois componentes visuais** (eixo dentro do canvas + minimapa fora dele) em vez de eliminar o minimapa: CA-03 pede explicitamente a navegação rápida por clique num furo longo, que o eixo alinhado (por natureza, só mostra o que está visível) não pode oferecer sozinho — é exatamente o valor que motivou o GT-0015 originalmente.
- Mantive a nomenclatura dos métodos do GT-0015 (`syncRulerFromViewport`) em vez de renomear/fundir tudo, criando `syncDepthOverlays` como um wrapper fino que chama os dois — reduz o diff e mantém cada peça testável isoladamente.

### Divergências
Nenhuma quanto aos critérios de aceitação (CA-01 a CA-05 implementados e testados; CA-06 pendente por limitação de ambiente, não por decisão de escopo). Nenhuma mudança de contrato de API/backend (100% frontend).

### Pendências
- **CA-06 (validação visual em navegador) não executada nesta sessão** — mesma limitação recorrente das sessões anteriores do GT-0015/GT-0018 (ambiente compartilhado com múltiplos processos `dotnet`/`node` e o mesmo banco MySQL de outras sessões concorrentes; risco de colidir com quem já está validando algo nesse mesmo diretório de trabalho). Validação feita via: (a) build de produção limpo, (b) suítes automatizadas listadas em "Validação" abaixo, incluindo testes novos contra uma instância REAL do OpenSeadragon (não mock) que verificam a posição exata dos ticks e a limitação de densidade.
- Recomendação para quem revisar o PR (ou para a próxima sessão com ambiente livre): `dotnet run --project api/src/Back.API` + `ng serve`, abrir Single View, selecionar SEED-DH-10 (320 m) e um furo curto, e confirmar visualmente: (1) o eixo dentro do canvas mostra só a profundidade visível e acompanha zoom/pan; (2) a faixa estreita à esquerda (minimapa) mostra o furo inteiro e clicar nela pula para a profundidade; (3) não há mais nenhum marcador de profundidade "solto" dentro das colunas de caixas (o antigo `addDepthMarker`); (4) alternar o modo vertical (GT-0018) mantém o eixo coerente.

## Validação
- `ng build --configuration development`: build limpo (mesmos warnings pré-existentes não relacionados — `Login2Component`, `drill-hole-view-mult`, `drillholes-view-3d`).
- `ng build --configuration production`: build limpo (mesmos warnings pré-existentes de dependências CommonJS de terceiros — `apexcharts`, `geotiff`).
- `ng test` (ChromeHeadless):
  - `single-view-metric-layout.spec.ts`: **21/21 verdes** (nenhuma mudança nesse arquivo — confirma que a matemática compartilhada com GT-0018 não regrediu).
  - `drill-hole-view-unic.component.spec.ts`: **17/18 verdes** — a única falha (`should create`, `NullInjectorError: No provider for HttpClient!`) é pré-existente e documentada nos handoffs do GT-0015/GT-0018 (TestBed sem `HttpClientTestingModule` no describe mais antigo do arquivo), não relacionada a este trabalho. Os 4 testes novos do GT-0033 (densidade de marcas em zoom-out/zoom-in, posição exata via `worldYAtDepth`, ausência de duplicatas, nenhuma marca sem furo selecionado) passaram, assim como os testes de regressão do clique da régua (GT-0015) e do clip de imagem (GT-0018) já existentes.
  - `depth-ruler.component.spec.ts`: **6/9 verdes** — as 3 falhas são **pré-existentes e não relacionadas**: confirmado rodando o arquivo isolado sem nenhuma alteração local (`git status` mostra o diretório `shared/depth-ruler/` inteiramente limpo). Causa aparente: timing de `ViewChild({ static: true })` vs. `ngOnChanges` chamado manualmente antes do primeiro `detectChanges()` no helper `setDepth` do próprio spec, incompatível com a versão atual de Angular/Karma/Chrome deste ambiente — não é algo que este PR tenha tocado ou possa corrigir dentro do escopo do GT-0033.
- QA manual no navegador (CA-06): **não executada** — ver Pendências acima.

## Handoff
Revisita o GT-0015 (que continua correto para o requisito original de minimapa/overview — agora só com papel secundário). Coordena com GT-0018: a matemática compartilhada (`buildHoleLayout`/`depthAtWorldY`/`worldYAtDepth`) não foi tocada, e o modo vertical (cores empilhados) usa o mesmo `rebuildDepthAxis`/`axisAnchorX` do modo horizontal sem nenhuma lógica condicional adicional — validado pelos mesmos testes novos (a suíte não distingue os dois modos porque ambos alimentam `rulerRows` da mesma forma).

**Conflito esperado com GT-0035** (estado vazio): ambas as tasks tocam `drill-hole-view-unic.component.*`, mas em regiões diferentes — GT-0033 mexeu em `initializeViewer` (handlers de viewer), no corpo de `renderViewerLayout`/`renderViewerLayoutVertical` (remoção da chamada a `addDepthMarker`, adição de `clearDepthAxisOverlays`), e adicionou métodos novos perto do fim da classe (`syncDepthOverlays`, `rebuildDepthAxis`, `addDepthAxisTick`, `clearDepthAxisOverlays`) — não deve conflitar com lógica de estado vazio, mas um merge por união deve ser revisado com atenção caso GT-0035 também mexa nesses mesmos pontos de entrada do render.

PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/392 (branch `feat/gt-0033-regua-eixo-alinhado-minimapa`, base `feature/visualizadores-navegacao-layout`).

## Merge
PR # mesclado em `feature/visualizadores-navegacao-layout` em 2026-09-03. **Não movido para `completed/`**: falta a validação visual humana (retest do Sergio na branch de integração) — 2 das 3 evidências (código + teste) estão registradas; a terceira (confirmação de comportamento em navegador real) é justamente o que o QA rodada 2 apontou como falho.
