---
execution: subagent
agent: product-curator
inputFile: squads/reporter/output/foco-semanal.md
outputFile: squads/reporter/output/atualizacao-produto.md
model_tier: powerful
---

# Step 02: Atualização de Conhecimento do Produto

## Context Loading

Load these files before executing:
- `squads/reporter/output/foco-semanal.md` — escopo desta
  execução: quais produtos estão em foco (GeoCloudAI / E-LIMS / Ambos) e
  qualquer tema prioritário adicional que possa afetar o que vale a pena
  inspecionar no código.
- `squads/reporter/agents/product-curator.agent.md` — persona
  de Paulo Produto, princípios de "capacidade de negócio vs. detalhe de
  implementação" e as regras de nunca commitar/push.
- `squads/reporter/agents/product-curator/tasks/atualizar-conhecimento-produto.md`
  — processo operacional detalhado de comparação contra o commit citado,
  inspeção via git log/show e atualização incremental do documento.
- Os repositórios de produto reais, cada um com seu `product-capabilities.md`
  existente a ser atualizado in-place:
  - `C:\Software\GeoCloud\GeoCloudAI\Documentation\Main\product-capabilities.md`
  - `C:\Software\ELIMS\ELIMS\Documentation\Main\product-capabilities.md`
  (nota: `GeoCloudAI_Replit` foi renomeado para `GeoCloudAI`, e
  `ELIMS_Replit` foi renomeado para `ELIMS` — use sempre os nomes atuais).

## Instructions

### Process

1. Ler o escopo em `foco-semanal.md` e determinar quais produtos processar
   nesta execução (pode ser um ou ambos).
2. Para cada produto em escopo, criar um **git worktree somente leitura**
   apontando para a branch `main` atual, em um diretório temporário fora do
   checkout de trabalho (ex.: `git worktree add <caminho-temp> main` a partir
   do repositório do produto). **Nunca** rodar `git checkout`, alterar branch,
   ou tocar de qualquer forma no checkout ativo de `GeoCloudAI` ou `ELIMS`.
3. Ler o commit já citado no `product-capabilities.md` existente do produto e
   comparar contra o HEAD da main dentro do worktree (`git log
   <commit-citado>..HEAD` no worktree). Se não houver commits novos, apenas
   confirmar validade do documento e não reescrevê-lo.
4. Se houver commits novos, inspecioná-los individualmente (`git log`,
   `git show`) para separar mudanças de negócio reais (nova capacidade,
   capacidade alterada, capacidade removida) de fixes/refatoração sem
   impacto de capacidade observável pelo usuário.
5. Atualizar o `product-capabilities.md` existente **in-place** (nunca
   recriar do zero): adicionar capacidades novas confirmadas, corrigir
   capacidades que mudaram, remover o que foi confirmado como removido —
   cada mudança citando o commit e o arquivo/classe/componente de evidência
   real. Nunca alterar o `overview.md` técnico nem qualquer outro arquivo do
   repositório de produto.
6. Ao final da análise de cada produto, remover o worktree temporário
   (`git worktree remove`). **Nunca** executar `git add`, `git commit` ou
   `git push` nos repositórios de produto — essa decisão pertence ao
   checkpoint de aprovação final do squad (step 7).
7. Escrever o resumo do delta desta execução (por produto) no `outputFile`,
   seguindo o Output Format abaixo.

## Output Format

```markdown
## Paulo Produto — {Produto}
Commit atual da main (`<hash-atual>`) [é o mesmo já registrado | avançou de
`<hash-anterior>` para `<hash-atual>`, N commits].

[Se sem mudança de capacidade:]
Nenhuma atualização necessária. Documento permanece válido.

[Se com mudança de capacidade real:]
Inspecionados via git log/show: X são fixes/refatoração, Y introduzem
mudança de capacidade real: {descrição, arquivo/classe/componente de
evidência}.
**Atualização de capacidade real**: {o que mudou no product-capabilities.md
e por quê}. Documento atualizado, commit não realizado (aguardando
checkpoint de aprovação).
```

## Output Example

```markdown
## Paulo Produto — GeoCloudAI
Commit atual da main (`83863f1`) é o mesmo já registrado em
product-capabilities.md. Nenhuma atualização necessária. Documento
permanece válido.

## Paulo Produto — E-LIMS
main avançou de `ad10947` para `f3a9c21` (8 commits). Inspecionados via
git log/show: 6 são fixes de validação, 2 introduzem um novo endpoint
`POST /Equipment/{id}/telemetry/ingest` com persistência real de leituras
(`EquipmentTelemetryController.cs`, `EquipmentTelemetry` entity).
**Atualização de capacidade real**: a limitação "sem ingestão automática de
telemetria" descrita na versão anterior não é mais válida — adicionada nova
seção "Ingestão de Telemetria de Equipamento" com evidência do novo
controller/entidade. Documento atualizado, commit não realizado (aguardando
checkpoint de aprovação).
```

## Veto Conditions
Reject and redo if ANY of these are true:
- Qualquer operação git além de leitura via worktree foi executada nos
  repositórios de produto (checkout, add, commit, push, ou alteração de
  branch fora do worktree temporário).
- Uma capacidade nova/alterada foi declarada sem citar o commit e o
  arquivo/classe/componente de evidência real que a introduziu.
- O `overview.md` técnico (ou qualquer arquivo fora de `product-capabilities.md`)
  foi alterado.
- O worktree temporário não foi removido ao final da análise.
- O `product-capabilities.md` foi recriado do zero quando uma atualização
  incremental resolveria.

## Quality Criteria
- [ ] Toda capacidade nova/alterada cita o commit e o arquivo de evidência real.
- [ ] `overview.md` técnico não foi alterado por este agente.
- [ ] Nenhuma operação git além de leitura via worktree foi executada.
- [ ] Worktree temporário removido ao final.
- [ ] O delta reportado no `outputFile` cobre apenas os produtos em escopo
      definidos em `foco-semanal.md`.
