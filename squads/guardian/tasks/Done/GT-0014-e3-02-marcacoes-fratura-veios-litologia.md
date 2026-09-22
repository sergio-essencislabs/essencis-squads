---
id: GT-0014
title: "Exibir marcações de fratura, veios e litologias específicas (somente leitura)"
status: completed
type: feature
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "N/A — feature"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/337"
grupo_execucao: "Onda 2"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-02
affected_modules: [single-view]
related_adrs: []
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0014 — Marcações de fratura, veios e litologias (somente leitura)

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
Renderizar no Single View marcações de fratura, veios e litologias específicas, em modo somente visualização.

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/337.

## Objetivo
Os 3 tipos de marcação visíveis e distinguíveis, sem nenhuma ação de edição.

## Fora de escopo
Criar/editar/excluir marcações.

## Comportamento atual
Marcações de fratura/veios/litologia não aparecem no Single View.

## Comportamento esperado
Aparecem, visualmente distinguíveis, somente leitura.

## Regras de negócio
- RN-01: N/A.

## Critérios de aceitação
- [x] CA-01: Os três tipos de marcação aparecem, visualmente distinguíveis entre si (cor/traço/legenda).
- [x] CA-02: Nenhuma ação de edição disponível na tela (nem por atalho ou menu de contexto).
- [x] CA-03: Alinhamento correto — depende de GT-0013.

## Impacto técnico
### Frontend
Renderização de 3 tipos de marcação, legenda.
### Backend / Banco de dados / Integrações / Segurança
N/A — usa dado já existente (marcações do seed, GT-0001).

## Plano de implementação
- [x] Implementar renderização dos 3 tipos com legenda.
- [x] Confirmar ausência de qualquer ação de edição.

