---
id: GT-0013
title: "🐛 Corrigir desalinhamento das marcações em relação às caixas"
status: active
type: feature
achado_origem: "N/A — pedido direto de implementação (bug)"
auditor_origem: "Jarvis — planejamento"
severidade: "Alta — bug mais visível da tela, bloqueia GT-0014/GT-0017/GT-0018"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/330"
grupo_execucao: "Onda 1"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-02
affected_modules: [single-view]
related_adrs: []
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0013 — Bug: desalinhamento das marcações no Single View

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
As marcações renderizam deslocadas em relação às caixas no Single View — é o bug mais visível da tela e compromete a confiança no que é exibido. Bloqueia GT-0014, GT-0017, GT-0018.

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/330. Investigar origem: calibração profundidade→pixel, escala/zoom, offset de container ou dimensões da imagem.

## Objetivo
Marcação sempre coincide com a região correspondente na imagem, em qualquer zoom.

## Fora de escopo
Novos tipos de marcação (GT-0014).

## Comportamento atual
Marcações deslocadas em relação às caixas.

## Comportamento esperado
Alinhamento correto em todos os níveis de zoom, com causa raiz documentada.

## Regras de negócio
- RN-01: N/A — bug de renderização.

## Critérios de aceitação
- [x] CA-01: Marcação renderizada coincide com a região correspondente na imagem, em todos os níveis de zoom. Validado via teste de regressão automatizado (round-trip de coordenada com múltiplas imagens carregadas, independente de zoom — o bug era de referencial, não de escala).
- [ ] CA-02: Validado em furo com > 200 m e múltiplas caixas (GT-0001). Validação automatizada cobre a condição estrutural (2+ tiled images no world simultâneo, que é a causa do bug); validação manual em furo real de >200m ainda pendente de ambiente com dados reais.
- [x] CA-03: Causa raiz documentada na issue e no PR.

## Impacto técnico
### Frontend
Calibração profundidade→pixel, escala/zoom, offset de container.
### Backend / Banco de dados / Integrações
N/A.
### Segurança
N/A.

## Plano de implementação
- [ ] Investigar causa raiz (calibração, escala, offset, dimensões).
- [ ] Corrigir e cobrir com teste de regressão.

## Estratégia de testes
- [ ] Regressão automatizada.
- [ ] Manual — furo de 200m+ com múltiplas caixas (GT-0001).

## Riscos e rollback
Nenhum — é correção de bug, sem mudança de contrato.

## Registro de execução

### Causa raiz
`boxLocalToGlobalImageCoords()` (em `drill-hole-view-unic.component.ts`) convertia o pixel local de uma caixa de sondagem para uma coordenada "global" expressa no referencial **local da primeira imagem carregada no viewer** (`item 0`), via `TiledImage#viewportToImageCoordinates`.

O problema: todo o resto do pipeline de renderização — inclusive, internamente, o próprio `@annotorious/openseadragon` (a lib que desenha os retângulos de core/fracture/lithology/annotation) — reconverte essa coordenada "global" de volta para tela usando `viewer.viewport.imageToViewportCoordinates()` (nível **Viewport**, não **TiledImage**).

O `Viewport` do OpenSeadragon só se comporta como "relativo à imagem 0" quando o `world` tem exatamente **1** tiled image carregada (delegação interna documentada no próprio source do OSD). A partir de 2 imagens — o caso normal de qualquer furo real em Single View, onde cada caixa é sua própria `TiledImage` — o OpenSeadragon muda silenciosamente para um referencial diferente, porém consistente: o bounding box agregado do `world` inteiro (`World._homeBounds` / `_contentFactor`). O código já continha `(this.viewer.viewport as any).silenceMultiImageWarnings = true;`, ou seja, o aviso de runtime do próprio OpenSeadragon alertando exatamente sobre essa inconsistência já vinha sendo suprimido em vez de tratado — evidência de que o bug já tinha sido "descoberto" por um dev anterior e contornado silenciando o warning, não corrigindo a causa.

Resultado prático: toda marcação calculada em "espaço da imagem 0" era desenhada como se estivesse no referencial agregado do world inteiro — um descompasso de referencial (não de escala/zoom) que desloca a marcação de forma proporcional ao layout (mais caixas na tela = maior a divergência entre os dois referenciais = deslocamento mais visível), e ocorre em qualquer nível de zoom, pois é um erro de origem/escala de coordenada fixa por layout, não algo que dependa do fator de zoom em si.

Hipóteses descartadas durante a investigação: calibração profundidade→pixel (a lógica de `single-view-metric-layout.ts` está correta), offset de container (CSS/DOM não é a causa), dimensões de imagem por si só (não há redimensionamento incorreto de `contentSize`). Foi puramente um descompasso de referencial de coordenadas entre `TiledImage` (item 0) e `Viewport` (agregado do world) em cenário multi-imagem.

### Alterações realizadas
- `boxLocalToGlobalImageCoords()` agora fecha a conversão através de `viewer.viewport.viewportToImageCoordinates()` (referencial agregado) em vez de `world.getItemAt(0).viewportToImageCoordinates()` (referencial local da imagem 0). Essa é a única mudança funcional — as demais ~6 chamadas do componente que já usavam `viewer.viewport.*` (para os overlays customizados: labels de core, labels de fracture/lithology/annotation, marcador de depth, posicionamento de modal) já estavam corretas e foram mantidas como estavam.
- Comentários extensos adicionados no código explicando a causa raiz, para não ser reintroduzida por engano numa refatoração futura (ex.: GT-0014, que vai reabilitar o modo de desenho/edição de marcações nesta mesma tela).
- Teste de regressão automatizado adicionado (ver Validação).

