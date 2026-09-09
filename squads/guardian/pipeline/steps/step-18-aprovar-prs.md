---
type: checkpoint
outputFile: squads/guardian/output/aprovacao-prs.md
---

# Step 18: Aprovar PRs

## Context Loading

Load these files before presenting this checkpoint:
- `squads/guardian/output/revisao-prs.md` — veredito de Otávio Review (Revisor Final) sobre todos os PRs abertos pelos especialistas de camada, com evidência, pendências não bloqueantes, motivos de bloqueio e decisão de fechamento de cada `GT-NNNN` (movida para `completed/` ou pendência registrada)

## Purpose

Este é o ponto de decisão humana antes de qualquer merge. O Revisor Final já filtrou e justificou cada PR com evidência concreta, mas a decisão final de mesclar (ou não) é sempre do usuário — nenhum PR é mesclado automaticamente pelo pipeline.

## Instructions

Apresentar ao usuário:

1. A lista numerada de todos os PRs Aprovados por Otávio Review em `revisao-prs.md`, com task original (`GT-NNNN`), evidência confirmada e pendências não bloqueantes (se houver).
2. A lista numerada de todos os PRs Bloqueados, com o motivo do bloqueio e para qual especialista/step eles retornam para rework.
3. Perguntar explicitamente ao usuário:
   - Aprovar todos os PRs da lista de Aprovados para merge?
   - Aprovar apenas alguns (usuário especifica quais números)?
   - Rejeitar algum PR que Otávio aprovou, mandando de volta para o especialista mesmo assim (o usuário pode discordar do revisor)?
   - Confirmar que os PRs bloqueados seguem para rework no especialista responsável, ou o usuário quer tratar algum manualmente?

## Output Format

The output MUST follow this exact structure:
```markdown
# Aprovação de PRs — {data}

## Decisão do Usuário

### PRs Aprovados para Merge
{lista numerada com referência de PR e task}

### PRs Rejeitados pelo Usuário (mesmo aprovados por Otávio)
{lista, com motivo dado pelo usuário, ou "nenhum"}

### PRs Bloqueados — Confirmados para Rework
{lista, com especialista/step de destino}

## Observações do Usuário
{qualquer comentário livre adicional}
```

## Output Example

```markdown
# Aprovação de PRs — 2026-08-21

## Decisão do Usuário

### PRs Aprovados para Merge
1. PR #142 — fix: exigir permissão explícita em POST /Address/add (GT-0001)
2. PR #144 — chore(db): marcar testsjson como legado em testrequest (GT-0002)

### PRs Rejeitados pelo Usuário (mesmo aprovados por Otávio)
Nenhum.

### PRs Bloqueados — Confirmados para Rework
1. PR #145 — refactor: consolidar modal de endereço duplicado (GT-0003) → retorna a Flávia Frontend (step 13)

## Observações do Usuário
Priorizar o merge do PR #142 antes do fim do dia — é a task de segurança crítica.
```

## Notes

- Este checkpoint não bloqueia indefinidamente: o usuário pode aprovar parcialmente e seguir adiante, deixando PRs bloqueados para uma execução futura do pipeline.
- Registrar a decisão do usuário fielmente, mesmo quando ela diverge do veredito de Otávio Review — o checkpoint existe justamente para essa divergência ser possível.
