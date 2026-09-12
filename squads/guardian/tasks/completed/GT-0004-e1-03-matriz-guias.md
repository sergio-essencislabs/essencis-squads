---
id: GT-0004
title: "Definir matriz de disponibilidade das guias por entidade"
status: completed
type: feature
reaberta_qa: "2026-09-03"
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "N/A — spike/decisão, bloqueante de 4 issues"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/319"
grupo_execucao: "Onda 1"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-03
affected_modules: [navegacao, images, single-view, multiview, koregeo3]
related_adrs: [GADR-0001]
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0004 — Matriz de disponibilidade das guias por entidade

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
As guias Images, Single View, MultiView e KoreGeo3 precisam aparecer em níveis diferentes da hierarquia. Definir a regra num só lugar evita implementação divergente nas 4 guias.

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/319. Matriz proposta (a validar): Images só em DrillHole/DrillBox; Single View, MultiView e KoreGeo3 em todos os níveis (Region a DrillBox).

## Objetivo
Componente/config única de "guias disponíveis por entidade", consumida por GT-0011 (E2-07), GT-0019 (E3-07), GT-0022 (E4-03), GT-0026 (E5-04).

## Fora de escopo
Implementação das guias em si (cada issue dependente implementa a própria guia).

## Comportamento atual
Sem regra centralizada — risco de implementação divergente entre as 4 guias.

## Comportamento esperado
Config única definindo disponibilidade por entidade, comportamento em nível agregador, e estratégia de carga.

## Regras de negócio
- RN-01: N/A — spike/decisão de arquitetura de navegação, ver GADR-0001.

## Critérios de aceitação
- [x] CA-01: Matriz revisada e aprovada pelo time.
- [x] CA-02: Componente/config única de "guias disponíveis por entidade" definido, consumido pelas issues #328, #332, #340, #336.
- [x] CA-03: Definido o comportamento quando a guia é aberta num nível agregador — agregam furos descendentes ou exigem seleção?
- [x] CA-04: Definida a estratégia de carga nos níveis altos (limite, paginação ou seleção obrigatória), já que Region pode conter centenas de furos.
- [x] CA-05: Definida a ordem em que as guias aparecem e qual é a guia padrão em cada entidade.

## Impacto técnico
### Backend
Se a estratégia de carga exigir paginação server-side em nível de Region, pode exigir endpoint novo/ajustado — confirmar com Breno.
### Frontend
Config/serviço compartilhado consumido por 4 telas.
### Banco de dados
N/A.
### Integrações
N/A.
### Segurança
N/A.

## Plano de implementação
- [ ] Validar matriz com o time (ver GADR-0001).
- [ ] Definir comportamento agregador e estratégia de carga.
- [ ] Implementar componente/config compartilhado.

## Estratégia de testes
- [ ] Manual — validar em cada guia consumidora após a config estar pronta.

## Riscos e rollback
Decisão errada de estratégia de carga em Region (centenas de furos) pode travar a tela nas 4 guias simultaneamente — ver GADR-0001.

## Registro de execução
### Alterações realizadas
Implementada a config/serviço compartilhado decidido em GADR-0001 (Alternativa C):
- Matriz de disponibilidade das 4 guias (Images, Single View, MultiView, KoreGeo3) por nível
  da hierarquia (Region → Deposit → Mine → MineArea → DrillHole → DrillBox).
- Ordem de exibição e guia padrão por nível (CA-05): resolvido genericamente pela primeira
  guia disponível na ordem canônica — `images` em DrillHole/DrillBox, `singleView` em
  Region/Deposit/Mine/MineArea (onde Images não existe).
- Comportamento agregador híbrido por guia (CA-03): Single View e KoreGeo3 = `requireSelection`
  (reaproveita o padrão de listagem paginada, ex. `region-view-drill-holes`); MultiView =
  `autoLoadTopN`; Images = `notApplicable` (nunca aberta de nível agregador).
- Estratégia de carga (CA-04) operacionalizada num serviço único
  (`DescendantDrillHolesLoaderService`) que delega para os endpoints já existentes
  `DrillHole/getBy{Region,Deposit,Mine,MineArea}` — todos já suportam paginação server-side
  (`PageParams`) e (exceto MineArea) o flag `direct`. Não foi necessário endpoint novo/ajustado
  no backend, ao contrário do que o "Impacto técnico" da task levantava como risco.
- Padrão aplicado: `pageSize=10`, `direct=false` por padrão (árvore completa
  Region→Deposit→Mine→MineArea→DrillHole, não só vínculo direto).

