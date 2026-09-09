---
id: GT-0019
title: "Acesso ao Single View desde Region"
status: completed
type: feature
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "N/A — feature"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/332"
grupo_execucao: "Onda 4"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-02
affected_modules: [single-view, navegacao]
related_adrs: [GADR-0001]
pr_url: "https://github.com/Essencis-Labs/GeoCloudAI/pull/371"
---

# GT-0019 — Single View desde Region

## Contexto
Tornar o Single View acessível a partir de Region e dos níveis intermediários, conforme a matriz de GT-0004.

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/332. Definir comportamento ao abrir num nível agregador (seleção de furo vs. agregação) — decisão de GT-0004/GADR-0001.

## Objetivo
Guia disponível a partir de Region, comportamento agregador implementado conforme GADR-0001.

## Fora de escopo
N/A.

## Comportamento atual
Single View não acessível de Region.

## Comportamento esperado
Disponível a partir de Region, comportamento agregador conforme decidido.

## Regras de negócio
- RN-01: N/A.

## Critérios de aceitação
- [x] CA-01: Guia disponível a partir de Region (e Deposit/Mine/MineArea, pela mesma matriz de GT-0004).
- [x] CA-02: Comportamento no nível agregador implementado conforme decidido em GT-0004/GADR-0001 (seleção obrigatória, sem auto-load — Alternativa C).

## Impacto técnico
### Frontend
Integração com config de GT-0004.
### Backend
Pode exigir endpoint de agregação/seleção — depende da decisão do GADR-0001.
### Banco de dados / Integrações / Segurança
N/A.

## Plano de implementação
- [x] Consumir decisão de GADR-0001.
- [x] Implementar acesso desde Region (e Deposit/Mine/MineArea).

## Estratégia de testes
- [x] Automatizado — 5 specs novos em `drill-hole-view-unic.component.spec.ts` cobrindo carga a partir de Region/Deposit/Mine/MineArea e a não-pré-seleção de furo.
- [ ] Manual — abrir Single View a partir de Region (pendente de validação humana em ambiente real; não bloqueante, ver Pendências).

## Riscos e rollback
Nenhum.

