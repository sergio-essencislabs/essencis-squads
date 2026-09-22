---
id: GT-0017
title: "Camadas de dados no Single View (cores, geoquímica, mineralogia, hiperespectral, caixa molhada)"
status: active
type: feature
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "N/A — feature"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/338"
grupo_execucao: "Onda 3"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-02
affected_modules: [single-view]
related_adrs: []
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0017 — Camadas de dados no Single View

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
Implementar as camadas aprovadas em GT-0016 (E3-04), com seletor para ligar/desligar cada uma.

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/338. Cores, geoquímica, mineralogia quantitativa, mapa hiperespectral, caixa molhada (mock nesta fase), demais parâmetros do spike. Considerar quebrar em sub-issues por camada se o esforço for alto.

## Resultado do spike GT-0016 (refina o escopo)
Comparativo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/322#issuecomment-5514028049; resumo aplicado a esta issue em https://github.com/Essencis-Labs/GeoCloudAI/issues/338#issuecomment-5514032501. Lista priorizada, todas seguindo o padrão de `ImgRect` já usado por Fracture/Lithology no single-view exceto onde indicado:

1. Mineralogia quantitativa — `DrillCoreMineralOccurrence` (real, `ImgRect` direto).
2. Mineralização (tipo/gênese) — `DrillCoreMineralization` (real, `ImgRect` direto — adicionada pelo spike, não estava no achado original).
3. Textura — `DrillCoreTexture` (real, `ImgRect` direto — adicionada pelo spike).
4. Estrutura — `DrillCoreStructure` (real, `ImgRect` direto — adicionada pelo spike).
5. Alteração — `DrillCoreAlteration` (real, `ImgRect` direto — adicionada pelo spike).
6. Geoquímica — `AnalysisAssay` (real, **sem** `ImgRect`; requer mapear profundidade→pixel via `DrillCoreDepth`, calibração já usada no single-view atual). Maior esforço que 1–5.
7. Cores — reaproveitar `Color`/hexadecimal já vinculado a `Lithology` (real parcial, já renderizado hoje no overlay de litologia; colorimetria instrumentada de fato não existe, fora de escopo).
8. Caixa molhada — **mock explícito** confirmado (`DrillBox` não tem estado molhada/seca, só uma imagem única).
9. Mapa hiperespectral — **mock explícito** confirmado (nenhuma referência no domínio/backend; exigiria integração com hardware externo).

**Confirmado: nenhum endpoint novo é necessário** — todas as camadas reais (1–7) já têm controller + service completos (`Back.API/Controllers`, `web/src/app/services`). A hipótese de endpoint novo registrada no Impacto técnico abaixo não se confirmou.

## Objetivo
Cada camada aprovada ativável/desativável, camadas mock sinalizadas como tal.

## Fora de escopo
Camadas não aprovadas em GT-0016.

## Comportamento atual
Sem camadas de dado sobreposto na imagem.

## Comportamento esperado
Seletor de camadas, sobreposição correta, mock explicitamente sinalizado.

## Regras de negócio
- RN-01: N/A.

## Critérios de aceitação
- [x] CA-01: Cada camada aprovada é ativável/desativável independentemente. (camadas 1, 3, 4, 5, 7; geoquímica/item 6 pendente, ver Divergências)
- [x] CA-02: Camadas mockadas estão explicitamente sinalizadas como mock na UI.
- [x] CA-03: Camadas sobrepõem corretamente a imagem, sem desalinhamento (GT-0013). (mesmo `boxLocalToGlobalImageCoords()`, sem caminho paralelo)

## Impacto técnico
### Backend
Nenhum endpoint novo necessário — confirmado no spike GT-0016 (controllers/services já existem para todas as camadas reais).
### Frontend
Seletor de camadas + renderização sobreposta. Camadas 1–5 reaproveitam diretamente o padrão `ImgRect` (mesmo mecanismo de fracture/lithology). Geoquímica (6) exige lógica adicional de mapeamento profundidade→pixel via `DrillCoreDepth`.
### Banco de dados
Confirmado — nenhuma tabela nova necessária, todo o dado real já existe no modelo atual.
### Integrações
Mapa hiperespectral confirmado como mock nesta fase — nenhuma integração externa disponível/no escopo.
### Segurança
N/A.

## Plano de implementação
- [x] Consumir resultado de GT-0016.
- [x] Implementar seletor + renderização por camada aprovada, na ordem priorizada (ver "Resultado do spike GT-0016" acima) — itens 1, 3, 4, 5, 7 feitos; item 2 já estava feito (GT-0014); item 6 (geoquímica) recomendado como sub-issue, ver Divergências.
- [x] Sinalizar mocks explicitamente (caixa molhada, mapa hiperespectral).

## Estratégia de testes
- [ ] Manual — cada camada, com e sem alinhamento correto (depende de GT-0013). Não executado nesta sessão (sem ambiente `ng serve` disponível) — ver Validação/Pendências.

