---
id: GT-0027
title: "Remover (comentar) guias de visualização legadas — manter só Images, Single View, MultiView, KoreGeo3"
status: active
type: feature
achado_origem: "N/A — escopo extra pedido pelo usuário (2026-09-02)"
auditor_origem: "Usuário (Sergio Mendes), via Jarvis"
severidade: "N/A — chore de fechamento"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-tomas-jarvis-visualizadores-2"
issue_url: ""
status_atualizado: completed
grupo_execucao: "Onda 5 — Fechamento (só após todo o resto do projeto estar implementado e validado)"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-02
affected_modules: [drill-hole-view]
related_adrs: [GADR-0002]
---

# GT-0027 — Remover guias de visualização legadas

## Contexto
Pedido do usuário (2026-09-02): "Após conclusão da implementação na branch, remover todas as guias de visualização que não são Images, Single View, Multi View e KoreGeo3. Basta comentar elas no código com `//`."

## Achado original
Investigação de código em `web/src/app/pages/geodata/drill-holes/drill-hole-view/drill-hole-view.component.html` (o nav de tabs da tela de detalhe de DrillHole) encontrou 11 tabs no total. Das relacionadas a visualização de imagem/testemunho:

| Tab | `ngbNavItem` | Componente | Ação |
|---|---|---|---|
| Images | 3 | `app-drill-hole-view-images` | **Manter** |
| Images 2 | 4 | `app-drill-hole-view-images2` | **Comentar** — não mapeada em nenhuma issue original, achada só nesta investigação; confirmado pelo usuário em 2026-09-02 |
| KoreGeo | 7 | `app-drill-hole-view-koregeo` | **Comentar** — versão v1, sem número |
| KoreGeo 2 | 8 | `app-drill-hole-view-koregeo2` | **Comentar** |
| KoreGeo 3 | 9 | `app-drill-hole-view-koregeo3` | **Manter** |
| Multi View | 10 | `app-drill-hole-view-mult` | **Manter** |
| Single View | 11 | `app-drill-hole-view-unic` | **Manter** |

Tabs não relacionadas a visualização de imagem (Drill Boxes, Deviations, Runs, e a tab 1 de detalhe) ficam fora do escopo — não são "guias de visualização" no sentido discutido nos épicos.

`DrillBoxView` (`drill-box-view.component.html`) não tem duplicação — só "Overview" e "Box Image" — nada a remover ali.

## Objetivo
Só as 4 guias combinadas (Images, Single View, MultiView, KoreGeo3) continuam acessíveis via UI; as demais ficam comentadas no código (recuperáveis, não deletadas).

## Fora de escopo
Rotas em `pages.routes.ts` (`drillHoleViewKoregeo`, `drillHoleViewKoregeo2`) — o pedido foi comentar no código da tela, não necessariamente remover a rota; avaliar se faz sentido comentar a rota também para consistência, ou deixá-la acessível só por URL direta (decidir na implementação).

## Comportamento atual
7 guias de visualização acessíveis (Images, Images 2, KoreGeo, KoreGeo 2, KoreGeo 3, Multi View, Single View).

## Comportamento esperado
4 guias acessíveis (Images, Single View, MultiView, KoreGeo3); as demais comentadas com `//` no HTML (bloco `<li>` do `ngbNavItem`), não deletadas.

## Regras de negócio
- RN-01: N/A.

