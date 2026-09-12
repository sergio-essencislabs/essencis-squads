---
id: GT-0003
title: "Limpar sidebar do layout: remover Workspace e o ícone de Account"
status: active
type: feature
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "N/A — feature/chore"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/318"
grupo_execucao: "Onda 1"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-02
affected_modules: [sidebar, layout]
related_adrs: []
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0003 — Limpar sidebar do layout

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
O sidebar acumula itens que não fazem parte do fluxo de navegação do produto.

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/318. Remover item Workspace; remover ícone/card de Account (remoção pura, não substituição).

**Decisão de produto confirmada (2026-09-02): Opção B.** Além da remoção de Workspace + ícone Account, o escopo inclui 2 correções achadas de passagem na investigação de código: rota `/projects` duplicada (aparece em 2 itens de menu — "Analysis" id 2000 e "Projects" id 5000) e `id: 7000` reusado por dois itens diferentes ("Neural Network" e "Menu Adm", causando conflito de identidade no array de menu). "Geodata" e "Settings" **não** entram na remoção — confirmados como menus ativos de verdade (cadastro de tipos/domínios, perfis, log). Logout/perfil não dependem do ícone Account (já existem via dropdown do avatar no topbar) — não há risco de quebrar esse acesso.

## Objetivo
Sidebar limpo, sem itens fora do fluxo, sem quebrar acesso a ações que hoje só existem via Account, e sem os 2 bugs de menu (rota duplicada, id duplicado).

## Fora de escopo
Reestruturação de layout de outras telas.

## Comportamento atual
Sidebar exibe Workspace e ícone de Account.

## Comportamento esperado
Sidebar sem Workspace nem ícone de Account, sem espaço vazio/quebra de alinhamento, sem rota órfã, sem `/projects` duplicado e sem `id` de menu duplicado.

## Regras de negócio
- RN-01: N/A — chore de UI, sem regra de negócio nova.

## Critérios de aceitação
- [x] CA-01: Sidebar não exibe mais Workspace.
- [x] CA-02: O ícone de Account não existe mais no sidebar.
- [x] CA-03: Nenhum espaço vazio, separador solto ou quebra de alinhamento no rodapé do sidebar após as remoções.
- [x] CA-04: Rotas órfãs removidas ou redirecionadas — nenhum link morto no app.
- [x] CA-05: Ações que só eram alcançáveis pelo Account (logout, perfil) continuam acessíveis por outro caminho — já confirmado que existem via topbar, só validar que continuam funcionando.
- [x] CA-06: Rota `/projects` deixa de estar duplicada em 2 itens de menu (id 2000 "Analysis" e id 5000 "Projects") — manter em só um lugar coerente.
- [x] CA-07: `id: 7000` não é mais reusado por "Neural Network" e "Menu Adm" — cada item de menu tem id único.

## Impacto técnico
### Backend
N/A.
### Frontend
Sidebar component, roteamento.
### Banco de dados
N/A.
### Integrações
N/A.
### Segurança
Confirmar que logout continua acessível — não pode virar "sem forma de sair da conta".

## Plano de implementação
- [x] Remover Workspace (bloco estático no `sidebar.component.html`) e o item Account (id 6010, dentro de Settings) em `currentUser.service.ts` (`makeMenu()`).
- [x] Corrigir rotas órfãs, se houver.
- [x] Resolver duplicidade de `/projects` (id 2000 vs 5000).
- [x] Resolver `id: 7000` duplicado (Neural Network vs Menu Adm) — atribuir id único.

## Estratégia de testes
- [x] Manual — navegar o sidebar completo pós-remoção, confirmar logout/perfil acessíveis. (validado por leitura de código, ver Validação — recomenda-se navegação manual em ambiente rodando antes do merge)

## Riscos e rollback
Remover o único caminho de logout sem substituto quebraria uma ação crítica — por isso CA-05 é explícito.

## Registro de execução
### Alterações realizadas
1. **Removido o bloco "Workspace"** — HTML estático em `sidebar.component.html` (comentário "Workspace block (Claude design)"), incluindo as propriedades `workspaceName`/`workspacePlan`/`workspaceInitials` e a lógica de preenchimento em `sidebar.component.ts` (`ngOnInit`), e todos os estilos associados (`.gc-side-section`, `.gc-side-eyebrow`, `.gc-workspace*`) em `sidebar.component.scss`, incluindo a variante para sidebar colapsado (`data-sidebar-size="sm"/"sm-hover"`).
2. **Removido o item "Account"** (id 6010) do submenu Settings em `currentUser.service.ts` (`makeMenu()`). A rota `/account` (`pages/settings/account/settings/settings.component.ts`) não foi apagada — apenas deixou de ter entrada no menu, por decisão de "remoção pura" (Opção B). Não há mais nenhum link para ela no código (confirmado via grep), então não é uma "rota órfã" (link morto) — é uma rota que segue existindo mas sem atalho de menu, como esperado.
3. **Corrigida a duplicidade de `/projects`** — removido o subitem `id: 2060` ("MENUITEMS.ANALYSIS.LIST.PROJECTS") dentro de "Analysis" (id 2000); mantida apenas a entrada dedicada em "Projects" (id 5000, subitem 5010), local mais coerente por já ser o menu de primeiro nível dedicado a projetos.
4. **Corrigido o `id: 7000` duplicado** — o item "Menu Adm" (visível só para `user.id == 1`) passou a usar `id: 9000` (antes 7000, colidindo com "Neural Network") e seu subitem para `id: 9010` (antes 7010).
5. **Ajuste de altura do sidebar** — o `max-height` inline do `ngx-simplebar` em `sidebar.component.html` foi reduzido de `calc(100vh - 280px)` para `calc(100vh - 220px)` (mesmo valor já usado antes para o layout colapsado, que tinha o bloco Workspace menor) para a área de scroll do menu ocupar o espaço liberado pela remoção do bloco Workspace, evitando espaço vazio no rodapé (CA-03). Com isso, o bloco de override específico para sidebar colapsado (que usava o mesmo valor `calc(100vh - 220px) !important`) ficou redundante e foi removido do SCSS.

