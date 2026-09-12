---
id: GT-0035
title: "Estado vazio honesto nos visualizadores quando o furo/nível não tem caixas (hoje mostra painel preto / 'No image')"
status: active
type: feature
achado_origem: "QA-Sergio-2026-09-03: 'Single view completamente bugado' / 'Multiview inexistente' (depósito Tapira)"
auditor_origem: "Sergio Mendes (teste manual) — investigado por Jarvis"
severidade: "Média — não há perda de dado, mas a tela parece quebrada quando na verdade não há dado"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-jarvis-qa-2026-09-03-rodada-2"
issue_url: ""
grupo_execucao: "Correção pós-QA rodada 2"
owner: ""
created_at: 2026-09-03
updated_at: 2026-09-03
affected_modules: [single-view, multiview, images-viewer]
related_adrs: []
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0035 — Estado vazio honesto nos visualizadores

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

## Achado original
Sergio (2026-09-03), testando no depósito **Tapira**: "Single view completamente bugado" e "Multiview inexistente" — Multi View renderiza dois painéis pretos rotulados "No image"; Single View mostra um badge "0 caixas" e canvas vazio.

## Causa raiz (confirmada no banco, Jarvis)
**Não é bug de carregamento — é ausência de dado.** Query no banco de dev:

```
depositId | deposit | holeId | hole          | boxes | boxesWithImg
2         | Tapira  | 10     | Drill Hole 10 | 0     | 0
2         | Tapira  | 11     | Drill Hole 11 | 0     | 0
```

Os dois furos do depósito Tapira têm **zero caixas**. Não há absolutamente nada para renderizar. O defeito real é de UX: em vez de dizer isso, a tela entrega um painel preto com "No image", que é indistinguível de uma falha de carregamento.

Confirmação cruzada: no Mine Area (onde há dado real), os visualizadores renderizam — os problemas de lá são outros (GT-0031, já corrigido, e GT-0033, régua).

## Objetivo
Quando não há caixas/imagens, a tela diz isso claramente, em vez de parecer quebrada.

## Critérios de aceitação
- [x] CA-01: Single View, com furo sem caixas, exibe estado vazio explícito (ex.: "Este furo não tem caixas cadastradas"), não canvas em branco.
- [x] CA-02: Multi View, com furo sem caixas, exibe estado vazio explícito por painel, não painel preto com "No image".
- [x] CA-03: Distinguir claramente os 3 casos: (a) sem caixas cadastradas; (b) caixas cadastradas mas sem imagem; (c) imagem cadastrada mas que falhou ao carregar (404 do arquivo físico). Hoje os três parecem iguais.
- [x] CA-04: Aberto a partir de nível agregador (Region/Deposit/Mine/MineArea) onde **nenhum** furo descendente tem caixa, mostrar um estado vazio de nível, não N painéis vazios.
- [~] CA-05: Validação visual real com o depósito Tapira (caso vazio) e com Mine Area 4 (caso com dado), confirmando que o caso com dado não regrediu. — **Não executada**: sem ambiente rodando disponível nesta sessão (ver Validação). Build + specs confirmam a lógica; validação visual real fica pendente para quem tiver o ambiente de dev up.

## Nota sobre o caso (c)
Durante a investigação do GT-0031 foi observado que parte das caixas seedadas mais recentes não tem o arquivo físico de imagem presente no `Resources/` de todo ambiente (pasta gitignored, populada por quem rodou o seed). Isso torna o caso (c) comum em ambiente de desenvolvimento — mais um motivo para diferenciá-lo visualmente de "não há dado".

## Riscos e rollback
Baixo — aditivo, sem mudança de fluxo de dados.

## Registro de execução

### Alterações realizadas

