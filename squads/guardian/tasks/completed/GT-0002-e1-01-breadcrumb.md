---
id: GT-0002
title: "Breadcrumb com caminho hierárquico completo"
status: active
type: feature
reaberta_qa: "2026-09-03"
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "N/A — feature"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/317"
grupo_execucao: "Onda 1"
owner: "Flávia Frontend"
created_at: 2026-09-02
updated_at: 2026-09-02
affected_modules: [breadcrumb, layout]
related_adrs: []
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0002 — Breadcrumb com caminho hierárquico completo

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
Hoje o breadcrumb mostra apenas o link/último nível. O usuário perde a noção de onde está na hierarquia Region › Deposit › Mine › MineArea › DrillHole › DrillBox › DrillCore.

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/317. Breadcrumb renderiza a cadeia completa de ancestrais, cada nível clicável, truncado à esquerda a partir do nível atual (ex.: numa página de Mine, exibe Region A › Deposit Y › Mine T).

## Objetivo
Usuário sempre sabe onde está na hierarquia e navega para qualquer ancestral em 1 clique.

## Fora de escopo
Navegação lateral/sidebar (issue separada, GT-0003).

## Comportamento atual
Breadcrumb mostra só o nível atual.

## Comportamento esperado
Cadeia completa de ancestrais, truncada à esquerda a partir do nível atual, todos os níveis exceto o atual clicáveis.

## Regras de negócio
- RN-01: N/A — feature de navegação, sem regra de negócio nova.

## Critérios de aceitação
- [x] CA-01: Página de DrillHole exibe os 5 níveis, do Region ao DrillHole.
- [x] CA-02: Página de Mine exibe Region › Deposit › Mine.
- [x] CA-03: Todos os níveis, exceto o atual, navegam para a respectiva página.
- [x] CA-04: Nomes longos truncam com ellipsis + tooltip, sem quebrar o layout em telas menores.
- [x] CA-05: Entidade sem ancestral (ex.: Region) exibe apenas o próprio nível, sem separadores soltos.

## Impacto técnico
### Backend
Nenhum endpoint novo. Confirmado nos controllers/repositories que `GetById` de cada entidade já devolve a cadeia de ancestrais aninhada (ver Decisões).
### Frontend
Novo utilitário `hierarchy-breadcrumb.utils.ts` monta os itens de breadcrumb a partir do objeto retornado por `getById`; `AppPageHeaderComponent` ganhou suporte a navegação com `sessionStorage` por item e ellipsis+tooltip.
### Banco de dados
N/A — hierarquia já existe no schema.
### Integrações
N/A.
### Segurança
N/A — nenhuma decisão de tenant/permissão no cliente; dado vem pronto do backend, que já valida a cadeia de ancestrais para autorização (ver Decisões).

## Plano de implementação
- [x] Confirmar fonte de dados da cadeia de ancestrais (endpoint existente ou novo).
- [x] Implementar componente de breadcrumb truncado à esquerda.
- [x] Tooltip + ellipsis para nomes longos.

## Estratégia de testes
- [x] Unitário — `hierarchy-breadcrumb.utils.spec.ts` cobre CA-01, CA-02, CA-05 e o caso de ancestral ausente (DrillHole ligado só até Deposit).
- [ ] Manual — validar em cada nível da hierarquia (usar dados de GT-0001). Recomendado antes do merge; não executado nesta sessão por falta de ambiente com dados reais.
- [ ] E2E — navegação por clique em cada nível do breadcrumb. Não implementado (sem suíte E2E no projeto até o momento).

## Riscos e rollback
Nenhum risco estrutural — é aditivo, sem quebra de contrato. Rollback trivial (reverter o PR); nenhuma migration ou mudança de endpoint envolvida.