**Achado do GT-0013 relevante para esta task**: `BoxCoordinateMapperService.registerBoxFromTiledImage()` mistura unidades (viewport + pixels), mas só afeta hit-testing de clique/desenho, não a renderização de overlay — não deve afetar as camadas somente-leitura desta task. Registrado por precaução, não é bloqueante.

## Riscos e rollback
O spike GT-0016 confirmou que cada camada real (1–6 da lista priorizada) tem fonte de dado e endpoint próprios e independentes entre si — recomendação de quebrar em sub-issues por camada (já sinalizado no corpo original) se mantém válida, especialmente separando geoquímica (item 6, maior esforço) das demais.

## Registro de execução
### Alterações realizadas
Implementadas as 5 camadas de menor esforço da lista priorizada (1, 3, 4, 5, 7 —
mineralogia quantitativa, textura, estrutura, alteração, cor), mais os dois
mocks explícitos (8, 9). Camada 2 (mineralização/"Vein") já estava
implementada pelo GT-0014/#354 e não foi tocada. Camada 6 (geoquímica) ficou
fora deste PR — ver "Divergências" abaixo.

Para cada uma das 4 camadas novas com `ImgRect` (mineral occurrence, texture,
structure, alteration): adicionado `getByDrillHoleList(drillHoleId)` ao
service HTTP correspondente (mesma convenience method que o GT-0014 adicionou
em `DrillCoreMineralizationService`, todas espelhando o endpoint real
`getByDrillHole` já existente no controller — nenhum endpoint novo), um bloco
de carregamento em `loadAnnotationsForSelectedHoles()` (barreira agora conta
10 fontes de dado por hole em vez de 6), uma função `drawX(item, core)`
reaproveitando exatamente `boxLocalToGlobalImageCoords()` (mesmo padrão do
GT-0014, sem caminho de conversão paralelo), estilo próprio em
`setupAnnotoriousStyles` e entrada automática na legenda lateral via
`annotationCategories` (já gera toggle independente + contagem).

"Cor" (item 7) não é uma fonte de dado nova: `drawColorFill` reaproveita os
mesmos registros de `drillCoreLithologies` já carregados para a camada
"Lithology" (mesmo `lithology.color`), desenhando um preenchimento sólido
independente do contorno fino já existente — toggle próprio via `typeVisibility['color']`.
Usa purpose `colorLithologyId` (não `lithologyId`) no body Annotorious de
propósito, para não ser confundido com a seleção da camada "Lithology" em
`selectionChanged`.

Mocks (CA-02): "Caixas molhadas" já existia na UI sem nenhum aviso — agora
tem badge "MOCK" + tooltip explicando a limitação real (`DrillBox` não modela
estado molhada/seca). "Mapa hiperespectral" não tinha UI nenhuma — adicionado
como toggle próprio na seção "Exibição", com badge "MOCK"; quando ativo,
desenha um overlay HTML claramente rotulado ("Mock — mapa hiperespectral")
na mesma rect da imagem da caixa (`renderViewerLayout`) — deliberadamente
**não** usa Annotorious/pixel space, para não correr nenhum risco de
reintroduzir o bug de coordenadas do GT-0013/#330 numa camada que nem é dado
real.

### Arquivos principais
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.ts`
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.html`
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.scss`
- `web/src/app/services/drillCoreMineralOccurrence.service.ts`
- `web/src/app/services/drillCoreTexture.service.ts`
- `web/src/app/services/drillCoreStructure.service.ts`
- `web/src/app/services/drillCoreAlteration.service.ts`

### Decisões
- Cores de cada camada reaproveitadas de `drill-box-view-images.component.ts`
  (mesmo editor de caixa individual, que já tinha as 4 camadas + "Vein"
  implementadas com toggle/desenho completos, incluindo edição — não usada
  aqui por Single View ser view-only): mineralOccurrence `#9c27b0`, texture
  `#4caf50`, structure `#795548`, alteration `#00bcd4`. Consistência visual
  entre as duas telas, não uma decisão nova.
- Confirmado por inspeção do repository (`DrillCoreAlterationRepository.cs`
  e equivalentes) que o mesmo `BaseQuery`/SELECT com joins é reaproveitado por
  `GetByDrillHole`, `GetByDrillBox`, `GetByDrillCore` e `GetById` — o payload
  de `getByDrillHole` já traz `imgRect` e a entidade relacionada (`mineral`/
  `texture`/`type`/`style`) aninhados, sem precisar de nenhuma chamada extra.
- Mock do mapa hiperespectral implementado como overlay HTML simples (mesmo
  mecanismo de `addRqdBlock`/`addEmptySlot`), não como anotação Annotorious —
  decisão deliberada para isolar completamente qualquer risco de regressão no
  pipeline de coordenadas pixel (GT-0013).

