---
id: GT-0022
title: "Disponibilizar a guia MultiView a partir de Region (e níveis abaixo)"
status: completed
type: feature
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "N/A — feature"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/340"
grupo_execucao: "Onda 3"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-02
affected_modules: [multiview, navegacao]
related_adrs: [GADR-0001]
---

# GT-0022 — MultiView desde Region

## Contexto
Guia MultiView disponível de Region até DrillBox, conforme a matriz de GT-0004.

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/340. Em cada nível agregador, conjunto inicial de caixas coerente e definido; a partir de Region, o volume potencial não pode travar a tela — limite/paginação ou seleção obrigatória.

## Objetivo
Guia funcional em todos os níveis, com estratégia de carga definida e identificação de origem por caixa.

## Fora de escopo
N/A.

## Comportamento atual
MultiView não acessível de níveis agregadores.

## Comportamento esperado
Disponível de Region a DrillBox, com estratégia de carga (GT-0004/GADR-0001) aplicada.

## Regras de negócio
- RN-01: N/A.

## Critérios de aceitação
- [x] CA-01: Guia visível e funcional em todas as entidades da matriz, de Region a DrillBox.
- [x] CA-02: Em cada nível agregador, o conjunto inicial de caixas exibido é coerente e definido.
- [x] CA-03: A partir de Region, o volume potencial de caixas não trava a tela: limite/paginação ou seleção obrigatória definidos e implementados.
- [x] CA-04: Identificação da origem de cada caixa (furo + metragem) visível.

## Impacto técnico
### Frontend
Integração com GT-0004/GADR-0001 e GT-0020 (base MultiView).
### Backend
Estratégia de carga pode exigir paginação server-side — confirmar com Breno.
### Banco de dados / Integrações / Segurança
N/A.

## Plano de implementação
- [x] Consumir decisão de GADR-0001.
- [x] Integrar com base de GT-0020.
- [x] Implementar limite/paginação em Region (via `DescendantDrillHolesLoaderService`, pageSize=10, direct=false — mesmo mecanismo usado em Deposit/Mine/MineArea).

## Estratégia de testes
- [x] Automatizado — 3 specs novos em `drill-hole-view-mult.component.spec.ts` cobrindo o fluxo agregador (carga via loader compartilhado, desativação de painel com menos furos que painéis, nível sem furos).
- [ ] Manual — abrir a partir de cada nível, incluindo Region com muitos furos (GT-0001). Recomendado antes do merge; não executado nesta sessão (sem ambiente rodando).

## Riscos e rollback
Abrir desde Region pode significar centenas de furos — estratégia de carga precisa estar decidida (GADR-0001) antes desta issue entrar em desenvolvimento (risco já sinalizado no corpo original).

## Registro de execução
### Alterações realizadas
Conectada a guia MultiView (componente `DrillHoleViewMultComponent`, já existente desde GT-0020) aos 4 níveis agregadores (Region, Deposit, Mine, MineArea) e ao nível DrillBox (antes só existia embutida em DrillHole). Dois `@Input()` novos no componente (`aggregatorLevel`, `aggregatorEntityId`) acionam um novo fluxo de entrada quando a guia é aberta a partir de um nível agregador:
- `loadAggregatorDrillHoles(level, entityId)` chama `DescendantDrillHolesLoaderService.load(...)` (já existente, GT-0004/GADR-0001 — `DrillHole/getBy{Region|Deposit|Mine|MineArea}`, `pageSize=10`, `direct=false`).
- `openInitialAggregatorWindows(holes)` atribui os N primeiros furos retornados aos painéis padrão (V1/V2) reaproveitando `selectHoleForSlot` (o mesmo caminho já usado pelo seletor "compare a box from another drill hole" de GT-0020) — sem requisição extra. Painéis padrão sem furo correspondente (menos furos que painéis) são desativados.
- Sem furo "primário" (`drillHoleId` fica em 0), então `isCrossHole()` é sempre `true` para qualquer painel — o badge de origem (nome do furo) fica sempre visível, e o título do painel já mostra número da caixa + metragem (CA-04).
- Um badge no toolbar (`Region · N drill holes`, reaproveitando o estilo `.origin-badge`) deixa explícito de onde vieram as caixas iniciais (CA-02).
- O item "This drill hole (default)" do seletor de furo fica oculto em modo agregador (não existe furo padrão nesse contexto).
- Nível DrillBox: aba "Multi View" nova, sem `aggregatorLevel` (segue o fluxo de furo único já existente) — `DrillBoxViewComponent` agora sincroniza `sessionStorage['drillHoleId']` com o furo pai da caixa ao carregar, mesma convenção já usada pela página de Drill Hole.

