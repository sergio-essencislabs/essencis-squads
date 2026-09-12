---
id: GT-0010
title: 'Botão "Analisar furo inteiro" (placeholder para visão computacional)'
status: active
type: feature
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "N/A — feature, só UI"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/327"
grupo_execucao: "Onda 3"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-02
affected_modules: [images-viewer]
related_adrs: []
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0010 — Botão "Analisar furo inteiro" (placeholder)

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
Futuro ponto de entrada da classificação automática de litologias por imagem. A visão computacional ainda não está integrada (ver `arquitetura/classificacao-automatica-litologias.md`, fluxos A-D).

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/327. **Escopo desta issue é só UI**: botão em posição definitiva, desabilitado com tooltip explicando indisponibilidade, contrato de chamada previsto (stub) para plugar depois.

## Objetivo
Botão presente e coerente visualmente, sem nenhuma inferência real — decisão de fluxo A/B/C/D fica para issue futura, não bloqueia esta.

## Fora de escopo
A inferência em si, o pipeline de importação, a geração de marcações — issue separada, a abrir junto com a decisão de fluxo A/B/C/D (needs-decision, não resolvido aqui).

## Comportamento atual
Sem ponto de entrada para a futura análise automática.

## Comportamento esperado
Botão desabilitado, tooltip explicativo, stub documentado.

## Regras de negócio
- RN-01: N/A — feature de UI, decisão de fluxo A-D é de outra issue.

## Critérios de aceitação
- [x] CA-01: Botão presente, visualmente coerente com GT-0008 (iconografia), desabilitado.
- [x] CA-02: Tooltip explicativo.
- [x] CA-03: Stub documentado para a futura integração (issue separada, a abrir junto com a decisão de fluxo A/B/C/D).

## Impacto técnico
### Frontend
Botão + stub de contrato de chamada.
### Backend / Banco de dados / Integrações / Segurança
N/A — nesta issue.

## Plano de implementação
- [x] Adicionar botão desabilitado + tooltip.
- [x] Documentar stub de contrato futuro.

## Estratégia de testes
- [x] Manual — confirmar botão desabilitado, tooltip visível. (Revisão de código + `ng build`/`ng test`; QA manual no app rodando não foi feita nesta sessão — sem backend/DB de dev disponível no ambiente do agente.)

## Riscos e rollback
Nenhum — é só UI.

## Registro de execução
### Alterações realizadas
- Botão "Analisar furo inteiro" adicionado à barra de ferramentas compartilhada do
  visualizador OpenSeadragon (`app-viewer-toolbar`, consumida via `app-osd-viewer-menu`).
  Sempre `disabled` + `aria-disabled="true"`, ícone `ri-scan-2-line`, `title` e
  `aria-label` explicando que a análise automática de litologias ainda não está
  disponível.
- Novo `@Input() showAnalyzeHoleButton` / `@Output() analyzeHoleClick` propagados de
  `ViewerToolbarComponent` → `ViewerMenuComponent` → consumidores.
- Habilitado nos dois pontos de entrada que representam "o visualizador do furo":
  - `drill-box-view-images` (visualizador por caixa, embutido em
    `drill-hole-view-images` / `drill-hole-view-images2`, que listam todas as caixas
    de um furo) — só quando já existe uma caixa/box definida (`imgBoxId > 0`).
  - `drill-hole-view-unic` (Single View — tira contínua somente-leitura do furo
    inteiro com régua de profundidade, GT-0015), que é o visualizador cujo conceito
    mais se aproxima literalmente de "furo inteiro".
- Stub documentado criado em
  `web/src/app/shared/openseadragon-viewer/drill-hole-analysis.stub.ts`:
  interfaces `DrillHoleAnalysisRequest`/`DrillHoleAnalysisResult` +
  `analyzeDrillHoleStub()`, que só rejeita a Promise com uma mensagem explicativa.
  Não faz nenhuma chamada HTTP real (não existe endpoint no backend para isto ainda).
  Handlers `onAnalyzeDrillHoleClick()` em ambos os componentes consumidores chamam o
  stub só para documentar o ponto de plugagem futuro — inalcançável a partir de um
  clique real hoje, já que o botão está sempre desabilitado.