## Estratégia de testes
- [x] `ng build` (development) — build limpo, sem erro/warning novo.
- [x] `ng test --include='**/drill-hole-view-unic.component.spec.ts'` — specs de alinhamento (GT-0013/#330) continuam passando.
- [ ] Manual — usar dado do GT-0001, confirmar alinhamento (GT-0013) e ausência de edição. **Pendente**: não executado nesta sessão (sem ambiente com backend/seed rodando disponível); ver "Pendências".

## Riscos e rollback
Nenhum.

**Achado do GT-0013 relevante para esta task**: `web/src/app/shared/openseadragon-viewer/services/box-coordinate-mapper.service.ts`, método `registerBoxFromTiledImage()`, mistura unidades (viewport + pixels) ao computar `globalLeft/globalRight` — só afeta hit-testing de clique/desenho (não a renderização), hoje sem efeito porque `anno.readOnly = true` em Single View. Como esta task não altera esse modo (permanece somente leitura), não é bloqueante aqui, mas fica registrado — se algum dia esta tela ganhar edição, checar esse serviço antes.

## Registro de execução

PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/354 (branch `feat/gt-0014-marcacoes-fratura-veios-litologia` → base `feature/visualizadores-navegacao-layout`).

### Alterações realizadas
- Single View já desenhava **fratura** e **litologia** via Annotorious (herdado de trabalho anterior à Onda 2); faltava o terceiro tipo pedido pela issue, **veios** (`DrillCoreMineralization`/`MineralizationType` no domínio). Implementado:
  - `DrillCoreMineralizationService.getByDrillHoleList(drillHoleId)` — convenience method nova, espelhando exatamente o padrão de `DrillCoreFractureService`/`DrillCoreLithologyService` (chama `GET DrillCoreMineralization/getByDrillHole?drillHoleId=`, endpoint já existente em `DrillCoreMineralizationController`; nenhuma rota nova no backend).
  - `drawMineralization()` em `drill-hole-view-unic.component.ts` — mesmo formato de anotação Annotorious dos outros tipos (`RECTANGLE`, bodies `tagging`/`mineralizationId`/`coreId`/`annotationType`), usando **exatamente** `boxLocalToGlobalImageCoords()` (não escrevi um caminho de conversão paralelo).
  - Estilo próprio: laranja `#ff9800` — mesma cor já usada para "mineralization" em `drill-hole-view-koregeo3.component.ts` (convenção pré-existente no app, não inventei uma nova).
  - Entrada em `annotationCategories` (`key: 'mineralization', label: 'Vein'`) — a legenda lateral (cor + contagem + toggle de visibilidade) já é gerada dinamicamente a partir dessa lista, então nenhuma mudança de template foi necessária.
  - `getOverlayPrefix()` ganhou a entrada `mineralization: 'overlayVein'` — sem isso, o toggle de visibilidade escondia o retângulo (via `anno.setFilter`) mas deixava a etiqueta de texto (`addBottomLabelFor`) visível, um bug que teria sido introduzido junto com o novo tipo se não corrigido.
- **CA-02 (achado durante a implementação, não estava nos critérios originalmente antecipados como "já quebrado")**: `handleDoubleClickAnnotation()` abria modais de edição completos (Core/Fracture/Lithology/Annotation, com Save/Delete) via duplo-clique em qualquer marcação, **mesmo com `anno.readOnly = true`** — esse `readOnly` do Annotorious só desliga os handles de *drag* dele, não a lógica de clique customizada que este componente já tinha (herdada do editor multi-caixa). Era o único ponto da tela de onde uma ação de edição era alcançável (a toolbar de anotação e o modo de desenho já estavam desabilitados via template/`readOnly`). Virou um no-op deliberado, comentado no código explicando o porquê — necessário para o CA-02 valer de fato, não só para os 3 tipos novos mas para todos os tipos já existentes na tela.

### Arquivos principais
- `web/src/app/services/drillCoreMineralization.service.ts`
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.ts`

### Decisões
- Chave de tipo interna `mineralization` (não `vein`) — consistente com `DrillCoreMineralizationDto`/`MineralizationType` no backend e com `AnnotationPanelType` (já usado por `annotations-panel.component.ts`/`viewer-menu.component.ts`, que já tinham UI pronta para "mineralization" mas nenhum consumidor desenhava de fato). Label visível ao usuário é "Vein", em inglês, consistente com os labels das outras categorias já existentes na sidebar (Core/Depth/Fracture/Lithology/Annotation).
- Cor `#ff9800` reaproveitada de `drill-hole-view-koregeo3.component.ts` (única outra tela do app que já rotulava mineralization/veio visualmente) em vez de escolher uma cor nova — mantém uma convenção implícita de cor por tipo de marcação no produto.
- `handleDoubleClickAnnotation` foi neutralizado (não removido/refatorado) para minimizar o diff e o risco; o código morto resultante (`openCoreModalForEdit` e afins, agora inalcançáveis) foi deixado no lugar — é um refactor maior e separado do escopo desta task.

### Divergências
- Nenhuma em relação ao escopo pedido. O achado de CA-02 (double-click bypassando `readOnly`) não estava listado como "comportamento atual" na task, mas é coberto pelo próprio CA-02 desta task, então foi corrigido aqui em vez de aberto como issue separada.

### Pendências
- **Validação manual em ambiente rodando** (Single View com dado seedado do GT-0001, conferir visualmente os 3 tipos lado a lado e testar duplo-clique) não foi executada nesta sessão — não havia backend/DB disponível no ambiente de execução. Recomendo validar isso antes do merge do PR #354.

## Validação
- `cd web && ng build --configuration development` — sucesso, sem erro; nenhum warning novo introduzido (warnings pré-existentes de NG8107 em `login2`, `drill-hole-view-mult`, `drillholes-view-3d`, não relacionados a este PR).
- `cd web && npx ng test --watch=false --browsers=ChromeHeadless --include='**/drill-hole-view-unic.component.spec.ts'` — 2/3 specs passam (os 2 specs de regressão de alinhamento do GT-0013/#330, que exercitam `boxLocalToGlobalImageCoords()` com OpenSeadragon real). O terceiro (`should create`) falha com `NullInjectorError: No provider for HttpClient` — confirmado como falha **pré-existente e não relacionada**: reproduzida também rodando a suíte contra o código-base sem estas alterações (o `TestBed` do spec nunca configurou `provideHttpClient()`, e `DrillHoleService` — não `DrillCoreMineralizationService` — já é o primeiro serviço a falhar na cadeia de injeção).

## Handoff
Depende de GT-0013 (concluído, mesclado em `feature/visualizadores-navegacao-layout` via PR #344). PR desta task: #354. Pendência de validação manual em ambiente com backend antes do merge (ver "Pendências").
