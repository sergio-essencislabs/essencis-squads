---
name: reporter
description: Roda o squad Opensquad "Reporter" — pesquisa semanal de concorrentes do GeoCloudAI e do E-LIMS, novidades em exploração mineral e análise laboratorial, e atualização do documento de capacidades de produto a partir da branch main de cada repositório. Use quando o pedido for para rodar/executar esse squad, pesquisar concorrentes/mercado do GeoCloud ou do ELIMS, atualizar o product-capabilities.md de um desses produtos, ou gerar o resumo executivo semanal — mesmo que a sessão atual esteja aberta em outro repositório (GeoCloudAI, ELIMS, ou qualquer outro). Também cobre pedidos ad-hoc endereçados a QUALQUER persona do squad por nome ou papel — ex.: "Rita, pesquisa esse concorrente", "Paulo, atualize o product-capabilities do ELIMS", "Diego, estrutura esses achados", "Beatriz, escreve o resumo disso", "Vitor, revisa este texto" — que rodam só aquele agente, sem o pipeline completo.
---

# Reporter — wrapper de execução cross-repo

Este skill é um ponteiro fino. O squad em si — definição, agentes, pipeline —
não vive neste repositório. Ele vive no projeto Opensquad, em:

```
C:\Software\ClaudeCode
```

**Regra central: todo caminho relativo mencionado nos arquivos abaixo
(`squads/{name}/...`, `_opensquad/...`) é relativo a `C:\Software\ClaudeCode`,
NUNCA ao working directory atual da sessão.** Se a sessão foi aberta em
`C:\Software\GeoCloud\GeoCloudAI`, `C:\Software\ELIMS\ELIMS` ou em qualquer
outro repo, ignore esse cwd para fins de leitura/escrita dos arquivos do
squad — sempre use o caminho absoluto prefixado com `C:\Software\ClaudeCode\`.

## O que este squad pesquisa/atualiza

- Concorrentes e novidades de mercado em exploração mineral e análise
  laboratorial (pesquisa web, sem tocar em repositórios).
- `C:\Software\GeoCloud\GeoCloudAI\Documentation\Main\product-capabilities.md`
  e `C:\Software\ELIMS\ELIMS\Documentation\Main\product-capabilities.md` —
  atualizados in-place a partir da branch `main` real de cada repositório de
  produto, via git worktree somente leitura.

Se esta sessão já está aberta num desses repositórios (GeoCloudAI, ELIMS), use
isso como um indício natural de escopo (ex.: sessão aberta em ELIMS sugere
"E-LIMS" como produto padrão), mas **sempre pergunte no checkpoint de foco
semanal** em vez de assumir — o usuário pode querer pesquisar o outro produto
ou ambos.

## Como executar

1. Ler, todos por caminho absoluto:
   - `C:\Software\ClaudeCode\_opensquad\_memory\company.md`
   - `C:\Software\ClaudeCode\_opensquad\_memory\preferences.md`
   - `C:\Software\ClaudeCode\squads\reporter\squad.yaml`
   - `C:\Software\ClaudeCode\squads\reporter\squad-party.csv`
   - `C:\Software\ClaudeCode\squads\reporter\_memory\memories.md`
   - `C:\Software\ClaudeCode\squads\reporter\pipeline\pipeline.yaml`
2. **Decidir qual runner seguir** — pipeline completo (padrão) ou agente isolado ad-hoc:
   - Se o pedido nomeia uma persona diretamente — **qualquer uma das 5**, por nome ou papel — e a
     task dela dá conta sozinha, ler `C:\Software\ClaudeCode\_opensquad\core\runner.agent.md` e
     seguir esse runner (sem os checkpoints do pipeline, sem `output/{run_id}/`, 1 única
     confirmação consolidada antes de qualquer escrita externa). Mapa ad-hoc por persona — inputs
     de *foco/escopo* são sintetizados do pedido (ver runner § Ad-hoc input synthesis):
     - **Paulo Produto** (product-curator) — `atualizar-conhecimento-produto.md`: lê a `main` real
       via git worktree somente leitura e atualiza
       `Documentation/Main/product-capabilities.md` do produto em escopo (gate antes de gravar;
       commit/push continuam sendo decisão do usuário — nunca commit/push automático no repo de
       produto).
     - **Rita Radar** (competitor-researcher) — `pesquisar-concorrentes-e-mercado.md` com foco
       sintetizado do pedido; entrega os achados na conversa.
     - **Diego Dados** (data-analyst) — `estruturar-achados.md` sobre material fornecido no pedido
       (ou produzido pela Rita na mesma conversa).
     - **Beatriz Briefing** (writer) — resumo executivo a partir de material fornecido/indicado
       (sem arquivo de task próprio: roda em modo monolítico, via fallback do runner
       § Error Handling).
     - **Vitor Veredito** (reviewer) — revisão final de um texto indicado; parecer na conversa
       (sem arquivo de task próprio: modo monolítico, idem).
     Helpers: qualquer persona líder pode consultar **qualquer outra** do squad (pergunta pontual
     com evidência, profundidade 1 — helper não chama helper) — ver `runner.agent.md` § Helper
     agents.
   - Caso contrário (pesquisa semanal completa, resumo executivo oficial com todas as etapas),
     seguir o pipeline normalmente — passos 3 a 5 abaixo.
3. Ler `C:\Software\ClaudeCode\_opensquad\core\runner.pipeline.md` — esse é o
   motor de execução do pipeline. Segui-lo à risca, com `{name}` = `reporter`
   e todo caminho `squads/{name}/...` ou `_opensquad/...` mencionado nele
   prefixado com `C:\Software\ClaudeCode\`.
4. Executar o pipeline passo a passo exatamente como o runner descreve
   (checkpoints via pergunta ao usuário, steps `subagent` via Task tool, steps
   `inline` trocando de persona) — nenhuma mecânica muda, só a raiz dos
   caminhos.
5. `output/{run_id}/`, `_memory/runs.md` etc. — tudo isso é escrito dentro de
   `C:\Software\ClaudeCode\squads\reporter\`, nunca no repositório onde a
   sessão foi aberta. No modo ad-hoc não há `output/{run_id}/` — só a linha em
   `_memory/runs.md` (ver `runner.agent.md`).

## Repositórios de produto (etapa de conhecimento de produto)

- A atualização de `product-capabilities.md` roda contra os repositórios de
  produto reais, sempre via git worktree somente leitura apontando para
  `main` — nunca `git checkout`, `commit` ou `push` neles. A decisão de
  consolidar mudanças pertence ao checkpoint de aprovação final do squad.
- Este squad não abre PRs nem toca no GitHub Project Essencis-Labs — isso é
  escopo do squad **Guardian**.

## Escopo deste wrapper

Este arquivo só resolve o problema de "de onde" o squad é invocável — ele não
duplica nenhuma lógica do squad. Qualquer mudança de comportamento (agentes,
pipeline, checkpoints) deve ser feita editando os arquivos originais em
`C:\Software\ClaudeCode\squads\reporter\` (via `/opensquad edit reporter`
numa sessão aberta naquele projeto) — nunca copiada ou duplicada aqui.
