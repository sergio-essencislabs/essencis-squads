---
execution: inline
agent: chief-architect
inputFile: squads/guardian/output/implementacao-frontend.md
outputFile: squads/guardian/output/roteamento.md
---

# Step 14: Arbitragem Pós-Frontend

Mesmo padrão do Step 12 (Arbitragem Pós-Backend), agora com o resultado real
de Flávia. Regrava `roteamento.md` (vira `v3` pelo auto-versionamento do
runner) antes do Database (Step 15) rodar.

## Context Loading

Load these files before executing:
- `squads/guardian/output/implementacao-frontend.md` — PRs abertos por
  Flávia Frontend nesta execução, "Coordenação necessária" declarada por
  task, e tasks não implementadas/bloqueadas.
- `squads/guardian/output/roteamento.md` (versão mais recente, já refletindo
  a Arbitragem Pós-Backend) — plano vigente antes desta arbitragem.
- `squads/guardian/agents/chief-architect.agent.md` e
  `squads/guardian/agents/chief-architect/tasks/arbitrar-pos-implementacao.md`
  — persona e processo operacional desta etapa (parametrizada aqui como
  "pós-Frontend").

## Instructions

### Process

1. Ler o resultado real de Flávia (PRs abertos, "Coordenação necessária" por
   task, tasks bloqueadas por contrato de API não confirmado).
2. Para toda task com "Coordenação necessária: Backend" ou "Database"
   declarada por Flávia, tratar como dependência obrigatória na
   reclassificação dos grupos ainda não implementados.
3. Reaplicar as regras de veto de sempre com a informação nova.
4. Atualizar a "Ordem de merge sugerida" com a informação real dos PRs de
   Backend e Frontend já abertos.
5. Regravar `roteamento.md` (o runner versiona automaticamente).

## Output Format

Mesmo formato do Step 09/12, com uma seção adicional:

```markdown
## Arbitragem Pós-Frontend
**Data:** YYYY-MM-DD
**Mudanças em relação à versão anterior:** [lista objetiva, ou "nenhuma mudança necessária"]
```

## Veto Conditions

Reject and redo if ANY of these are true:
- Uma "Coordenação necessária" declarada por Flávia foi ignorada na
  atualização do roteamento.
- Uma task de Database ainda não implementada foi mantida em grupo paralelo
  com uma task frontend da qual depende e que ainda não foi mesclada.
- O `roteamento.md` foi regravado sem registrar o que mudou.

## Quality Criteria

- [ ] Toda "Coordenação necessária" de `implementacao-frontend.md` foi
      avaliada e refletida no roteamento atualizado.
- [ ] Nenhuma dependência real foi tratada como paralelizável.
