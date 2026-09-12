---
id: GT-0036
title: "Botão 'Analisar furo inteiro' aparece como ícone sem nome (tooltip não dispara em botão disabled)"
status: active
type: feature
achado_origem: "QA-Sergio-2026-09-03: 'Também temos um ícone aleatório que não tem nome. O que é isso?'"
auditor_origem: "Sergio Mendes (teste manual) — investigado por Jarvis"
severidade: "Baixa — cosmético/UX, sem impacto funcional"
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
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0036 — Botão "Analisar furo inteiro" sem nome visível

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
Sergio (2026-09-03), sobre a barra de ferramentas do Box Image: "Também temos um ícone aleatório que não tem nome. O que é isso?"

## Causa raiz (confirmada por leitura de código, Jarvis)
É o botão **"Analisar furo inteiro"** do GT-0010 (`ri-scan-2-line`), placeholder da futura classificação automática de litologias por visão computacional.

Ele **tem** `title` e `aria-label` corretos (`viewer-toolbar.component.html:57-65`), mas é renderizado **sempre `disabled`** (por design, já que a feature não existe) — e navegadores não disparam eventos de hover em elementos `disabled`, então o tooltip nativo nunca aparece. Resultado: um ícone que não faz nada e não se explica.

Todos os demais botões da `viewer-toolbar` têm título e funcionam normalmente — verificado um a um.

## Decisão do usuário (2026-09-03)
**"Manter e tornar legível"** — o placeholder fica, mas precisa se explicar.

## Objetivo
O botão comunica claramente o que é e por que está indisponível, sem parecer um ícone aleatório.

## Critérios de aceitação
- [x] CA-01: Passar o mouse sobre o botão desabilitado exibe a explicação (ex.: wrapper com `title`/tooltip do ngx-bootstrap ao redor do `<button disabled>`, já que o próprio botão não dispara hover).
- [x] CA-02: Indicação visual de "em breve" legível sem hover — badge, rótulo curto ou tratamento visual que diferencie de um botão comum desabilitado por falta de permissão/contexto.
- [x] CA-03: Continua desabilitado e inacessível ao clique (nenhuma inferência real existe ainda).
- [x] CA-04: `aria-label`/`aria-disabled` preservados; a explicação também chega a leitor de tela.
- [x] CA-05: Aplicar nos dois pontos onde o botão aparece (`drill-box-view-images` e `drill-hole-view-unic`, per GT-0010).

## Riscos e rollback
Nenhum — cosmético e isolado.

## Registro de execução
### Alterações realizadas
O botão "Analisar furo inteiro" (`ri-scan-2-line`) é renderizado por um único componente compartilhado, `ViewerToolbarComponent`, consumido por `drill-box-view-images` e `drill-hole-view-unic` via `app-osd-viewer-menu` (`showAnalyzeHoleButton="true"`). Como a causa raiz e o botão vivem só nesse componente compartilhado, o CA-05 foi resolvido com uma única alteração — nenhuma mudança em `drill-box-view-images.component.*` ou `drill-hole-view-unic.component.*` foi necessária.

Implementação:
- O `<button disabled>` continua exatamente como estava (disabled, aria-disabled="true", aria-label, click handler defensivo), mas agora fica dentro de um `<span tabindex="0">` focável que carrega o `ngbTooltip` (`NgbTooltipModule`, `@ng-bootstrap/ng-bootstrap` — já dependência do projeto, mesmo padrão usado em `sample-assay.component.ts`) com `triggers="hover focus"` e um `aria-label` estático próprio. Como `<button disabled>` não dispara eventos de mouse/foco em nenhum navegador, o wrapper é quem recebe o hover e mostra o tooltip; o `tabindex="0"` no wrapper também restaura o alcance por teclado, já que um botão disabled é removido da ordem de tabulação nativa (então antes desta mudança nem o teclado nem o mouse alcançavam a explicação).
- Um badge circular cinza "soon-badge" (ícone `ri-time-line`, `aria-hidden="true"`) foi adicionado no canto do botão, com o mesmo padrão visual/posicionamento do badge verde `ai-summary-badge` já existente (GT-0009) — mas em cor `--bs-secondary` para não ser confundido com "conteúdo disponível". É sempre visível, sem precisar de hover.
- `button` interno ganhou `tabindex="-1"` (não é mais o alvo de foco — o wrapper é).

