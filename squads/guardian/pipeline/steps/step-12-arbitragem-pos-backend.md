---
execution: inline
agent: chief-architect
inputFile: squads/guardian/output/implementacao-backend.md
outputFile: squads/guardian/output/roteamento.md
---

# Step 12: Arbitragem Pós-Backend

Jarvis deixa de ser um evento único no início do fluxo (Step 09) — este step
reavalia o roteamento com evidência real (PR aberto, "Coordenação
necessária" declarada por Breno) antes do Frontend (Step 13) e do Database
(Step 15) rodarem. O arquivo `roteamento.md` é regravado aqui — o runner
versiona automaticamente cada regravação do mesmo output dentro da run
(`v1` → `v2` → `v3`...), preservando o histórico da evolução do plano sem
nenhuma mudança no runner genérico.

## Context Loading

Load these files before executing:
- `squads/guardian/output/implementacao-backend.md` — PRs abertos por Breno
  Backend nesta execução, "Coordenação necessária" declarada por task, e
  tasks não implementadas/bloqueadas.
- `squads/guardian/output/roteamento.md` (versão mais recente) — plano
  vigente antes desta arbitragem.
- `squads/guardian/agents/chief-architect.agent.md` e
  `squads/guardian/agents/chief-architect/tasks/arbitrar-pos-implementacao.md`
  — persona e processo operacional desta etapa (parametrizada aqui como
  "pós-Backend").

## Instructions

### Process

1. Ler o resultado real de Breno (PRs abertos, contratos de API alterados,
   "Coordenação necessária" por task) — nunca assumir que o plano original
   (Step 09) ainda reflete a realidade sem checar.
2. Para toda task com "Coordenação necessária: Frontend" (ou Database)
   declarada por Breno, tratar essa dependência como **obrigatória**: uma
   task de Flávia ou Rui que dependa de algo ainda não mesclado nunca pode
   estar no mesmo grupo paralelo que a implementação backend da qual depende.
3. Reaplicar as regras de veto de sempre (núcleo compartilhado, mesmo
   arquivo/endpoint, segurança antes de dívida técnica) com a informação
   nova — ajustar `grupo_execucao` das tasks de Frontend/Database ainda não
   implementadas se a realidade mudou o que é seguro paralelizar.
4. Se alguma task backend ficou bloqueada, decidir se isso bloqueia
   dependentes de Frontend/Database ou se pode seguir em paralelo
   (dependência não confirmada = nunca paralelizar por padrão).
5. Atualizar a "Ordem de merge sugerida" com a informação real dos PRs
   abertos.
6. Regravar `roteamento.md` (o runner versiona automaticamente).

## Output Format

Mesmo formato do Step 09 (`roteamento.md`), com uma seção adicional:

```markdown
## Arbitragem Pós-Backend
**Data:** YYYY-MM-DD
**Mudanças em relação à versão anterior:** [lista objetiva: task X saiu do grupo paralelo porque Breno sinalizou "Coordenação necessária: Frontend"; task Y permanece; etc. — ou "nenhuma mudança necessária, plano original se confirmou"]
```

## Veto Conditions

Reject and redo if ANY of these are true:
- Uma "Coordenação necessária" declarada por Breno foi ignorada na
  atualização do roteamento.
- Uma task de Frontend/Database foi mantida em grupo paralelo com uma task
  backend da qual depende e que ainda não foi mesclada.
- O `roteamento.md` foi regravado sem registrar o que mudou (ou a nota
  explícita de que nada mudou).

## Quality Criteria

- [ ] Toda "Coordenação necessária" de `implementacao-backend.md` foi
      avaliada e refletida no roteamento atualizado.
- [ ] Nenhuma dependência real (confirmada pelo PR) foi tratada como
      paralelizável.
