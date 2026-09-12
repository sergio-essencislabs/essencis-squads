---
id: GT-0007
title: "Lista de caixas: tornar retrátil e remover o seletor inferior"
status: active
type: feature
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "N/A — feature"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/321"
grupo_execucao: "Onda 2"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-02
affected_modules: [images-viewer]
related_adrs: []
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0007 — Lista de caixas retrátil, remover seletor inferior

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
Existem hoje dois pontos de seleção de caixa (menu lateral com miniaturas + barra inferior). Redundante.

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/321. Adicionar botão de minimizar/expandir a lista lateral; remover o menu inferior — seleção passa a ser exclusivamente pelo menu lateral.

## Objetivo
Um único ponto de seleção de caixa, recolhível.

## Fora de escopo
N/A.

## Comportamento atual
Dois pontos de seleção redundantes.

## Comportamento esperado
Só o menu lateral, recolhível.

## Regras de negócio
- RN-01: N/A.

## Critérios de aceitação
- [x] CA-01: Menu inferior não existe mais na tela (no contexto do visualizador de Images do DrillHole — ver Decisões sobre o escopo em `drill-box-view`).
- [x] CA-02: Lista lateral de miniaturas recolhe e expande por botão.
- [x] CA-03: Toda navegação entre caixas (incluindo teclado/atalhos, se existirem) continua funcionando apenas pelo menu lateral.

## Impacto técnico
### Frontend
Remoção do menu inferior, adição de toggle na lista lateral.
### Backend / Banco de dados / Integrações / Segurança
N/A.

## Plano de implementação
- [x] Adicionar toggle na lista lateral.
- [x] Remover menu inferior, migrando atalhos de teclado se existirem.

## Estratégia de testes
- [x] Manual — navegar por caixas usando só o menu lateral, incluindo atalhos (ver Validação; não há atalhos de teclado ligados à barra removida).

## Riscos e rollback
Perder atalho de teclado hoje só suportado pelo menu inferior — validar antes de remover.

## Registro de execução
### Alterações realizadas
- Investigado o fluxo real (não assumido a partir da issue): o "menu lateral com miniaturas" vive em `drill-hole-view-images` e `drill-hole-view-images2` (as duas abas "Images"/"Images 2" da tela DrillHole View); a "barra inferior" redundante ("Other boxes from <drill hole>") vive dentro do componente compartilhado `drill-box-view-images`, renderizado dentro dos dois hosts acima.
- Adicionado botão de minimizar/expandir (`toggleSidebar()` / `sidebarCollapsed`) na coluna da lista lateral de miniaturas, em ambos `drill-hole-view-images` e `drill-hole-view-images2`. Ícone Remix (`ri-arrow-left-s-line` / `ri-arrow-right-s-line`, já usado em outras telas do projeto) alterna com o estado; ao colapsar, a coluna encolhe para `col-auto` (largura mínima, só o botão) e a área de imagem ocupa o espaço restante (`col`).
- Adicionado `@Input() showOtherBoxesBar` (default `true`) em `DrillBoxViewImagesComponent`, controlando a exibição — e também o fetch HTTP (`getOtherBoxes()`) — da barra "Other boxes". Os dois hosts do visualizador do DrillHole passam `[showOtherBoxesBar]="false"`.
- Buscado por atalhos de teclado (`HostListener`, `keydown`, `ArrowLeft/Right`) ligados à navegação entre caixas em toda a pasta `pages/geodata`: não existe nenhum. A navegação sempre foi por clique (`drillBoxView(id)` na lista lateral, `selectOtherBox(box)` na barra inferior). Não havia nada para "migrar" — CA-03 já era satisfeito pela lista lateral existente.

### Arquivos principais
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-images/drill-hole-view-images.component.ts/.html/.scss`
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-images2/drill-hole-view-images2.component.ts/.html/.scss`
- `web/src/app/pages/geodata/drill-boxes/drill-box-view-images/drill-box-view-images.component.ts/.html`

### Decisões
- **Escopo de CA-01 restrito ao visualizador de Images do DrillHole.** `DrillBoxViewImagesComponent` também é usado de forma standalone em `pages/geodata/drill-boxes/drill-box-view` (visualização de uma caixa avulsa, fora do contexto de um DrillHole), tela que **não tem** lista lateral equivalente — lá, a barra "Other boxes" é o único meio de navegar entre caixas da mesma sondagem (inclusive o link "View all" que leva de volta ao DrillHole View). Remover a barra incondicionalmente quebraria essa navegação sem substituto. Optei por um `@Input` (`showOtherBoxesBar`, default `true`) em vez de excluir o código, desligando a barra apenas onde ela é de fato redundante (os dois hosts do DrillHole), preservando o comportamento atual em `drill-box-view`. Isso segue o padrão já usado no próprio componente para outros toggles de UI (`showAiChatButton`, `showViewerToolbar` etc. em `ViewerMenuComponent`).
- Optei por não remover o código/CSS da barra "Other boxes" (`.dbx-other-boxes*` no scss), já que ainda está em uso ativo em `drill-box-view`.

### Divergências
- Nenhuma em relação aos critérios de aceite. Divergência apenas de interpretação de escopo (ver Decisões acima) — se o time quiser remover a barra também de `drill-box-view`, é um ticket à parte pois exigiria um substituto de navegação lá (não há lista lateral nesse contexto).

### Pendências
- Validação visual manual (abrir a tela, clicar no toggle, confirmar ausência da barra inferior nas abas Images/Images 2) não foi possível neste ambiente (sem acesso a navegador/backend rodando) — sinalizado no PR como item pendente do test plan.

## Validação
- `cd web && ng build --configuration=production`: sucesso. Nenhum erro nos arquivos alterados; apenas warnings pré-existentes em componentes não relacionados (`Login2Component`, `DrillHoleViewMultComponent`, `Drillholesview3DComponent`) e avisos de dependências CommonJS (openseadragon, geotiff etc.), todos anteriores a esta mudança.
- `cd web && ng test --watch=false --browsers=ChromeHeadless` (specs de `DrillHoleViewImagesComponent`, `DrillHoleViewImages2Component`, `DrillBoxViewImagesComponent`): 3 falhas, todas pré-existentes na branch base (`TestBed.configureTestingModule({ declarations: [...] })` usando `declarations` para componentes `standalone: true` — erro do Angular 19, não relacionado a esta mudança). Confirmado reproduzindo a mesma falha após `git stash` das minhas alterações (voltando ao estado da branch base) e reexecutando o mesmo comando.
- Grep por `HostListener|keydown|ArrowLeft|ArrowRight` em `pages/geodata`: nenhum resultado ligado à navegação de caixas — confirma que não há atalho de teclado para migrar (CA-03 trivialmente satisfeito).

## Handoff
- PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/352 (branch `feature/e2-03-lista-caixas-retratil` → base `feature/visualizadores-navegacao-layout`).
- Pendência de validação manual visual antes do merge (ver Pendências).
- Nota operacional: durante a execução, o diretório de trabalho (`.claude/worktrees/agent-afc9718542393ee3f`) mostrou evidências de uso concorrente por outra sessão (arquivos `drill-hole-view-unic.component.ts` e `drillCoreMineralization.service.ts` modificados por terceiros, e um `git stash` meu foi sobrescrito por um stash de outra sessão com um refactor de i18n `uiText` não relacionado). Não commitei nem toquei nesses arquivos/stash alheios; apenas os 8 arquivos desta task foram staged e commitados por caminho explícito. Recomendo evitar reaproveitar esse worktree para tasks paralelas simultâneas sem isolamento adicional.
