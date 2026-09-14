---
name: guardian
description: >-
  Roda o squad Opensquad Guardian para auditar dívida técnica, documentação e segurança no
  GeoCloudAI e E-LIMS, criar backlog no GitHub Project Essencis-Labs e executar correções aprovadas
  via PR. Use para rodar o squad, auditar os produtos, gerir achados no board ou acionar uma persona
  do Guardian por nome ou papel em modo ad-hoc.
---

# Guardian — wrapper de execução cross-repo

Este skill é um ponteiro fino. O squad em si — definição, agentes, pipeline —
não vive neste repositório. Ele vive no projeto Opensquad, em:

```
C:\Software\ClaudeCode
```

> **Onde os arquivos realmente vivem** (desde 2026-09-09): em
> `C:\Software\EssencisSquads\squads\guardian\`, no repositório privado
> `sergio-essencislabs/essencis-squads`. `C:\Software\ClaudeCode\squads\guardian` é uma
> **junção de diretório** que aponta para lá, e este próprio `SKILL.md` é
> `skills/guardian/SKILL.md` daquele repositório, alcançado por outra junção.
>
> Ou seja: os caminhos abaixo continuam corretos e não precisam mudar — mas agora o que
> você edita está versionado. Antes disso o squad inteiro vivia fora de controle de
> versão, e o `opensquad`, que seria o home natural, é público demais para achado de
> segurança e documentação interna de cliente. Contexto: `TASK-060` no GeoCloudAI.
>
> Numa máquina nova, rode os `mklink` do README daquele repositório uma vez após o clone.

**Regra central: todo caminho relativo mencionado nos arquivos abaixo
(`squads/{name}/...`, `_opensquad/...`) é relativo a `C:\Software\ClaudeCode`,
NUNCA ao working directory atual da sessão.** Se a sessão foi aberta em
`c:\Software\ELIMS\ELIMS` ou em qualquer outro repo, ignore esse cwd
para fins de leitura/escrita dos arquivos do squad — sempre use o caminho
absoluto prefixado com `C:\Software\ClaudeCode\`.

## O que este squad audita/executa

- Os codebases de produto GeoCloudAI e E-LIMS.

Se esta sessão já está aberta num desses repositórios, use isso como um
indício natural de escopo (ex.: sessão aberta em ELIMS sugere "E-LIMS" como
produto padrão), mas **sempre pergunte no checkpoint de escopo** em vez de
assumir — o usuário pode querer auditar o outro produto ou ambos.

## Como executar

0. **Resolver a branch antes de decidir sobre a LLML.** O Guardian atua por padrão na branch
   semanal/de integração vigente. Atuação direta em `main`/`master` é excepcional e só existe
   quando o usuário a ordenar explicitamente para aquela execução; estar com `main` aberta no
   checkout não constitui autorização.

   A `Library\` da LLML documenta somente o estado da `main`. Portanto:
   - **branch semanal/de integração ou branch de task derivada dela:** não consultar nem sincronizar
     a LLML. Código, testes, tasks, handoffs e issues da branch em escopo são a fonte de verdade.
     Registrar em memória de trabalho: `Conhecimento Prévio (VaultS): N/A — LLML representa a main
     e esta execução atua na branch <nome>.` Não invocar `LLML-query`, `LLML-ingest`,
     `LLML-sync-squads` nem `LLML-approve` em nenhuma etapa dessa run.
   - **atuação direta em `main`/`master`, explicitamente ordenada pelo usuário:** consultar uma única
     vez `LLML-query` sobre `C:\VaultS\VaultS\Library\` antes de carregar o contexto do squad,
     buscando o conhecimento consolidado relevante. O Step 01 reutiliza esse resultado; nenhuma
     outra etapa repete a consulta. A sincronização final da LLML continua sujeita aos gates da
     Lívia e ao `LLML-approve`.

   Se não houver uma branch semanal/de integração conhecida e o usuário não tiver autorizado
   atuação direta na `main`, parar no checkpoint de escopo e pedir o nome da branch; nunca usar a
   LLML para preencher essa lacuna.
1. Ler, todos por caminho absoluto:
   - `C:\Software\ClaudeCode\_opensquad\_memory\company.md`
   - `C:\Software\ClaudeCode\_opensquad\_memory\preferences.md`
   - `C:\Software\ClaudeCode\squads\guardian\squad.yaml`
   - `C:\Software\ClaudeCode\squads\guardian\squad-party.csv`
   - `C:\Software\ClaudeCode\squads\guardian\_memory\memories.md`
   - `C:\Software\ClaudeCode\squads\guardian\pipeline\pipeline.yaml`
2. **Decidir qual runner seguir** — pipeline completo (padrão) ou agente isolado ad-hoc:
   - Se o pedido nomeia uma persona diretamente — **qualquer uma das 10**, por nome ou papel — e a
     task dela dá conta sozinha (ex.: "Marta, atualize a documentação", "rode só a Selma nisso",
     "Dante, procura duplicação no módulo de amostras"), ler
     `C:\Software\ClaudeCode\_opensquad\core\runner.agent.md` e seguir esse runner (mais leve: sem
     os 5 checkpoints do pipeline, sem `state.json`, 1 única confirmação consolidada antes de
     qualquer escrita externa).
   - Mapa ad-hoc por persona — inputs de *escopo* são sintetizados do pedido; *achados/aprovações*
     têm de vir do usuário (ver `runner.agent.md` § Ad-hoc input synthesis):
     - **Jarvis** (chief-architect) — `rotear-achados.md` sobre achado(s) colados no pedido;
       avaliação de impacto no núcleo compartilhado Conta/Identidade entre os dois produtos.
       Plano de roteamento entregue na conversa (sem `output/roteamento.md`); referências da task
       a `issues-criadas.md` são supridas pelos achados que o usuário forneceu. Para um pedido do
       tipo "Guardian, preciso fazer X" (implementação nova, sem achado de auditoria por trás) —
       `planejar-implementacao.md`: Jarvis decide sozinho quais camadas agem, com o mesmo ritual
       gradual de opções para ambiguidade arquitetural; se justificar, redige um `GADR` via
       `redigir-gadr.md`. Correção/pedido que atravessa camadas e precisa do hub de tasks (`squads/guardian/tasks/`) → pipeline completo, não ad-hoc.
       **Quando acionar o Jarvis (revisto em 13/09/2026):** núcleo compartilhado de Conta/Identidade,
       mais de uma camada, ou decisão que exige GADR. Pedido de **camada única e evidente** vai
       direto ao dono do papel — ver `chief-architect.agent.md` § "Quando Jarvis é acionado".
     - **Dante Débito** (tech-debt-auditor) — `auditar-divida-tecnica.md` com escopo sintetizado
       (produto + área).
     - **Selma Segurança** (security-auditor) — `auditar-seguranca.md` com escopo sintetizado
       (produto + área).
     - **Marta Manual** (documentation-architect) — "atualize a documentação"/"toda a documentação
       e KB da main" → `atualizar-documentacao.md` + `curar-knowledge-base.md` em sequência.
       **Reclassificação explícita** (runner § Ad-hoc input synthesis): sem PRs no pedido,
       `atualizar-documentacao.md` roda como *sincronização completa docs-vs-main* — o input
       `prs_aprovados` da task só se aplica no pipeline; se o usuário citar PRs, roda no modo
       por-PR normal. Escreve em `Documentation/Main/` do produto em escopo (GeoCloudAI por
       padrão; perguntar se ambíguo); "audite a documentação de X" → `auditar-documentacao.md`
       com escopo sintetizado.
     - **Tomás Tíquete** (task-curator) — `curar-issues.md` a partir de achado(s) fornecidos
       (só o caso estreito: 1 achado, sem roteamento). No pipeline completo isso virou 2 tasks
       separadas por um gate: `gerar-tasks.md` (Step 07, gera `GT-NNNN.md` em
       `squads/guardian/tasks/backlog/`, sem `gh`) e `criar-issues-de-tasks.md` (Step 10, só
       depois do Gate de Promoção do Step 08). Busca de duplicata via `gh` (leitura) é livre em
       qualquer modo; `gh issue create`/comentário/board só depois do gate — e a regra "board só
       para achados da main" continua valendo.
     - **Breno Backend / Flávia Frontend / Rui Registro** — `implementar-{backend,frontend,database}.md`
       a partir de um achado/pedido fornecido: branch + PR no repositório de produto depois do
       gate; nunca push na main. Correção que atravessa camadas (back+front+db juntos) → pipeline
       completo.
     - **Otávio Olhar** (reviewer) — `revisar-prs.md` sobre PR(s) indicados: parecer no chat;
       postar review/comentário no GitHub só depois do gate.
     - **Lívia Librarian** (librarian) — curadora da LLM Library. "Lívia, atualiza o vault"/"atualiza
       a LLML" → `atualizar-vault.md` (modo sob demanda: checa frescor da documentação de origem antes
       de sincronizar e, se estiver velha, chama Marta ad-hoc primeiro — profundidade 1). "Verifica a
       consistência da Library"/"a Library bate com os guias?" → `verificar-consistencia-bidirecional.md`.
       `sincronizar-run.md` é só do pipeline (Step 20) — exige `output/docs-atualizados.md`, que não
       existe em modo ad-hoc. Escreve só dentro de `C:\VaultS\VaultS\` (propostas em `_Proposals\`,
       nunca direto em `Library\`) e nos 3 guias HTML em `Documents\`; promoção a Gold só via
       `LLML-approve`, e achado da verificação bidirecional nunca é aplicado sem "sim" explícito do
       usuário. Única chamada cross-squad permitida a ela: **Rita Radar** (Reporter), para Concepts de
       mercado/competidores.
   - Helpers: qualquer persona líder pode consultar **qualquer outra** do squad como helper —
     pergunta pontual com evidência, profundidade 1 (helper não chama helper), nunca a task
     completa do outro. Ex. típico: Marta consulta Breno/Rui para confirmar assinatura de
     Service/Repository ou schema real antes de escrever uma linha da planilha — ver
     `runner.agent.md` § Helper agents.
   - Caso contrário (auditoria completa, ou qualquer coisa que vá gerar PR/precisa de aprovação),
     seguir `C:\Software\ClaudeCode\_opensquad\core\runner.pipeline.md` normalmente.
3. Executar exatamente como o runner escolhido descreve (checkpoints via pergunta ao usuário, steps
   `subagent` via Task tool, steps `inline` trocando de persona) — nenhuma mecânica muda, só a raiz
   dos caminhos: `{name}` = `guardian`, todo caminho `squads/{name}/...` ou `_opensquad/...`
   mencionado no runner é prefixado com `C:\Software\ClaudeCode\`.
4. `state.json`, `output/{run_id}/`, `_memory/runs.md` etc. — tudo isso é
   escrito dentro de `C:\Software\ClaudeCode\squads\guardian\`,
   nunca no repositório onde a sessão foi aberta. No modo ad-hoc não há `state.json` nem
   `output/{run_id}/` — só a linha em `_memory/runs.md` (ver `runner.agent.md`).
5. **Hub de tasks/decisões do Guardian**: `squads/guardian/tasks/{backlog,active,completed}/`
   (`GT-NNNN.md`) e `squads/guardian/decisions/` (`GADR-NNNN.md`) — próprio e centralizado do
   squad. **Continua sendo o hub, mas deixou de ser o único lugar** (decisão do dono do produto,
   2026-09-09; ver `TASK-060` no GeoCloudAI).

   Todo `GT-NNNN` gerado ganha um par de **mesmo número** em
   `<repo-de-produto>/.agents/tasks/backlog/GT-NNNN-{slug}.md`, no template **daquele**
   repositório, com referência cruzada obrigatória nos dois sentidos (`contraparte:` no
   front-matter de cada um). Ver
   `squads/guardian/agents/task-curator/tasks/gerar-tasks.md`, passo 5.

   **O prefixo `GT` também no repo de produto não é cosmético.** Aquela pasta é compartilhada
   com o orquestrador `bootstrap-*`, que cria `TASK-NNN` e mantém a própria sequência — o
   Matheus e o Victor trabalham por ali. Duas fontes numerando na mesma sequência colidem no dia
   em que as duas criam na mesma janela: as duas nascem válidas e só brigam no merge. Prefixos
   distintos tornam a colisão **impossível**, não improvável. **O Guardian nunca cria
   `TASK-NNN`; o orquestrador nunca cria `GT`.**

   Um item de trabalho, um número, dois arquivos com papéis diferentes: o `GT` do **hub**
   responde *por que isto entrou na fila* (achado, evidência, severidade, run de origem) e vive
   junto do histórico de auditoria que lhe dá sentido; o `GT` do **repo de produto** responde
   *como será feito e como foi feito* e vive ao lado do código, versionado, revisado no mesmo PR.
   Nenhum dos dois é resumo do outro.

   A sequência `GT` é **global ao Guardian**, não por repositório: ao numerar, varrer o hub e o
   `.agents/tasks/` de cada repositório de produto em escopo. Um `GT-0041` no GeoCloudAI e outro
   no E-LIMS seriam dois trabalhos distintos com o mesmo nome.

   A regra anterior dizia "nunca `.agents/` do repositório alvo". Ela caiu porque o efeito
   prático era o registro do trabalho ficar invisível para quem revisa: `.agents/` é ignorado por
   padrão, então a task existia só na máquina de quem a escreveu. No GeoCloudAI, `tasks/` e
   `decisions/` passaram a ser versionados por exceção no `.gitignore`; num repositório que ainda
   não fez essa exceção, gerar o `TASK` continua correto — ele só não viaja na branch até a
   exceção existir.

   O `bootstrap-agent-architecture` continua sendo o dono do **template e do ciclo de vida** de
   `.agents/` (backlog → active → completed, Definition of Done, ADRs). O Guardian escreve nessa
   pasta seguindo essas regras, não as substituindo. As skills `bootstrap-*` só rodam por comando
   explícito do usuário (`/bootstrap-plan`, `/bootstrap-complete`, …) — a criação de task a
   partir de trabalho novo é do Guardian. O pipeline completo
   gera a task **antes** de qualquer issue existir (Step 07) e só cria issue/começa a implementar
   mediante pedido explícito no Gate de Promoção (Step 08) — que pode vir dias depois, retomado
   pelo modo "retomar tasks pendentes" do Step 01.

## GitHub (etapa de backlog e PRs)

- `gh` CLI já autenticado como `sergio-essencislabs` (scopes: `project`,
  `repo`, `read:org`) — não precisa de token adicional.
- Board: GitHub Project **Essencis-Labs** (org **Essencis-Labs**, project
  **#7**), repositórios **Essencis-Labs/GeoCloudAI** e **Essencis-Labs/ELIMS**.
- Correções de código (steps de implementação) rodam nos repositórios de
  produto de verdade (GeoCloudAI / ELIMS) — abrem branch + PR ali, nunca em
  `C:\Software\ClaudeCode`. Nunca push direto em main/master.

## Escopo deste wrapper

Este arquivo só resolve o problema de "de onde" o squad é invocável — ele não
duplica nenhuma lógica do squad. Qualquer mudança de comportamento (agentes,
pipeline, checkpoints) deve ser feita editando os arquivos originais em
`C:\Software\ClaudeCode\squads\guardian\` (via `/opensquad edit
guardian` numa sessão aberta naquele projeto) — nunca copiada ou
duplicada aqui.
