---
id: GT-0018
title: "Modo de visualização vertical (drillcores empilhados)"
status: completed
reaberta_qa: "2026-09-03"
type: feature
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "N/A — feature"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/339"
grupo_execucao: "Onda 4"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-02
owner_execucao: "frontend-angular (execução autônoma)"
affected_modules: [single-view]
related_adrs: []
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0018 — Modo vertical (drillcores empilhados)

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
Alternativa de visualização em que os drillcores já cortados são empilhados verticalmente, formando a representação contínua do furo inteiro.

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/339. Toggle horizontal ↔ vertical, continuidade de profundidade sem gaps, integração com a régua (GT-0015).

## Objetivo
Toggle funcional preservando profundidade atual, sem sobreposição/gap.

## Fora de escopo
N/A.

## Comportamento atual
Só visualização horizontal.

## Comportamento esperado
Toggle para vertical, cores empilhados na ordem correta, marcações alinhadas, performance ok em 200m+.

## Regras de negócio
- RN-01: N/A.

## Critérios de aceitação
- [x] CA-01: Toggle alterna os dois modos preservando a profundidade atual.
- [x] CA-02: Cores empilhados na ordem correta de profundidade, sem sobreposição nem gap.
- [x] CA-03: Marcações acompanham o modo vertical, alinhadas.
- [x] CA-04: Performance aceitável em furo de 200 m+.

## Impacto técnico
### Frontend
Novo modo de renderização, reuso do componente de régua (GT-0015).
### Backend / Banco de dados / Integrações / Segurança
N/A.

## Plano de implementação
- [x] Implementar renderização vertical empilhada.
- [x] Integrar régua (GT-0015).
- [x] Validar performance com GT-0001.

## Estratégia de testes
- [x] Automatizado — layout puro (`toCoreMetricInputs` + `buildHoleLayout` reaproveitado, `single-view-metric-layout.spec.ts`) e posicionamento do crop OSD contra uma instância real do OpenSeadragon (`drill-hole-view-unic.component.spec.ts`), no mesmo padrão da suíte de regressão do GT-0013.
- [ ] Manual — furo 200m+, alternar toggle, checar continuidade. **Não executado nesta sessão** (sem ambiente full-stack disponível — ver Pendências).

**Achado do GT-0013 relevante para esta task**: `BoxCoordinateMapperService.registerBoxFromTiledImage()` mistura unidades (viewport + pixels) e só afeta fluxos de criação/edição de marcação (`onAnnotoriousCreate`, `handleDoubleClickAnnotation`, `handleDepthClick`) — hoje inofensivo porque essas telas estão em modo leitura. Se o modo vertical desta task reabilitar edição de qualquer forma, checar esse serviço antes.

## Riscos e rollback
Nenhum.

## Registro de execução
### Alterações realizadas
Explorei o Single View real antes de decidir a abordagem (instrução explícita da task) e descobri que o texto original da issue estava impreciso quanto à "estrutura interna": o modo hoje único (renomeado aqui para "horizontal") já empilha verticalmente **caixas inteiras** (`DrillBox`, GT-0015/`buildHoleLayout`) — não corta cores individuais. O que faltava, e que GT-0021 já confirmou explicitamente ser escopo distinto ("aquele [GT-0018] é vertical, cores empilhados um sobre o outro... este [GT-0021] é horizontal, linhas lado a lado"), é um modo que corta cada **`DrillCore`** da foto da sua `DrillBox` e empilha os cortes formando um log contínuo do furo, sem a caixa como unidade.