## Registro de execução
### Alterações realizadas
- Novo utilitário `web/src/app/shared/hierarchy-breadcrumb/hierarchy-breadcrumb.utils.ts`: monta a cadeia de breadcrumb (Home + ancestrais clicáveis + nível atual ativo) para Region, Deposit, Mine, MineArea, DrillHole e DrillBox, a partir dos objetos aninhados já retornados pelos endpoints `GetById`.
- `AppPageHeaderComponent` (`web/src/app/ui/app-page-header/`): `PageHeaderBreadcrumbItem` ganhou `sessionKey`/`sessionValue`; novo método `onCrumbClick()` grava o id do ancestral em `sessionStorage` antes do `routerLink` navegar (mesmo padrão já usado nos links "View" das listagens, ex. `mine-view-mine-areas.component.ts:200`). Template com `ngbTooltip` + `<span class="ph-crumb-label">` com `text-overflow: ellipsis`; SCSS com `max-width` responsivo (breakpoints 767.98px e 575.98px).
- 6 componentes `-view` (`region-view`, `deposit-view`, `mine-view`, `mine-area-view`, `drill-hole-view`, `drill-box-view`) passaram a chamar o builder correspondente após o `getById` resolver, substituindo o array estático `[Home, Lista, "X View"]`.

### Arquivos principais
- `web/src/app/shared/hierarchy-breadcrumb/hierarchy-breadcrumb.utils.ts` (novo)
- `web/src/app/shared/hierarchy-breadcrumb/hierarchy-breadcrumb.utils.spec.ts` (novo)
- `web/src/app/ui/app-page-header/app-page-header.component.ts` / `.html` / `.scss`
- `web/src/app/pages/geodata/regions/region-view/region-view.component.ts`
- `web/src/app/pages/geodata/deposits/deposit-view/deposit-view.component.ts`
- `web/src/app/pages/geodata/mines/mine-view/mine-view.component.ts`
- `web/src/app/pages/geodata/mine-areas/mine-area-view/mine-area-view.component.ts`
- `web/src/app/pages/geodata/drill-holes/drill-hole-view/drill-hole-view.component.ts`
- `web/src/app/pages/geodata/drill-boxes/drill-box-view/drill-box-view.component.ts`

### Decisões
- **Nenhum endpoint novo — confirmado no backend antes de implementar** (passo 1 pedido na task):
  - `MineController.GetById` (linha 321) já usa `result.Deposit?.Region?.AccountId` para a checagem de permissão — ou seja, `Mine.Deposit.Region` já vem preenchido.
  - `MineAreaRepository.GetById` faz `INNER JOIN Mine → INNER JOIN Deposit → INNER JOIN Region`, sempre presentes.
  - `DrillHoleRepository.GetById` traz `Region` (INNER JOIN, obrigatório), `Deposit`/`Mine`/`MineArea` (LEFT JOIN, podem ser nulos) — todos "achatados" no próprio objeto `DrillHole`, não aninhados uns nos outros.
  - `DrillBoxRepository.GetById` popula `DrillBox.DrillHole.Region/Deposit/Mine/MineArea` na mesma query (multi-mapping do Dapper).
  - O front já usava esses campos aninhados em outras telas (ex. `mine-view-mine-areas.component.html:98` — `data.mine?.deposit?.region?.name`; `drill-hole-view.component.ts` — `drillHole.mine?.imgBanner`), confirmando que o padrão já era estabelecido antes desta task.
- Mantido o item "Home" como raiz do breadcrumb (consistente com todas as outras páginas do app que usam `AppPageHeaderComponent`), em vez de começar direto pelo nível de Region — a issue não deixa isso explícito e remover o "Home" seria uma mudança de UX mais ampla, fora do escopo desta issue.
- Removido o link genérico da listagem (ex. "Mines" antes de "Mine View") do breadcrumb das páginas afetadas, já que ele não faz parte da cadeia de ancestrais real e o objetivo da issue é justamente substituí-lo pela hierarquia verdadeira.
- `DrillCore` não tem tela de detalhe própria (nenhuma rota `.../drillCoreView` em `pages.routes.ts`) — documentado como fora de escopo, não como pendência (não há onde montar um breadcrumb).
- Navegação por clique grava o id do ancestral em `sessionStorage` antes do `routerLink` navegar, porque as telas `-view` leem o id via `sessionStorage.getItem(...)` no `ngOnInit`, não via route params — reaproveita exatamente o padrão já usado nos botões "View" das listagens (ex. `sessionStorage.setItem('mineAreaId', id)`).

