---
type: checkpoint
outputFile: squads/guardian/output/gate-promocao.md
---

# Step 08: Gate de Promoção

As tasks geradas no Step 07 (ou já existentes, em modo retomar-promocao)
estão em `squads/guardian/tasks/backlog/`. **Nenhuma issue foi criada e
nenhuma implementação começou até este ponto.** Este é o gate: só avança
para criação de issue (Step 10) e implementação coordenada (Steps 11-16)
mediante pedido explícito do usuário — que pode vir nesta mesma sessão ou
dias depois, em uma sessão nova (ver `runner.agent.md`/modo retomar do Step
01).

## Ação do Pipeline Runner

1. Listar as `GT-NNNN` geradas/confirmadas em `tasks-geradas.md` (ou a lista
   de retomada do Step 06, em modo retomar-promocao), com título e camada
   provisória de cada uma.

## Pergunta ao Usuário

> "As tasks acima estão em `tasks/backlog/`. Quer que eu crie as issues no
> Project e comece a implementação agora? Pode ser 'agora, todas', 'agora,
> só [lista de GT-IDs]', ou 'parar aqui' — as tasks continuam salvas e você
> pode retomar quando quiser."

## Ação do Pipeline Runner (após a resposta)

1. Se "parar aqui": registrar a decisão em `gate-promocao.md`, encerrar o
   pipeline nesta execução. As `GT-*.md` permanecem em `backlog/` — nenhuma
   mudança nelas.
2. Se "agora" (todas ou uma lista): registrar as `GT-IDs` aprovadas para
   promoção em `gate-promocao.md` e avançar para o Step 09 (Roteamento).

## Formato de Salvamento

```markdown
# Gate de Promoção

**Data:** YYYY-MM-DD
**Decisão:** [parar-aqui | promover-agora]

## GT-IDs promovidas nesta decisão
- [GT-NNNN] — [título]

(vazio se a decisão foi "parar aqui")

## GT-IDs que permanecem em backlog
- [GT-NNNN] — [título]
```