### Arquivos principais
- `web/src/app/shared/openseadragon-viewer/viewer-toolbar/viewer-toolbar.component.ts`
- `web/src/app/shared/openseadragon-viewer/viewer-toolbar/viewer-toolbar.component.html`
- `web/src/app/shared/openseadragon-viewer/viewer-menu/viewer-menu.component.ts`
- `web/src/app/shared/openseadragon-viewer/viewer-menu/viewer-menu.component.html`
- `web/src/app/shared/openseadragon-viewer/drill-hole-analysis.stub.ts` (novo)
- `web/src/app/pages/geodata/drill-boxes/drill-box-view-images/drill-box-view-images.component.ts`
- `web/src/app/pages/geodata/drill-boxes/drill-box-view-images/drill-box-view-images.component.html`
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.ts`
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.html`

### Decisões
- A issue original diz apenas "adicionar o botão no visualizador, em posição
  definitiva", sem especificar qual visualizador — o app tem mais de um
  (`drill-box-view-images` por caixa, `drill-hole-view-unic` Single View,
  `drill-hole-view-mult` MultiView). Optei por colocar o botão na
  `ViewerToolbarComponent` compartilhada (mesmo componente que já hospeda os botões
  de navegador/fullscreen/rotação/AI chat, iconografia GT-0008), e habilitá-lo
  explicitamente nos dois lugares que semanticamente representam "o furo inteiro":
  o visualizador por caixa usado nas páginas de furo (`drill-hole-view-images`/`2`,
  que listam todas as caixas do furo) e o Single View (`drill-hole-view-unic`, a
  tira contínua do furo com régua de profundidade). Não habilitei no MultiView
  (`drill-hole-view-mult`) nem no estado "menu-start" de `drill-box-view-images`
  (antes de a caixa ter sido definida), por não fazerem sentido para uma "análise do
  furo inteiro" ainda sem contexto de caixa.
- Tooltip em português, alinhado ao padrão já existente no botão de AI chat
  ("Neural · Análise por IA") — o restante da toolbar usa inglês, mas os dois botões
  mais "assistidos por IA" já quebram esse padrão.
- Adicionei `aria-label` mesmo sem o resto da toolbar ter (GT-0008, ainda não
  implementada nesta branch), por ser um acréscimo de acessibilidade de baixo custo
  e alinhado à direção futura do GT-0008.

### Divergências
- Nenhuma quanto ao escopo da issue (só UI, sem inferência real).

### Pendências
- QA manual no navegador (abrir a página com um furo/caixa real e confirmar tooltip
  visualmente) não foi feita nesta sessão — sem backend/DB de desenvolvimento
  disponível no ambiente do agente. Ver seção "Validação" para o que foi
  efetivamente rodado.

## Validação
- `cd web && ng build --configuration development` — sucesso (exit code 0). Únicos
  warnings são `NG8107` pré-existentes e não relacionados a esta mudança
  (`login2.component.html`, `drill-hole-view-mult.component.html`,
  `drillholes-view-3d.component.html`).
- `cd web && ng test --watch=false --browsers=ChromeHeadlessCI` (suíte completa) —
  245 executados, 179 falharam / 66 passaram. Número idêntico ao baseline
  pré-existente documentado no PR #355 ("179 failed / 66 success"), confirmando que
  esta mudança não introduziu nenhuma falha nova (as falhas existentes são de specs
  antigos usando `TestBed.declarations` com componentes standalone, não relacionadas
  a este trabalho).

## Handoff
PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/364 (branch
`feature/gt-0010-botao-analisar-furo`, base `feature/visualizadores-navegacao-layout`).
Fica pendente para uma issue futura (needs-decision, fluxo A/B/C/D) a implementação
real da análise automática, que deve substituir `analyzeDrillHoleStub` sem precisar
alterar os componentes consumidores. Recomendação para quem revisar o PR: abrir a
Single View e o visualizador por caixa com um furo real, passar o mouse no botão
"Analisar furo inteiro" e confirmar visualmente o tooltip/estado desabilitado antes
do merge — QA manual não foi possível neste ambiente (sem backend/DB de dev).