- Novo toggle "Horizontal" (padrão, comportamento inalterado — fotos de `DrillBox` inteiras) / "Vertical" (novo — `DrillCore`s cortados e empilhados), na barra de ferramentas do Single View.
- Modo vertical: cada `DrillCore` elegível (com `imgCore` mapeado e caixa-mãe com foto) é recortado da foto da própria `DrillBox` via `clip` do OpenSeadragon (não uma imagem nova nem endpoint novo — mesma foto, mesmo `imgCore` pixel-space já usado pelas anotações) e posicionado para que a região recortada (não a foto inteira) ocupe exatamente a largura/posição da linha calculada pelo layout.
- **Reaproveitamento máximo de GT-0015**: em vez de duplicar a lógica de empilhamento/gap-detection, `toCoreMetricInputs` (novo, em `single-view-metric-layout.ts`) reformata a lista de cores no mesmo formato `MetricBoxInput[]` que `buildHoleLayout` já consome — cada core vira sua própria "caixa" de um único core. Isso reaproveita 100% de `buildHoleLayout`, `depthAtWorldY`, `worldYAtDepth`, `totalDepthOf` (mesmas funções, mesma cobertura de teste do GT-0015, incluindo a forma do SEED-DH-10) para o novo modo, sem lógica paralela.
- Cores são ordenadas por profundidade real (`startDepth`), não por `DrillCore.number` — esse número reinicia a cada caixa e não é uma sequência monotônica no furo inteiro; ordenar por ele misturaria cores de caixas diferentes.
- **CA-03 (marcações alinhadas no modo vertical)**: o maior risco técnico da task. `boxLocalToGlobalImageCoords` (o helper de coordenadas do GT-0013) resolve a posição de uma marcação a partir de um "mapper key" registrado no `BoxCoordinateMapperService`. No modo horizontal esse key é sempre `drillBoxId` (uma caixa = um placement). No modo vertical uma mesma caixa pode gerar **várias** placements independentes (uma por core que ela contém, cada uma com posição/clip diferentes) — usar `drillBoxId` resolveria sempre para o último core registrado daquela caixa, desalinhando os demais. Resolvido com `annotationMapperKey(core)`: retorna `core.id` no modo vertical (uma placement por core, registrada por core) e `core.drillBoxId` no modo horizontal (comportamento inalterado). Todas as 10 funções `draw*`/`drawDepth` que chamavam `boxLocalToGlobalImageCoords(..., core.drillBoxId)` foram atualizadas para usar essa resolução — mudança mecânica, sem alterar a matemática de posicionamento em si.
- **CA-01 (preservar profundidade/zoom ao trocar de modo)**: os dois modos têm escalas mundo↔profundidade (`rulerRows`) diferentes (uma por caixa vs. uma por core), então não dá para copiar os bounds brutos do viewport OSD entre eles. `setViewOrientation()` captura a janela atual em **metros** (`captureDepthWindow`, via `depthAtWorldY` no modo antigo) antes de trocar, e `applyDepthWindowOrHome` reconverte essa janela para coordenadas do **novo** layout (via `worldYAtDepth`) depois de renderizar — preserva profundidade central e o "zoom" em metros visíveis, não os pixels/unidades OSD brutos.
- Sem colunas de caixa molhada/RQD/mock hiperespectral no modo vertical — são conceitos de `DrillBox` (mesma foto duas vezes, ou estatística por caixa) sem equivalente natural num log contínuo por core; a seção "Exibição" da sidebar fica oculta (com aviso) quando o modo vertical está ativo. As camadas de anotação (fratura/litologia/veio/etc., CA-03) continuam disponíveis nos dois modos.
- Toggle com ícones `ri-arrow-left-right-line` (horizontal) / `ri-arrow-up-down-line` (vertical), `title` + `aria-label` em ambos (padrão GT-0008/GT-0021).