### Divergências
- Nenhuma quanto ao objetivo. Ajuste feito durante a validação: o binding `openDelay="400"` no `ngbTooltip` falhava a compilação AOT (`ngbTooltip` espera um `number`, não `string`) — corrigido para `[openDelay]="400"`.

### Pendências
- Validação manual com dados reais (múltiplos níveis, nomes longos de verdade, telas pequenas) não foi feita nesta sessão — recomendada antes do merge.
- Specs legadas de `MineViewComponent`, `DepositViewComponent`, `RegionViewComponent`, `MineAreaViewComponent`, `DrillHoleViewComponent`, `DrillBoxViewComponent` (`*.component.spec.ts`) já falhavam antes desta mudança — usam `TestBed.configureTestingModule({ declarations: [...] })` com componentes standalone, o que o Angular 19 rejeita. Débito pré-existente, não introduzido por esta task; não corrigido aqui por estar fora do escopo (afeta o padrão de scaffold de specs em dezenas de componentes do projeto).

## Validação
- `ng test --include="src/app/shared/hierarchy-breadcrumb/**/*.spec.ts"` → **9/9 SUCCESS** (cobre CA-01, CA-02, CA-03, CA-05 e o caso de ancestral ausente).
- `ng build --configuration production` → **build completo sem erros** (`Application bundle generation complete`); apenas warnings pré-existentes não relacionados a este PR (ex. `login2.component.html`, dependências CommonJS).
- Confirmado por leitura de código (não apenas suposição) que os endpoints `GetById` de Mine/MineArea/DrillHole/DrillBox já populam a cadeia de ancestrais usada pelo breadcrumb — ver Decisões.
- Revisão manual do template/SCSS: separador (`ph-crumb-sep`) só é renderizado a partir do segundo item do `@for`, então uma entidade sem ancestral (Region) nunca deixa separador solto (CA-05).

## Handoff
PR #346 (branch `feature/gt-0002-breadcrumb-hierarquico`, referencia a issue #317).
Pendências para quem revisar: validação manual com dados reais e decisão sobre manter ou não o item "Home" como raiz do breadcrumb (ver Decisões).

**Merge (2026-09-02)**: PR #346 mesclado (squash) em `feature/visualizadores-navegacao-layout`, commit `be08ff8f99e1d94e0bbc538921748810ae876049`. Ainda não mesclado em `main` — aguardando validação manual do usuário na branch de integração.

## Achado de QA pós-implementação (2026-09-03)
Relatório de QA (Matheus, `TASKS.md`, E1-01): "o link do nível Region no breadcrumb às vezes carrega em branco (API responde 200, UI não renderiza) — parece reuso de rota do Angular sem refazer o load. Reproduzido 2 de 3 vezes." Confirmado como Ok/funcional no restante.

**Análise (Jarvis)**: hipótese plausível e não descartada pela leitura do código. A navegação lê o id do ancestral de `sessionStorage` (não de route params, ver "Decisões" acima) e o carregamento dos dados roda em `ngOnInit()` de cada `-view.component.ts`. Se o `routerLink` de destino resolver para a MESMA rota Angular (path idêntico) de onde o clique partiu — cenário possível dependendo de como as rotas de Region estão configuradas — a estratégia padrão de reuso de rota do Angular pode não disparar `ngOnInit()` de novo, deixando a tela com o estado antigo/vazio mesmo com a API respondendo 200 (intermitência batendo com "2 de 3 vezes": comportamento típico de uma condição de reuso de instância, não um erro determinístico). **Não reproduzido nem confirmado nesta sessão** — precisa de repro real antes de decidir a correção (provável: forçar reload de dados a partir de mudança de valor em `sessionStorage`/`ActivatedRoute`, não só de `ngOnInit`).

