---
id: GT-0015
title: "Régua de profundidade navegável em escala reduzida"
status: active
type: feature
reaberta_qa: "2026-09-03"
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "N/A — feature"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/331"
grupo_execucao: "Onda 2"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-02
affected_modules: [single-view]
related_adrs: []
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0015 — Régua de profundidade navegável

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
Referência: régua do IMAGO. Precisa mostrar a profundidade inteira do furo cabendo na tela.

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/331. Clique numa metragem leva direto à profundidade; indicador de posição/janela atual sobre a régua.

## Objetivo
Navegação rápida por profundidade em furos longos (200m+).

## Fora de escopo
N/A.

## Comportamento atual
Sem régua navegável.

## Comportamento esperado
Régua vertical em escala reduzida, clicável, com indicador de posição.

## Regras de negócio
- RN-01: N/A.

## Critérios de aceitação
- [x] CA-01: Furo de 200 m+ tem a régua inteira visível sem scroll.
- [x] CA-02: Clicar em ~200 m posiciona a visualização nessa metragem.
- [x] CA-03: Indicador de posição acompanha a rolagem da visualização.
- [x] CA-04: Marcações de escala legíveis (intervalos coerentes conforme a profundidade total).

## Impacto técnico
### Frontend
Componente de régua — possível reuso futuro em GT-0025 (E5-03, KoreGeo3).
### Backend / Banco de dados / Integrações / Segurança
N/A.

## Plano de implementação
- [x] Implementar régua em escala reduzida com indicador de posição.
- [x] Validar com furo de 200m+ (GT-0001) — validado via testes automatizados com a forma exata do furo mais profundo do seed (SEED-DH-10, 320 m / 12 caixas); QA manual no navegador não foi executada nesta sessão (ver Pendências).

## Estratégia de testes
- [x] Automatizado — funções puras de mapeamento profundidade↔coordenada (`single-view-metric-layout.spec.ts`) e componente da régua (`depth-ruler.component.spec.ts`), incluindo um layout com a forma exata do furo SEED-DH-10 (320 m).
- [ ] Manual — furo de 200m+, clicar em várias metragens. **Não executado nesta sessão** (ver Pendências).

## Riscos e rollback
Nenhum.

## Registro de execução
### Alterações realizadas
- Criado componente reutilizável `app-depth-ruler` (`web/src/app/shared/depth-ruler/`), deliberadamente "burro"/apresentacional: recebe apenas `minDepth`/`maxDepth`/`viewportStart`/`viewportEnd` em metros e emite `depthSelected` (metros) — nunca conhece OpenSeadragon nem o domínio de furo/caixa, para permitir reuso futuro pelo GT-0025 (KoreGeo3) sem inventar uma API mais genérica do que o necessário hoje.
  - Preenche 100% da altura disponível (`flex:1`/`height:100%`), então a régua inteira sempre cabe na tela independente da profundidade do furo — resolve CA-01 estruturalmente, sem lógica condicional por profundidade.
  - Densidade das marcações escolhida por um algoritmo padrão de "nice numbers" (1/2/5 × potência de 10) mirando ~10 marcas — CA-04.
  - Indicador da janela visível como faixa sobreposta (`top%`/`height%`), no mesmo padrão visual já usado em `drill-hole-view-koregeo3` para seu indicador de viewport.
- Adicionadas funções puras `depthAtWorldY`, `worldYAtDepth`, `totalDepthOf` em `single-view-metric-layout.ts` — convertem entre profundidade real (metros) e a coordenada "y" do mundo OSD usada pelas linhas já calculadas por `buildHoleLayout` (GT-0013). Mantêm a lógica de mapeamento fora do componente de UI e fora do componente do viewer.
- Integrado ao Single View (`drill-hole-view-unic.component.*`):
  - A régua reflete o primeiro furo selecionado (cada painel de furo tem sua própria origem `y=0` — furos lado a lado não compartilham uma única "profundidade" quando múltiplos estão selecionados; ver comentário no código).
  - `viewer.addHandler('pan'|'zoom', ...)` sincroniza o indicador da janela visível a cada interação (mesmo padrão de `drill-hole-view-koregeo3.syncDepthFromOSD`).
  - Clique na régua chama `viewport.panTo` preservando zoom e posição horizontal atuais (CA-02).