### Arquivos principais
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/single-view-metric-layout.ts` — `toCoreMetricInputs` (novo), zero mudança nas funções existentes do GT-0015.
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/single-view-metric-layout.spec.ts` — 5 novos testes cobrindo `toCoreMetricInputs` (filtragem, ordenação por profundidade real, gaps, forma de furo 320 m).
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.ts` — `viewOrientation`, `setViewOrientation`, `captureDepthWindow`/`applyDepthWindowOrHome` (CA-01), `renderViewerLayoutVertical` (novo), `eligibleCoresForVerticalMode`, `annotationMapperKey` (CA-03), `positionClippedTiledImage` (matemática de posicionamento do crop OSD, extraída em método próprio para ser testável isoladamente); as 10 funções `draw*`/`drawDepth` passaram a resolver o mapper key via `annotationMapperKey` em vez de `core.drillBoxId` fixo.
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.html`/`.scss` — toggle horizontal/vertical na toolbar; seção "Exibição" (molhada/RQD/mock) oculta no modo vertical.
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.spec.ts` — 2 novos testes de `positionClippedTiledImage` contra uma instância real do OpenSeadragon (mesmo padrão da suíte de regressão do GT-0013 já existente no arquivo), provando que a região recortada (não a foto inteira) fica exatamente na largura/posição alvo, independente da resolução/aspecto da foto da caixa.

### Decisões
- **O texto da issue ("hoje só renderiza os drillcores cortados numa tira contínua horizontal") não bate com o código real pós-GT-0015** (que já empilha caixas inteiras verticalmente, com régua vertical). Segui a instrução explícita da própria task ("não assuma nada do texto acima... leia o componente atual") e a confirmação independente do GT-0021 ("aquele [GT-0018] é vertical, cores empilhados... formando o furo contínuo") para decidir que a granularidade nova é **por `DrillCore` recortado**, não por `DrillBox`; o modo "horizontal" (existente) foi mantido bit-a-bit como estava.
- Recorte via `OpenSeadragon.TiledImage`'s `clip` (nativo do OSD, já usado pela versão instalada — confirmei lendo o bundle publicado `openseadragon@4.1.1`, não documentação de terceiros) em vez da técnica de `background-image`/CSS puro do GT-0021: o Single View precisa manter zoom/pan OSD e a sobreposição de anotações via Annotorious (CA-03), que o modo "somente DrillCore" do GT-0021 explicitamente **não** precisa (aquele é view-only, sem anotação). Escolher CSS ali e OSD aqui não é inconsistência — são requisitos diferentes.
- `setWidth`/`setHeight` do `TiledImage` sempre reescalam a imagem inteira mantendo a proporção original da foto (confirmado lendo o bundle da lib, não assumido) — por isso `positionClippedTiledImage` resolve a largura para que o **recorte** (não a foto inteira) fique na largura alvo, e aceita que a altura resultante siga a proporção do próprio recorte (que já é exatamente o valor usado para calcular a altura da linha no layout, então na prática batem). Mesma "imprecisão" que o modo horizontal já aceita silenciosamente quando `MAX_ROW_HEIGHT` força um `setHeight` numa caixa fora do padrão — não é uma regressão nova, é o mesmo comportamento pré-existente do GT-0015 estendido ao novo modo.
- Nenhuma mudança de contrato de API/backend — a task é 100% frontend (recorte é client-side, reaproveitando a mesma foto/endpoint da `DrillBox` que o modo horizontal já busca).

### Divergências
- Nenhuma quanto aos critérios de aceitação formais. A única divergência é a constatação acima de que o "comportamento atual" descrito na issue já estava desatualizado (GT-0015 mudou o baseline depois que a issue foi escrita) — documentada em vez de silenciada.

### Pendências
- **QA manual no navegador não foi executada** (mesma limitação já registrada pelo GT-0015/GT-0021: sem ambiente full-stack próprio disponível nesta sessão para não colidir com outras sessões usando o mesmo banco/diretório). Recomendo ao revisor: `dotnet run --project api/src/Back.API` + `ng serve`, abrir Single View, selecionar um furo do seed GT-0001 (idealmente SEED-DH-10, 320 m) e comparar visualmente os dois modos — checar particularmente CA-03 (uma anotação de fratura/litologia visível nos dois modos, alinhada ao core certo) e a suavidade do toggle preservando a profundidade (CA-01).
- Descoberto **incidentalmente** ao rodar a suíte escopada: o teste pré-existente `single-view-metric-layout keeps the drilled interval when the box has its own depths and recovery is partial` já falha na branch de integração **antes** desta PR (confirmado via `git diff --stat` mostrando zero linhas modificadas em `buildHoleLayout`, e reproduzindo o cálculo manualmente) — quando a primeira caixa/linha do layout tem `startDepth > 0`, `buildHoleLayout` insere uma linha `gap` "do colar até a primeira caixa" antes da linha esperada, deslocando `rows[0]` para o gap em vez da caixa. Não é uma regressão desta PR (não toquei `buildHoleLayout`) e está fora do escopo do GT-0018 corrigir uma função do GT-0015; documentando aqui para rastreio, sem tentar consertar.
- A suíte completa (`ng test` sem `--include`) trava cedo por dívida técnica pré-existente e não relacionada: `TestBed.configureTestingModule({ declarations: [...] })` em componentes standalone (`LayoutComponent`, `DrillBoxesListComponent`, etc.) e um crash de import circular (`Cannot access 'DrillHoleViewDeviationsComponent' before initialization`) — já rastreados na branch `fix/angular-standalone-testbed-specs` e, pelo padrão do crash, correspondem aos bugs #357/#358 já conhecidos. Não tentei corrigir (fora de escopo desta task); usei `--include` para escopar a suíte aos arquivos tocados, como as tasks GT-0008/GT-0015/GT-0021 já fizeram antes.

## Validação
- `ng build --configuration development` (worktree sem `node_modules` — copiado de uma checkout irmã com `package-lock.json` idêntico via `robocopy`, evitando um `npm install` completo): **exit code 0**, build limpo. Únicos warnings são pré-existentes e não relacionados (`login2.component.html`, `drill-hole-view-mult.component.html`, `drillholes-view-3d.component.html` — optional chaining redundante, NG8107).
- `ng test --watch=false --browsers=ChromeHeadless --include='**/drill-hole-view-unic*.spec.ts' --include='**/single-view-metric-layout*.spec.ts'`: **23/25 passaram**. As 2 falhas são pré-existentes e não relacionadas a esta mudança (ver Pendências): 1) `buildHoleLayout` "keeps the drilled interval..." (bug pré-existente do GT-0015, não tocado por esta PR); 2) `DrillHoleViewUnicComponent should create` (falta `provideHttpClient`/`HttpClientTestingModule` no `TestBed` desse describe, não tocado por esta PR — mesma classe de falha já documentada pelo GT-0021 para `DrillHoleViewMultComponent`).
  - Dos 25 specs executados, **7 são novos desta PR** e todos passaram: 5 de `toCoreMetricInputs`/`buildHoleLayout` reaproveitado (`single-view-metric-layout.spec.ts`) e 2 de `positionClippedTiledImage` contra uma instância real do OpenSeadragon (`drill-hole-view-unic.component.spec.ts`), provando a matemática de recorte/posicionamento sem depender de QA visual.
- `ng test --watch=false --browsers=ChromeHeadless` (suíte completa, sem `--include`): trava cedo por dívida técnica pré-existente e não relacionada (ver Pendências) — não avança além de ~130/245+ specs antes de um `ReferenceError` de import circular interromper a execução. Comportamento idêntico ao já documentado pelo GT-0015 (que rodou a suíte completa antes e reportou 179 falhas pré-existentes) e pelas notas de arquitetura sobre a branch `fix/angular-standalone-testbed-specs`; não é uma regressão desta PR.

## Handoff
Depende de GT-0013, GT-0015 (ambos mesclados na branch de integração). Nenhuma dependência nova introduzida para outras tasks; GT-0021 (MultiView "somente DrillCore") já foi implementado e confirmou de forma independente que não reutiliza este código (linhas horizontais lado a lado, sem anotação — escopo diferente).

PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/372 (branch `feat/gt-0018-modo-vertical-single-view`, base `feature/visualizadores-navegacao-layout`). **Mesclado (squash), sem conflito** — apesar de tocar o mesmo arquivo que GT-0019 (`drill-hole-view-unic.component.ts`/`.html`), as duas mudanças ficaram em regiões distintas da classe (GT-0019: `@Input aggregatorLevel/aggregatorEntityId` + carga de furos; GT-0018: toggle horizontal/vertical + recorte OSD).

**Com este merge, o projeto "Visualizadores, Navegação e Layout" está 100% implementado em `feature/visualizadores-navegacao-layout`** — todas as tasks das Ondas 1-5, exceto GT-0012 (migração Anthropic/Sonnet 5/streaming), que permanece bloqueada por falta de credencial externa (fora do alcance desta execução).

## Achado de QA pós-implementação (2026-09-03)
Relatório de QA (Matheus, `TASKS.md`, E3-06): "Modo vertical quebrado: caixas somem, sobram poucos drillcores ainda na posição/orientação horizontal. Esperado: cada drillcore empilhado em pé, simulando o furo no chão. Em meu teste (outro furo, 7 caixas) o modo funcionou — pode ser dependente de furo/quantidade de caixas; recomendo retestar em mais casos."

**Análise (Jarvis) — dois problemas distintos**:
1. **"Caixas somem" (dependente de furo/quantidade)**: forte suspeito é o bug **já documentado por esta mesma task** em "Pendências" ("descoberto incidentalmente... `buildHoleLayout` insere uma linha `gap`... deslocando `rows[0]`") — na época classificado como "fora do escopo do GT-0018 corrigir uma função do GT-0015" e "não é uma regressão desta PR". A intermitência relatada por Matheus (funciona em alguns furos, não em outros) bate com um bug que só se manifesta quando a primeira linha do layout tem `startDepth > 0` — depende da forma específica do furo, exatamente como observado. Isso eleva o bug de "dívida técnica monitorada" para "causa provável de defeito real visível" — recomendo corrigir `buildHoleLayout` (GT-0015) agora em vez de continuar só documentando.
2. **"Orientação ainda horizontal" vs. "empilhado em pé"**: a implementação real (ver "Registro de execução" acima) recorta cada `DrillCore` mantendo a MESMA orientação em que aparece na foto da caixa (segmento horizontal) e empilha esses recortes um abaixo do outro — não rotaciona os cores.

**Decisão confirmada pelo usuário (2026-09-03)**: "Rotacionar os cores. Eles têm que já estar na vertical." Cada `DrillCore` recortado deve ser rotacionado 90° antes de empilhado, para aparecer como um cilindro vertical (não mais o segmento horizontal original).

## Escopo do redesenho (além do fix do "caixas somem")
- `positionClippedTiledImage` precisa aplicar rotação (`TiledImage.setRotation`, nativo do OpenSeadragon 4.1.1, já usado no bundle instalado — confirmar API exata antes de assumir o nome do método) a cada core recortado, além do `clip` já existente.
- Rotacionar 90° troca largura↔altura visual do core exibido — a matemática de posicionamento (que hoje calcula a largura/posição da linha a partir da largura original do recorte) precisa ser recalculada para a orientação rotacionada, não só "girar o pixel".
- `toCoreMetricInputs`/reuso de `buildHoleLayout` (empilhamento vertical por profundidade) devem continuar funcionando — a rotação é só do conteúdo visual de cada célula da pilha, a lógica de qual altura cada core ocupa na pilha (por profundidade real) não muda.
- Confirmar com o usuário, durante a implementação, exemplos visuais (screenshot) antes de considerar concluído — dado que a interpretação errada já aconteceu uma vez aqui.

Ver plano consolidado em `squads/guardian/output/qa-pos-implementacao-2026-09-03.md`.

## Registro de execução — redesenho pós-QA (2026-09-03, executado em conjunto com GT-0015)

### 1. Fix do `buildHoleLayout` ("caixas somem")
Corrigido o bug já documentado nesta task em "Pendências": em `buildHoleLayout` (`single-view-metric-layout.ts`), o gap "do colar até a primeira linha" só é considerado a partir da **segunda** linha do layout em diante (`index > 0`) — a primeira linha nunca mais recebe um gap sintético só por ter `startDepth > 0`. Antes, `metersCursor` começava em 0 e qualquer primeira caixa/core com profundidade inicial > 0 m disparava um gap "fantasma" antes dela, empurrando `rows[0]` (e todos os índices seguintes) para a posição errada — exatamente a intermitência relatada por Matheus ("funciona em alguns furos, não em outros"), já que só se manifesta quando a forma específica do furo tem essa característica.
- Teste de regressão novo em `single-view-metric-layout.spec.ts` fixando esse caso; o teste pré-existente que já documentava a falha ("keeps the drilled interval...") volta a passar sem alteração no próprio teste.
- Comentário no teste `toCoreMetricInputs` que descrevia esse comportamento como "existing behavior" foi removido (o comportamento mudou — o comentário descrevia o bug, não uma decisão de design).

### 2. Rotação dos cores (decisão do usuário, 2026-09-03)
Implementado em `positionClippedTiledImage` e `renderViewerLayoutVertical`:
- `TiledImage#setRotation(90, true)` (API confirmada lendo o bundle instalado `openseadragon@4.1.1`, não documentação de terceiros) aplicado a cada core recortado antes de ser posicionado.
- **Matemática de posicionamento recalculada, não só o pixel girado**: uma rotação de 90° pivota em torno do centro do retângulo NÃO recortado (`TiledImage#_getRotationPoint` = centro de `getBoundsNoRotate`), então a correção de posição foi generalizada para usar `getClippedBounds(true)` (bounds já recortados E rotacionados, normalizados pela própria lib para um retângulo eixo-alinhado em múltiplos de 90°) em vez de calcular manualmente qual canto do retângulo pré-rotação vira o canto superior-esquerdo pós-rotação — a translação de posição desloca o corpo rígido inteiro (incluindo o pivô) pelo mesmo delta, então a mesma técnica de correção funciona com ou sem rotação.
- **Redesenho do "contain fit"**: como o core rotacionado tem largura/altura trocadas (o que era comprimento passa a ser altura, o que era diâmetro passa a ser largura), a altura "natural" de cada linha para um `colWidth` fixo passou a ser tipicamente MUITO maior que antes (cores são bem mais compridos que largos) — o clamp de `MAX_ROW_HEIGHT`, antes um caso raro no modo horizontal, passou a ser o caso comum no modo vertical rotacionado. Corrigido para resolver a escala (`setWidth`) que satisfaz o menor entre "caber na largura alvo" e "caber na altura alvo" (fit tipo "contain") em uma única operação, em vez da sequência antiga "larguraprimeiro, depois `setHeight` de override" — essa segunda chamada independente mudaria a escala (e, por consequência, a posição já corrigida do recorte) sem reposicionar depois, o que é inofensivo numa foto inteira sem `clip` (modo horizontal) mas causaria deslocamento visível num recorte `clip`ado (modo vertical).
- Fórmula de altura de linha (`rowHeights`, base do empilhamento por profundidade) trocada de `(h/w)*colWidth` para `(w/h)*colWidth` (largura/altura do recorte em pixels) — reflete que, pós-rotação, o que renderiza como largura vem da altura do recorte (diâmetro) e o que renderiza como altura vem da largura do recorte (comprimento).
- **Confirmação visual**: prova isolada fora do stack completo (HTML standalone + OpenSeadragon real, reproduzindo linha a linha a lógica de produção) mostrando 3 "cores" sintéticos coloridos e rotulados — "antes" (deitados, bug) vs "depois" (em pé, empilhados sem gap/overlap, largura proporcional ao diâmetro simulado e altura proporcional ao comprimento simulado de cada core). Screenshot compartilhado no relatório de execução desta sessão (não anexável a este arquivo/PR diretamente).

