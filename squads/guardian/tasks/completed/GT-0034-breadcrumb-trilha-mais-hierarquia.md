---
id: GT-0034
title: "Breadcrumb: combinar trilha de navegação (Geodata Management > Deposits) com a cadeia hierárquica"
status: completed
type: feature
achado_origem: "QA-Sergio-2026-09-03: 'O breadcrumb ainda está péssimo. Clico em dashboard>Geodatamanagement>Deposits e quando seleciono um deposit já quebra o breadcrumb'"
auditor_origem: "Sergio Mendes (teste manual) — investigado por Jarvis"
severidade: "Média — navegação confusa, sem perda de dado"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-jarvis-qa-2026-09-03-rodada-2"
issue_url: ""
grupo_execucao: "Correção pós-QA rodada 2"
owner: ""
created_at: 2026-09-03
updated_at: 2026-09-03
affected_modules: [breadcrumb, navegacao]
related_adrs: []
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0034 — Breadcrumb: trilha de navegação + hierarquia

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
Sergio (2026-09-03): "O breadcrumb ainda está péssimo. Clico em dashboard > Geodata Management > Deposits e quando seleciono um deposit já quebra o breadcrumb."

## Causa raiz (investigação Jarvis, 2026-09-03)
Dois problemas distintos, ambos reais:

1. **A trilha percorrida desaparece (decisão deliberada do GT-0002)**. O GT-0002 registrou em "Decisões": *"Removido o link genérico da listagem (ex. 'Mines' antes de 'Mine View') do breadcrumb das páginas afetadas, já que ele não faz parte da cadeia de ancestrais real"*. Ou seja: você navega Dashboard → Geodata Management → Deposits → abre um item, e o breadcrumb troca a trilha que você percorreu pela cadeia hierárquica do item. Para quem navegou pela lista, parece que o breadcrumb "quebrou".

2. **Níveis com nome idêntico ficam indistinguíveis**. Confirmado no banco: a Region id 2 e o Deposit id 3 se chamam **literalmente** "Canaã dos Carajás". O breadcrumb então renderiza `Home > Canaã dos Carajás > Canaã dos Carajás > Canaã Mine > Mine Area 4 > Drill Hole 1` — fiel ao dado, mas visualmente parece defeito, porque nada indica qual crumb é Region e qual é Deposit.

## Decisão do usuário (2026-09-03)
**"Trilha de navegação + hierarquia"**: `Home > Geodata Management > Deposits > [cadeia hierárquica do item]`. Preserva o caminho percorrido e mantém a informação de onde o item vive na hierarquia.

## Objetivo
O usuário nunca perde a referência de como chegou ali, e continua enxergando a hierarquia real do item.

