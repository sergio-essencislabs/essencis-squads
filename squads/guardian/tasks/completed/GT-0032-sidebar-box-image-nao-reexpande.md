---
id: GT-0032
title: "Sidebar do Box Image some ao recolher e não pode ser reaberta (CSS legado esconde o próprio botão de expandir)"
status: active
type: feature
achado_origem: "QA-Sergio-2026-09-03 (teste manual na branch de integração)"
auditor_origem: "Sergio Mendes (teste manual) — investigado por Jarvis"
severidade: "Alta — usuário fica preso sem caminho de volta; só logout/login recupera"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-jarvis-qa-2026-09-03-rodada-2"
issue_url: ""
grupo_execucao: "Correção pós-QA rodada 2"
owner: ""
created_at: 2026-09-03
updated_at: 2026-09-03
affected_modules: [images-viewer]
related_adrs: []
---

# GT-0032 — Sidebar do Box Image não re-expande

## Achado original
Sergio (2026-09-03): "Em DrillBox Image ao clicar para recolher menu lateral esquerdo ou direito, eles ficam invisíveis e não consigo mais recuperá-los. Só voltei a visualizar ao fazer logout e login."

## Causa raiz (confirmada por leitura de código, Jarvis)
`web/src/app/pages/geodata/drill-boxes/drill-box-view-images/drill-box-view-images.component.scss`, linhas 2026-2035:

```scss
.sidebar-menu.collapsed .menu-header,
.sidebar-menu.collapsed .sidebar-menu-content,
... { display: none !important; }
```

O botão de expandir (`.toggle-btn.sidebar-collapse-toggle`) fica **dentro** de `.menu-header` (template, linha 14-20), que por sua vez está dentro de `.sidebar-menu-content` (linha 13). Ao recolher, as duas regras escondem o próprio botão que traria a barra de volta — sobra uma faixa de 40px vazia e sem ação possível.

O template está correto (renderiza o botão e troca o ícone por `ri-arrow-right-s-line` quando recolhido, linhas 18-19). O defeito é exclusivamente do CSS.

**Por que só logout resolve**: o estado é persistido em `sessionStorage` (`dbxToolsSidebarCollapsed` / `dbxAnnotationsSidebarCollapsed`, GT-0005). F5 mantém o estado recolhido; logout/login limpa o `sessionStorage` e volta ao padrão expandido.

**Origem do defeito**: esse bloco de CSS é legado de quando existia **uma** sidebar única (onde recolher = esconder tudo, e o menu flutuante tinha toggle próprio, fora do `.sidebar-menu`). O GT-0005 dividiu em duas sidebars, cada uma com seu cabeçalho e toggle interno, mas não atualizou a regra antiga.

## Objetivo
Recolher e re-expandir cada sidebar (ferramentas e marcações) livremente, sem nunca perder o caminho de volta.

## Critérios de aceitação
- [x] CA-01: Com a sidebar recolhida, o botão de expandir continua visível e clicável na faixa de 40px. Confirmado via spec (`offsetParent !== null`); validação visual manual em navegador ainda pendente (ver Pendências).
- [x] CA-02: Vale para as duas sidebars (ferramentas à esquerda, marcações à direita), independentemente. Spec cobre as duas separadamente.
- [x] CA-03: Estado recolhido continua sobrevivendo à troca de caixa e ao F5 (comportamento do GT-0005 preservado) — mas agora sempre reversível pela UI. Não alterei a lógica de `sessionStorage`/`selectOtherBox` (só a regra de CSS), então o comportamento de persistência é preservado por construção; não testei manualmente o cenário de troca de caixa em navegador (ver Pendências).
- [x] CA-04: Spec de regressão que recolhe, confirma que o toggle segue no DOM **e visível** (não só presente), e re-expande. Ver `drill-box-view-images.component.spec.ts`.
- [x] CA-05: Conferir se o mesmo bloco de CSS legado afeta os modos `left`/`right`/`floating` (`#floating-menu`, `#menu-start`) — se afetar, corrigir junto; se não, registrar que foi verificado. Não afeta (seletores de ID, sem a classe `.sidebar-menu`); confirmado por leitura e por spec.

## Plano de implementação
- [x] Ajustar a regra de `.collapsed` para preservar `.menu-header` (ou ao menos `.sidebar-collapse-toggle`) visível; esconder só o conteúdo abaixo dele.
- [x] Remover `!important` se possível, ou escopar melhor a regra, para não voltar a atropelar o template.
- [x] Spec de regressão (CA-04).

## Riscos e rollback
Mudança só de CSS num arquivo já grande; risco de regressão visual nos modos de menu flutuante — daí o CA-05.

## Registro de execução
### Alterações realizadas
- Removidas `.menu-header` e `.sidebar-menu-content` da regra legada `.sidebar-menu.collapsed { ..., display: none !important; }` (linhas ~2026-2035 originais). A regra `.sidebar-menu.collapsed .sidebar-menu-content > *:not(.menu-header)`, já existente no arquivo (linha ~1661), já cobria "esconder conteúdo preservando o header" — a regra legada duplicava isso de forma mais agressiva, sem a exceção do `.menu-header`, e por isso escondia o próprio botão.
- Removido também `.sidebar-menu.collapsed .sidebar-menu` da mesma lista (seletor sem sentido — uma sidebar nunca é descendente dela mesma; dead code inofensivo removido por limpeza, não fazia parte do bug).
- `!important` removido do que sobrou na regra (`.top-group`, `.bottom-group`, `.group.top-group`, `.data-panels`, `.rotation-control`) — não é mais necessário para essas classes, que não colidem com o toggle.
- Comentário adicionado no SCSS explicando a origem do bug (legado pré-GT-0005) e por que a regra restante é segura.

