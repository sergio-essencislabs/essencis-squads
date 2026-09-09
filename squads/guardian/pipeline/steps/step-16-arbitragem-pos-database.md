---
execution: inline
agent: chief-architect
inputFile: squads/guardian/output/implementacao-database.md
outputFile: squads/guardian/output/roteamento.md
---

# Step 16: Arbitragem Pós-Database / Consolidação

Última arbitragem antes da Revisão dos PRs (Step 17) — consolida o
roteamento final com o resultado real dos três especialistas e sinaliza
qualquer risco cross-cutting remanescente para Otávio revisar.

## Context Loading

Load these files before executing:
- `squads/guardian/output/implementacao-database.md` — PRs abertos por Rui
  Register nesta execução, migrations, rollback e resultado do
  database-diff.
- `squads/guardian/output/implementacao-backend.md`,
  `squads/guardian/output/implementacao-frontend.md` — resultado completo
  das três camadas, para a consolidação final.
- `squads/guardian/output/roteamento.md` (versão mais recente) — plano
  vigente antes desta consolidação.
- `squads/guardian/agents/chief-architect.agent.md` e
  `squads/guardian/agents/chief-architect/tasks/arbitrar-pos-implementacao.md`
  — persona e processo operacional desta etapa (parametrizada aqui como
  "pós-Database / Consolidação").

## Instructions

### Process

1. Ler o resultado real de Rui (migrations, rollback, database-diff,
   "Coordenação necessária" com Backend).
2. Reconstituir, para cada PR aberto nas três camadas, se alguma
   "Coordenação necessária" declarada por qualquer especialista ficou sem
   resposta (ex.: Rui notificou Breno sobre uma coluna nova e o PR de Breno
   já aberto não reflete isso) — sinalizar isso explicitamente como risco
   remanescente, não silenciar.
3. Consolidar a "Ordem de merge sugerida" final — mesmo que a implementação
   tenha rodado em paralelo, a integração é sempre sequencial: registrar a
   ordem definitiva para o Step 17 (Revisão dos PRs) e o Step 18 (Aprovar
   PRs, checkpoint humano).
4. Regravar `roteamento.md` com a seção de consolidação final.

## Output Format

Mesmo formato do Step 09/12/14, com uma seção adicional:

```markdown
## Consolidação Final (Pós-Database)
**Data:** YYYY-MM-DD
**Riscos remanescentes:** [lista de "Coordenação necessária" ainda sem resposta entre camadas, ou "nenhum risco remanescente identificado"]
**Ordem de merge final:** [ordem definitiva, PR por PR, com produto/repositório de cada]
```

## Veto Conditions

Reject and redo if ANY of these are true:
- Uma "Coordenação necessária" entre camadas ficou sem resposta e não foi
  sinalizada como risco remanescente.
- A ordem de merge final não cobre todos os PRs abertos nas três camadas.

## Quality Criteria

- [ ] Todo PR das três camadas aparece na ordem de merge final.
- [ ] Toda "Coordenação necessária" cruzada entre camadas foi resolvida ou
      sinalizada explicitamente como risco remanescente para o Step 17.