**Single View (`drill-hole-view-unic.component.ts`)**
- CA-01: quando `layout.rows.length === 0` para um furo selecionado (0 `DrillBox`es, ou — no modo vertical — 0 cores elegíveis para crop), um painel explícito substitui o antigo "pill do header flutuando sobre nada": `addEmptyHolePanel(x, width, message)`. Mensagem distingue os dois casos do modo vertical: furo sem caixa nenhuma vs. caixas existentes mas sem core mapeado para o modo vertical.
- CA-03 (caso c): `addTiledImage(...)` (tanto a coluna seca horizontal quanto o crop clipado do modo vertical) ganhou callback `error`, que desenha `addFailedImageSlot(rect)` — borda/tom vermelho, texto "Falha ao carregar imagem" — no lugar exato onde a foto entraria. Confirmado contra o bundle instalado do openseadragon 4.1.1 (`build/openseadragon/openseadragon.js`) que uma `ImageTileSource` cuja URL retorna erro de carregamento dispara `open-failed` na tile source, que `addTiledImage` converte em `options.error(event)` — ou seja, o 404 realmente cai nesse callback, não fica silenciosamente sem imagem.
- `addEmptySlot` (já existente, "sem caixa"/"sem imagem" dentro de um furo com outras caixas) não foi alterado — já distinguia (a)/(b) razoavelmente bem a nível de linha; o problema real era a ausência de qualquer coisa quando o furo inteiro não tinha nenhuma caixa.

**Multi View (`drill-hole-view-mult.component.ts` + `.html` + `.scss`)**
- Novo `holeRawBoxCountCache: Map<number, number>` guarda a contagem **não filtrada** de `DrillBox` por furo (populado em `getDrillBoxes()` e `selectHoleForSlot()`), porque `holeBoxesCache` só guarda a lista já filtrada por `imgBoxId != null` — sem essa contagem separada não dá pra distinguir "0 caixas" de "caixas sem imagem" (CA-03 a/b).
- Novo `windowImageLoadFailed: Record<ViewerSlot, boolean>`, setado por um handler `open-failed` no viewer (registrado uma vez em `ensureViewer`) e resetado no início de cada tentativa em `loadImageInViewer` — cobre o caso (c) por painel.
- Novo getter `windowEmptyState(slot)` retorna `'no-boxes' | 'no-image' | 'load-failed' | null`, consumido pelo template para desenhar um overlay sobre o `.openseadragon-viewer` (que continua preto por baixo — nada precisou mudar na inicialização do OSD em si).
- CA-04: `loadAggregatorDrillHoles` agora chama `probeHolesForBoxes(holes)` antes de abrir os painéis padrão — uma sondagem paralela (`forkJoin`, pageSize=1 por furo) checando se **algum** furo descendente tem caixa. Se nenhum tiver, `aggregatorEmptyState` é setado e o template substitui todo o `.viewers-grid` por uma única mensagem de nível, em vez de abrir N painéis pretos. Achado real que motivou isso: `DescendantDrillHolesLoaderService` retorna os furos existentes independente de eles terem caixa — o guard antigo (`holes.length === 0`) nunca disparava para o caso Tapira (2 furos, 0 caixas cada).
- Efeito colateral corrigido de propósito: `loadImageInViewer` agora fecha o viewer (`viewer.close()`) quando o índice de imagem é inválido (painel sem caixas), pra nenhuma imagem antiga ficar visível atrás da mensagem de estado vazio ao trocar de furo num painel.