Nenhuma das 4 guias em si foi alterada/integrada (fora de escopo desta task, por decisão
explícita) — GT-0011/GT-0019/GT-0022/GT-0026 consomem esta config quando forem implementadas.

### Arquivos principais
- `web/src/app/shared/entity-guides/entity-guide.model.ts` — matriz, tipos (`GeoEntityLevel`,
  `EntityGuideKey`, `AggregatorLoadStrategy`) e funções puras (`getAvailableGuides`,
  `getDefaultGuide`, `isGuideAvailable`, `isAggregatorLevel`, `getAggregatorStrategy`).
- `web/src/app/shared/entity-guides/entity-guide.model.spec.ts` — 7 specs cobrindo a matriz
  completa (disponibilidade por guia/nível, agregador, ordem, guia padrão, estratégia agregadora).
- `web/src/app/shared/entity-guides/descendant-drill-holes-loader.service.ts` — serviço
  `DescendantDrillHolesLoaderService`, delega para `DrillHoleService.getBy{Region,Deposit,Mine,
  MineArea}` conforme o nível, com defaults `pageSize=10`/`direct=false`.
- `web/src/app/shared/entity-guides/descendant-drill-holes-loader.service.spec.ts` — 4 specs
  com `HttpClientTestingModule` validando o roteamento por nível e os parâmetros de query.

### Decisões
- GADR-0001, Alternativa C, aceita por Sergio Mendes em 2026-09-02 (ver arquivo da decisão).
- Guia padrão por entidade resolvida por regra genérica (primeira guia disponível na ordem
  canônica), não hardcoded por entidade — evita divergência se a ordem/matriz mudar no futuro.
- Endpoint `getByMineArea` não tem parâmetro `direct` no backend (MineArea é sempre vínculo
  direto com DrillHole, não há ambiguidade de árvore) — o loader reflete isso, sem inventar
  um parâmetro que o backend não aceita.

### Divergências
Nenhuma divergência da decisão do GADR-0001.

### Pendências
- **Teto de `pageSize` no backend não incluído neste PR** (recomendação opcional do GADR-0001,
  `PageParams.MaxPageSize` em `api/src/Back.Persistence/Models/PageParams.cs`, hoje comentado).
  Motivo: o frontend já depende, em **79 pontos de chamada** espalhados por ~20+ telas (listas
  de apoio/combobox — ex. `drillHoleType.getByAccount(1,100000,...)`), do padrão
  `pageSize=100000` para "carregar tudo de uma vez". Reativar um teto agora sem antes migrar
  esses call sites para um endpoint "getAll" de verdade truncaria silenciosamente essas telas
  em produção — risco maior que o benefício dentro do escopo desta task. Registrado como
  dívida técnica pré-existente (não introduzida por este PR), a ser tratada como task própria
  (auditoria dos ~79 call sites + decisão de teto real).
  - **Auditoria completa realizada em 2026-09-02** (a pedido de Sergio Mendes): confirma a
    estimativa — **96 call sites em 36 arquivos** (74 com `pageSize=100000` puro, mais 22 com
    outras magnitudes grandes com a mesma intenção: `1000`/`500`/`100`). Não existe ponto
    central de migração: cada um de ~18-20 services Angular duplica seu próprio
    `getByAccount()`, sem `BaseService` comum — a alavanca de menor esforço é migrar esses
    ~18-20 services, não os 96 call sites em componentes. Dois achados adicionais separados
    do escopo de dívida técnica "combobox":
    - Bug funcional (não dívida de arquitetura): `sample-assay.component.ts:317` usa
      `pageSize=5000` para a listagem *principal* de resultados (não um combobox) e pagina
      inteiramente no cliente — trunca silenciosamente acima de 5000 análises. Registrado
      separadamente como issue
      [#349](https://github.com/Essencis-Labs/GeoCloudAI/issues/349).
    - Risco de escala real (não "lista pequena de tipo/status"): `drillHoleService.getByAccount
      (1,100000,...)` em `samples.component.ts` e `sample-assay.component.ts` popula um
      seletor de Drill Hole — entidade que pode ter milhares de furos por conta. Candidato a
      autocomplete assíncrono, não a um endpoint "getAll" simples.
    - Plano de migração completo e priorização registrados na issue
      [#350](https://github.com/Essencis-Labs/GeoCloudAI/issues/350) (não urgente, dívida
      técnica pré-existente).
- Revisão do GADR-0001 pede reavaliar se a matriz "tudo ✅ abaixo de Region" sobrevive à
  estratégia de carga — confirmado que sim, pois a estratégia de carga (paginação, não carga
  total) já resolve o volume potencial sem precisar restringir a matriz de disponibilidade.

## Validação
- `ng test` (escopo `web/src/app/shared/entity-guides/**`): **11/11 sucesso**.
- `ng test` (suíte completa do projeto, `web/`): 44 sucesso / 176 falhas — as 176 falhas são
  **pré-existentes na main**, todas do mesmo padrão (specs de scaffold do Angular CLI
  declarando componentes `standalone` no array `declarations` do `TestBed`, ex.
  `CompanyTypesListComponent`, `LithologiesListComponent`) e não têm relação com os arquivos
  deste PR.
- `ng build --configuration production`: sucesso, sem erros. Únicos warnings são pré-existentes
  (dependências CommonJS de terceiros — canvg, jspdf, apexcharts, geotiff).
- PR aberto: https://github.com/Essencis-Labs/GeoCloudAI/pull/347 (branch
  `feature/gt-0004-e1-03-matriz-guias`, a partir de `main`, sem merge).

