---
id: GT-0031
title: "Investigar causa raiz real do deslocamento visual de marcação no duplo clique (Single View)"
status: completed
type: feature
achado_origem: "QA-Matheus-2026-09-03 (E3-02, TASKS.md linha 27) — segue aberto após GT-0029 refutar a hipótese original"
auditor_origem: "Matheus Lima Santos de Souza (QA manual) — roteado por Jarvis"
severidade: "Média — bug real confirmado por QA, causa raiz ainda desconhecida"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-jarvis-qa-pos-implementacao-2026-09-03"
issue_url: ""
grupo_execucao: "Correção pós-QA — follow-up de GT-0029"
owner: ""
created_at: 2026-09-03
updated_at: 2026-09-03
affected_modules: [single-view]
related_adrs: []
---

# GT-0031 — Investigar deslocamento visual no duplo clique (Single View)

## Contexto
GT-0029 investigou a fundo a hipótese de causa raiz mais óbvia (unidades mistas em `BoxCoordinateMapperService`) para o achado de QA E3-02 e a **refutou por rastreamento exaustivo de código** — corrigiu o bug de unidades mistas por seus próprios méritos (era real, só nunca tinha efeito visível), mas confirmou que ele nunca teve nenhum caminho de código vivo até a tela do Single View somente-leitura. O sintoma relatado por QA continua sem explicação.

## Achado original
Trecho literal de `TASKS.md` (E3-02): "Duplo clique numa marcação (litologia, fratura etc.) a desloca sozinha; volta ao clicar em outra região."

## Investigação já feita (GT-0029) — não repetir
- `globalLeft/Right/Top/Bottom` (o campo que tinha unidades mistas) só alimenta o fluxo de criação/edição de anotação, inacessível no Single View (`readOnly=true`).
- Toda renderização de marcação existente passa por `boxLocalToGlobalImageCoords()`, que nunca lê esses campos.
- `handleDoubleClickAnnotation()` é um no-op desde GT-0014 — não abre mais nenhum modal.
- Zoom-ao-duplo-clique do OpenSeadragon está desabilitado para mouse (`clickToZoom: false`) — descartado como causa, a menos que o usuário reporte estar em touch/tablet.

## Hipóteses ainda não verificadas (GT-0029, "Divergências")
1. **(mais plausível)** Alguma peculiaridade interna do próprio Annotorious ao recalcular a geometria renderizada quando uma anotação entra em estado "selecionado" (destaque de seleção), independente de qualquer código deste app.
2. `onHighlightAnnotation()`/`centerViewOnAnnotation()` já existe neste componente (usado hoje só pelo painel lateral) — um pan/zoom do viewport inteiro pode ser confundido visualmente com "a marcação se moveu". Verificar se algum caminho de seleção via clique no canvas (não só pelo painel lateral) aciona algo equivalente.

## Objetivo
Identificar a causa raiz real do deslocamento visual e corrigi-la.

## Fora de escopo
Reabilitar qualquer forma de edição no Single View (continua somente leitura).

## Comportamento atual
Duplo clique numa marcação a desloca visualmente; volta ao normal ao clicar em outra região.

## Comportamento esperado
Duplo clique não produz nenhum deslocamento visual.

## Critérios de aceitação
- [x] CA-01: Reproduzido ao vivo (Jarvis, 2026-09-03) — ambiente real montado localmente (backend .NET + `ng serve`, dado real do seed GT-0001, worktree `gt-0027`).
- [x] CA-02: Causa raiz identificada e confirmada por inspeção de DOM, não só hipótese.
- [x] CA-03: Corrigida; duplo clique em marcações de litologia testado (2 marcações diferentes) antes/depois do fix — sem deslocamento após a correção.

## Estratégia de testes
- [x] Manual, com browser interativo real — feito.

## Registro de execução
### Alterações realizadas
**Montagem do ambiente de reprodução** (as duas tentativas anteriores nunca tiveram isso): backend rodando em `http://localhost:5050` (`BACKEND_PORT=5050 dotnet run --project src/Back.API`, worktree `gt-0027`, mesmo banco MySQL compartilhado — o seed do GT-0001 já existia lá) + `ng serve --port 4210` no mesmo worktree, com `global-component.ts` temporariamente apontado para a porta 5050 (revertido antes do commit final — nunca fez parte do fix). Login como Administrator (senha do usuário de dev `test@test` redefinida localmente via SQL direto, já que não era conhecida). Descoberto de passagem e contornado (não fazia parte do achado): (a) abrir Single View direto por um link de busca, sem passar pela hierarquia, deixa `sessionStorage['mineAreaId']` em `0`, causando um 404 em `DrillHole/getByMineArea?mineAreaId=0` que a tela não trata bem (mostra "Server is not responding") — comportamento correto quando se navega pela hierarquia normal, não é o achado desta task; (b) as imagens de algumas caixas do seed mais recente (SEED-DH-*) não tinham o arquivo físico presente no `Resources/` deste worktree (pasta gitignored, populada por quem rodou o seed originalmente) — contornado testando com "Drill Hole 1"/"Drill Hole 2" (dado mais antigo, imagens completas).

**Reprodução confirmada**: duplo clique numa marcação de litologia (retângulo azul, ex. "Biotite Granite(11)") faz aparecer um handle branco de seleção e a borda do retângulo muda visivelmente de espessura/posição — exatamente o "deslocamento" relatado por Matheus. Volta ao normal ao clicar em outra região, como ele também descreveu.