## Critérios de aceitação
- [x] CA-01: Confirmar com o usuário se "Images 2" também deve ser comentada — **confirmado em 2026-09-02: sim**.
- [x] CA-02: Tabs "KoreGeo" (v1), "KoreGeo 2" e "Images 2" comentadas no `drill-hole-view.component.html`.
- [x] CA-03: Tabs "Images", "KoreGeo 3", "Multi View", "Single View" continuam funcionais, sem regressão (confirmado por `ng build` limpo — nenhuma delas foi tocada).
- [x] CA-04: Executada só depois que GT-0024 (#359) e GT-0025 (#365) mescladas na integração.
- [x] CA-05: Comentário no código (`<!-- -->` no HTML, `//` no TS), nunca exclusão do arquivo/componente.

## Impacto técnico
### Frontend
`drill-hole-view.component.html` — comentar blocos `<li [ngbNavItem]="4|7|8">` (Images 2, KoreGeo, KoreGeo 2).
### Backend / Banco de dados / Integrações / Segurança
N/A.

## Plano de implementação
- [x] Confirmar com o usuário o caso "Images 2" (CA-01) — confirmado.
- [x] Comentar as 3 tabs (Images 2, KoreGeo, KoreGeo 2).
- [x] Validar que as 4 guias mantidas continuam funcionando (via `ng build`; QA manual em navegador fica para a sessão de teste do usuário na branch de integração).

## Estratégia de testes
- [ ] Manual — abrir a tela de DrillHole, confirmar só 4 guias de visualização visíveis + demais tabs não afetadas (Drill Boxes, Deviations, Runs). **Não executado nesta sessão** (sem ambiente full-stack rodando) — fica para a validação manual do usuário.

## Riscos e rollback
Comentar em vez de deletar já é a proteção de rollback pedida pelo usuário — reverter é só descomentar.

## Registro de execução
### Alterações realizadas
Executada diretamente por Jarvis (sem despachar agente dedicado — mudança pequena, reversível, sem ambiguidade de design). Branch `feature/gt-0027-remover-guias-legadas`, a partir de `origin/feature/visualizadores-navegacao-layout`.

- `drill-hole-view.component.html`: os 3 blocos `<li [ngbNavItem]="4|7|8">` (Images 2, KoreGeo, KoreGeo 2) envolvidos em comentário HTML `<!-- ... -->`, com uma linha explicando o motivo (GT-0027/E5-04) e apontando para a paridade já atingida pelo KoreGeo3.
- `drill-hole-view.component.ts`: os 3 `import` correspondentes e as 3 entradas em `imports:` do `@Component` também comentados com `//` — sem isso, o `ng build` emitia `TS-998113` ("componente não usado no template") para os 3; comentar os dois lados junto com o HTML deixa o revert completo (só descomentar as 3 partes).
- Nenhuma rota (`pages.routes.ts`) tocada — confirmado como fora de escopo desta task; as rotas `drillHoleViewKoregeo`/`drillHoleViewKoregeo2` continuam existindo, só não há mais link de UI para elas a partir da tela de DrillHole.
- `DrillBoxView` não tinha duplicação (confirmado na investigação original) — nada a fazer ali.

### Arquivos principais
- `web/src/app/pages/geodata/drill-holes/drill-hole-view/drill-hole-view.component.html`
- `web/src/app/pages/geodata/drill-holes/drill-hole-view/drill-hole-view.component.ts`

### Decisões
- Comentário duplo (HTML + TS) em vez de só o HTML, para eliminar o warning `TS-998113` do build e manter o revert atômico (as 3 partes do "religar" uma guia ficam juntas, comentadas com a mesma referência a GT-0027/E5-04).

### Divergências
Nenhuma em relação à task original.

### Pendências
- QA manual em navegador (abrir DrillHole, confirmar só 4 guias visíveis, nenhuma regressão nas demais tabs) não executada nesta sessão — sem ambiente full-stack disponível. Fica para a sessão de teste manual do usuário na branch de integração.

## Validação
- `npm ci` + `ng build --configuration development` (branch `feature/gt-0027-remover-guias-legadas`, a partir de `origin/feature/visualizadores-navegacao-layout`): sucesso, exit 0. Antes de comentar os imports/`imports:` no `.ts`, o build emitia 3 warnings novos `TS-998113` (componentes agora não referenciados no template) — resolvido comentando também o lado TS; build final só tem os 3 warnings `NG8107` pré-existentes de sempre (`login2`, `drill-hole-view-mult`, `drillholes-view-3d`), nenhum novo.
- PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/370 (mesclado, squash, em `feature/visualizadores-navegacao-layout`).

## Handoff
Última task do projeto. Dependia de GT-0024 (#359) e GT-0025 (#365), ambas mescladas antes desta task começar. **PR #370 mesclado.** Fica só a QA manual (ver Pendências) para a sessão de teste do usuário.
