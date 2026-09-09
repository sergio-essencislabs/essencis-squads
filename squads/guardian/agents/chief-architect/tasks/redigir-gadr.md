---
task: "Redigir GADR"
order: 3
input: |
  - task_ou_pedido: a GT-NNNN (ou o pedido de implementação direta) que toca o núcleo compartilhado, tem mais de uma abordagem viável, ou é severidade crítica com impacto cross-produto
output: |
  - gadr: squads/guardian/decisions/GADR-NNNN-{slug}.md
---

# Redigir GADR

Registra uma decisão arquitetural tomada por Jarvis durante o roteamento (Step 09) ou o planejamento de uma solicitação direta de implementação (Step 02). Só é chamada quando o critério de `squads/guardian/decisions/README.md` é atendido — nunca para uma correção óbvia de único caminho.

## Process

1. Determinar o próximo `GADR-NNNN` livre escaneando `squads/guardian/decisions/*.md`.
2. Preencher o template (`squads/guardian/decisions/_template.md`): Contexto (o que motivou), Decisão (uma frase clara), Alternativas consideradas (cada uma com vantagens/desvantagens reais, nunca genéricas), Consequências (Positivas/Negativas/Riscos), Plano de adoção (ordem das `GT-NNNN` relacionadas), Validação, Revisão.
3. Se a decisão envolveu mais de uma opção viável, registrar as opções realmente apresentadas ao usuário (Step 02) ou a avaliação de impacto cross-produto que embasou a escolha (Step 09) — nunca uma alternativa inventada após o fato só para preencher a seção.
4. Preencher `related_tasks` com toda `GT-NNNN` que depende desta decisão, e `produtos_afetados`.
5. Atualizar `related_adrs` em cada `GT-NNNN` relacionada, apontando para este GADR.
6. Salvar em `squads/guardian/decisions/GADR-NNNN-{slug}.md` com `status: accepted` quando a decisão já foi confirmada pelo usuário, ou `status: proposed` se ainda está em aberto (caso raro — normalmente Jarvis só redige o GADR depois da escolha do usuário estar feita).

## Quality Criteria

- Toda alternativa registrada foi de fato considerada, nunca inventada retroativamente.
- Toda `GT-NNNN` relacionada tem `related_adrs` preenchido apontando para este GADR.
- O GADR nunca decide sozinho uma ambiguidade que deveria ter sido levada ao usuário primeiro.

## Veto Conditions

Reject e refaça se QUALQUER uma for verdadeira:
- Um GADR foi criado para uma correção de único caminho óbvio, sem ambiguidade real nem núcleo compartilhado envolvido.
- Uma alternativa "considerada" no GADR nunca foi de fato apresentada ao usuário ou avaliada.
- Uma `GT-NNNN` relacionada ficou sem `related_adrs` preenchido.