### Arquivos principais
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.ts`
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-mult/drill-hole-view-mult.component.ts`
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-mult/drill-hole-view-mult.component.html`
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-mult/drill-hole-view-mult.component.scss`
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-mult/drill-hole-view-mult.component.spec.ts` (testes existentes de CA-02/CA-04 do GT-0022 ajustados para a nova requisição de sondagem; teste novo para o CA-04 desta task)

### Decisões
- Não criei nenhum serviço/endpoint novo — o probe do CA-04 reusa `DrillBoxService.getByDrillHole` (mesmo endpoint que o resto da tela já chama), só com `pageSize=1`. Nenhuma decisão de tenant/permissão no frontend; a query em si já deriva o furo do id passado, igual ao resto do código.
- `addEmptySlot`/`addFailedImageSlot`/`addEmptyHolePanel` ficaram como três overlays visualmente distintos de propósito (cinza tracejado "sem dado" vs. vermelho "falha de carregamento" vs. card maior "furo inteiro vazio") — critério CA-03 pede explicitamente que os três casos não se pareçam.
- No modo vertical do Single View, quando o furo TEM caixas mas nenhum core elegível pro crop, a mensagem é diferente ("Nenhum core mapeado disponível para o modo vertical") em vez de reusar "não tem caixas cadastradas", que seria enganoso.

### Divergências
- Nenhuma da task original. CA-05 (validação visual) não foi executada por falta de ambiente — ver seção Validação.

### Pendências
- Validação visual real no depósito Tapira e no Mine Area 4 (CA-05) — ver Validação/Handoff.

## Validação

- `cd web && npx tsc -p tsconfig.json --noEmit` — sem erros.
- `cd web && npx ng build --configuration development` — build completo, sem erros (mesmos 3 warnings NG8107 pré-existentes, não relacionados a esta task).
- `cd web && npx ng test --watch=false --browsers=ChromeHeadless --include='**/drill-hole-view-mult.component.spec.ts' --include='**/drill-hole-view-unic.component.spec.ts' --include='**/single-view-metric-layout.spec.ts'` — **39 passaram, 1 falhou**.
  - A falha (`DrillHoleViewUnicComponent should create`, `NullInjectorError: No provider for HttpClient!`) é **pré-existente e não relacionada** a esta task: o describe block na raiz do spec (linhas 10–28) nunca importou `HttpClientTestingModule`, e o componente já dependia de `DrillHoleService`/`HttpClient` antes desta mudança. Não toquei nesse arquivo de spec. Consistente com a dívida técnica de specs conhecida (`.claude/agent-memory` do agente frontend-angular, memória "Fix TestBed.declarations"). Não corrigi aqui por estar fora do escopo do GT-0035 — sinalizando para triagem separada.
  - Os testes de Multi View que cobrem diretamente o fluxo alterado (entrada por nível agregador, GT-0022/CA-04) passaram, incluindo o teste novo escrito para o CA-04 desta task.
- **Validação visual real (Tapira / Mine Area 4): NÃO EXECUTADA.** Esta sessão não tinha um ambiente de API/DB rodando disponível (sem `dotnet run` da API nem `ng serve` validado contra um backend com os dados descritos na task). A lógica foi validada por: (1) leitura direta do código OpenSeadragon instalado confirmando que os eventos `error`/`open-failed` disparam exatamente como assumido; (2) os testes automatizados de Multi View cobrindo o fluxo agregador; (3) inspeção manual da árvore de renderização (`buildHoleLayout`, `renderViewerLayout`/`renderViewerLayoutVertical`) confirmando que `layout.rows.length === 0` é exatamente e apenas a condição "furo sem caixas/sem core mapeado". Quem pegar esta task para revisão/merge deve validar visualmente no depósito Tapira (furos 10 e 11, 0 caixas) e no Mine Area 4 (para confirmar que o caso com dado não regrediu) antes do merge final, se possível.

## Handoff
- Atenção ao conflito de arquivos com GT-0034 (breadcrumb) e GT-0033 (régua) — ambas tocam `drill-hole-view-unic.component.*`. Minhas mudanças em `drill-hole-view-unic.component.ts` são duas inserções pontuais e aditivas dentro de `renderViewerLayout`/`renderViewerLayoutVertical` (logo após o header/antes do loop de rows) e dois `error:` callbacks acrescentados às chamadas existentes de `addTiledImage` — nenhuma reescrita de método, nenhuma mudança de assinatura. Resolução por união deve ser direta; se o merge tool reclamar de contexto, o marcador é o comentário `GT-0035` em cada trecho.
- **Pendência para quem mergear**: rodar a validação visual real (CA-05) — depósito Tapira (estado vazio) e Mine Area 4 (estado com dado, sem regressão) — que não pude executar por falta de ambiente nesta sessão.
- A falha pré-existente de `DrillHoleViewUnicComponent should create` (NullInjectorError/HttpClient) não foi corrigida por estar fora do escopo — mas é rápida de corrigir (adicionar `HttpClientTestingModule` ao `imports` desse describe block) se algum agente futuro passar por ali.

**PR #389 mesclado (squash) em `feature/visualizadores-navegacao-layout`** (Jarvis, 2026-09-03). CA-05 (validação visual em Tapira e Mine Area 4) segue pendente — o usuário tem o ambiente rodando e valida na próxima rodada de teste.

## Merge
PR # mesclado em `feature/visualizadores-navegacao-layout` em 2026-09-03. **Não movido para `completed/`**: falta a validação visual humana (retest do Sergio na branch de integração) — 2 das 3 evidências (código + teste) estão registradas; a terceira (confirmação de comportamento em navegador real) é justamente o que o QA rodada 2 apontou como falho.
