---
task: "Planejar Implementação"
order: 1
input: |
  - pedido: texto livre do usuário em modo "solicitação direta de implementação" (squads/guardian/output/audit-scope.md, Step 01)
output: |
  - plano_implementacao: quebra por camada, com GADR quando aplicável (squads/guardian/output/plano-implementacao.md)
---

# Planejar Implementação

Só roda em modo "solicitação direta de implementação" — quando o usuário pede
"Guardian, preciso fazer X" em vez de rodar uma auditoria. Jarvis decide
sozinho quais camadas precisam agir, sem que o usuário chame cada
especialista por nome.

## Process

1. Ler o pedido em `audit-scope.md` com fidelidade total — nunca reinterpretar
   a intenção além do que foi escrito.
2. Explorar o código/arquitetura relevante (codebase de produto + material de
   referência interno) o suficiente para decidir quais camadas (backend,
   frontend, database, ou combinação) o pedido afeta.
3. Se houver mais de uma abordagem viável, ou o pedido tocar o núcleo
   compartilhado de Conta/Identidade, seguir o ritual gradual do
   `bootstrap-plan`: propor até 3 opções com trade-offs concretos e pedir ao
   usuário para escolher — nunca decidir sozinho. Depois da escolha, redigir
   um `GADR` (`redigir-gadr.md`).
4. Se o pedido for trivial (um passo óbvio, uma camada só, sem ambiguidade),
   pular direto para a quebra por camada.
5. Produzir a quebra final: uma entrada por camada afetada, com escopo
   objetivo suficiente para o Step 07 (Geração de Tasks) gerar uma
   `GT-NNNN.md` por camada.
6. Registrar tudo em `plano-implementacao.md` para o Step 06 (Revisão)
   apresentar ao usuário.

## Output Format

```yaml
plano_implementacao:
  pedido_original: "..."
  gadr: "GADR-NNNN"  # ou null
  quebra:
    - camada: "backend"
      escopo: "..."
      depende_de: []
      observacao: "..."
    - camada: "frontend"
      escopo: "..."
      depende_de: ["backend"]
      observacao: "..."
  nucleo_compartilhado:
    tocado: false
    avaliacao: "N/A"
```

## Quality Criteria

- Toda camada realmente afetada pelo pedido aparece na quebra.
- Ambiguidade de abordagem foi resolvida com o usuário, nunca decidida sozinho.
- Núcleo compartilhado, quando tocado, tem avaliação de impacto registrada e GADR associado.

## Veto Conditions

Reject e refaça se QUALQUER uma for verdadeira:
- O pedido do usuário foi reinterpretado além do que foi escrito.
- Uma abordagem arquiteturalmente ambígua foi decidida sem apresentar opções ao usuário.
- Uma camada afetada pelo pedido ficou de fora da quebra final.
