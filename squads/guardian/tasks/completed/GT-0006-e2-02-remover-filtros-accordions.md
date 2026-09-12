---
id: GT-0006
title: "Remover filtros dos accordions de marcações"
status: completed
type: feature
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "N/A — chore"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/324"
grupo_execucao: "Onda 3"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-02
affected_modules: [images-viewer]
related_adrs: []
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0006 — Remover filtros dos accordions de marcações

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
Simplificação da sidebar direita de marcações (GT-0005).

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/324. Retirar controles de filtro dos accordions — lista sempre completa.

## Objetivo
Accordions sem filtro, lista completa sem regressão de performance.

## Fora de escopo
N/A.

## Comportamento atual
Accordions têm controles de filtro.

## Comportamento esperado
Sem filtro, lista completa sempre.

## Regras de negócio
- RN-01: N/A.

## Critérios de aceitação
- [x] CA-01: Nenhum campo/controle de filtro visível nos accordions.
- [x] CA-02: Lista completa de marcações renderiza sem regressão de performance em caixas com muitas marcações (validar com GT-0001). — validado por análise de complexidade + `ng build`; ver "Validação" (não houve execução manual em ambiente full-stack rodando, ver "Pendências").

## Impacto técnico
### Frontend
Remoção de controles + validação de performance com lista completa.
### Backend / Banco de dados / Integrações / Segurança
N/A.

## Plano de implementação
- [x] Remover controles de filtro.
- [x] Validar performance com dado real do seed (GT-0001) — validação por análise de complexidade, não por medição manual em navegador (ver "Divergências").

## Estratégia de testes
- [x] Manual — caixa com muitas marcações, medir performance. — não executado como teste manual em navegador nesta sessão (sem ambiente full-stack interativo disponível); substituído por análise de complexidade documentada em "Validação". `ng build --configuration development` executado com sucesso.

## Riscos e rollback
Nenhum.

## Registro de execução
### Alterações realizadas
- Removidos os 10 blocos `.filter-bar` (input de texto + wrapper) do template
  `annotations-panel.component.html`, um por accordion: Drill Cores, Depths,
  Fracture, Lithology, Alterations, Mineral Occurrences, Mineralizations,
  Textures, Structures, Annotations.
- Removidos, no componente `AnnotationsPanelComponent`
  (`annotations-panel.component.ts`): o record `filterText`, o método privado
  `applyFilter()` e os 10 getters `filtered*` (`filteredCores`,
  `filteredDepths`, `filteredFractures`, `filteredLithologies`,
  `filteredAnnotations`, `filteredAlterations`, `filteredMineralOccurrences`,
  `filteredMineralizations`, `filteredTextures`, `filteredStructures`).
- Os getters `*GroupedByBox` (e `coresGroupedByHole`) passaram a consumir
  diretamente os `@Input()` originais (`drillCoreDepths`, `drillCoreFractures`
  etc.) em vez dos getters `filtered*` removidos — o agrupamento por
  caixa/furo (`groupByBox`/`groupByBoxFromList`) não mudou.
- Removidos os 3 blocos `.empty-msg` ("No results for...") que só existiam
  para o caso de filtro sem resultado (core/depths/annotation).
- `FormsModule` removido dos imports do componente standalone — não havia
  mais nenhum `[(ngModel)]` no template depois da remoção dos inputs de
  filtro.
- CSS morto removido: bloco `.filter-bar` (com estilos do `input` interno) e
  `.empty-msg` em `annotations-panel.component.scss`; regra responsiva
  `.filter-bar input` (fonte 10px) dentro do bloco "Filtros (accordions)" em
  `drill-box-view-images.component.scss`, renomeado o comentário para
  "Accordions (marcações)" já que não há mais filtro ali.

### Arquivos principais
- `web/src/app/shared/openseadragon-viewer/annotations-panel/annotations-panel.component.ts`
- `web/src/app/shared/openseadragon-viewer/annotations-panel/annotations-panel.component.html`
- `web/src/app/shared/openseadragon-viewer/annotations-panel/annotations-panel.component.scss`
- `web/src/app/pages/geodata/drill-boxes/drill-box-view-images/drill-box-view-images.component.scss`

