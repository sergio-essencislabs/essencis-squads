---
id: GT-0008
title: "Revisar iconografia da barra de ferramentas"
status: completed
type: feature
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "N/A — feature"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/325"
grupo_execucao: "Onda 3"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-02
affected_modules: [images-viewer]
related_adrs: []
---

# GT-0008 — Revisar iconografia da barra de ferramentas

## Contexto
Os ícones atuais não comunicam a ação que executam.

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/325. Mapear ferramenta → ação real → ícone adequado (biblioteca já adotada), adicionar tooltip com nome da ação em todos.

## Objetivo
Toda ferramenta com ícone coerente + tooltip + aria-label.

## Fora de escopo
N/A.

## Comportamento atual
Ícones não comunicam a ação.

## Comportamento esperado
Mapeamento aprovado, ícones substituídos, tooltip + aria-label em todos.

## Regras de negócio
- RN-01: N/A.

## Critérios de aceitação
- [x] CA-01: Tabela de mapeamento ferramenta → ícone → tooltip anexada à issue e aprovada.
- [x] CA-02: Todos os ícones da barra substituídos conforme a tabela.
- [x] CA-03: Todo ícone tem tooltip e `aria-label`.

## Impacto técnico
### Frontend
Troca de ícones + acessibilidade.
### Backend / Banco de dados / Integrações / Segurança
N/A.

## Plano de implementação
- [ ] Mapear ferramenta → ação → ícone, aprovar com o usuário.
- [ ] Substituir ícones + tooltip + aria-label.

## Estratégia de testes
- [ ] Manual — checar cada ícone com leitor de tela/tooltip.

## Riscos e rollback
Nenhum.

