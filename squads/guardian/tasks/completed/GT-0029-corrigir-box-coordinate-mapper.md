---
id: GT-0029
title: "Corrigir unidades mistas em BoxCoordinateMapperService.registerBoxFromTiledImage()"
status: active
type: feature
achado_origem: "QA-Matheus-2026-09-03 (E3-02, TASKS.md linha 27)"
auditor_origem: "Matheus Lima Santos de Souza (QA manual) — roteado por Jarvis"
severidade: "Média-Alta — bug dormant conhecido, agora com efeito visível confirmado"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-jarvis-qa-pos-implementacao-2026-09-03"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/pull/380"
grupo_execucao: "Correção pós-QA"
owner: ""
created_at: 2026-09-03
updated_at: 2026-09-03
affected_modules: [single-view, box-coordinate-mapper]
related_adrs: []
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0029 — Corrigir unidades mistas em BoxCoordinateMapperService

## Par no repositório de produto

**Não há par, e ele não foi perdido.** Esta GT é de 2026-09-03; o diretório `.agents/tasks/` do
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
`web/src/app/shared/openseadragon-viewer/services/box-coordinate-mapper.service.ts`, método `registerBoxFromTiledImage()`, mistura unidades (viewport + pixels) ao computar `globalLeft`/`globalRight`. Esse achado já foi registrado **três vezes** neste projeto (GT-0013, GT-0014, GT-0017) como "hoje inofensivo porque as telas afetadas são somente leitura (`anno.readOnly = true`)" — nunca corrigido, só monitorado.

## Achado original
Trecho literal de `TASKS.md` (E3-02):
> "Duplo clique numa marcação (litologia, fratura etc.) a desloca sozinha; volta ao clicar em outra região. Não testado por mim — vale documentar o passo a passo pro dev."