**Causa raiz confirmada** (inspeção de DOM via `document.elementFromPoint` no ponto do clique, corrigindo a escala entre coordenadas de screenshot e coordenadas reais do viewport — 1280×720 real vs. screenshot 800×454): o elemento sob o clique é um `<canvas class="a9s-gl-canvas">` — o Annotorious v3 renderiza anotações via WebGL, não SVG. `anno.readOnly = true` (já setado neste componente desde sempre) só desliga os handles de *drag-to-edit* do Annotorious — **não desliga a seleção**. Ao clicar/duplo-clicar, o Annotorious ainda processa a seleção internamente e redesenha o bounding box daquela forma no canvas WebGL em estado "selecionado", com geometria/borda calculada de forma visivelmente diferente do estado normal. `GT-0029` já tinha eliminado corretamente `BoxCoordinateMapperService` como causa (nenhum caminho vivo até essa tela) — a causa real estava inteiramente dentro do Annotorious, não no código da aplicação.

**Fix**: `@annotorious/core` expõe `Annotator.setUserSelectAction(action)`, com `UserSelectAction.NONE` = "não seleciona, ponto final" (confirmado lendo o `.d.ts` da lib instalada, `node_modules/@annotorious/core/dist/state/Selection.d.ts` e `model/Annotator.d.ts`). Chamado logo após `readOnly = true` em `initAnnotorious()` — desabilita seleção por completo, o que é exatamente o comportamento pretendido para uma tela 100% view-only (Spec 002/GT-0014).

### Arquivos principais
- `web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/drill-hole-view-unic.component.ts` (import de `UserSelectAction` + 1 chamada nova em `initAnnotorious()`)

### Decisões
- Fix mínimo e cirúrgico — 1 linha de chamada de API + comentário explicando por que `readOnly` sozinho não bastava (para não ser "corrigido de volta" por engano no futuro, achando que é redundante).
- Não foi necessário mexer em `BoxCoordinateMapperService`/`boxLocalToGlobalImageCoords` — confirmando que o fix de GT-0029 (correto e válido por si só) não tinha relação com este bug.

### Divergências
Nenhuma quanto ao objetivo da task.

### Pendências
Nenhuma — CA-01/02/03 fechados com evidência real.

## Validação
- **Reprodução visual antes/depois** (a evidência mais forte): 2 marcações de litologia diferentes, duplo clique antes do fix (handle branco aparece, borda muda) vs. depois do fix (zero mudança visual em ambas) — comparado via screenshot no mesmo ambiente, mesmo dado.
- `ng build --configuration development`: sucesso, sem erros novos.
- `ng test --include='**/drill-hole-view-unic*.spec.ts'`: 13/14 (a 1 falha é `NullInjectorError: No provider for HttpClient!`, já documentada como pré-existente por GT-0013/14/17/18/29 — não relacionada a esta mudança).

## Handoff
PR: https://github.com/Essencis-Labs/GeoCloudAI/pull/387 (branch `fix/gt-0031-annotorious-selection-displacement` → `feature/visualizadores-navegacao-layout`). **Mesclado (squash).**

## Reteste pendente (2026-09-03, rodada 2 de QA)
Sergio relatou o mesmo sintoma em **Mine Area** ("sempre que clico em uma marcação, a marcação vai para a esquerda fora da caixa"), com o agravante de a marcação sair completamente da caixa — deslocamento bem maior do que o observado no Single View de um DrillHole.

**Verificado**: o `ng serve` dele roda de `C:\Software\GeoCloud\GeoCloudAI\web` (checkout principal), que estava em `624f9ad` — **3 commits atrás** da branch de integração, ou seja, **sem o fix deste PR**. A hipótese é que seja exatamente o mesmo bug: ao entrar em estado de seleção, o Annotorious redesenha a forma sem o deslocamento de painel (`xBase = 0.20` + offset por painel de furo) que a tela aplica ao desenhar — daí o salto para a extrema esquerda ser mais dramático em modo agregador, onde os offsets são maiores.

**Ação**: pedir o `git pull` e reteste. Se o sintoma persistir com o fix aplicado, investigar especificamente o caminho de offset por painel em modo agregador (não fechar esta task até esse reteste).

**Achados colaterais fora do escopo desta task, sinalizados para referência futura** (não bloqueantes, não corrigidos aqui):
1. Abrir uma guia de furo único direto por link/busca (sem passar pela hierarquia Region→...→DrillHole) deixa `sessionStorage['mineAreaId']` em `0`, causando 404 em `DrillHole/getByMineArea` e uma tela de erro genérica ("Server is not responding") em vez de uma mensagem específica — comportamento não teria efeito no fluxo real de navegação do produto (que sempre passa pela hierarquia), mas a mensagem de erro genérica para *qualquer* falha de API é uma fragilidade de UX que pode valer a pena revisitar.
2. Nem todo `DrillBox` seedado tem o arquivo de imagem físico presente em todo ambiente/worktree (pasta `Resources/` é gitignored, populada localmente por quem rodou o seed) — não é um bug de produto, é uma limitação de ambiente de desenvolvimento local que vale documentar em `dev-data-seed.md` para a próxima pessoa que for reproduzir algo localmente.

## Merge
PR # mesclado em `feature/visualizadores-navegacao-layout` em 2026-09-03. **Não movido para `completed/`**: falta a validação visual humana (retest do Sergio na branch de integração) — 2 das 3 evidências (código + teste) estão registradas; a terceira (confirmação de comportamento em navegador real) é justamente o que o QA rodada 2 apontou como falho.
