---
id: GT-0030
title: "Camada de geoquímica (gráfico por profundidade) e redesenho do mock de mapa hiperespectral no Single View"
status: active
type: feature
achado_origem: "QA-Matheus-2026-09-03 (E3-04/E3-05, TASKS.md linha 31)"
auditor_origem: "Matheus Lima Santos de Souza (QA manual) — roteado por Jarvis"
severidade: "Média — gap de escopo confirmado, não regressão"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-jarvis-qa-pos-implementacao-2026-09-03"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/373"
grupo_execucao: "Correção pós-QA"
owner: ""
created_at: 2026-09-03
updated_at: 2026-09-03
affected_modules: [single-view]
related_adrs: []
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0030 — Geoquímica e redesenho do hiperespectral (Single View)

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
GT-0017 (E3-05) implementou 5 das 9 camadas priorizadas pelo spike GT-0016 (E3-04) e deixou 2 pendências já documentadas e nunca resolvidas: (1) geoquímica (item 6) nunca implementada — o próprio GT-0017 recomendava "abrir sub-issue de geoquímica", nunca feito; (2) o mock de mapa hiperespectral foi implementado como overlay HTML na mesma área da foto da caixa, não como duplicação da caixa ao lado.

## Achado original
Trecho literal de `TASKS.md` (E3-04/E3-05):
> "Hiperespectral foi inserido substituindo a visualização normal; o esperado era duplicar a caixa e mostrar o hiperespectral ao lado. Falta coluna de concentração química por profundidade (gráfico de pontos ligados por linha) e cor dominante por profundidade — referência DataRock/FastGeo. Confirmo: hoje não existe camada de geoquímica."

## Investigação de causa raiz (Jarvis, 2026-09-03)
Confirmado por leitura do código e do próprio histórico das tasks:

1. **Hiperespectral**: GT-0017 implementou o mock como um overlay HTML desenhado **sobre a mesma área/rect da imagem real da caixa** (`renderViewerLayout`), ativado por toggle. Isso significa que, quando ativado, o overlay visualmente **cobre/substitui** a imagem normal em vez de aparecer ao lado dela — bate exatamente com a queixa de Matheus ("substituindo a visualização normal"). A decisão de GT-0017 foi deliberada (isolar risco de coordenadas, ver GT-0017 "Decisões"), mas o resultado visual diverge do que o usuário original pediu ("duplicar a caixa e mostrar o hiperespectral ao lado").
2. **Geoquímica**: confirmado como gap real, não uma percepção equivocada — GT-0017 já documentou explicitamente que o item 6 (geoquímica, `AnalysisAssay`) exige lógica de mapeamento profundidade→pixel mais complexa que as demais camadas e recomendou abrir uma sub-issue dedicada; isso nunca foi feito. O pedido de Matheus/Sergio é mais específico e maior do que o que GT-0017 havia esboçado: não é uma camada de overlay sobre a foto, é um **gráfico próprio** (coluna de concentração química por profundidade, pontos ligados por linha, referência DataRock/FastGeo) — um componente de visualização novo, não uma extensão do padrão `ImgRect` usado pelas outras camadas.

## Objetivo
1. Hiperespectral: reprojetar o mock para duplicar a visualização da caixa e mostrar o painel hiperespectral **ao lado**, não sobreposto.
2. Implementar a camada de geoquímica como um gráfico dedicado (concentração por profundidade + cor dominante por profundidade), referenciando o padrão de produtos como DataRock/FastGeo.

## Fora de escopo
Integração real com hardware hiperespectral (mock explícito continua sendo mock — issue original já confirmou isso). Mineralogia quantitativa/mineralização/textura/estrutura/alteração/cor (já implementadas em GT-0014/GT-0017, não fazem parte desta correção).

## Comportamento atual
Hiperespectral: overlay que cobre a foto real da caixa quando ativado. Geoquímica: nenhuma camada existe.

## Comportamento esperado
Hiperespectral: ao ativar, a caixa é duplicada e o painel hiperespectral (mock, rotulado como tal) aparece ao lado da foto real, não sobre ela. Geoquímica: gráfico de concentração química por profundidade (pontos ligados por linha) + indicador de cor dominante por profundidade, alinhado ao eixo de profundidade do Single View.

## Regras de negócio
- RN-01: N/A.

## Critérios de aceitação
- [ ] CA-01: Ativar o mock de hiperespectral duplica a área de exibição da caixa (real + hiperespectral lado a lado), sem esconder/substituir a foto real.
- [ ] CA-02: Camada de geoquímica exibe concentração química por profundidade como gráfico de pontos ligados por linha, alinhado ao eixo de profundidade real do furo.
- [ ] CA-03: Camada de geoquímica exibe cor dominante por profundidade (indicador visual, referência DataRock/FastGeo).
- [ ] CA-04: Ambas as camadas mantêm sinalização explícita de mock (hiperespectral) ou dado real (geoquímica, `AnalysisAssay`) conforme já estabelecido pelo CA-02 do GT-0017.