### Decisões
- Escopo limitado ao `AnnotationsPanelComponent` (a sidebar de marcações
  separada pelo GT-0005/#320) — é o único lugar do app com accordions de
  marcação com filtro; outros usos de "filter"/"applyFilters" no repo
  (`drillholes-view-3d.component.ts`, `mine-3d-view.component.ts`) são
  filtros de uma feature de visualização 3D não relacionada e fora do
  escopo desta issue.
- Em vez de apenas esconder os inputs via CSS, o código de filtragem
  (`filterText`/`applyFilter`/getters `filtered*`) foi removido por
  completo — não faz sentido manter lógica morta e sem uso quando o CA-01
  exige que a lista seja *sempre* completa (não há mais um caminho de UI
  para acioná-la).

### Divergências
- O termo de filtro de cada accordion sempre começava vazio
  (`filterText[type] = ''`), e `applyFilter` retornava a lista completa
  quando o termo era vazio (`if (!term) return items;`). Ou seja, **"lista
  completa" já era o comportamento padrão antes desta tarefa** — o usuário
  precisava digitar algo para reduzir a lista. Isso muda a leitura do CA-02:
  não há alteração no volume de linhas renderizado no caso comum (accordion
  aberto sem filtro digitado); a única coisa que a mudança elimina é (a) a
  possibilidade de o usuário filtrar e (b) a variação extra de computação
  (`Array.prototype.filter` com montagem de string por item) que rodava a
  cada tecla digitada quando alguém usava o filtro. Isso é registrado aqui
  porque contradiz a suposição implícita da tarefa de que "muitas
  marcações" + "sem filtro" seria um cenário novo de carga — na prática, já
  era o cenário padrão.
- Validação de performance do CA-02 não foi feita via execução manual em
  navegador com a massa de dados do GT-0001/#316 rodando (API + MySQL +
  `ng serve`) — o agente que executou esta tarefa não tinha, na sessão,
  acesso a um navegador interativo acoplado a um ambiente full-stack local
  para clicar na UI e cronometrar. A validação executada foi: (1) `ng build
  --configuration development` limpo, sem erros novos (confirma que o
  template compila e que nenhum outro spec/arquivo do repo referenciava os
  membros removidos); (2) busca no repositório confirmando que nenhum
  outro arquivo (`*.ts`/`*.html`) referenciava `filterText`, `filtered*` ou
  `.filter-bar` do `AnnotationsPanelComponent`; (3) análise de
  complexidade (ver "Divergências" acima) mostrando que a mudança só
  remove trabalho, nunca adiciona. Registrado como pendência abaixo para
  quem revisar o PR com ambiente local rodando.
- Não existe spec (`*.spec.ts`) dedicado ao `AnnotationsPanelComponent`
  hoje — não havia teste automatizado prévio para atualizar ou quebrar.

### Pendências
- Confirmação visual manual (fora desta sessão): abrir Single View de um
  furo do seed GT-0001/#316 (ex.: `SEED-DH-01`, 12 caixas / 36 testemunhos
  / 36 marcações de litologia / ~12 de fratura / ~9 de veio) com API +
  MySQL rodando localmente e conferir que os accordions abrem e rolam sem
  travamento perceptível. Não bloqueante para o merge dado o raciocínio de
  complexidade acima, mas recomendado antes de fechar a issue #324
  definitivamente.

## Validação
- `ng build --configuration development` (branch `chore/gt-0006-e2-02-remover-filtros-accordions`, a partir de `origin/feature/visualizadores-navegacao-layout`): build concluído com sucesso (exit code 0), sem erros novos. Os 3 warnings `NG8107` emitidos pertencem a outros componentes (`login2`, `drill-hole-view-mult`, `drillholes-view-3d`) não tocados por esta mudança — preexistentes.
- Busca (`grep`) no repositório confirmando ausência de qualquer outra referência a `filterText`, aos getters `filtered*` removidos ou à classe `.filter-bar` do `AnnotationsPanelComponent` fora dos 4 arquivos alterados.
- Não foi executado `ng test` completo (193 specs, nenhum deles cobre `AnnotationsPanelComponent`) nem validação manual em navegador com o seed GT-0001 rodando — ver "Pendências".

## Handoff
Depende de GT-0005 (#320), já mesclada na branch de integração
`feature/visualizadores-navegacao-layout`.

PR aberto: https://github.com/Essencis-Labs/GeoCloudAI/pull/361
(branch `chore/gt-0006-e2-02-remover-filtros-accordions` → base
`feature/visualizadores-navegacao-layout`). Pendência de validação visual
manual descrita acima deve ser conferida por quem revisar/mergear o PR,
ou registrada como follow-up se o merge ocorrer antes disso.