## Handoff
Bloqueia GT-0011, GT-0019, GT-0022, GT-0026 — todas as 4 podem agora importar
`web/src/app/shared/entity-guides/entity-guide.model.ts` e
`descendant-drill-holes-loader.service.ts` em vez de reimplementar a regra.
Pendência de dívida técnica de backend (teto de `pageSize`) documentada acima, não bloqueante.

**Merge (2026-09-02)**: PR #347 mesclado (squash) em `feature/visualizadores-navegacao-layout`, commit `659370e48617967ff8dffbb9a4d8434fc1bb9ea8`. Ainda não mesclado em `main` — aguardando validação manual do usuário na branch de integração.

## Achado de QA pós-implementação (2026-09-03)
Relatório de QA (Matheus, `TASKS.md`, E1-03): "Ok, mas falta reordenar as guias: Single View → MultiView → KoreGeo3 ('Core View') → Images ('Box View'). Hoje: Overview, Drill Boxes, Images, Deviations, Runs, KoreGeo 3, Multi View, Single View. Ajuste concentrado em entity-guide.model.ts (campo order)."

**Análise (Jarvis)**: confirmado como pedido novo (reordenação + rename), não regressão. Duas mudanças distintas:
1. **Rename**: KoreGeo3 → "Core View", Images → "Box View" (labels).
2. **Reordenar**: Single View, MultiView, KoreGeo3, Images (nessa ordem).

**Nuance importante não coberta pelo apontamento**: o campo `order` de `entity-guide.model.ts` hoje só decide `getDefaultGuide()` (guia padrão, CA-05 original) — a ordem visual real dos `<li>` em `drill-hole-view.component.html` (e nos 4 templates agregadores: region/deposit/mine/mineArea-view) é **hardcoded no HTML**, não gerada a partir da matriz via `*ngFor`. Corrigir só o `order` no `.ts` não muda a ordem visível na tela — é necessário também reordenar os blocos `<li [ngbNavItem]>` nos 5 templates (e renomear o label em cada um). Escopo maior do que "ajuste concentrado em entity-guide.model.ts", mas contido e mecânico.

Ver plano consolidado em `squads/guardian/output/qa-pos-implementacao-2026-09-03.md`.

## Correção do achado de QA (2026-09-03)