### Arquivos principais
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.ts`
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.spec.ts`

### Decisões
- Não foi tocado `web/src/app/shared/openseadragon-viewer/services/box-coordinate-mapper.service.ts`, apesar de `registerBoxFromTiledImage()` também combinar unidades inconsistentes (`tiledImage.getBounds()` em unidades de viewport + `tiledImage.getContentSize()` em pixels) em `globalLeft/globalRight`. Esse código só é exercitado pelos fluxos de criação/edição de marcação (`onAnnotoriousCreate`, `handleDoubleClickAnnotation`, `handleDepthClick`), que estão desabilitados em Single View MVP (`anno.readOnly = true`, comentário "Spec 002" no próprio código). Como GT-0014/GT-0017/GT-0018 provavelmente reabilitam esse fluxo, deixo registrado aqui para quem pegar essas tasks: há um segundo bug relacionado (unidades misturadas no `BoxCoordinateMapperService`) que só afeta hit-testing de clique/desenho, não a renderização.
- Não foi corrigido o mesmo padrão de supressão de warning (`silenceMultiImageWarnings`) em `drill-hole-view-koregeo3.component.ts` — fora do escopo desta issue (que é especificamente sobre Single View / `drill-hole-view-unic`), mas é um sinal de que o mesmo componente irmão pode ter um bug de classe idêntica; vale investigar depois.

### Divergências
Nenhuma — implementação seguiu o escopo definido (investigar causa raiz, corrigir, cobrir com teste de regressão).

### Pendências
- Validação manual em furo real com >200m e múltiplas caixas (CA-02) — não executada por falta de acesso a um ambiente com dados reais nesta sessão; a validação automatizada cobre a condição estrutural exata que causa o bug (2+ tiled images simultâneas no world), mas não substitui a validação visual em dado real pedida pela issue.
- `should create` (teste pré-existente no mesmo spec) falha por `NullInjectorError: No provider for HttpClient` — confirmado como falha pré-existente (não introduzida por esta mudança; nenhum spec do projeto hoje configura `HttpClient` no `TestBed` para este componente). Não corrigido aqui para manter o PR focado no bug do GT-0013.

## Validação
- `ng test` (Karma, Chrome real) rodado localmente para o spec do componente: os 2 testes novos de regressão passam.
  - Teste 1: pixel local de uma segunda caixa (`box B`, offset de `box A`/item 0) convertido via `boxLocalToGlobalImageCoords` e reconvertido para viewport via `viewer.viewport.imageToViewportCoordinates` (o mesmo caminho usado por todo o app e pelo Annotorious internamente) aterrissa exatamente na posição real do pixel na tela — reproduz a condição exata da issue (2+ tiled images carregadas simultaneamente).
  - Teste 2: mesma verificação para um pixel na primeira caixa (item 0), garantindo que a correção não regride o caso que já funcionava.
  - Confirmado que a suíte de testes usada é real (`OpenSeadragon.Viewer` real com 2 tiled images de imagem 1x1 em data URI, sem mocks), não uma simulação da lógica.
- Build/compilação: `ng test` gera o bundle da aplicação com sucesso (sem erros de TypeScript) antes de rodar os specs.
- PR aberto, não mergeado: https://github.com/Essencis-Labs/GeoCloudAI/pull/344

## Handoff
**Ajuste de onda confirmado pelo usuário (2026-09-02)**: movido para a Onda 1 (o `.md` original sugeria Onda 2) porque GT-0014 (E3-02), GT-0017 (E3-05) e GT-0018 (E3-06) dependem deste fix e ficariam parados à toa. Bloqueia GT-0014, GT-0017, GT-0018. Comentário de reprioritização já postado em #330 e aprovado pelo usuário.

**Handoff para quem pegar GT-0014/GT-0017/GT-0018**: ao reabilitar o modo de desenho/edição de marcações em Single View (hoje `anno.readOnly = true`, ver comentário "Spec 002" em `drill-hole-view-unic.component.ts`), revisar `BoxCoordinateMapperService.registerBoxFromTiledImage()` — ele mistura `tiledImage.getBounds()` (unidades de viewport) com `tiledImage.getContentSize()` (pixels) ao computar `globalLeft/globalRight/globalTop/globalBottom`, o que quebra o hit-testing de clique (`findDrillBoxAtPixelCoordinates` → `boxMapper.resolveCoordinate`) usado para detectar em qual caixa o usuário clicou/desenhou. Esse bug não afeta a renderização (por isso não foi corrigido no GT-0013), mas vai aparecer assim que o modo de criação for reabilitado.

**Merge (2026-09-02)**: PR #344 mesclado (squash) em `feature/visualizadores-navegacao-layout`, commit `3d0746d749019dfc9b296eaee6ea37bdb4f14dbd`. Ainda não mesclado em `main` — aguardando validação manual do usuário na branch de integração (inclusive validação em furo real >200m, CA-02 ainda pendente).