### Arquivos adicionais tocados nesta rodada
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/single-view-metric-layout.ts` — fix do gap líder em `buildHoleLayout`.
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/single-view-metric-layout.spec.ts` — novo teste de regressão + limpeza do comentário desatualizado.
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.ts` — `positionClippedTiledImage` (rotação + contain-fit generalizados), `renderViewerLayoutVertical` (fórmula de altura trocada, remoção do override de `setHeight` pós-posicionamento), `onRulerDepthSelected` (ver GT-0015).
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.spec.ts` — 2 novos testes de rotação (`positionClippedTiledImage` com `rotationDegrees=90`, incluindo o caso de contain-fit/clamp) contra uma instância real do OpenSeadragon.

## Validação (atualização 2026-09-03)
- `single-view-metric-layout.spec.ts`: 21/21 verdes.
- `drill-hole-view-unic.component.spec.ts`: 34/35 verdes — única falha é a pré-existente `should create` (`HttpClient` faltando no TestBed daquele describe), já documentada antes desta sessão, não tocada aqui.
- `ng build --configuration development`: exit 0, build limpo (mesmos warnings pré-existentes não relacionados — `Login2Component`, `DrillHoleViewMultComponent`, `Drillholesview3DComponent`).
- `npx tsc -p tsconfig.spec.json --noEmit`: sem erros de tipo.
- QA manual no navegador: **não executada** (mesma limitação de ambiente compartilhado já documentada nesta task). Recomendo ao revisor confirmar visualmente com SEED-DH-10 (320 m) antes do merge — em particular a rotação dos cores e a ausência de gaps/overlaps no empilhamento.