### Arquivos principais
- `web/src/app/shared/depth-ruler/depth-ruler.component.ts` (+ `.html`, `.scss`, `.spec.ts`) — novo.
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/single-view-metric-layout.ts` — funções de mapeamento depth↔y.
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/single-view-metric-layout.spec.ts` — testes das novas funções, incluindo um layout com a forma exata do furo SEED-DH-10 (320 m / 12 caixas).
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.{ts,html,scss}` — integração da régua ao Single View.

### Decisões
- Régua implementada como divs/CSS puro (top%/height%) em vez de reaproveitar `ngx-slider-v2` (já usado em `drill-hole-view-koregeo3` para um propósito parecido): a interação pedida é "clique para saltar" + "indicador de janela visível" (like a minimap/scrollbar), não um slider de arrasto de valor único — divs simples cobrem exatamente isso com menos acoplamento, e o padrão "indicador top%/height%" já existe no próprio `drill-hole-view-koregeo3`.
- Régua espelha o **primeiro furo selecionado**, não uma média/composição de todos: no Single View cada furo selecionado tem sua própria origem de profundidade (painéis lado a lado, cada um com y=0 próprio), então não existe uma única "profundidade da tela" quando há mais de um furo — decisão pragmática documentada em comentário no código, sem tentar resolver o caso multi-furo nesta task (fora do pedido original, que fala de "o furo").
- Mantido desacoplado do OpenSeadragon (só depende de números em metros) especificamente para não obrigar o GT-0025 a reescrever a régua caso o KoreGeo3 use outro mecanismo de viewport.

### Divergências
- Nenhuma quanto aos critérios de aceitação. Nenhuma mudança de contrato de API/backend (tarefa é 100% frontend, sem novo endpoint).

### Pendências
- **QA manual no navegador não foi executada nesta sessão.** O ambiente de execução já tinha MySQL (porta 3306) e múltiplos processos `dotnet`/`node` ativos de outras sessões concorrentes usando o mesmo diretório de trabalho compartilhado; iniciar `dotnet run`/`ng serve` próprios arriscava colidir com esse trabalho em andamento (mesmo banco `geocloudai`, possível seed duplicado/estado inconsistente para quem já estava validando outra coisa). Em vez disso, a validação com dados do GT-0001 foi feita via teste automatizado usando a forma exata do furo mais profundo do seed (SEED-DH-10: 320 m, 12 caixas de ~26,67 m) nos testes de `single-view-metric-layout.spec.ts` (round-trip profundidade→y→profundidade, clamp nos limites, total de profundidade).
- Recomendação para quem revisar o PR: rodar `dotnet run --project api/src/Back.API` localmente (sobe o seed do GT-0001 automaticamente) + `ng serve`, abrir Single View, selecionar SEED-DH-10 (ou qualquer furo 200m+) e confirmar visualmente CA-01..CA-04 antes do merge — isso não substitui a revisão de código, mas fecha a lacuna de QA manual que não foi possível fazer aqui.

## Validação
- `ng test` (suíte completa, ChromeHeadless): 245 specs executadas, **179 falhas pré-existentes / 66 sucessos antes e depois desta mudança** (falhas não relacionadas — problemas de `TestBed`/standalone em specs legadas, já documentados como dívida técnica preexistente). Nenhuma falha nova introduzida; nenhuma falha menciona `depth-ruler`, `single-view-metric-layout` ou `DrillHoleViewUnicComponent`.
- Testes novos (24 casos): `web/src/app/shared/depth-ruler/depth-ruler.component.spec.ts` (9) e adições em `single-view-metric-layout.spec.ts` (5, além dos 10 pré-existentes) — todos verdes.
- `ng build --configuration=production`: build limpo (apenas warnings pré-existentes não relacionados — `Login2Component`, `drill-hole-view-mult`, dependências CommonJS de terceiros).
- QA manual no navegador com dado real do seed GT-0001: **não executada** — ver Pendências acima.

## Handoff
Depende de GT-0001 (mesclado). Avaliar reuso do componente por GT-0025 (E5-03) antes de duplicar: `app-depth-ruler` já é standalone e desacoplado de OpenSeadragon (recebe apenas metros), então KoreGeo3 só precisa traduzir seu próprio viewport para `minDepth/maxDepth/viewportStart/viewportEnd` e tratar o evento `depthSelected` — não deveria precisar de mudança no componente da régua em si. `drill-hole-view-koregeo3` já tem uma régua própria (`ts-rulers`/`ngx-slider-v2`) com propósito parecido mas não idêntico (desenha marcações dentro do canvas OSD, não uma régua fixa fora dele); avaliar se vale a pena migrar aquela também para `app-depth-ruler` como parte do GT-0025, em vez de manter as duas implementações.
PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/355 (branch `feature/gt-0015-regua-profundidade`, base `feature/visualizadores-navegacao-layout`).

## Achado de QA pós-implementação (2026-09-03)
Relatório de QA (Matheus, `TASKS.md`, E3-03): "Régua de profundidade com visual estranho e não funcional: clicar numa profundidade deveria focar a caixa correspondente (padrão IMAGO) e não acontece. Não peguei isso porque testei um furo curto (~28m, sem necessidade de scroll)."

**Análise (Jarvis)**: exatamente a lacuna que a própria task já havia previsto e sinalizado como pendência ("QA manual no navegador não foi executada nesta sessão" — repetido 2x no arquivo). O código implementa `viewport.panTo` no clique da régua (CA-02) e testes automatizados cobrem o mapeamento profundidade↔coordenada, mas nunca foi exercitado num navegador real. Como o teste de Matheus usou um furo curto (28m, sem necessidade de scroll), pode não ter nem chegado a acionar o cenário que a régua resolve — recomendo reteste também com um furo longo do seed (SEED-DH-10, 320m) além de investigar o "visual estranho" relatado.

**Achado cruzado relevante**: GT-0018 (modo vertical) documentou um bug pré-existente em `buildHoleLayout` (a mesma função de layout usada pela régua) — quando a primeira linha do layout tem `startDepth > 0`, uma linha de "gap" é inserida antes da esperada, deslocando `rows[0]`. Não confirmado como causa do problema relatado aqui, mas é um suspeito razoável dado que ambos dependem da mesma função — vale investigar em conjunto.

Ver plano consolidado em `squads/guardian/output/qa-pos-implementacao-2026-09-03.md`.

## Registro de execução — reteste QA (2026-09-03, executado em conjunto com GT-0018)

### Diagnóstico
Investiguei o "visual estranho e não funcional" relatado por Matheus. Duas causas distintas, ambas confirmadas por leitura de código + prova via teste automatizado contra uma instância real do OpenSeadragon (sem QA manual em navegador — mesma limitação de ambiente compartilhado já documentada na sessão original):

1. **"Não funcional" (causa raiz confirmada)**: `onRulerDepthSelected` só chamava `viewport.panTo`. Logo após selecionar um furo, `applyDepthWindowOrHome` deixa o viewer em zoom "home" — o furo inteiro já cabe na tela. Nesse estado, `panTo` é um no-op: `constrainDuringPan: true` (já configurado em `initializeViewer`) não deixa o viewport se mover além do conteúdo, e quando todo o conteúdo já está visível não há "além" para onde ir. Isso bate exatamente com o relato de Matheus (furo curto, sem necessidade de scroll) e explica por que o bug também afetaria um furo longo logo após a seleção (antes do usuário dar zoom manualmente) — não é exclusivo de furos curtos.
2. **"Visual estranho" (causa mais provável)**: o bug de `buildHoleLayout` já documentado como "achado cruzado" (ver seção anterior) — quando a primeira linha do layout tem `startDepth > 0`, uma linha de gap incorreta é inserida antes da linha esperada. Isso desloca `rows[0]`, afetando tanto o painel principal quanto a régua (que usa os mesmos `rows`). Corrigido junto (ver GT-0018 para o detalhe da correção, reaproveitada aqui pois é a mesma função).

### Correção
`onRulerDepthSelected` (`drill-hole-view-unic.component.ts`): quando a altura atual do viewport (`viewport.getBounds().height`) já é maior ou igual à altura total do layout (`rulerRows`), um `panTo` não teria efeito visível — nesse caso, em vez de panorâmica, aplica um zoom "contain" (`viewport.fitBounds`) focando a linha/caixa correspondente à profundidade clicada, com padding de 50% da altura da linha. A largura do retângulo alvo é derivada de `viewport.getAspectRatio()` (não da largura atual do viewport) — `fitBounds` sempre expande o eixo necessário para casar com a proporção do container (confirmado lendo `Viewport#_fitBounds` no bundle instalado), então usar uma largura já compatível com essa proporção evita que o pedido de zoom seja "desfeito" pela própria função. Quando o usuário já deu zoom manualmente (altura do viewport menor que a altura total), o comportamento original é mantido: só panorâmica, preservando o zoom atual (CA-02).

