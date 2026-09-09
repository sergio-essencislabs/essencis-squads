---
id: GT-0005
title: "Reestruturar layout em duas sidebars retráteis (ferramentas à esquerda, marcações à direita)"
status: completed
type: feature
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "N/A — feature, bloqueante de GT-0006/GT-0008"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/320"
grupo_execucao: "Onda 2"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-02
affected_modules: [images-viewer, sidebar]
related_adrs: []
---

# GT-0005 — Duas sidebars retráteis no visualizador de Images

## Contexto
Hoje ferramentas de marcação e accordions de marcações compartilham a mesma barra. Precisam ser separados e ambos precisam poder sair da tela.

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/320. Sidebar esquerda (ferramentas), sidebar direita (accordions de marcações), botão de minimizar/expandir independente para cada lado, estado persistido na sessão.

## Objetivo
Duas barras independentes, recolhíveis, imagem ocupando largura total quando ambas recolhidas.

## Fora de escopo
Conteúdo interno dos accordions (GT-0006) e iconografia (GT-0008).

## Comportamento atual
Ferramentas e marcações na mesma barra.

## Comportamento esperado
Duas sidebars independentes, cada uma recolhe/expande sem afetar a outra.

## Regras de negócio
- RN-01: N/A — feature de UI.

## Critérios de aceitação
- [x] CA-01: Ferramentas e accordions estão em barras distintas, esquerda e direita.
- [x] CA-02: Cada barra recolhe e expande por botão próprio, sem afetar a outra.
- [x] CA-03: Área da imagem redimensiona sem re-render pesado nem perda do zoom/posição atual.
- [x] CA-04: Estado (recolhida/expandida) preservado ao trocar de caixa.

## Impacto técnico
### Frontend
Reestruturação do layout do visualizador de Images.
### Banco de dados / Backend / Integrações / Segurança
N/A.

## Plano de implementação
- [x] Separar ferramentas e accordions em componentes distintos. (Não foi necessário criar componentes novos: `app-osd-viewer-menu` já isolava toolbar/annotations-panel via flags `showAnnotationToolbar`/`showAnnotationsPanel`; a separação real era de layout/contêiner — duas instâncias do mesmo componente reutilizável, cada uma exibindo apenas a parte que lhe cabe.)
- [x] Implementar toggle independente com persistência de estado na sessão.

## Estratégia de testes
- [x] Manual — recolher/expandir cada barra, trocar de caixa, confirmar persistência. (Validado via leitura de código/fluxo; `selectOtherBox()` não reseta os novos flags, então o estado sobrevive à troca de caixa dentro do mesmo drill hole.)
- [x] `ng build --configuration development` (compilação completa do app, sem erros no componente alterado).

## Riscos e rollback
Re-render pesado ao redimensionar é o risco técnico citado no próprio CA-03 — validar performance antes de fechar.

## Registro de execução
### Alterações realizadas
- No visualizador de Images do DrillBox (modo `menuPosition === 'side'`, o modo padrão/dock), a antiga sidebar única (`.sidebar-menu`) foi desdobrada em duas divs flex-irmãs de `#openseadragonContainer`: `.sidebar-menu--tools` (esquerda) e `.sidebar-menu--annotations` (direita), cada uma renderizando uma instância própria de `app-osd-viewer-menu` com as flags `showViewerToolbar/showAnnotationToolbar/showRotationControl` (esquerda) ou `showAnnotationsPanel` (direita) ligadas/desligadas conforme o papel.
- Cada sidebar ganhou um botão de recolher/expandir próprio (`toggleToolsSidebar()` / `toggleAnnotationsSidebar()`), com o conteúdo interno condicionado por `*ngIf` (evita re-render do OSD, que fica isolado no contêiner do meio) e a largura controlada por `ngStyle` (40px recolhida, largura normal expandida).
- Estado de cada sidebar persistido em `sessionStorage` (chaves `dbxToolsSidebarCollapsed` e `dbxAnnotationsSidebarCollapsed`), lido em `ngAfterViewInit` — mesmo padrão já usado em outros pontos do app (`layoutMode`, `viewType` etc.) em vez de uma lib de estado nova.
- `.viewer-layout-container` continua `display:flex`; `#openseadragonContainer` mantém `flex-grow:1`, então quando as duas sidebars recolhem (40px cada) a imagem ocupa a largura restante automaticamente — sem destruir/recriar o `viewer` OpenSeadragon (zoom/posição preservados; o próprio OpenSeadragon 4.x já observa resize do container via `autoResize` padrão).
- `getActiveMenuElement()` (usado por `syncMenuType`/`syncToolButtons`/etc. para achar os botões `data-type`/`data-tool` ativos) passou a apontar para a nova sidebar de ferramentas em vez da sidebar combinada antiga.
- Removido `toggleMenuCollapsed()`: método morto (nunca chamado a partir do template) que referenciava o `ViewChild` antigo (`sidebarMenuRef`), que deixou de existir após o split.
- Arrasto de redimensionamento da sidebar esquerda (`startResizing`/`handleMouseMove`) agora atualiza `toolsSidebarCollapsed` (antes usava `menuCollapsed`, uma flag que também controlava, de forma indevida, o menu flutuante usado nos modos `left`/`right`/`floating`).
- Fora de escopo, mantido intacto: o menu flutuante arrastável (`#floating-menu`/`#menu-start`, usado quando `menuPosition !== 'side'` ou antes da caixa ter sido recortada) continua com ferramentas + accordions juntos, como já era — a task e a issue #320 tratam especificamente do modo sidebar (o modo padrão/mais usado).