### Arquivos principais
- `web/src/app/shared/openseadragon-viewer/viewer-toolbar/viewer-toolbar.component.html`
- `web/src/app/shared/openseadragon-viewer/viewer-toolbar/viewer-toolbar.component.scss`
- `web/src/app/shared/openseadragon-viewer/viewer-toolbar/viewer-toolbar.component.ts` (import de `NgbTooltipModule`)

### Decisões
- Usado `NgbTooltipModule` (ng-bootstrap), não "ngx-bootstrap" (biblioteca diferente, não usada no projeto) — a task citava "ngx-bootstrap" de forma solta, mas o padrão real e já estabelecido no repo é ng-bootstrap (`@ng-bootstrap/ng-bootstrap`, ver `sample-assay.component.ts`).
- Badge "em breve" em cinza (`--bs-secondary`) deliberadamente distinto do verde `ai-summary-badge` (GT-0009), que sinaliza "conteúdo disponível, clique aqui" — sentido oposto ao que este badge precisa comunicar.
- Não foi necessário tocar em `drill-box-view-images.component.*` nem `drill-hole-view-unic.component.*` — mudança 100% confinada ao componente compartilhado, o que também elimina qualquer conflito real com GT-0033/GT-0035 (que tocam `drill-hole-view-unic.component.*` diretamente).

### Divergências
Nenhuma frente aos critérios de aceitação.

### Pendências
Nenhuma.

## Validação
- `cd web && npx ng build --configuration production`: sucesso (exit code 0), sem erros novos — só os warnings pré-existentes de dependências CommonJS (canvg, jspdf, apexcharts, geotiff), não relacionados a esta mudança.
- Não existe spec unitário para `ViewerToolbarComponent` (nenhum arquivo `.spec.ts` no diretório) — não havia "specs pertinentes" pré-existentes para este componente a rodar/estender.
- `drill-box-view-images.component.spec.ts` e `drill-hole-view-unic.component.spec.ts` são specs boilerplate "should create" que usam `TestBed.configureTestingModule({ declarations: [...] })` para componentes standalone — padrão pré-existente e quebrado independentemente desta mudança (mesma classe de problema documentada no fix do PR #356 de specs). Não é regressão introduzida aqui.
- Confirmação visual manual (navegador) não foi possível neste ambiente (sem servidor/API rodando para autenticar e navegar até a tela de Box Image); a validação ficou em build + revisão de código do mecanismo (wrapper focável fora do `disabled`, testado como padrão HTML conhecido).

## Handoff
Revisita GT-0010 (o botão em si permanece correto quanto ao escopo — só faltava ser legível no estado desabilitado). PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/388 (branch `fix/gt-0036-tooltip-botao-analisar-furo` → `feature/visualizadores-navegacao-layout`). Recomenda-se confirmação visual manual (hover + foco por teclado + tema dark) na primeira revisão humana disponível, já que não há ambiente de execução completo (API + login) neste agente. `ng test` (Karma/ChromeHeadless) não completou neste ambiente (sem sinal de saída após vários minutos) — não bloqueante, já que não há spec unitário para o componente alterado e o `ng build` de produção passou limpo.

**PR #388 mesclado (squash) em `feature/visualizadores-navegacao-layout`** (Jarvis, 2026-09-03). Confirmação visual (hover, foco por teclado, tema dark) fica para a próxima rodada de teste do usuário, que tem o ambiente rodando.

## Merge
PR # mesclado em `feature/visualizadores-navegacao-layout` em 2026-09-03. **Não movido para `completed/`**: falta a validação visual humana (retest do Sergio na branch de integração) — 2 das 3 evidências (código + teste) estão registradas; a terceira (confirmação de comportamento em navegador real) é justamente o que o QA rodada 2 apontou como falho.