## Critérios de aceitação
- [x] CA-01: Ao abrir um item a partir de uma listagem, o breadcrumb mostra a seção de navegação (ex. `Geodata Management > Deposits`) **e** a cadeia hierárquica do item.
- [x] CA-02: Cada segmento navega para o lugar certo (seção → listagem correspondente; ancestral → página daquele ancestral).
- [x] CA-03: Breadcrumb longo não quebra o layout — truncamento/ellipsis + tooltip já existentes do GT-0002 continuam funcionando, inclusive em tela pequena. Definir e documentar qual ponta trunca primeiro quando não couber. (Decisão: nenhuma ponta "trunca" a sequência — `flex-wrap` quebra linha, cada label trunca no final do texto; ver Decisões.)
- [x] CA-04: Resolver a ambiguidade de níveis homônimos (ver causa raiz #2) — decidir entre rótulo de nível, ícone por nível ou tooltip, e aplicar de forma consistente. Validar especificamente com Region+Deposit "Canaã dos Carajás". (Ícone + tooltip; validado via spec dedicado, não visualmente — ver Pendências.)
- [x] CA-05: Entrar direto por link/URL (sem passar pela listagem) continua funcionando, com um fallback coerente para a parte de navegação. (Trilha estática por tipo de entidade, não depende de histórico de navegação.)
- [ ] CA-06: Specs de `hierarchy-breadcrumb.utils` atualizados (feito, 11/11 SUCCESS); validação visual real nos 6 níveis (**não feita** — sem backend disponível nesta sessão, ver Pendências).

## Riscos e rollback
Reverte parcialmente uma decisão registrada do GT-0002 — documentar isso explicitamente na task para não parecer contradição sem contexto.

## Registro de execução

### Alterações realizadas
- `hierarchy-breadcrumb.utils.ts` reescrito: cada builder (`buildRegionBreadcrumb`, `buildDepositBreadcrumb`, `buildMineBreadcrumb`, `buildMineAreaBreadcrumb`, `buildDrillHoleBreadcrumb`, `buildDrillBoxBreadcrumb`) agora monta `[trilha de navegação] + [cadeia hierárquica] + [item ativo]`, em vez de só a cadeia hierárquica:
  - **Trilha de navegação** (`navigationSection()`): `Home > Geodata Management > <listagem do nível atual>` (ex.: `Deposits`, `Mines`, `Mines Areas`...) — texto e link **idênticos** ao breadcrumb estático já usado nas telas de listagem (`DepositsComponent.ngOnInit()` etc.), reaproveitado em vez de duplicado com texto diferente.
  - **Cadeia hierárquica**: igual ao GT-0002 (Region › Deposit › Mine › MineArea › DrillHole › DrillBox, a partir dos objetos aninhados do `GetById`), sem mudança de fonte de dado nem de endpoint.
  - Ela é **estática por tipo de entidade**, não construída a partir do histórico real de navegação do browser — resolve CA-01 e CA-05 ao mesmo tempo: aparece igual entrando pela listagem ou colando a URL direto, sem precisar rastrear de onde o usuário veio.
- **CA-04 (níveis homônimos)**: cada ancestral e o item ativo agora carregam (a) o mesmo ícone Remix já usado no `icon` do `app-page-header` daquele nível nas 6 telas `-view` (Region `ri-map-2-line`, Deposit `ri-stack-line`, Mine `ri-hammer-line`, MineArea `ri-map-pin-line`, DrillHole `ri-focus-3-line`, DrillBox `ri-archive-2-line` — convenção já existente, não inventada) e (b) um `tooltipLabel` no formato `"<Nível>: <nome>"` (ex. `"Region: Canaã dos Carajás"` vs. `"Deposit: Canaã dos Carajás"`). Testado especificamente com o par Region id 2 / Deposit id 3, ambos "Canaã dos Carajás" — ver spec `CA-04: níveis homônimos`.
- `AppPageHeaderComponent`: `PageHeaderBreadcrumbItem` ganhou `tooltipLabel?` (cai para `label` se ausente). Template ganhou um terceiro ramo (`@else if (item.active)` / `@else`) para diferenciar visualmente um item de **seção pura** (ex. "Geodata Management" — não navega, não é a página atual) do item **realmente ativo** — antes os dois usavam o mesmo estilo bold/branco (`.ph-crumb-current`), o que ficava ambíguo agora que a trilha aparece também nas 6 telas `-view` (antes só aparecia nas listagens). Nova classe `.ph-crumb-section` (cor mais apagada, sem negrito).
- Os 6 componentes de **listagem** (`RegionsComponent`, `DepositsComponent`, `MinesComponent`, `MineAreasComponent`, `DrillHolesComponent`, `DrillBoxesComponent`) ganharam `icon` nos itens estáticos `{ label: 'Geodata Management' }` (`ri-database-2-line`, ícone da seção no menu lateral) e `{ label: '<Entidade>', active: true }` (mesmo ícone da entidade) — só para ficarem visualmente consistentes com o que as telas `-view` agora mostram para os mesmos dois rótulos; texto e comportamento de nenhum deles mudou.
- **Nenhuma mudança nos 6 componentes `-view`** (`region-view`, `deposit-view`, `mine-view`, `mine-area-view`, `drill-hole-view`, `drill-box-view`) — eles só chamam `build<Entidade>Breadcrumb(res)`, cuja assinatura e tipo de retorno não mudaram. Feito de propósito para minimizar a superfície de conflito com GT-0035, que toca as mesmas 6 telas em outra frente (estado vazio).

### Arquivos principais
- `web/src/app/shared/hierarchy-breadcrumb/hierarchy-breadcrumb.utils.ts`
- `web/src/app/shared/hierarchy-breadcrumb/hierarchy-breadcrumb.utils.spec.ts`
- `web/src/app/ui/app-page-header/app-page-header.component.ts` / `.html` / `.scss`
- `web/src/app/pages/geodata/regions/regions.component.ts`
- `web/src/app/pages/geodata/deposits/deposits.component.ts`
- `web/src/app/pages/geodata/mines/mines.component.ts`
- `web/src/app/pages/geodata/mine-areas/mine-areas.component.ts`
- `web/src/app/pages/geodata/drill-holes/drill-holes.component.ts`
- `web/src/app/pages/geodata/drill-boxes/drill-boxes.component.ts`

### Decisões
- **Reverte parcialmente o GT-0002, de propósito.** O GT-0002 registrou: *"Removido o link genérico da listagem (...) do breadcrumb (...) já que ele não faz parte da cadeia de ancestrais real"*. O achado de QA do Sergio (2026-09-03) mostrou que essa remoção tinha um custo real: quem navega Dashboard → Geodata Management → Deposits → abre um item perde a trilha que percorreu, e o breadcrumb "troca de assunto" abruptamente para a cadeia hierárquica. A decisão do usuário (2026-09-03) foi manter as duas informações juntas — a trilha entra de volta, mas não substitui mais a hierarquia, as duas coexistem. Não é uma contradição do GT-0002: é uma correção de um trade-off que só ficou visível depois de uso real (QA rodada 2), documentada explicitamente aqui como pedido pela task.
- **A trilha é estática (por tipo de entidade), não rastreada por navegação real.** Cogitado usar `Router`/histórico de navegação ou `sessionStorage` para lembrar "de onde o usuário veio", mas isso teria exigido um mecanismo novo (não existe hoje nenhum rastreamento de histórico de navegação no app) só para reproduzir, na prática, o MESMO texto/link que a tela de listagem já exibe sempre (`Geodata Management > Deposits`, sempre, para qualquer Deposit). Usar o texto estático da própria listagem resolve CA-01 e CA-05 com uma implementação mais simples e sem introduzir um padrão novo — e como bônus não quebra nunca com navegação direta por URL, F5, ou link compartilhado.
- **Ícone por nível (não rótulo de nível nem só tooltip) para CA-04.** As 3 opções descritas na task (rótulo de nível, ícone por nível, tooltip) não são mutuamente exclusivas — foi escolhida a combinação ícone + tooltip: o ícone é reconhecível de relance (resolve o caso "Canaã dos Carajás" aparecendo duas vezes seguidas sem precisar ler/comparar texto) e o tooltip cobre acessibilidade/leitura de tela e o caso de o ícone sozinho não bastar. Um rótulo de nível textual (ex. "Region: Canaã dos Carajás" direto no crumb, sem ser só no tooltip) foi descartado por ocupar mais da largura já escassa de cada crumb (max-width de 90px em mobile — ver CA-03). Os ícones reaproveitados são os MESMOS já usados no cabeçalho de cada tela `-view` (`icon` do `app-page-header`) — não foram inventados ícones novos.
- **CA-03 (truncamento): decisão é "wrap, nunca esconder segmento".** Com a trilha somada à hierarquia, o breadcrumb pode chegar a 9 segmentos (caso DrillBox). Decisão: manter `flex-wrap: wrap` (já existente desde o GT-0002) e deixar os itens que não cabem quebrarem para a linha seguinte — nenhum segmento é escondido/colapsado dinamicamente. Um padrão de "colapsar o meio da cadeia num ellipsis clicável" foi considerado e descartado: não existe esse padrão em nenhum outro breadcrumb do app, e adicionar um novo componente de UI só para este caso seria desproporcional ao problema (a largura já é resolvida pelo wrap, sem esconder informação). Dentro de cada crumb individual, o texto continua truncando no FINAL (ellipsis + tooltip), mantendo o início do nome visível — comportamento inalterado do GT-0002. Documentado em comentário no `.scss`.
- **Ícones adicionados também às 6 telas de listagem** (`Geodata Management` e o rótulo ativo, ex. "Deposits"), fora do pedido explícito da task, para não deixar os dois lugares (listagem vs. `-view`) mostrando o mesmo rótulo com aparência diferente (um com ícone, outro sem) agora que ambos compartilham o componente `app-page-header` e a nova distinção visual `.ph-crumb-section`. Mudança de escopo pequeno e mecânico (só adiciona `icon:` a objetos já existentes, sem mudar texto/link/comportamento).
- **Não fixado o typo pré-existente "Mines Areas"** (em vez de "Mine Areas") no rótulo da listagem de áreas de mina — mantido de propósito idêntico ao texto já usado em `mine-areas.component.ts`, para a mesma rota nunca aparecer com dois textos diferentes dependendo de onde o usuário entrou. Corrigir o typo é uma mudança de texto de UI fora do escopo desta task; sinalizado aqui caso outra task queira endereçar.
- **Nova classe `.ph-crumb-section` afeta todas as telas do app que usam `app-page-header`** (não só geodata) — várias outras seções (Settings, Entities, Analysis) já usam o mesmo padrão de rótulos de seção sem link no meio do breadcrumb (ex. `{ label: 'Settings' }`, `{ label: 'Geodata' }`, `{ label: 'Others' }` em `colors.component.ts`). Antes, esses rótulos usavam o MESMO estilo bold/branco do item realmente ativo (`.ph-crumb-current`), o que já era um pouco ambíguo lá também. Optado por corrigir de forma consistente em todo o componente compartilhado, em vez de introduzir a distinção só nas 6 telas geodata — é uma mudança puramente visual (CSS + branch de template), sem alterar texto, link ou comportamento de nenhuma tela.

### Divergências
Nenhuma quanto ao objetivo pedido. A extensão do `icon`/`.ph-crumb-section` às 6 listagens e a todo `app-page-header` do app (não só as 6 telas `-view` citadas na task) foi uma decisão tomada durante a implementação, justificada acima — sinalizando aqui para quem revisar avaliar se concorda com o escopo ampliado.

### Pendências
- **Validação visual real nos 6 níveis não foi executada** — sem backend rodando neste ambiente (mesma limitação já registrada no GT-0002 original e na correção de QA anterior). Recomendado antes do merge: navegar Dashboard → Geodata Management → Deposits → abrir um Deposit e confirmar visualmente `Home > Geodata Management > Deposits > Region > Deposit(atual)`; repetir para os outros 5 níveis; e validar especificamente o par Region id 2 / Deposit id 3 ("Canaã dos Carajás") nos dados de dev, confirmando que os ícones (mapa vs. pilha) e o tooltip diferenciam os dois crumbs.
- Suíte completa de `ng test` não foi executada de ponta a ponta nesta sessão (ambiente compartilhado com alta carga tornou uma rodada completa impraticável no tempo disponível) — rodados os escopos relevantes (`hierarchy-breadcrumb`, `geodata`, `ui`) via `--include`; ver Validação.
- Specs legadas de `RegionsComponent`, `DepositsComponent`, `MinesComponent`, `MineAreasComponent`, `DrillHolesComponent`, `DrillBoxesComponent` (as 6 **listagens**, não as `-view`) usam `TestBed.configureTestingModule({ declarations: [...] })`, inválido para componentes standalone no Angular 19 — mesmo débito pré-existente já documentado no GT-0002 para as 6 telas `-view` (PR #356 já corrigiu 161 specs em outro lugar do app, mas não estas). Não corrigido aqui por disciplina de escopo; confirmado por leitura que nenhuma dessas specs faz asserção sobre `breadCrumbItems`, então a mudança desta task não piora nem melhora o estado delas.

## Validação
- `ng test --include="src/app/shared/hierarchy-breadcrumb/**/*.spec.ts"` (Chrome Headless real, launcher `ChromeHeadlessCI`) → **11/11 SUCCESS**, incluindo os 2 testes novos de CA-04 (par homônimo Region/Deposit "Canaã dos Carajás" e cadeia de 3 níveis com Mine por cima).
- `ng build --configuration production` → **build completo, exit code 0**. Únicos warnings são pré-existentes e não relacionados a esta mudança (NG8107 em `Login2Component`/`DrillHoleViewMultComponent`/`Drillholesview3DComponent`, dependências CommonJS/ESM) — mesmos já documentados nas validações do GT-0002.
- Revisão de código (não apenas suposição) confirmando que os 6 componentes `-view` não precisaram de nenhuma alteração — só consomem `build<Entidade>Breadcrumb()`, cuja assinatura pública não mudou.
- Confirmado por leitura que nenhuma spec pré-existente (`regions.component.spec.ts` e as outras 5 listagens) faz asserção sobre o conteúdo de `breadCrumbItems`, portanto adicionar `icon:` a esses arrays não introduz nem mascara nenhuma regressão.
- **Não executado**: validação visual real em navegador com backend ativo (sem ambiente disponível nesta sessão — ver Pendências) e rodada completa de `ng test` sobre toda a suíte (ambiente compartilhado sob alta carga).

## Handoff
Revisita GT-0002 (reversão parcial e deliberada, motivo documentado acima em "Decisões"). Nenhuma mudança nos arquivos dos 6 componentes `-view` — apenas em `hierarchy-breadcrumb.utils.ts`, `app-page-header` e nas 6 telas de **listagem** — por isso o conflito de arquivos com GT-0035 (que mexe nas telas `-view` para o estado vazio) deve ficar limitado, na pior hipótese, a `git blame` cruzado no mesmo componente sem sobreposição de linhas; nenhuma sobreposição de arquivo esperada com os pontos que o GT-0035 provavelmente altera (templates das 6 `-view`, não o builder do breadcrumb).

Pendente para quem revisar: (1) validação manual navegando pelos 6 níveis com dados reais, especialmente o par "Canaã dos Carajás"; (2) decidir se concorda com a extensão da correção visual `.ph-crumb-section` a todo o `app-page-header` do app (Settings/Entities/Analysis também usam o mesmo padrão de rótulo de seção), em vez de limitá-la só às 6 telas geodata.

**PR #391 mesclado (squash)** em `feature/visualizadores-navegacao-layout` (Jarvis, 2026-09-03): https://github.com/Essencis-Labs/GeoCloudAI/pull/391

**Ponto levado ao usuário**: a correção visual `.ph-crumb-section` foi aplicada a todo o `app-page-header`, ou seja, afeta também Settings/Entities/Analysis, não só as 6 telas geodata. Blast radius maior que o escopo original da task — sinalizado para o usuário decidir se mantém assim ou se quer restringir.

## Merge
PR # mesclado em `feature/visualizadores-navegacao-layout` em 2026-09-03. **Não movido para `completed/`**: falta a validação visual humana (retest do Sergio na branch de integração) — 2 das 3 evidências (código + teste) estão registradas; a terceira (confirmação de comportamento em navegador real) é justamente o que o QA rodada 2 apontou como falho.

## QA 2026-09-05 — tooltip duplicado
Todo hover do breadcrumb mostrava também o título da página ("Detalhe da Caixa"): `<app-page-header title="...">` (atributo estático em 57 telas) deixava `title` como atributo HTML no host → tooltip nativo sobre o cabeçalho inteiro. Corrigido no componente com `host: { '[attr.title]': 'null' }` (PR de layout mesclado em `feature/visualizadores-navegacao-layout`). Continua em `active/` até retest.