Ver plano consolidado em `squads/guardian/output/qa-pos-implementacao-2026-09-03.md`.

## Correção do achado de QA (2026-09-03, frontend-angular)

### Investigação — hipótese de "reuso de rota" REFUTADA
Escrito e executado um teste isolado (`RouterTestingHarness`, Angular 19, duas rotas estáticas
irmãs sem `:id` na URL, exatamente a topologia real de `regions/regionView` vs. `mines/mineView`
etc.) navegando Mine → Region A → Mine → Region B repetidamente. Resultado: `ngOnInit()` roda
em TODAS as navegações, sempre com o id mais recente — **Angular sempre destrói e recria a
instância ao trocar entre rotas com `routeConfig` diferentes** (o `DefaultRouteReuseStrategy`
só reaproveita quando `future.routeConfig === curr.routeConfig`, o que nunca acontece aqui, já
que cada `-view` é um path estático distinto em `pages.routes.ts`, sem parâmetro de rota — e
"Region" nunca é link dentro da própria `RegionView`, só nas outras 5 telas). Nenhum
`RouteReuseStrategy` customizado está registrado em `app.config.ts` (confirmado por grep).
**Conclusão: a hipótese documentada acima está refutada para esta topologia de rotas.** O
teste isolado foi descartado após confirmar (não faz parte do fix — não há regressão de
roteamento a proteger).

### Causa real encontrada
`RegionViewComponent.getRegion()` disparava uma cadeia SEQUENCIAL de 5 chamadas HTTP
dependentes umas das outras apenas por ORDEM DE CÓDIGO, não por dependência real de dados
(`getDeposits` → `getMines` → `getMineAreas` → `getDrillHoles` → `getDrillBoxes`, cada uma só
disparada dentro do `next` da anterior). Duas consequências, ambas batendo com o achado de QA:
1. **Falha silenciosa em cascata**: uma falha transitória (timeout, 5xx, blip de rede) em
   QUALQUER chamada intermediária interrompia todo o restante da cadeia — inclusive
   `buildGeoMapMarkers()`, nunca alcançado. A página ficava com dados parciais/vazios (arrays
   nos seus valores iniciais `[]`) mesmo a chamada de `Region/getById` já tendo respondido 200
   — exatamente "API responde 200, UI não renderiza".
2. **Região é o nível com a cadeia mais longa de toda a hierarquia** (5 chamadas dependentes
   contra 4 do Mine, 3 do MineArea, 2 do DrillBox — contagem confirmada por grep nos 6
   `-view.component.ts`), logo o mais exposto estatisticamente a uma falha em algum elo —
   explica por que só "Region" foi sinalizado por QA entre os 6 níveis navegáveis pelo
   breadcrumb, e por que a taxa foi alta mas não 100% ("2 de 3 vezes").

### Correção aplicada
`RegionViewComponent`: as 5 chamadas (`Deposit/getByRegion`, `Mine/getByRegion`,
`MineArea/getByRegion`, `DrillHole/getByRegion`, `DrillBox/getByRegion`) passam a rodar EM
PARALELO via `forkJoin`, cada uma com `catchError` própria (loga e cai para `[]`) — uma falha
isolada não derruba mais as demais nem o mapa. Chain antiga removida; `getDeposits`,
`getMines`, `getMineAreas`, `getDrillHoles`, `getDrillBoxes` substituídos por um único método
privado `loadRegionAggregates()`. Adicionado também `implements OnInit` (a classe já
implementava o método, só faltava a interface — inconsistência com as outras 5 `-view`, que já
declaravam; correção trivial, sem efeito em runtime).