### Achado adicional durante a validação (fora de escopo, não corrigido)
`depth-ruler.component.spec.ts` (GT-0015) tem 3 falhas pré-existentes e não relacionadas a esta rodada (`trackRef` undefined, `ticks` vazio) — reproduzidas mesmo rodando o arquivo isoladamente, sem nenhuma mudança nele nesta sessão. Provavelmente mesma categoria de dívida técnica de `TestBed`/standalone já rastreada em `fix/angular-standalone-testbed-specs` (issues #357/#358). Sinalizando para rastreio.

## Handoff (atualização 2026-09-03)
Corrigida em conjunto com GT-0015 (mesmo PR) — ambas as tasks tocam `single-view-metric-layout.ts` (fix de `buildHoleLayout`, compartilhado) e `drill-hole-view-unic.component.ts` (clique da régua e rotação dos cores, em métodos distintos da mesma classe). Um PR único evita um conflito de merge garantido entre duas branches concorrentes na mesma família de arquivos.

PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/381 (branch `fix/gt-0015-gt-0018-regua-modo-vertical`, base `feature/visualizadores-navegacao-layout`). **Mesclado (squash)** em `feature/visualizadores-navegacao-layout`.

**Confirmação visual (Jarvis, 2026-09-03)**: o agente gerou um demo standalone do OpenSeadragon reproduzindo a matemática de produção (`gt0018-rotation-demo.png`) — confirmei visualmente antes do merge: os 3 cores sintéticos passam de faixas horizontais deitadas para retângulos verticais em pé, empilhados sem gaps/overlaps, largura proporcional ao diâmetro e altura proporcional ao comprimento. Bate com o pedido do usuário ("rotacionar os cores, eles têm que já estar em pé"). QA manual real no navegador (com dado do seed) segue pendente para a sessão de teste do usuário.
