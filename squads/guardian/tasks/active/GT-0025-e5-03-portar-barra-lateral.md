---
id: GT-0025
title: "Portar barra lateral de marcação e profundidade do KoreGeo2"
status: active
type: feature
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "N/A — feature"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/335"
status_atualizado: completed
grupo_execucao: "Onda 3"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-02
affected_modules: [koregeo3]
related_adrs: [GADR-0002]
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0025 — Portar barra lateral (KoreGeo2 → KoreGeo3)

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
Inserir no KoreGeo3 a barra lateral do KoreGeo2 com marcações e escala de profundidade.

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/335. Avaliar reuso do componente de régua de GT-0015 (E3-03) antes de duplicar.

**Escopo revisado após investigação de código (GADR-0002, Alternativa A aceita)**: o HTML da barra lateral (`depth-slider-container`, `core-numbers-track`, `depth-indicators-wrapper`) já é **idêntico** entre KoreGeo2 e KoreGeo3 (`drill-hole-view-koregeo3.component.html` linhas 9-69 vs. `drill-hole-view-koregeo2.component.html` linhas 9-83) — ela aparece "vazia" pela mesma causa raiz de GT-0024 (carregamento comentado). Reativar o carregamento (mesmo fix de GT-0024) deve resolver a maior parte desta task também — confirmar se sobra algo específico da barra em si depois da reativação.

**Escopo adicional descoberto (3 gaps reais não mapeados na issue original, incluídos aqui por afetarem a mesma área)**:
1. Botão de anotação por testemunho individual — KoreGeo2 tem um botão por imagem (`toggleAnnotationMode(i)`); KoreGeo3 tem só um botão global que afeta sempre o core de índice 0. Portar o botão por core.
2. Destaque visual (highlight) do testemunho ativo por hover/clique — existe em KoreGeo2 (`currentHighlightedIndex`, `isHighlighted()`, `highlightCore()`, `onImageHover`/`onImageLeave`/`onImageClick`), sem equivalente em KoreGeo3. Portar.
3. Fallback de imagem quebrada (`onImageError`, tenta URL alternativa sem sufixo `_`) — existe em KoreGeo2, sem equivalente em KoreGeo3. Portar.

## Objetivo
Barra lateral com paridade de comportamento ao KoreGeo2, incluindo os 3 gaps reais acima, sem duplicar componente já existente (avaliar reuso com GT-0015).

## Fora de escopo
N/A.

## Comportamento atual
KoreGeo3 sem barra lateral de marcação/profundidade.

## Comportamento esperado
Barra funcional, profundidade sincronizada, consistente com a régua de GT-0015.

## Regras de negócio
- RN-01: N/A.