### Divergências
- **Geoquímica (item 6) não entrou neste PR.** `AnalysisAssay` é real mas não
  tem `ImgRect` — a camada exigiria: (1) buscar assays via
  `AnalysisAssayService.getByDrillholeList` (endpoint já existente, mas note
  que ele — diferente de todo o resto do padrão `getByAccount` do app — já
  recebe `accountId` explícito do frontend via `sessionStorage.getItem('accountId')`,
  padrão pré-existente replicado de `analysis-assay.component.ts`, não
  introduzido por esta task); (2) resolver `sample.startDepth`/`endDepth` por
  amostra; (3) localizar o(s) `DrillCore` cuja faixa de profundidade cobre a
  amostra; (4) interpolar posição X a partir de ≥2 `DrillCoreDepth` daquele
  core (hoje só usado para desenhar tick marks de profundidade ao longo do
  eixo X, não para mapear um intervalo completo). Esse último passo é lógica
  nova, não uma reaplicação direta de `boxLocalToGlobalImageCoords` como as
  camadas 1–5. Confirma o "Riscos e rollback" já registrado nesta task:
  recomendo abrir sub-issue própria para geoquímica em vez de apressar uma
  implementação frágil.
- `ng build`/`ng test` completos não puderam ser executados neste ambiente —
  `npm ci` não concluiu a instalação de `node_modules` dentro da sessão
  (rede lenta na sandbox, não bloqueada: um `npm install typescript` isolado
  levou ~2 min só para 1 pacote). Validação de sintaxe feita via parser do
  TypeScript compiler (0 diagnósticos nos 5 arquivos `.ts` alterados) e
  revisão cruzada manual linha a linha contra o padrão já em produção
  (GT-0014 e `drill-box-view-images.component.ts`). Recomendo rodar
  `cd web && ng build && ng test` no CI do PR antes do merge.

### Pendências
- Abrir sub-issue de geoquímica (item 6) referenciando #338 e este PR.
- Validação manual no navegador (`ng serve` + Single View com múltiplas
  camadas ativas simultaneamente) — não executada nesta sessão.

## Validação
- Checagem de sintaxe TypeScript (TS compiler parser, 0 diagnósticos) nos 7
  arquivos alterados.
- Inspeção cruzada de `DrillCoreMineralOccurrenceController.cs`,
  `DrillCoreTextureController.cs`, `DrillCoreStructureController.cs`,
  `DrillCoreAlterationController.cs` — mesmo formato de autorização
  `getByDrillHole`/`getByDrillBox`/`getByDrillCore`/`getById` já usado pelas
  camadas existentes (fracture/lithology/mineralization); nenhuma mudança de
  contrato de API.
- Inspeção do repository (`DrillCoreAlterationRepository.cs` e análogos) para
  confirmar que `GetByDrillHole` retorna a mesma projeção aninhada
  (`imgRect`, entidade relacionada) que `GetByDrillBox`, já validado em uso
  real por `drill-box-view-images.component.ts`.
- `ng build`/`ng test` **não executados** nesta sessão — ver "Divergências".
  PR aberto com essa limitação sinalizada explicitamente na descrição.

## Handoff
Depende de GT-0016, GT-0013.
PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/362 (mira
`feature/visualizadores-navegacao-layout`, não `main`).
Pendência de handoff: abrir sub-issue de geoquímica (item 6 do spike GT-0016)
antes de fechar esta task, ou renomear/reescopar esta task para refletir que
geoquímica ficou fora.

---

## Reconciliacao - 21/09/2026 (GT-0156)

**Parcialmente resolvido - permanece active.**

Entregue e em origin/main: commit `93762c5b` (#362) - camadas de mineralogia, textura, estrutura,
alteracao e cor. Codigo: `drill-hole-view-unic.component.ts:1366` (drawColorFill), :1387, :3562;
selo MOCK da caixa molhada em ...component.html:154. Teste versionado que falharia se o selo MOCK
regredisse: ...component.spec.ts:712-751.

Nao entregue: camada de geoquimica (AnalysisAssay) nunca implementada; camada de hiperespectral foi
implementada e depois revertida por ordem explicita do usuario (0214edc1, #375). Escopo
residual vive em GT-0030-geoquimica-e-hiperespectral-single-view.md (issue #373, Status: Blocker
no Project).

Decisao pendente do Sergio: o Handoff original ja prescrevia "abrir sub-issue de geoquimica OU
renomear/reescopar esta task". A sub-issue foi aberta (GT-0030), mas esta GT nunca foi formalmente
reescopada para excluir as camadas que migraram. Fechar como esta seria marcar como feito algo que
nao foi; a alternativa e reescrever o escopo desta GT para excluir explicitamente geoquimica e
hiperespectral, citando GT-0030 como dona delas - ai sim fecharia hoje.

Evidencia completa no relatorio da reconciliacao GT-0156.