### Arquivos principais
- `web/src/app/layouts/sidebar/sidebar.component.html`
- `web/src/app/layouts/sidebar/sidebar.component.ts`
- `web/src/app/layouts/sidebar/sidebar.component.scss`
- `web/src/app/services/currentUser.service.ts`

### Decisões
- Mantida a rota `/account` (`pages.routes.ts`) e seu componente sem alteração — a task pede remoção do item do menu ("remoção pura, não substituição"), não a eliminação da página. Como nenhum outro lugar do código referencia `/account` além do item de menu removido, não sobra nenhum "link morto" apontando para algo inexistente (o inverso do problema de rota órfã).
- Escolhido remover o subitem duplicado de `/projects` dentro de "Analysis" (id 2060) em vez do item dedicado "Projects" (id 5000), por "Projects" já ser um item de primeiro nível dedicado ao recurso, sendo o local mais coerente.
- Reutilizado o valor `220px` (já validado no código anterior para o estado colapsado do sidebar) como novo valor de `max-height` do estado normal, em vez de calcular um número novo sem poder validar visualmente em navegador — decisão conservadora para reduzir risco de regressão visual.
- Traduções (`en.json`/`es.json`) para as chaves `MENUITEMS.SETTINGS.LIST.ACCOUNT` e `MENUITEMS.ANALYSIS.LIST.PROJECTS` não foram removidas — essas chaves de tradução (`ACCOUNT`, `PROJECTS`) são reutilizadas em múltiplos namespaces não relacionados ao menu (ex.: outras páginas do template Velzon), então removê-las traria risco de quebrar outras telas sem benefício real (chave JSON não usada não quebra nada).
- Variável CSS `--gc-side-bg-soft` em `web/src/assets/scss/claude-theme.scss` ficou sem nenhum uso após a remoção do bloco Workspace (era usada só no `.gc-workspace` removido). Não foi removida por estar em um arquivo de tokens de tema compartilhado por todo o app, fora do escopo desta task — variável CSS não utilizada não tem efeito funcional.

### Divergências
Nenhuma divergência do escopo decidido (Opção B). Único ponto adicional (não pedido explicitamente, mas necessário para CA-03): ajuste do `max-height` do scroll do menu, documentado acima em "Decisões".

### Pendências
- Validação manual em ambiente rodando (`ng serve`) para confirmar visualmente a ausência de espaço vazio no rodapé do sidebar em telas altas e no estado colapsado (sm/sm-hover) — não foi possível fazer verificação visual em navegador real neste ambiente de execução, apenas leitura/raciocínio sobre o CSS e build de produção bem-sucedido.
- `ng test` tem uma falha pré-existente em `sidebar.component.spec.ts`, não relacionada a esta mudança (`TestBed.configureTestingModule` usa `declarations: [SidebarComponent]` para um componente standalone, que já falha independente do conteúdo do componente — arquivo não foi tocado neste PR).

## Validação
- `ng build --configuration production` — sucesso, sem erros (apenas warnings pré-existentes de dependências CommonJS/ESM, não relacionados a esta mudança).
- `ng test --include='**/sidebar.component.spec.ts'` — 1 teste, 1 falha pré-existente e não relacionada (ver "Pendências"). Não há teste automatizado cobrindo `currentUser.service.ts`/`makeMenu()`.
- Verificação por grep: nenhuma referência restante a `workspaceName`, `workspacePlan`, `workspaceInitials`, `gc-workspace*`, `gc-side-eyebrow`, `gc-side-section`, `id: 6010`, `id: 2060` ou `id: 7000` duplicado no repositório.
- Verificação por leitura de código: `topbar.component.html` tem `routerLink="/user"` (Profile) e `(click)="logout()"` (Logout) no dropdown do avatar, ambos independentes do item Account removido — confirma CA-05.
- PR aberto (não mergeado): https://github.com/Essencis-Labs/GeoCloudAI/pull/343, branch `chore/gt-0003-limpar-sidebar`, referenciando a issue #318.

## Handoff
PR #343 aberto para revisão humana. Antes do merge, recomenda-se:
1. Rodar `ng serve` e verificar visualmente o sidebar (estado normal e colapsado) em pelo menos uma tela alta, confirmando ausência de espaço vazio/quebra no rodapé.
2. Confirmar visualmente logout e acesso a "Profile" via dropdown do avatar no topbar.
3. Opcional/fora de escopo: considerar corrigir o pré-existente `TestBed` de `sidebar.component.spec.ts` (usa `declarations` em vez de `imports` para standalone component) em uma task separada de dívida técnica de testes.

**Merge (2026-09-02)**: PR #343 mesclado (squash) em `feature/visualizadores-navegacao-layout`, commit `a82c4ab4e72470ec002fb442d21d32377f64f1b8`. Ainda não mesclado em `main` — aguardando validação manual do usuário na branch de integração (inclusive os itens 1-2 acima, não executados em nenhum ambiente rodando de verdade).