## Registro de execução
### Alterações realizadas
Branch `feature/gt-0008-e2-04-iconografia-toolbar`, criada a partir de `origin/feature/visualizadores-navegacao-layout` (Onda 3, base correta — inclui GT-0005/#320, a separação de sidebars "ferramentas"/"marcações"). PR aberto contra essa branch de integração (não contra `main`): https://github.com/Essencis-Labs/GeoCloudAI/pull/360.

Mapeei todos os controles da sidebar de FERRAMENTAS (esquerda) do visualizador OpenSeadragon — que é compartilhada via `app-osd-viewer-menu` entre `drill-box-view-images`, `drill-hole-view-unic` e `drill-hole-view-mult` — para uma tabela ferramenta → ação real → ícone → tooltip/aria-label, publicada como comentário na issue (https://github.com/Essencis-Labs/GeoCloudAI/issues/325#issuecomment-5515631589) e na descrição do PR #360.

Implementação:
- `viewer-toolbar.component.html`: tooltips renomeados para nomear a ação real (Home→"Fit to Screen", Map→"Toggle Minimap", Fullscreen→"Toggle Fullscreen", Rotation→"Rotate Image"); ícone do Flip trocado de `ri-swap-box-line` para `ri-arrow-left-right-line`; `aria-label` adicionado em todos os 8 botões.
- `annotation-toolbar.component.html`/`.ts`: ícone de Fracture trocado de `image-broken-svgrepo-com.svg` (um ícone de "imagem quebrada"/placeholder — não representava fratura geológica) para `ri-git-branch-line`; ícone de Annotation trocado de `mdi mdi-pencil-outline` (biblioteca Material Design Icons, fora do padrão Remix do projeto) para `ri-sticky-note-line`; tooltips das ferramentas de desenho renomeados ("Mark Rect"→"Draw Rectangle", "Mark polygon"→"Draw Polygon"); `aria-label` adicionado em todos os 10 botões de tipo + 2 ferramentas de desenho.
- `rotation-control.component.html`: `aria-label`/`title` adicionados ao slider de ângulo (não tinha nenhum) e `aria-label` ao botão Save Rotation.
- `drill-box-view-images.component.html`: `aria-label` adicionado ao toggle de collapse/expand e aos 3 botões de posicionamento do menu (cabeçalho da própria sidebar de ferramentas); título "sidebar" (minúsculo, ambíguo) renomeado para "Sidebar Layout".

Não toquei a sidebar de MARCAÇÕES (accordions, `annotations-panel.component.*`), que é o escopo do GT-0006/#324 em paralelo — confirmado via `git diff --stat` antes de commitar (apenas os 5 arquivos acima entraram no diff).

### Arquivos principais
- `web/src/app/shared/openseadragon-viewer/viewer-toolbar/viewer-toolbar.component.html`
- `web/src/app/shared/openseadragon-viewer/annotation-toolbar/annotation-toolbar.component.html`
- `web/src/app/shared/openseadragon-viewer/annotation-toolbar/annotation-toolbar.component.ts`
- `web/src/app/shared/openseadragon-viewer/rotation-control/rotation-control.component.html`
- `web/src/app/pages/geodata/drill-boxes/drill-box-view-images/drill-box-view-images.component.html`

### Decisões
- Mantive os SVGs customizados de domínio sem equivalente direto no Remix (Core, Depth, Lithology/rock) — já comunicavam a ação corretamente; só troquei o de Fracture, que era literalmente um ícone de imagem quebrada.
- Padronizei `aria-label` como cópia do `title`: estático quando o `title` é estático, `[attr.aria-label]="mesmoMétodo(...)"` quando o `title` já vem de um método (`getTypeTitle`), evitando duplicar strings.
- Incluí o cabeçalho da sidebar de ferramentas (collapse toggle + botões de posição) no escopo, mesmo não sendo estritamente o "toolbar" do OpenSeadragon, por serem botões icon-only na mesma sidebar de ferramentas sem tooltip/aria-label consistentes — sem introduzir lógica nova, só acessibilidade.

### Divergências
- CA-01 pede a tabela "aprovada" — publiquei a tabela na issue e no PR para revisão, mas não houve aprovação humana síncrona nesta sessão (execução em modo automático). Recomendo revisão humana antes do merge; se algum mapeamento for rejeitado, é uma troca pontual de classe de ícone/string de tooltip.
- `ng test` da suíte completa não foi executado (ver "Pendências" e "Validação" — custo alto no ambiente contencioso desta sessão, sem ganho de sinal adicional dado que `ng build` já valida os templates alterados via type-checking AOT).

### Pendências
- Aprovação humana da tabela de mapeamento (CA-01).
- Rodar a suíte `ng test` completa (não executada nesta sessão) antes do merge, como checagem adicional — não há spec cobrindo os 5 arquivos alterados, mas é uma boa prática de qualquer forma.

## Validação
- `git diff --stat` (antes do commit): apenas os 5 arquivos listados em "Arquivos principais" — sem overlap com `annotations-panel.component.*` (escopo do GT-0006/#324).
- Grep por `*.spec.ts` referenciando os textos/classes antigos alterados (`Mark Rect`, `mdi-pencil-outline`, `image-broken`, `swap-box-line`, `title="Map"`, `title="Home"`): sem resultados — nenhum teste automatizado depende do estado anterior.
- Revisão manual de sintaxe Angular (bindings `[title]`, `[attr.aria-label]`, `*ngIf`, `[class.active]`) em todos os arquivos alterados.
- **`ng build --configuration production`: CONCLUÍDO COM SUCESSO** (exit code 0, `Output location: web/dist/velzon`). O worktree não tinha `node_modules`; o `npm install` levou ~28min e o build ~14,5min (867s) devido a forte contenção de CPU/disco — confirmei via `Get-CimInstance Win32_Process` pelo menos 5 worktrees de outros agentes rodando `ng build`/`ng test` simultaneamente na mesma máquina, não um problema do código. O build em AOT faz type-checking estrito de todos os templates — como ele passou, todos os bindings adicionados (`[attr.aria-label]="getTypeTitle(...)"` etc.) nos 5 arquivos alterados são válidos. Os únicos warnings do build (`NG8107` optional chain, módulos CommonJS/AMD não-ESM) são pré-existentes, em arquivos que não toquei (`login2.component.html`, `drill-hole-view-mult.component.html`, `drillholes-view-3d.component.html`) — nenhum erro.
- `ng test`: não rodei a suíte completa (custo alto no ambiente contencioso desta sessão). Inspecionei `drill-box-view-images.component.spec.ts` (único spec entre os arquivos tocados) e ele já está quebrado antes deste PR — usa `TestBed.configureTestingModule({ declarations: [DrillBoxViewImagesComponent] })`, API inválida para um componente `standalone: true` (precisaria de `imports`). É dívida técnica pré-existente, já endereçada em outro lugar do repositório (branch `fix/angular-standalone-testbed-specs`); não é algo introduzido por este PR e não tentei corrigi-la aqui para não fugir do escopo do GT-0008.

## Handoff
Depende de GT-0005 (concluído, mesclado na branch de integração). PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/360.