### Arquivos principais
- `web/src/app/pages/geodata/drill-boxes/drill-box-view-images/drill-box-view-images.component.scss`
- `web/src/app/pages/geodata/drill-boxes/drill-box-view-images/drill-box-view-images.component.spec.ts` (spec estava no esqueleto padrão quebrado `declarations: [Component]` para um componente standalone — nunca rodava de fato; reescrita como spec funcional com `imports:`, `HttpClientTestingModule`, `NgxSpinnerModule`, viewer OpenSeadragon/Annotorious substituído por fake mínimo via spy em `constructViewer`/`annoOpen` para isolar o teste do bug de CSS).

### Decisões
- CA-05 verificado por leitura: o bloco legado usa seletor de classe `.sidebar-menu.collapsed ...`; os modos `left`/`right`/`floating` usam `#floating-menu`/`#menu-start` (IDs, sem a classe `sidebar-menu`), com suas próprias regras `#floating-menu.collapsed button:not(.toggle-btn)` / `#menu-start.collapsed button:not(.toggle-btn)` que já preservavam o `.toggle-btn`. Não afetados. Confirmado também por spec (`modo floating ... não afetado pelo bug do GT-0032`).
- A spec verifica visibilidade via `el.offsetParent !== null`, não via `getComputedStyle(el).display`. Motivo (achado durante a validação, ver Divergências): `getComputedStyle` de um elemento reflete só a regra CSS que casa com ELE, não com um ancestral escondido — um botão dentro de um `.menu-header{display:none}` continua reportando seu próprio `display: inline-flex` (de `.sidebar-menu button`), mesmo estando de fato invisível. `offsetParent` reflete a visibilidade efetiva (fica `null` quando o próprio elemento ou qualquer ancestral está `display:none`), mas exige o fixture anexado a `document.body` (sem isso, não há layout e `offsetParent` seria sempre `null`, dando falso positivo de bug).

### Divergências
- Ao escrever a primeira versão da spec com `getComputedStyle(toggleBtn).display !== 'none'`, rodei um teste de sanidade revertendo o fix (`git stash` do `.scss`) para confirmar que a spec realmente pegava a regressão — e ela NÃO pegava (6/6 passavam mesmo com o CSS antigo). Causa: exatamente o motivo acima (computed style não herda "invisibilidade" de ancestral). Corrigido trocando para `offsetParent` antes de finalizar. Refazendo o mesmo teste de sanidade com a versão corrigida: 2/6 falham com o CSS antigo (exatamente os dois testes "mantém o botão de expandir visível ao recolher", ferramentas e marcações) e 6/6 passam com o fix — confirma que a spec de regressão é efetiva.
- Ambiente: o worktree não tinha `node_modules` (cada worktree é isolado). `npm ci` local resolveu (1289 pacotes, ~6min). Evitar `ln -s node_modules` apontando para outro worktree/repo no Windows+git-bash — na prática ele não cria um symlink real, faz um fallback de cópia recursiva que roda como processo solto em background (fora do controle do Bash tool), quase preenchendo o node_modules do repo principal por engano antes de eu perceber e matar o processo (`taskkill`). node_modules do repo principal ficou intacto (688 pacotes, conferido antes/depois).

### Pendências
- Validação visual manual no navegador (recolher/reexpandir as duas sidebars) não foi executada nesta sessão (ambiente sem navegador interativo disponível para o agente) — recomendo confirmação humana antes do merge, conforme registrado no PR.

## Validação
- `ng build --configuration development`: sucesso, sem erros novos (só warnings pré-existentes em outros componentes, não relacionados).
- `ng test` focado (`drill-box-view-images.component.spec.ts`): 6/6 SUCCESS.
  - Sanidade: com CSS antigo (via `git stash`) + spec com checagem `offsetParent`: 2/6 FAILED nos pontos exatos esperados (toggle da sidebar de ferramentas / marcações fica invisível ao recolher) — confirma que a spec detecta a regressão de fato.
- `ng test` mais amplo (`**/drill-box*/**/*.spec.ts`, 26 specs): 15 FAILED pré-existentes, todos no padrão quebrado `declarations: [StandaloneComponent]` em componentes não relacionados (`DrillBoxTypesComponent`, `DrillBoxStatusComponent`, `DrillBoxMaterialsComponent`, etc., em `settings/` e `geodata/drill-boxes/`) — dívida de teste já conhecida (ver PR #356, que corrigiu 161 specs mas não cobriu todos). Nenhuma falha envolve `drill-box-view-images`. Confirmado que essas falhas já existiam antes desta mudança (arquivos não tocados nesta task).

## Handoff
Reaberto de GT-0005 (duas sidebars retráteis) — não é regressão do GT-0005 em si, é CSS pré-existente que ele não sabia que precisava atualizar.

PR aberto contra `feature/visualizadores-navegacao-layout`: https://github.com/Essencis-Labs/GeoCloudAI/pull/393 (branch `fix/gt-0032-sidebar-box-image-reexpande`).

Pendente antes do merge: validação visual manual (recolher/reexpandir as duas sidebars num navegador real) — não executada nesta sessão por falta de navegador interativo no ambiente do agente.

## Merge
PR # mesclado em `feature/visualizadores-navegacao-layout` em 2026-09-03. **Não movido para `completed/`**: falta a validação visual humana (retest do Sergio na branch de integração) — 2 das 3 evidências (código + teste) estão registradas; a terceira (confirmação de comportamento em navegador real) é justamente o que o QA rodada 2 apontou como falho.