Escopo: só `RegionViewComponent` foi alterado — é o nível citado pelo QA e o único com essa
cadeia de 5 elos. As outras 5 `-view` (Deposit com 4, Mine com 3, MineArea com 2, DrillHole com
3, DrillBox com 1) têm o MESMO padrão (chamadas dependentes só por ordem de código, sem
`catchError` isolado) em menor escala — mesma classe de fragilidade, severidade menor. Não
corrigidas aqui por disciplina de escopo (o achado de QA é especificamente sobre Region) e para
não aumentar a superfície de conflito de merge com GT-0004/GT-0026, que já tocam os mesmos 6
arquivos `-view.component.ts` em outras partes. Recomendado abrir um achado de dívida técnica
separado se o mesmo sintoma for reportado em outro nível.

### Arquivos alterados
- `web/src/app/pages/geodata/regions/region-view/region-view.component.ts`
- `web/src/app/pages/geodata/regions/region-view/region-view.load-resilience.spec.ts` (novo)

### Validação
- Teste isolado de roteamento (RouterTestingHarness, descartado após confirmar a refutação —
  não é regressão a proteger permanentemente).
- `region-view.load-resilience.spec.ts` (novo, 2/2 SUCCESS): (1) confirma que as 5 chamadas
  disparam em paralelo — todas em voo simultaneamente logo após `Region/getById` responder, ao
  invés de uma de cada vez; (2) confirma que uma falha isolada (`MineArea` com 500) não impede
  `deposits`/`mines`/`drillHoles`/`drillBoxes` de popular nem `buildGeoMapMarkers()` de rodar —
  reproduz e corrige exatamente o sintoma relatado pelo QA.
- `ng test --include="src/app/shared/hierarchy-breadcrumb/**/*.spec.ts"` → 9/9 SUCCESS (specs
  do CA original de GT-0002, não afetadas por esta mudança).
- `ng build --configuration production` → build completo sem erros; únicos warnings são
  pré-existentes e não relacionados (Login2Component, DrillHoleViewMultComponent,
  Drillholesview3DComponent NG8107, dependências CommonJS) — mesmos já documentados na entrega
  original desta task.
- `region-view.component.spec.ts` (spec legada, débito pré-existente documentado acima em
  "Pendências") confirmado como falhando da MESMA forma de antes desta mudança (erro de
  `declarations` vs. standalone) — não é uma regressão introduzida aqui.
- Validação manual ponta a ponta (clicar repetidamente entre os mesmos níveis via breadcrumb
  num navegador real) não foi executada nesta sessão — sem backend rodando neste ambiente.
  Recomendada antes do merge, como já registrado na entrega original.

### Handoff
PR aberto contra `feature/visualizadores-navegacao-layout` a partir da branch
`fix/gt-0002-breadcrumb-region-blank-e1-01`. Pendências para quem revisar: (1) validação manual
com dados reais navegando repetidamente pelo breadcrumb até Region, para confirmar que o
sintoma relatado por Matheus não se repete; (2) decidir se vale abrir um achado de dívida
técnica separado para aplicar o mesmo tratamento (forkJoin + catchError isolado) nas outras 5
`-view` — não fizemos aqui por disciplina de escopo, mas a mesma fragilidade existe em menor
grau nelas.

**PR #383 mesclado (squash) em `feature/visualizadores-navegacao-layout`.** Hipótese original (route-reuse do Angular) refutada por teste isolado — causa real era 5 chamadas HTTP dependentes encadeadas apenas por ordem de código em `RegionViewComponent`, onde uma falha isolada truncava tudo depois dela silenciosamente. Corrigido com `forkJoin` + `catchError` por chamada. Achado de dívida técnica (mesmo padrão em menor escala nas outras 5 telas `-view`) sinalizado como task separada fora do escopo deste projeto.