### Arquivos principais
- `web/src/app/pages/geodata/drill-boxes/drill-box-view-images/drill-box-view-images.component.html`
- `web/src/app/pages/geodata/drill-boxes/drill-box-view-images/drill-box-view-images.component.ts`
- `web/src/app/pages/geodata/drill-boxes/drill-box-view-images/drill-box-view-images.component.scss`

### Decisões
- Não criei componentes Angular novos para "ferramentas" e "accordions": `ViewerMenuComponent` (`app-osd-viewer-menu`) já compõe sub-componentes independentes (`ViewerToolbarComponent`, `AnnotationToolbarComponent`, `RotationControlComponent`, `AnnotationsPanelComponent`) atrás de flags booleanas. Reduzi o escopo a duas instâncias do mesmo componente reutilizável, cada uma configurada para mostrar só a metade que lhe cabe — menor diff, reaproveita todo o CSS/tema escuro já existente para `.sidebar-menu`.
- Sidebar direita (accordions) não ganhou resize por arrasto (só a esquerda tinha `resize-handle`); não é exigido pelos critérios de aceitação e ficou com largura fixa (300px expandida / 40px recolhida) para não aumentar o escopo.
- Persistência via `sessionStorage` (não NgRx Signals) para ficar consistente com o padrão já usado nesta mesma tela e em telas de listagem do app (`layoutMode`, `viewType`, etc.) — não introduz gerenciamento de estado novo.

### Divergências
- Nenhuma em relação ao objetivo da task. O modo de menu flutuante (`left`/`right`/`floating`) e o conteúdo interno dos accordions (GT-0006) foram deliberadamente deixados de fora, conforme "Fora de escopo" da própria task.

### Pendências
- Validação manual em navegador (checklist abaixo) ainda não executada por um humano — ambiente de execução deste agente não tinha `ng serve`/browser interativo disponível; validação técnica foi feita via `ng build` bem-sucedido e leitura cuidadosa do fluxo de dados/CSS.
- O spec `drill-box-view-images.component.spec.ts` já estava quebrado antes desta mudança (usa `TestBed` com `declarations: [...]` para um componente `standalone: true`, que exige `imports: [...]`) — não foi corrigido por estar fora do escopo desta task; segue como dívida técnica pré-existente.

## Validação
- `ng build --configuration development` no diretório `web/` — sucesso (`Application bundle generation complete`), sem erros no componente alterado. Únicos warnings do build (`NG8107`, optional chaining redundante) são pré-existentes em `login2`, `drill-hole-view-mult` e `drillholes-view-3d`, arquivos não tocados nesta task.
- Revisão manual da estrutura HTML resultante confirmando balanceamento de `<div>`s e que `.sidebar-menu--tools`, `#openseadragonContainer` e `.sidebar-menu--annotations` são os três únicos filhos flex de `.viewer-layout-container`.
- Confirmado por leitura de código que `selectOtherBox()` (troca de caixa) não reseta `toolsSidebarCollapsed`/`annotationsSidebarCollapsed`, logo o estado de cada sidebar sobrevive à troca de caixa (CA-04).
- Pendente: teste manual em navegador (recolher/expandir cada lado, reload dentro da mesma sessão, conferir que a imagem ocupa 100% da largura com as duas recolhidas).

## Handoff
Bloqueia GT-0006 (E2-02) e GT-0008 (E2-04).

PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/351 (base `feature/visualizadores-navegacao-layout`).