### Arquivos principais
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-mult/drill-hole-view-mult.component.ts` — novo fluxo de entrada agregador.
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-mult/drill-hole-view-mult.component.html` — badge de contexto agregador; oculta opção "furo padrão" quando não há.
- `web/src/app/pages/geodata/{regions/region-view,deposits/deposit-view,mines/mine-view,mine-areas/mine-area-view}/*.component.{ts,html}` — nova aba "Multi View" em cada página, passando `[aggregatorLevel]`/`[aggregatorEntityId]`.
- `web/src/app/pages/geodata/drill-boxes/drill-box-view/drill-box-view.component.{ts,html}` — nova aba "Multi View" (nível DrillBox).
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-mult/drill-hole-view-mult.component.spec.ts` — reescrito: corrige `HttpClientTestingModule`/`NG03600` (ambos pré-existentes, quebrados independente desta task) e adiciona 3 specs do fluxo agregador.

### Decisões
- Nenhum novo endpoint/serviço HTTP — reaproveita 100% de `DescendantDrillHolesLoaderService` (GT-0004) e `selectHoleForSlot` (GT-0020); frontend não decide tenant (todas as chamadas vão para `DrillHole/getBy{Level}` já existentes, checagem de conta no backend).
- Entrada por nível agregador via `@Input()` explícito no componente (`aggregatorLevel`/`aggregatorEntityId`) em vez de mais uma chave ad-hoc em `sessionStorage` — os `*-view.component.ts` já expõem `regionId`/`depositId`/`mineId`/`mineAreaId` publicamente e populados de forma síncrona em `ngOnInit`, então não há race condition com a renderização preguiçosa das abas `ngbNav`.
- DrillBox (nível folha, não agregador) reaproveita o fluxo de furo único já existente via `sessionStorage['drillHoleId']` (mesma convenção do restante do app) em vez de inventar um terceiro modo — mínimo código novo.

### Divergências
Nenhuma da issue original. GT-0011/GT-0019/GT-0026 (Images/Single View/KoreGeo3 em níveis agregadores) permanecem não implementadas — são issues separadas que também consomem a mesma matriz/serviço.

### Pendências
- Validação manual (abrir cada nível, incluindo Region com muitos furos do seed de GT-0001) não executada nesta sessão — recomendada antes do merge.
- Teto de `pageSize` no backend (`PageParams.MaxPageSize`) segue como dívida técnica separada, já registrada em GADR-0001/#349/#350 — não bloqueante para esta task.

## Validação
- `ng build --configuration development` — sucesso (exit 0), sem erros; únicos warnings (`NG8107`) são pré-existentes e em linhas não tocadas por esta mudança.
- `ng test` (escopo `drill-hole-view-mult` + `entity-guides`) — `TOTAL: 15 SUCCESS` (12 specs pré-existentes + 3 novos cobrindo região/depósito/mineArea do fluxo agregador).
- PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/366 (branch `feature/gt-0022-e4-03-multiview-desde-region` → `feature/visualizadores-navegacao-layout`).

## Handoff
Depende de GT-0004, GT-0020 (ambos já mesclados na branch de integração). PR #366 mesclado (squash) em `feature/visualizadores-navegacao-layout`. Validação manual completa (todos os níveis) fica para a sessão de teste do usuário na branch de integração.