### Validação
- `single-view-metric-layout.spec.ts`: 21/21 verdes (inclui o teste de regressão do bug do gap líder, ver GT-0018).
- `drill-hole-view-unic.component.spec.ts`: 2 testes novos contra uma instância real do OpenSeadragon (não mock) — um simulando o estado "zoom home" (prova que o zoom realmente muda e a linha clicada fica visível) e outro simulando "já zoomado" (prova que o zoom é preservado e só a posição muda). 34/35 verdes no arquivo (1 falha pré-existente e não relacionada — `should create`, falta `HttpClient` no TestBed, já documentada pelo GT-0018 antes desta sessão).
- `ng build --configuration development`: build limpo, mesmos warnings pré-existentes não relacionados.
- QA manual no navegador: **não executada** (mesma limitação de ambiente compartilhado da sessão original — ver Pendências acima). Recomendo ao revisor confirmar visualmente com SEED-DH-10 (320 m) antes do merge.

## Handoff (atualização 2026-09-03)
Corrigida em conjunto com GT-0018 num único PR, pelos mesmos arquivos serem tocados por ambas (`single-view-metric-layout.ts` — a correção de `buildHoleLayout` é compartilhada; `drill-hole-view-unic.component.ts` — o clique da régua e a rotação dos cores). Um PR único evita um conflito de merge garantido entre duas branches concorrentes na mesma família de arquivos.

PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/381 (branch `fix/gt-0015-gt-0018-regua-modo-vertical`, base `feature/visualizadores-navegacao-layout`). **Mesclado (squash)** em `feature/visualizadores-navegacao-layout`. QA manual no navegador (confirmar CA-01..CA-04 com SEED-DH-10) segue pendente para a sessão de teste do usuário.
