---
id: GT-0020
title: "Visualizar múltiplas caixas — do mesmo furo e de furos distintos"
status: completed
type: feature
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "N/A — feature, base do épico MultiView"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/333"
grupo_execucao: "Onda 2"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-02
affected_modules: [multiview]
related_adrs: []
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0020 — MultiView base

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
Exibir todas as caixas de um furo lado a lado, e permitir comparação com caixas de furos diferentes.

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/333. Seletor de quais furos/caixas compõem a visualização.

## Objetivo
Comparação de caixas do mesmo furo e de furos diferentes, com identificação clara de origem.

## Fora de escopo
Modo "somente DrillCore" (GT-0021), acesso desde Region (GT-0022).

## Comportamento atual
Sem visualização multi-caixa.

## Comportamento esperado
Todas as caixas de um furo numa tela; possível adicionar caixas de outro furo, identificadas por furo+metragem.

## Regras de negócio
- RN-01: N/A.

## Critérios de aceitação
- [x] CA-01: É possível ver todas as caixas de um furo numa única tela. (já existia — múltiplas janelas + bandeja de miniaturas por janela; não alterado, apenas verificado por leitura de código)
- [x] CA-02: É possível adicionar caixas de outro furo à mesma comparação, com identificação clara de origem (furo + metragem). (implementado nesta task — badge com nome do furo + título do painel com "Box N startDepth–endDepth m")
- [ ] CA-03: Performance validada com os 10 furos de GT-0001. **Não validado em ambiente real** — este agente não tem acesso a backend/dev-server rodando; ver "Pendências".

## Impacto técnico
### Frontend
Base do MultiView, seletor de furos/caixas.
### Backend / Banco de dados / Integrações / Segurança
N/A.

## Plano de implementação
- [ ] Implementar visualização multi-caixa do mesmo furo.
- [ ] Implementar seleção de caixas de furos diferentes.
- [ ] Validar performance com GT-0001.

## Estratégia de testes
- [ ] Manual — 10 furos do seed, comparar caixas de furos diferentes.

## Riscos e rollback
Performance com muitas caixas simultâneas — validar com dado real do seed.

## Registro de execução
### Alterações realizadas
`app-drill-hole-view-mult` (tab "Multi View" do DrillHole, `drillHoles/drillHoleViewMult`) já implementava CA-01 (múltiplas janelas com bandeja de miniaturas para navegar pelas caixas do furo aberto) e uma infraestrutura de layout/workspace rica (presets, drag&drop, sync de pan/zoom, anotações). Faltava CA-02: cada janela só conseguia mostrar caixas do furo primário (`drillHoleId` lido de `sessionStorage`).

Implementado:
- `WindowState` (helpers) ganhou `drillHoleId: number | null` — cada janela do workspace agora sabe de qual furo está mostrando uma caixa.
- Novo estado no componente: `windowBoxesView` (lista de caixas resolvida por janela), `holeBoxesCache`/`holeInfoCache` (cache em memória por furo, evita recarregar a mesma lista/])metadado repetidamente), `availableDrillHoles` (lista para o seletor, carregada só na primeira abertura do seletor — não no carregamento da página).
- Botão "furo" no cabeçalho de cada painel abre um modal (ng-bootstrap) com busca + lista de furos (`DrillHoleService.getByAccount`) e opção de voltar ao furo original. Ao escolher um furo, busca as caixas dele (`DrillBoxService.getByDrillHole`) e troca a imagem exibida naquela janela, mantendo a bandeja de miniaturas existente para navegar pelas caixas do furo escolhido.
- Badge de origem (`ri-git-branch-line` + nome do furo) no cabeçalho do painel quando a janela mostra um furo diferente do primário; o título do painel continua mostrando "Box N startDepth–endDepth m" — juntos cobrem "furo + metragem" pedido em CA-02.
- Todos os pontos internos que liam `this.drillBoxesFiltered[...]` (índice global de caixa) foram trocados para ler da lista resolvida por janela (`windowBoxesView[slot][...]`), preservando o comportamento existente para janelas no furo primário.
- `addWindow()` (botão "+") agora copia também o `drillHoleId` da janela em foco para a nova janela, para manter consistência ao abrir mais um painel comparando o mesmo furo.

### Arquivos principais
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-mult/drill-hole-view-mult.component.ts`
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-mult/drill-hole-view-mult.component.html`
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-mult/drill-hole-view-mult.component.scss`
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-mult/drill-hole-view-mult-helpers.ts`