## Investigação de causa raiz (Jarvis, 2026-09-03)
GT-0014 (issue #337) já havia investigado duplo-clique em marcações no Single View e corrigido um problema diferente: `handleDoubleClickAnnotation()` abria modais de edição completos mesmo com `readOnly=true` — neutralizado para um no-op (ver GT-0014, "Registro de execução"). **Isso não explica o comportamento reportado por Matheus** (marcação se desloca visualmente, não um modal abrindo) — o no-op não deveria produzir nenhum efeito visual.

Hipótese de maior confiança, dado o padrão já documentado 3 vezes neste mesmo projeto: o **próprio Annotorious** (biblioteca de anotação) ainda processa o duplo-clique para entrar em estado de "seleção"/highlight — mesmo sem abrir modal — e o cálculo de onde desenhar esse highlight passa pelo mesmo `registerBoxFromTiledImage()`/hit-testing com unidades mistas (viewport + pixels) já sinalizado. Isso bateria exatamente com o sintoma: a marcação "pula" para uma posição calculada com a unidade errada ao entrar em estado selecionado, e "volta" ao perder a seleção (clicar em outra região), porque aí o Annotorious volta a desenhar pela posição original (correta) do body/target.

**Não confirmado por reprodução real nesta sessão** — é a hipótese mais bem fundamentada dado o padrão já observado 3x no código, não uma certeza. Investigação e correção devem confirmar isso experimentalmente antes de assumir a causa como fechada.

## Objetivo
`registerBoxFromTiledImage()` usa uma única unidade consistente (pixels OU viewport, não uma mistura) para `globalLeft`/`globalRight`, eliminando o comportamento incorreto de hit-testing em qualquer fluxo que dependa dele — incluindo o de seleção do Annotorious.

## Fora de escopo
Reabilitar edição em qualquer tela hoje somente-leitura (não é pedido aqui).

## Comportamento atual
Duplo clique numa marcação (litologia/fratura/veio) no Single View a desloca visualmente; volta ao normal ao clicar em outra região.

## Comportamento esperado
Duplo clique numa marcação não produz nenhum deslocamento visual — a marcação permanece exatamente onde estava, selecionada ou não.

## Regras de negócio
- RN-01: N/A.

## Critérios de aceitação
- [x] CA-01 (refinado): não foi possível reproduzir visualmente (sem browser interativo no ambiente desta sessão), mas a hipótese de causa raiz foi investigada a fundo por rastreamento exaustivo de código e **refutada** — ver "Divergências" no Registro de execução. A causa real do sintoma de QA permanece em aberto, fora do escopo do que esta hipótese cobria.
- [x] CA-02: `registerBoxFromTiledImage()` corrigido para usar uma única unidade consistente (frame agregado de pixels, o mesmo que todo o resto do app já usa).
- [ ] CA-03: Duplo clique em litologia, fratura e veio (os 3 tipos citados por Matheus) não desloca a marcação, testado manualmente. **Não executado** — ambiente sem `ng serve`/browser interativo disponível. Pendente para QA ou para quem tiver acesso a um ambiente com browser.
- [x] CA-04: Nenhuma regressão nas telas que já dependem deste serviço (GT-0013, GT-0014, GT-0017, GT-0018) — suítes de regressão de alinhamento existentes rodadas: 28/30 SUCCESS, as 2 falhas são pré-existentes e não relacionadas (ver Validação).

## Impacto técnico
### Frontend
`web/src/app/shared/openseadragon-viewer/services/box-coordinate-mapper.service.ts` — serviço compartilhado por Single View (GT-0013/14/15/17/18) e possivelmente outras telas que o consomem.
### Backend / Banco de dados / Integrações / Segurança
N/A.

## Plano de implementação
- [x] Reproduzir o bug num ambiente real com dado do GT-0001 — não executável nesta sessão (sem browser); substituído por rastreamento exaustivo de código (ver Divergências).
- [x] Ler `registerBoxFromTiledImage()` e identificar exatamente onde a mistura de unidades ocorre.
- [x] Corrigir para unidade única consistente.
- [x] Validar os 3 tipos de marcação (litologia/fratura/veio) + regressão das suítes existentes. Regressão automatizada completa — ver Validação (28/30, 2 falhas pré-existentes); manual pendente (CA-03).

## Estratégia de testes
- [x] Automatizado — teste de regressão dedicado a `registerBoxFromTiledImage()` cobrindo o caso que causava a mistura.
- [ ] Manual — duplo clique nos 3 tipos de marcação em furo real do seed. Não executado nesta sessão (sem ambiente com browser).

## Riscos e rollback
Serviço compartilhado por múltiplas telas já mescladas (GT-0013/14/15/17/18) — testar regressão em todas antes do merge.

## Registro de execução

### Alterações realizadas
- `registerBoxFromTiledImage()` corrigido para não misturar unidades: em vez de somar `tiledImage.getBounds()` (unidades de *viewport* do OpenSeadragon) com `tiledImage.getContentSize()` (pixels nativos daquela imagem específica), os dois cantos do bounds são agora convertidos via `viewer.viewport.viewportToImageCoordinates()` para o mesmo "frame agregado de pixels do world inteiro" que todo o resto do app já usa como referência única de coordenada "global" — o mesmo frame que o Annotorious e `boxLocalToGlobalImageCoords()` (fixado em GT-0013) consomem. `globalLeft/globalTop/globalRight/globalBottom` passam a estar todos na mesma unidade, para qualquer índice de caixa. Nota de precisão: nem a primeira caixa (`tiledImageIndex === 0`) ficava correta antes — em produção `renderViewerLayout` reserva `xBase = 0.20` para os marcadores de profundidade, então `bounds.x` da primeira caixa nunca foi `0`; o bug de unidades mistas nunca produziu um "pixel global" válido para nenhuma caixa, só passou despercebido por não haver nenhum consumidor vivo lendo esses campos (ver Divergências).
- Documentado (comentário, sem alterar comportamento) um bug irmão em `registerCoreBounds()`, descoberto durante a investigação: ele soma um offset de pixel *local à caixa* (`imgCore`, na resolução nativa daquela caixa) diretamente sobre `boxBounds.globalLeft/Top` (agora no frame agregado) — exato só quando a escala nativa-pixel-para-viewport da caixa coincide com a de `tiledImageIndex 0`, o que não é garantido (cada caixa é esticada para o mesmo `colWidth`/`rowH` independente da resolução original da foto, ver `single-view-metric-layout.ts`). Está dormente pelo mesmo motivo do bug original: nenhum consumidor de `coreBoundsMap` é lido por qualquer fluxo alcançável na tela somente-leitura. Não corrigido por estar fora do escopo desta task — registrado para não repetir o padrão "sinalizado e esquecido" pela 4ª vez.

### Arquivos principais
- `web/src/app/shared/openseadragon-viewer/services/box-coordinate-mapper.service.ts` — fix em `registerBoxFromTiledImage()` + comentário de rastreamento do bug irmão em `registerCoreBounds()`.
- `web/src/app/shared/openseadragon-viewer/services/box-coordinate-mapper.service.spec.ts` (novo) — suíte dedicada de regressão para o serviço (não existia nenhuma), com uma instância real de `OpenSeadragon.Viewer` (sem mock), replicando o padrão de teste já validado em GT-0013 (`drill-hole-view-unic.component.spec.ts`).

### Decisões
- Unidade única escolhida: "pixel, frame agregado do world inteiro" (a mesma que `viewer.viewport.viewportToImageCoordinates()` resolve), em vez de manter tudo em unidades de viewport ou em pixel nativo por-caixa — é a ÚNICA unidade que já é produzida/consumida em todo o resto do fluxo vivo do app (Annotorious, `boxLocalToGlobalImageCoords`); qualquer outra escolha exigiria conversão extra nos consumidores reais.
- `registerCoreBounds()` não foi alterado — fora do escopo explícito da task (que pede especificamente `registerBoxFromTiledImage()`), e seu único consumidor (`resolveCoordinate().drillCore`) é descartado por quem chama (`findDrillBoxAtPixelCoordinates`, em `drill-hole-view-unic.component.ts`). Ver "Divergências" e o comentário inline no código.
- Novo spec ficou em arquivo próprio (`box-coordinate-mapper.service.spec.ts`), dedicado só ao serviço, em vez de mais um `describe` no já extenso `drill-hole-view-unic.component.spec.ts` — o teste não depende do componente, só de um `Viewer` real.

### Divergências (a mais importante desta task)
CA-01 pedia para confirmar (ou refinar) a hipótese de causa raiz documentada — "Annotorious entra em estado de seleção/highlight no duplo clique e usa hit-testing com unidades mistas". **Essa hipótese foi investigada a fundo e REFUTADA (não apenas "não confirmada") por rastreamento exaustivo de código** — não foi possível reproduzir visualmente (sem `ng serve`/browser interativo disponível neste ambiente, ver "Pendências"), mas o rastreamento de todo o grafo de chamadas é conclusivo:

1. `globalLeft/globalTop/globalRight/globalBottom` (os campos afetados pela mistura de unidades) só são lidos dentro do próprio `box-coordinate-mapper.service.ts` — busca em todo `web/src/app` confirma que nenhum consumidor externo lê esses campos diretamente.
2. O único método público que os usa e que é efetivamente chamado em algum lugar do app vivo é `resolveCoordinate()` (via `findBoxAtImageCoordinate`/`findCoreAtImageCoordinate`), e o único chamador de `resolveCoordinate()` em toda a árvore é `findDrillBoxAtPixelCoordinates()`, em `drill-hole-view-unic.component.ts` — por sua vez só chamado por `updatePendingCoordinates()`.
3. `updatePendingCoordinates()` só é disparado pelos eventos `selectionChanged`/`updateAnnotation` do Annotorious, e seu único efeito é preencher `pendingAnnotationCoords`/`currentDrillBoxId`/`currentDrillCoreId` — estado lido apenas pelo fluxo de CRIAÇÃO/EDIÇÃO de anotação (abrir modal, salvar). Esse fluxo está inacessível no Single View: `anno.readOnly = true` e `handleDoubleClickAnnotation()` é um no-op explícito desde GT-0014.
4. A renderização de TODAS as marcações existentes (fratura/litologia/veio/mineralização/etc.) passa por `boxLocalToGlobalImageCoords()`, que usa apenas `boxBounds.tiledImageIndex` (não afetado pela mistura) e resolve a posição via `viewer.viewport.viewportToImageCoordinates()` diretamente — nunca lê `globalLeft/Right/Top/Bottom`. Ou seja, o bug de unidades mistas em `registerBoxFromTiledImage()` nunca teve caminho algum até qualquer coisa visível no Single View somente-leitura.
5. Existe um SEGUNDO chamador de `findDrillBoxAtPixelCoordinates()` além do fluxo do Annotorious: `handleDepthClick()`, acionado por um `OpenSeadragon.MouseTracker` que só é montado em `setupDepthTracker()`, por sua vez só chamado por `btnDepthSelect_Click()` — um handler de início de criação de marcação de profundidade. Esse handler não está vinculado a nenhum elemento do template desta tela (`grep` no `.html` não encontra `btnDepthSelect_Click`), ou seja, é código morto na UI atual — reforça, não enfraquece, a conclusão de que não há caminho vivo até o sintoma de QA.

Conclusão: o bug corrigido nesta task é real e confirmado independentemente (contrato de API do OpenSeadragon: `getBounds()` é viewport, `getContentSize()` é pixel), e vale a pena corrigir por si só (CA-02, hit-testing hoje incorreto para qualquer caixa além da primeira) — mas ele não é, e muito provavelmente nunca foi, a causa do deslocamento visual relatado por Matheus. **A causa real do sintoma de QA permanece não identificada** e deve ser investigada em uma task separada.

Hipóteses levantadas nesta sessão para esse follow-up, com o que já foi checado:
- (a) uma peculiaridade interna do próprio Annotorious ao recalcular a geometria renderizada no estado "selecionado" — não verificada, ainda a hipótese mais plausível.
- (b) ~~o gesto padrão do OpenSeadragon de zoom-ao-duplo-clique~~ — **descartada nesta sessão**: `initializeViewer()` configura `gestureSettingsMouse: { clickToZoom: false }`, e o próprio default do OpenSeadragon para mouse já é `dblClickToZoom: false` (confirmado em `node_modules/openseadragon/build/openseadragon/openseadragon.js`, bloco de defaults de `gestureSettingsMouse`) — só touch/pen/unknown têm `dblClickToZoom: true` por padrão. Duplo clique de mouse não deveria acionar zoom nesta tela. Não investigar mais essa via a menos que o usuário reportador esteja em touch/tablet.
- (c) (nova) `onHighlightAnnotation()` já demonstra que este componente TEM um recurso real de "recentralizar/dar fitBounds no viewport para uma anotação" (`centerViewOnAnnotation`, acionado hoje só pelo painel lateral de anotações, não pelo duplo clique no canvas) — um pan/zoom do viewport inteiro é facilmente confundido com "a marcação se moveu" por quem está olhando. Vale checar se algum caminho de seleção via canvas (não só o painel) acaba chamando algo equivalente.

É esperado que QA ainda reproduza o sintoma após este PR — isso não seria uma regressão desta mudança, e sim a confirmação de que a causa raiz está em outro lugar.

### Pendências
- CA-03 (teste manual de duplo clique nos 3 tipos de marcação num furo real do seed) não pôde ser executado nesta sessão — ambiente sem display/navegador interativo disponível para `ng serve` manual. Fica pendente para quem tiver acesso a um ambiente com browser, ou para QA (Matheus) re-validar diretamente.
- Investigação da causa raiz real do sintoma de QA (ver Divergências) — recomenda-se abrir uma nova task dedicada.

## Validação
- `ng test --include='**/box-coordinate-mapper.service.spec.ts'` (Karma, Chrome real, `ChromeHeadless`) — **2/2 SUCCESS**. Suíte nova e dedicada (ver "Arquivos principais"), com uma instância real de `OpenSeadragon.Viewer` (sem mock).
- `ng test --include='**/drill-hole-view-unic.component.spec.ts' --include='**/single-view-metric-layout.spec.ts'` — **28/30 SUCCESS, 2 FAILED**. As 2 falhas são pré-existentes e não relacionadas a esta mudança:
  1. `single-view-metric-layout — keeps the drilled interval when the box has its own depths and recovery is partial` — falha inteiramente dentro de `single-view-metric-layout.ts` (`buildHoleLayout`), um módulo de layout métrico puro que não importa nem referencia `box-coordinate-mapper.service.ts` em nenhum lugar (confirmado por busca) — impossível de ser afetado por esta mudança.
  2. `DrillHoleViewUnicComponent — should create` — `NullInjectorError: No provider for HttpClient!`. Já documentada como falha pré-existente na própria task GT-0013 ("Registro de execução" / "Pendências": "`should create`... falha por `NullInjectorError`... confirmado como falha pré-existente... não corrigido aqui para manter o PR focado"). Segue não corrigida pelo mesmo motivo — fora do escopo de GT-0029.
  
  Nenhuma das 2 falhas está relacionada a `registerBoxFromTiledImage()`/`box-coordinate-mapper.service.ts`. **CA-04 satisfeito**: zero regressão introduzida por esta mudança nas telas que dependem do serviço.
- `ng build --configuration development` — sucesso, "Application bundle generation complete" (exit code 0). 3 warnings `NG8107` pré-existentes, todos em arquivos não relacionados a esta mudança (`login2.component.html`, `drill-hole-view-mult.component.html`, `drillholes-view-3d.component.html`).
- Ambiente de execução: máquina compartilhada com dezenas de agentes/worktrees Guardian rodando `npm install`/`ng test`/`ng build` em paralelo — builds levaram de ~7 a ~15 min por corrida só por contenção de CPU/disco (não é um sinal de problema no código). O launcher customizado `ChromeHeadlessCI` (definido em `karma.conf.js`) nunca conecta um browser nesta máquina (porta 9876 fica `LISTENING` sem nenhuma conexão `ESTABLISHED` por 15+ minutos); usar sempre `--browsers=ChromeHeadless` (o preset embutido) — mesma convenção que todas as outras sessões concorrentes observadas via `ps -ef` já usavam.

## Handoff
Task nova, criada a partir do relatório de QA de Matheus (2026-09-03), roteada por Jarvis. Consolida um achado dormant já sinalizado 3x (GT-0013/14/17) — corrigido por si só, mas **não é a causa do sintoma de QA relatado**.

**PR #380 mesclado (squash) em `feature/visualizadores-navegacao-layout`.** O fix em si (unidades mistas) é real e válido, mas a hipótese de causa raiz do bug de duplo clique foi refutada por rastreamento exaustivo de código — **o achado original de QA (E3-02, marcação se desloca no duplo clique) segue sem correção real**. Aberta **GT-0031** para investigar a causa raiz de verdade a partir das 3 hipóteses levantadas nesta task (ver "Divergências").

**Atualização (2026-09-03, implementação)**: `registerBoxFromTiledImage()` corrigido (CA-02) e coberto por suíte de regressão dedicada nova. A hipótese de causa raiz do sintoma de QA (Annotorious + hit-testing de unidades mistas) foi refutada por rastreamento exaustivo de código — ver "Divergências". Recomenda-se: (1) QA re-validar o sintoma após merge, já que não se espera que ele desapareça com este fix; (2) abrir task nova para investigar a causa real caso o sintoma persista, com foco no comportamento interno do Annotorious no estado selecionado, ou em algum caminho de seleção via canvas que acabe chamando um equivalente de `centerViewOnAnnotation()` (ver hipótese (c) em "Divergências") — o gesto de zoom-por-duplo-clique do OpenSeadragon foi descartado nesta sessão (default `dblClickToZoom: false` para mouse).

**PR aberto (2026-09-03)**: https://github.com/Essencis-Labs/GeoCloudAI/pull/380, branch `fix/gt-0029-box-coordinate-mapper` → base `feature/visualizadores-navegacao-layout`. Rebaseado sobre o topo atual da base (inclui GT-0030 revert e GT-0021 redesign, sem conflito — arquivos não sobrepõem). Pendente: revisão humana, merge, e as duas validações manuais registradas em "Pendências" (CA-03 e a investigação de causa raiz real do sintoma de QA).