## Registro de execução
### Alterações realizadas
Seguindo o precedente direto de GT-0022 (#366, MultiView), o `DrillHoleViewUnicComponent`
(Single View) ganhou `@Input() aggregatorLevel`/`aggregatorEntityId` e um novo método
`loadAggregatorDrillHoles()` que usa o mesmo `DescendantDrillHolesLoaderService` já criado
por GT-0022 para listar os furos descendentes via `DrillHole/getBy{Region|Deposit|Mine|MineArea}`
(pageSize=10, direct=false — estratégia de carga já decidida em GADR-0001). A guia "Single View"
foi adicionada como nova aba em `region-view`, `deposit-view`, `mine-view` e `mine-area-view`,
no mesmo padrão de nomes/estrutura da aba "Multi View".

A diferença de comportamento exigida por GADR-0001 (Alternativa C) foi implementada aproveitando
uma característica já existente do componente: a sidebar de seleção de furos do Single View
(usada hoje quando a guia é aberta a partir de um DrillHole específico — ela lista todos os furos
da MineArea daquele furo) já não pré-seleciona nada; o usuário sempre marca manualmente o(s)
furo(s) que quer ver. `loadAggregatorDrillHoles()` populam a mesma lista (`drillHolesWithBoxes`,
todos com `isSelected: false`) a partir dos furos descendentes do nível agregador — nenhum furo é
escolhido automaticamente, e nada renderiza no viewer até a seleção manual. Isso satisfaz CA-02
sem precisar de nenhuma tela nova: é a mesma UI/UX que já existia, só com uma fonte de dados nova.

Pequenos ajustes de UX (não obrigatórios pelos CAs, mas alinhados ao padrão do MultiView):
label "— Region/Deposit/Mine/Mine Area" no cabeçalho da sidebar (`aggregatorLevelLabel`, mesma
convenção de nomes do MultiView) e um hint "Select a drill hole below to open it in Single View"
exibido só quando `aggregatorLevel` está setado e nada foi selecionado ainda.

### Arquivos principais
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.ts` — `@Input()`s, `loadAggregatorDrillHoles()`, `aggregatorLevelLabel`.
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.html` / `.scss` — label da sidebar e hint de seleção obrigatória.
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.spec.ts` — 5 specs novos (CA-01/CA-02).
- `web/src/app/pages/geodata/regions/region-view/region-view.component.{ts,html}` — nova aba Single View.
- `web/src/app/pages/geodata/deposits/deposit-view/deposit-view.component.{ts,html}` — idem.
- `web/src/app/pages/geodata/mines/mine-view/mine-view.component.{ts,html}` — idem.
- `web/src/app/pages/geodata/mine-areas/mine-area-view/mine-area-view.component.{ts,html}` — idem.
- Reaproveitados sem alteração: `web/src/app/shared/entity-guides/descendant-drill-holes-loader.service.ts` e `entity-guide.model.ts` (GT-0004/GT-0022).

### Decisões
- Não foi criada nenhuma tela/rota nova para a seleção de furo — a sidebar já existente do Single
  View (usada hoje pelo fluxo "furos da MineArea do DrillHole aberto") já implementa exatamente
  o comportamento "seleção obrigatória, nada pré-selecionado" que GADR-0001 pede; reaproveitá-la
  evita divergência de UX entre "Single View aberto de um furo" e "Single View aberto de um nível
  agregador".
- Estratégia de carga idêntica à de GT-0022 (mesmo `DescendantDrillHolesLoaderService`, pageSize=10,
  direct=false por padrão) — nenhuma decisão nova de paginação/teto foi tomada aqui; segue a mesma
  dívida técnica já registrada em GADR-0001 (teto de `pageSize` no backend ainda pendente, GT-0004).

### Divergências
Nenhuma da decisão de GADR-0001. Um novo achado local: a mesma sequência de arquivos
(`region-view`/`deposit-view`/`mine-view`/`mine-area-view` `.html`/`.ts`) recebeu, entre o início
e o fim desta execução, mais um merge concorrente na integração (GT-0026/KoreGeo3, #369, mesmo
padrão de aba nova nos mesmos 4 arquivos) — resolvido localmente via rebase antes de abrir o PR
(ver Handoff).

### Pendências
- Validação manual real (abrir a guia Single View a partir de uma Region/Deposit/Mine/MineArea
  de dados de fato e confirmar visualmente o fluxo de seleção) não foi executada nesta sessão —
  fora do alcance de `ng build`/`ng test` headless. Não bloqueante para o merge, mas recomendado
  antes do release.

## Validação
```bash
cd web && npx ng build --configuration development
# Application bundle generation complete. Únicos warnings são os 3 pré-existentes
# (login2, drill-hole-view-mult, drillholes-view-3d) — nenhum novo.

cd web && npx ng test --watch=false --browsers=ChromeHeadlessCI \
  --include='**/drill-hole-view-unic/**/*.spec.ts' \
  --include='**/region-view/**/*.spec.ts' \
  --include='**/deposit-view/**/*.spec.ts' \
  --include='**/mine-view/**/*.spec.ts' \
  --include='**/mine-area-view/**/*.spec.ts' \
  --include='**/entity-guides/**/*.spec.ts' \
  --include='**/drill-hole-view-mult/**/*.spec.ts' \
  --include='**/koregeo3-aggregator/**/*.spec.ts'
# TOTAL: 6 FAILED, 48 SUCCESS
```
As 6 falhas foram confirmadas como pré-existentes contra a baseline via `git stash` (mesmo erro,
mesma linha, antes de qualquer alteração desta task): 4x bug conhecido `TestBed.declarations` em
componente standalone (`region-view`/`deposit-view`/`mine-view`/`mine-area-view` `.component.spec.ts`
— mesma categoria do fix de PR #356, mas estes 4 specs específicos não foram cobertos por aquele PR);
1x `NullInjectorError` (HttpClient sem provider) em `DrillHoleViewUnicComponent` "should create"
(spec pré-existente, nunca cobria `HttpClientTestingModule`); 1x falha de cálculo em
`single-view-metric-layout.spec.ts` (não relacionada a Single View "aggregator entry"). Nenhuma
nova falha introduzida por esta task.

## Handoff
Depende de GT-0004 (concluída) e reaproveita infraestrutura de GT-0022 (`DescendantDrillHolesLoaderService`).

**PR**: https://github.com/Essencis-Labs/GeoCloudAI/pull/371 (branch `feat/gt-0019-single-view-desde-region`
→ `feature/visualizadores-navegacao-layout`).

**Aviso de conflito**: esta branch foi criada a partir de `origin/feature/visualizadores-navegacao-layout`
e, durante a execução, mais 3 commits foram mesclados na integração (GT-0026/KoreGeo3 #369, GT-0011/Images
#368, chore #370) — incluindo GT-0026, que tocava exatamente os mesmos 4 arquivos
`region-view`/`deposit-view`/`mine-view`/`mine-area-view` (`.html`/`.ts`) para adicionar sua própria aba
nova. O conflito de merge textual (mesma lista `<ul ngbNav>`, `<li>`s adjacentes) já foi resolvido
localmente via `git rebase` antes de abrir o PR — a resolução foi por união simples (ambas as abas,
KoreGeo3 e Single View, mantidas, renumerando `[ngbNavItem]` sequencialmente). Se novo trabalho aditivo
equivalente for mesclado na integração antes deste PR ser revisado, é esperado o mesmo tipo de conflito
textual — resolução sempre por união, nunca por escolha de um lado (mesmo padrão de GT-0009 vs GT-0010).

**PR #371 mesclado (squash) em `feature/visualizadores-navegacao-layout`** — verificado sem colisão de `[ngbNavItem]` nas 4 telas (região: MultiView=7/KoreGeo3=8/SingleView=9; deposit: 6/7/8; mine: 5/6/7; mineArea: 4/5/6).
