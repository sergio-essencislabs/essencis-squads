---
execution: inline
agent: chief-architect
inputFile: squads/guardian/output/audit-scope.md
outputFile: squads/guardian/output/plano-implementacao.md
---

# Step 02: Planejamento da Implementação

Só roda de fato em **modo 3 (solicitação direta de implementação)**. Em modo
1 (auditoria nova) e modo 2 (retomar), este step vira stub: gravar
`plano-implementacao.md` só com uma linha "N/A — modo {modo}, ver
audit-scope.md" e avançar imediatamente para o Step 03.

## Context Loading

Load these files before executing:
- `squads/guardian/output/audit-scope.md` — pedido em texto livre do usuário,
  produto(s) em escopo e profundidade.
- `squads/guardian/agents/chief-architect.agent.md` — persona do Jarvis.
- `squads/guardian/agents/chief-architect/tasks/planejar-implementacao.md` —
  processo operacional desta etapa.
- Codebase de produto relevante e o material de referência interno
  (`reference/geocloud` ou `reference/elims`) — para entender arquitetura e
  padrões existentes antes de propor abordagem.

Esta é uma execução **inline** (persona switching, não subagente) — o Jarvis
analisa o pedido diretamente na conversa principal.

## Instructions

### Process

1. Ler o pedido em `audit-scope.md` com fidelidade — nunca reinterpretar a
   intenção do usuário além do que foi escrito.
2. Explorar o código/arquitetura relevante o suficiente para decidir quais
   camadas (backend, frontend, database, ou combinação) o pedido afeta.
3. Se houver mais de uma abordagem viável, ou o pedido tocar o núcleo
   compartilhado de Conta/Identidade (Account, Entity, Profile, Functionality,
   User), seguir o ritual gradual do `bootstrap-plan`: propor até 3 opções com
   trade-offs concretos (nunca genéricos) e pedir ao usuário para escolher —
   nunca decidir sozinho nesse ponto. Registrar a escolha e redigir um `GADR`
   em `squads/guardian/decisions/` (usar
   `squads/guardian/agents/chief-architect/tasks/redigir-gadr.md`).
4. Se o pedido for trivial (um passo óbvio, uma camada só, sem ambiguidade),
   pular direto para a quebra por camada, sem o ritual de opções.
5. Produzir a quebra final: uma entrada por camada afetada, com escopo
   objetivo suficiente para o Step 07 gerar uma `GT-NNNN.md` por camada.
6. Registrar tudo em `plano-implementacao.md` — este arquivo é o que o Step 06
   (Revisão) apresenta ao usuário para confirmação antes da geração de tasks.

## Output Format

```markdown
# Plano de Implementação — Jarvis

**Data:** YYYY-MM-DD
**Pedido original:** "..."
**GADR relacionado:** [GADR-NNNN, ou "nenhum — pedido de caminho único"]

## Quebra por camada

| Camada | Escopo | Depende de | Observação |
|---|---|---|---|
| [Backend/Frontend/Database/Cross-cutting] | [o que precisa ser feito nessa camada] | [outra camada, ou "nenhuma"] | [justificativa] |

## Núcleo compartilhado
[avaliação de impacto em GeoCloudAI e E-LIMS, ou "N/A — pedido não toca o núcleo compartilhado"]
```

## Veto Conditions

Reject and redo if ANY of these are true:
- O pedido do usuário foi reinterpretado além do que foi escrito em `audit-scope.md`.
- Uma abordagem arquiteturalmente ambígua ou multi-opção foi decidida sem
  apresentar as opções ao usuário.
- Uma camada afetada pelo pedido ficou de fora da quebra final.
- Um pedido que toca o núcleo compartilhado avançou sem avaliação de impacto
  nos dois produtos.

## Quality Criteria

- [ ] Toda camada realmente afetada pelo pedido aparece na quebra.
- [ ] Ambiguidade de abordagem foi resolvida com o usuário, nunca decidida sozinho.
- [ ] Núcleo compartilhado, quando tocado, tem avaliação de impacto registrada.