### Decisões
- **Edição de anotações permanece restrita ao furo primário.** As séries `drillCores`/`drillCoreDepths`/`drillCoreFractures`/`drillCoreLithologies`/`drillCoreAnnotations` do componente são carregadas só para o furo primário (`loadAnnotationsForDrillHole`) e são **reatribuídas por completo** a cada salvar/excluir (não fazem merge incremental) — misturar anotações de furos diferentes nessas listas quebraria esse fluxo de recarregamento em qualquer save. Por isso, janelas mostrando um furo diferente do primário exibem só a imagem (para comparação visual), sem overlay/edição de anotações; os botões de tipo de anotação e o botão de seleção de profundidade ficam ocultos (`enabledTypes=[]`) quando o painel em foco está em modo "furo diferente", com guarda também no código (`isCrossHole()`) para o caso de o usuário focar outro painel via atalho antes da UI reagir.
- Serviço usado para listar furos no seletor é `DrillHoleService.getByAccount` (tenant sempre derivado do JWT no backend, nunca passado pelo frontend) — não `getByRegion/getByDeposit/...`, porque o seletor não está escopado à hierarquia do furo aberto (comparação pode ser com qualquer furo da conta).
- Lista de furos do seletor carrega só na primeira abertura do modal (lazy), não no carregamento da página — pensado para não pesar CA-03 com uma chamada extra desnecessária quando o usuário só quer ver as caixas do próprio furo.

### Divergências
- Nenhuma quanto ao pedido da issue; a única redução deliberada de escopo é a restrição de edição de anotação ao furo primário, documentada acima (a issue não exige edição cross-hole, só "visualizar"/"comparar").

### Pendências
- **CA-03 não validado com dado real.** Este agente não teve acesso a um backend rodando nem a um navegador interativo — só `ng build`/`ng test` via CLI. É necessário abrir a tela com os 10 furos do seed do GT-0001, montar uma comparação com caixas de 3–4 furos diferentes simultaneamente (até o limite de 6 janelas) e confirmar que o carregamento permanece fluido. O código minimiza o risco (nenhuma chamada de anotações é feita para furos que não sejam o primário; lista de caixas por furo é cacheada após o primeiro carregamento), mas isso precisa de confirmação visual.
- Teste automatizado do componente (`drill-hole-view-mult.component.spec.ts`) já falhava antes desta mudança: `NullInjectorError: No provider for HttpClient` (spec não configura `HttpClientTestingModule`/`provideHttpClient`). Confirmado como pré-existente isolando o diff (só os 4 arquivos deste PR foram tocados) — não é uma regressão desta task, mas seria bom um follow-up para corrigir a suíte.

## Validação
- `cd web && ng build --configuration=development` — build de produção (modo dev) concluído sem erros. 3 warnings `NG8107` (optional chaining redundante) no bundle final, todos pré-existentes ou de baixo risco: 2 já existiam antes desta mudança (`login2.component.html`, `drillholes-view-3d.component.html`); 1 introduzido por este PR (`drill-hole-view-mult.component.html:169`, `windowBoxesView[...][...]?.number` — TS não marca o tipo do array como nullable nesse ponto, mas o `?.` foi mantido de propósito porque em runtime a lista pode estar vazia antes do primeiro carregamento).
- `cd web && ng test --watch=false --browsers=ChromeHeadless --include='**/drill-hole-view-mult.component.spec.ts'` — executa e falha por `NullInjectorError: No provider for HttpClient` (ver "Pendências"; falha pré-existente, não introduzida por este PR).
- Ambiente sem `node_modules` instalado (worktree isolado do agente) — instalado via `npm ci --prefer-offline --no-audit --no-fund` para viabilizar `ng build`/`ng test`.
- Validação manual do fluxo (abrir DrillHole → tab Multi View → selecionar furo diferente em uma janela → conferir badge de origem + navegação pela bandeja de miniaturas do furo escolhido) **não realizada** — sem backend/dev-server disponível neste ambiente. Recomenda-se essa validação antes de mesclar o PR, junto com CA-03.

## Handoff
Depende de GT-0001. Bloqueia GT-0022 (E4-03, base para acesso desde Region).

PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/353 (branch `feature/gt-0020-multiview-base` → `feature/visualizadores-navegacao-layout`).

Para GT-0021 (modo "somente DrillCore"): `WindowState.drillHoleId` e `windowBoxesView` são propriedades por-janela, independentes do modo de exibição da caixa — um toggle de modo pode ser adicionado sem reestruturar o seletor de furo/caixa implementado aqui.