### Estado do KoreGeo3 nos 4 templates agregadores no momento da execução
Confirmado via `git log origin/feature/visualizadores-navegacao-layout`: **GT-0026 (#369, "disponibiliza KoreGeo3 a partir de Region e niveis inferiores") já estava mesclado** na branch de integração quando esta correção começou — ou seja, a aba KoreGeo3 **ainda estava presente** em `region-view`, `deposit-view`, `mine-view` e `mine-area-view` (não removida). A reversão mencionada em `qa-pos-implementacao-2026-09-03.md` ("E5-01/E5-04 — KoreGeo3 restrito a DrillHole/DrillBox... reverte GT-0026") é uma **task nova, ainda não despachada/mesclada**, não o estado atual do código.
Por isso, seguindo a contingência já prevista nesta task (ver seção "Achado de QA" acima), a **reordenação completa** (Single View → MultiView → KoreGeo3 → Images, com rename) foi aplicada nos **5 templates** (drill-hole-view + os 4 agregadores), não só no drill-hole-view.

### Alterações realizadas
1. `entity-guide.model.ts`: `order` recalculado (`singleView`=1, `multiView`=2, `koreGeo3`=3, `images`=4) e `label` renomeado (`koreGeo3` → "Core View", `images` → "Box View"). A `key` interna de cada guia não muda — só o rótulo exibido e a posição na matriz/comentários/docstrings (que citavam a ordem antiga como exemplo).
2. `entity-guide.model.spec.ts`: specs de guia padrão (`getDefaultGuide`) e de ordenação (`getAvailableGuides`) atualizados para a nova ordem — consequência direta e esperada: com Images deixando de ser `order:1`, a guia padrão em DrillHole/DrillBox passa de `images` para `singleView` (mesma regra genérica de "primeira guia disponível na ordem canônica" já usada, CA-05 — nenhuma lógica nova).
3. `drill-hole-view.component.html`: as 4 guias (Overview/Drill Boxes/Deviations/Runs) mantidas nas mesmas posições relativas entre si; os blocos `<li [ngbNavItem]>` de Single View/MultiView/KoreGeo3/Images movidos para o final da lista, nessa ordem, com os labels renomeados. Os comentários de guias legadas comentadas (Images2, KoreGeo, KoreGeo2) foram realocados para ficarem adjacentes ao substituto ativo correspondente.
4. `drill-hole-view.component.spec.ts`: teste que verificava a aba "Images" no template atualizado para "Box View".
5. `region-view.component.html`, `deposit-view.component.html`, `mine-view.component.html`, `mine-area-view.component.html`: Images não existe nesse nível (matriz), então só as 3 guias (Single View/MultiView/KoreGeo3) foram reordenadas e o label de KoreGeo3 renomeado para "Core View". Nenhuma mudança nos `.component.ts` desses 4 arquivos — não há guarda condicional (`*ngIf`) nessas guias nesse nível, e nenhum spec desses componentes testa label/ordem de abas.
6. `koregeo3-aggregator.component.html`: textos internos ("KoreGeo3 exige a seleção...", botão "Open KoreGeo3", "Carregando KoreGeo3...") renomeados para "Core View" por consistência com o novo label da aba — extensão mecânica de baixo risco do próprio pedido de rename, sem lógica nova. Nome do componente/seletor (`koregeo3-aggregator`) mantido (identificador interno, não visível ao usuário).

### Decisões
- Rename é só de `label`/texto de UI — a `key: EntityGuideKey` (`koreGeo3`, `images`) não muda, para não quebrar nenhum consumidor que já faça `isGuideAvailable('koreGeo3', ...)` etc.
- Mudança de guia padrão em DrillHole/DrillBox (de `images` para `singleView`) é consequência aceita da regra genérica já decidida em GADR-0001/CA-05, não uma decisão nova desta correção.

### Divergências
Nenhuma do pedido de QA. Divergência (documentada, não do achado em si) entre a nota original desta task sobre o estado de GT-0026 ("está removendo a aba") e o estado real do código (GT-0026 estava *adicionando*, ainda não revertido) — resolvida conforme a contingência já prevista, aplicando a reordenação completa nos 5 templates.

### Validação
- `ng test` (`web/src/app/shared/entity-guides/**`, inclui `entity-guide.model.spec.ts` e `koregeo3-aggregator.component.spec.ts`): **18/18 sucesso**.
- `ng test` (`drill-hole-view.component.spec.ts`): **3/3 sucesso**.
- `ng build --configuration production`: sucesso, sem erros. Warnings pré-existentes (CommonJS de canvg/jspdf/apexcharts/geotiff), não relacionados a este PR.
- Validação visual manual em cada nível (Region/Deposit/Mine/MineArea/DrillHole) ainda pendente — recomendada após merge na branch de integração.

### Handoff
PR aberto: https://github.com/Essencis-Labs/GeoCloudAI/pull/379 (branch `feature/gt-0004-e1-03-reorder-guias`, a partir de `origin/feature/visualizadores-navegacao-layout`, ainda sem merge).

**Conflito de merge esperado e aceitável** com a futura task de reversão de KoreGeo3 nos 4 templates agregadores (E5-01/E5-04, "GT-0026 novo" mencionado em `qa-pos-implementacao-2026-09-03.md`) — mesmos arquivos (`region/deposit/mine/mineArea-view.component.html`), regiões de mudança diferentes (reordenação de bloco vs. remoção do bloco inteiro). Resolução por união quando chegar a hora: a reversão deve simplesmente remover o bloco KoreGeo3/"Core View" (já reordenado por este PR) desses 4 templates, mantendo a reordenação de Single View/MultiView já aplicada aqui.

**PR #379 mesclado (squash) em `feature/visualizadores-navegacao-layout`.** GT-0026 (reversão de KoreGeo3 nos 4 templates agregadores) segue em execução em paralelo — quando terminar, checar se o conflito de merge previsto acima se materializou e resolver por união conforme já documentado.