## Impacto técnico
### Frontend
Redesenho do layout de exibição para hiperespectral (área duplicada, não overlay); novo componente de gráfico para geoquímica (fora do padrão `ImgRect`/Annotorious já usado pelas outras camadas — mapeamento profundidade→pixel via `DrillCoreDepth`, conforme já levantado por GT-0017).
### Backend
Nenhum endpoint novo confirmado como necessário por GT-0016/GT-0017 (`AnalysisAssayService.getByDrillholeList` já existe) — reconfirmar antes de implementar.
### Banco de dados / Integrações / Segurança
N/A.

## Plano de implementação
- [ ] Redesenhar o mock de hiperespectral (duplicar área de exibição em vez de overlay).
- [ ] Projetar o componente de gráfico de geoquímica (decisão de design — ver "Nota" abaixo).
- [ ] Implementar mapeamento profundidade→pixel para amostras de `AnalysisAssay` (já levantado em detalhe por GT-0017, "Divergências").
- [ ] Implementar indicador de cor dominante por profundidade.

## Estratégia de testes
- [ ] Manual — comparar visualmente com referência DataRock/FastGeo citada pelo usuário.
- [ ] Automatizado — funções puras de mapeamento profundidade→posição do gráfico.

## Riscos e rollback
Maior esforço que as demais camadas de GT-0017 (gráfico novo, não reaproveita o padrão `ImgRect`) — recomendo tratar como task própria de design antes de codar, dado o tamanho.

## Nota do Jarvis
Este item tem escopo maior e mais ambíguo que os demais desta rodada de correção — "gráfico de pontos ligados por linha" e "cor dominante por profundidade, referência DataRock/FastGeo" são uma descrição funcional, não uma especificação de UI. Recomendo que, antes de implementar, o usuário valide um mockup/wireframe do componente de geoquímica (dimensões, onde fica na tela em relação à régua de profundidade e às demais camadas) — evita retrabalho como o que motivou esta própria rodada de correção.

## Registro de execução
### Alterações realizadas
**2026-09-03 (Jarvis) — reversão do mock de hiperespectral**, por decisão explícita do usuário ("pode reverter o que foi alterado no hiperespectral, e marcar a issue como blocked"):
- Removido `showHyperspectralMock` (flag), o bloco `if (this.showHyperspectralMock) { this.addHyperspectralMockOverlay(...) }` dentro de `renderViewerLayout`, e o método `addHyperspectralMockOverlay()` inteiro, de `drill-hole-view-unic.component.ts`.
- Removido o toggle "Mapa hiperespectral" (checkbox + badge MOCK) da seção "Exibição" em `drill-hole-view-unic.component.html`.
- **Preservado intacto**: tudo o mais que GT-0017 implementou (mineralogia quantitativa, textura, estrutura, alteração, cor, e o mock de "Caixas molhadas" — que já duplica corretamente a imagem lado a lado via um segundo `TiledImage`, ao contrário do hiperespectral, e não recebeu nenhuma reclamação de QA).
- Nenhuma referência residual a hiperespectral em código funcional (`.ts`/`.html`) — confirmado por busca; só comentários históricos inofensivos permanecem em 2 lugares (`.html` linha 136, `.scss` linha 738).

### Arquivos principais
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.ts`
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.html`

### Decisões
- Reversão cirúrgica, não reversão do PR #362 (GT-0017) inteiro — as demais camadas daquele PR estão corretas e confirmadas pela própria QA (não foram alvo de nenhuma reclamação).

### Pendências
- Issue #373 criada e marcada `Status: Blocker` no Project Essencis-Labs — nenhuma implementação de geoquímica/redesenho de hiperespectral autorizada até nova decisão do usuário (ele pediu mais análise antes).

## Validação
- `ng build --configuration development` (branch `fix/gt-0030-revert-hiperespectral-mock`, a partir de `feature/visualizadores-navegacao-layout`): sucesso, sem erros novos.
- PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/375 — **mesclado (squash)** em `feature/visualizadores-navegacao-layout`.

## Handoff
Reversão do mock de hiperespectral concluída e mesclada. Issue https://github.com/Essencis-Labs/GeoCloudAI/issues/373 (Status: Blocker) segue aberta para consolidar a pendência de geoquímica (nunca implementada) mais o redesenho do hiperespectral — **bloqueada intencionalmente**, aguardando validação de mockup/wireframe antes de qualquer implementação futura.