## Critérios de aceitação
- [x] CA-01: Barra lateral presente e funcional, com paridade de comportamento com o KoreGeo2. HTML já era idêntico (confirmado); os 3 gaps de comportamento reais (CA-04/05/06) portados nesta task. Ressalva: a população visual completa (litologia/fratura/anotação carregadas automaticamente) depende também da reativação de `loadDrillCores()`/`ngOnInit()` feita em GT-0024 (#334, paralelo) — não tocada aqui de propósito.
- [x] CA-02: Profundidade sincronizada com a visualização. Já existia no KoreGeo3 antes desta task (`syncDepthFromOSD()` nos handlers `pan`/`zoom` do OSD) — não é um gap, o KoreGeo3 já tinha isso e o KoreGeo2 não (sincronização por scroll).
- [x] CA-03: Avaliado o reuso de `app-depth-ruler` (GT-0015). Recomendação: não migrar agora — ver "Decisões" abaixo.
- [x] CA-04: Botão de anotação por testemunho individual portado (não só o core de índice 0).
- [x] CA-05: Highlight do testemunho ativo por hover/clique portado.
- [x] CA-06: Fallback de imagem quebrada portado.

## Impacto técnico
### Frontend
Porte + avaliação de reuso do componente de régua.
### Backend / Banco de dados / Integrações / Segurança
N/A.

## Plano de implementação
- [x] Confirmar que a reativação de carregamento (GT-0024) já resolve a barra em si. Confirmado por leitura de código: HTML idêntico, reativação é responsabilidade de GT-0024 (não tocada nesta task).
- [x] Avaliar reuso do componente de régua (GT-0015) antes de portar do zero. Avaliado — não migrar agora (ver Decisões).
- [x] Portar botão de anotação por core individual.
- [x] Portar highlight do core ativo (hover/clique).
- [x] Portar fallback de imagem quebrada.

## Estratégia de testes
- [x] `ng build` (configuration development) — sucesso, sem erros no componente alterado.
- [x] `ng test` (Karma/ChromeHeadlessCI, escopo `drill-hole-view-koregeo3`) — falha pré-existente documentada (ver Validação), não corrigida por estar fora do escopo.
- [ ] Manual — comparar com KoreGeo2 (requer ambiente rodando com dados reais; não executado nesta sessão).

## Riscos e rollback
Duplicar componente de régua em vez de reutilizar — vigiar no code review.

## Registro de execução
### Alterações realizadas
Branch `feature/gt-0025-portar-barra-lateral-koregeo3` (a partir de `origin/feature/visualizadores-navegacao-layout`), PR #365 aberto contra essa mesma branch base (nunca contra `main`).

Confirmado por leitura de código que o HTML da barra lateral já era idêntico entre KoreGeo2 e KoreGeo3 (GADR-0002). O trabalho real foi portar os 3 gaps de comportamento, todos adaptados para a arquitetura de canvas único do OpenSeadragon do KoreGeo3 (sem `<img>` por testemunho como no KoreGeo2 — não dá para colar o código do KoreGeo2 verbatim):

1. **Botão de anotação por core (CA-04)**: removido o botão global do toolbar (`toggleAnnotationMode()` sem argumento, que sempre afetava o core 0) e adicionado um botão por core (`addAnnotationButtons()`), renderizado como overlay OSD fixo (`checkResize:false`) ancorado no canto superior direito de cada imagem, com estado visual (ícone/cor) atualizado por `updateAnnotationButtonsUI()` a cada chamada de `toggleAnnotationMode(i)`.
2. **Highlight do core ativo (CA-05)**: portados `highlightCore()`, `isHighlighted()`, `onImageHover()`, `onImageLeave()`, `onImageClick()` (mesma forma/nomes do KoreGeo2) e conectados nos 4 pontos onde o KoreGeo2 os chama e o KoreGeo3 não chamava (`onDepthChange`, `onIndicatorClick`, `onOverlayBarClick`, `navigateToSearchResult`). Sem elemento DOM por core para receber `(mouseenter)`/`(mouseleave)`/`(click)`, a detecção de hover/clique converte a posição do mouse em coordenada de mundo via `viewport.viewerElementToViewportCoordinates()` e verifica contra os bounds de cada core; o destaque visual é um único overlay OSD com borda, reposicionado dinamicamente (`updateCoreHighlightOverlay()`) em vez de uma classe CSS por elemento.
3. **Fallback de imagem quebrada (CA-06)**: `resolveCoreImage()` testa a URL primária com um `Image()` antes de montar os bounds do OSD e, em erro, tenta `getFallbackImageUrl()` (mesma regra do `onImageError` do KoreGeo2: mesma URL sem o sufixo `_` antes da extensão) antes de entregar a URL final ao `addSimpleImage()`.

### Arquivos principais
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-koregeo3/drill-hole-view-koregeo3.component.ts`
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-koregeo3/drill-hole-view-koregeo3.component.html`

### Decisões
- **Não migrar a régua para `app-depth-ruler` (GT-0015) nesta task** (CA-03). `app-depth-ruler` é deliberadamente presentacional (só `minDepth`/`maxDepth` + janela de viewport + clique). A barra lateral do KoreGeo2/KoreGeo3 cobre bem mais: indicadores de profundidade por anotação (litologia/fratura/anotação, coloridos, com tooltip e clique-para-navegar), números de core amarrados ao zoom, sincronismo de zoom ao vivo, destaque de resultado de busca. Migrar exigiria expandir a API pública de `app-depth-ruler` — escopo maior que "portar 3 gaps" e fora do pedido desta task. Documentado como recomendação para uma task futura dedicada, se a expansão da API valer a pena.
- **Highlight visual novo, não só portado**: no KoreGeo2, `[class.highlighted]="isHighlighted(i)"` no HTML não tem nenhuma regra CSS associada (busca confirmou — nenhum `.highlighted` ou `.image-box-with-ruler.highlighted` estilizado em `drill-hole-view-koregeo2.component.scss`), ou seja, o "highlight" do KoreGeo2 é hoje visualmente um no-op (só afeta `value`/scroll). Portar isso ao pé da letra no KoreGeo3 teria o mesmo problema. Em vez de replicar o no-op, implementei um destaque visual real (overlay com borda) — decisão deliberada de ir além da paridade estrita porque a intenção do CA-05 ("destaque visual") só se cumpre de fato assim. Nenhuma regra de negócio nova, é só feedback de UX.
- **`onImageHover`/`onImageLeave` não alteram `this.value`** (diferente do KoreGeo2, que muda o valor da régua ao simplesmente passar o mouse). O KoreGeo3 já sincroniza `value` pelo pan/zoom real do OSD (`syncDepthFromOSD`); fazer o hover também mudar `value` teria conflitado com esse mecanismo e pareceria um salto abrupto para quem só está passando o mouse sem interagir. `onImageClick` continua mudando `value` (seleção intencional), igual ao KoreGeo2.

### Divergências
Nenhuma divergência de escopo além das decisões acima.

### Pendências
- Reativação do carregamento comentado (`getColors()`, `loadDepthMarkers()`, `loadAnnotationsForCore` em loop, `calculateDepthIndicators()`/`updateViewportIndicator()`) é responsabilidade de GT-0024 (#334) — não tocada aqui.
- `drill-hole-view-koregeo3.component.spec.ts` falha por débito pré-existente de DI (`HttpClient` sem provider no `TestBed`), documentado e fora do escopo — ver Validação.

## Validação
- `ng build --configuration development`: **sucesso** (exit 0). Sem erros no componente alterado. 3 warnings `NG8107` pré-existentes em arquivos não relacionados (`login2.component.html`, `drill-hole-view-mult.component.html`, `drillholes-view-3d.component.html`).
- `ng test` (Karma, `ChromeHeadlessCI`, `--include='**/drill-hole-view-koregeo3/**/*.spec.ts'`): **1 FAILED** — `NullInjectorError: No provider for HttpClient!`. Confirmado como débito pré-existente e não introduzido por este PR: o spec `drill-hole-view-koregeo2.component.spec.ts` (irmão, não tocado) tem o mesmo padrão mínimo de `TestBed` e sofreria do mesmo erro; e o PR #356 ("fix(web): corrige specs legados com TestBed.declarations em componentes standalone", aberto contra a mesma branch base) documenta explicitamente `DrillHoleViewKoregeo*` como fora do seu escopo por "nunca ter tido o padrão `declarations`" — ou seja, esses specs precisam de uma correção de DI própria (não só `declarations`→`imports`), não incluída em nenhum dos dois PRs.
- Manual comparando com KoreGeo2: não executado (exigiria ambiente rodando com dados reais/autenticação; fora do que dá para validar nesta sessão).
- PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/365 (base `feature/visualizadores-navegacao-layout`).

## Handoff
Depende de GT-0023 (concluída via GADR-0002). Overlap real com GT-0024 (#334, mesmo arquivo, trabalho paralelo) documentado no PR #365 — GT-0024 reativa `loadDrillCores()`/`ngOnInit()`, este PR não toca essas linhas. Revisor humano deve decidir a ordem de merge entre #365, #356 (fix de specs legados) e o PR de GT-0024 quando existir; conflito textual esperado ser mínimo pois as regiões editadas não se sobrepõem.
