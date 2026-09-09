---
type: checkpoint
outputFile: squads/guardian/output/achados-selecionados.md
---

# Step 06: Revisão

O conteúdo revisado aqui depende do **modo** desta execução (definido em
`audit-scope.md`, Step 01):

- **Modo auditoria-nova**: os três auditores rodaram em paralelo nos Steps
  03-05. Este checkpoint apresenta os três relatórios consolidados e deixa a
  decisão de quais achados avançam para a geração de tasks (Step 07).
- **Modo retomar-promocao**: não há relatórios novos — lista-se as `GT-*.md`
  já pendentes em `squads/guardian/tasks/backlog/` e `tasks/active/` (do
  Glob feito no Step 01) para o usuário escolher quais retomar.
- **Modo implementacao-direta**: revisa-se a quebra por camada produzida pelo
  Jarvis em `plano-implementacao.md` (Step 02), confirmando com o usuário
  antes de gerar as tasks.

## Ação do Pipeline Runner

1. Ler `audit-scope.md` para determinar o modo.
2. **Modo auditoria-nova**: ler os três relatórios de auditoria —
   `squads/guardian/output/audit-divida-tecnica.md` (Dante Débito),
   `squads/guardian/output/audit-seguranca.md` (Selma Segurança),
   `squads/guardian/output/audit-documentacao.md` (Marta Manual) — e
   apresentar ao usuário um resumo consolidado, agrupado por auditor,
   listando cada achado pelo seu ID (TD-NN / SEC-NN / DOC-NN), severidade/
   prioridade e uma linha de descrição — destacando primeiro os achados de
   severidade Crítica/Alta.
3. **Modo retomar-promocao**: apresentar a lista de `GT-NNNN` pendentes já
   levantada no Step 01, com título e pasta atual (backlog/active) de cada
   uma.
4. **Modo implementacao-direta**: apresentar a tabela de quebra por camada de
   `plano-implementacao.md`, incluindo o GADR relacionado se houver.

## Pergunta ao Usuário

**Modo auditoria-nova:**
> "Quais IDs de achado você quer levar adiante para a geração de tasks? Pode
> ser todos, alguns (liste os IDs, ex.: SEC-01, TD-02) ou nenhum."

**Modo retomar-promocao:**
> "Quais `GT-IDs` pendentes você quer levar adiante agora? Pode ser todas,
> algumas (liste os IDs) ou nenhuma."

**Modo implementacao-direta:**
> "A quebra por camada acima está correta? Confirme, ajuste (diga o que
> mudar) ou cancele."

Se o usuário pedir mais detalhe sobre um achado/task/camada específica antes
de decidir, consultar o relatório/arquivo correspondente e responder antes de
registrar a decisão final.

## Ação do Pipeline Runner (após a resposta)

1. Registrar a decisão do usuário em `squads/guardian/output/achados-selecionados.md`
   no formato abaixo — este arquivo é o `inputFile` do Step 07 (Geração de
   Tasks) em todos os modos, então precisa deixar claro se a entrada é um
   achado de auditoria (TD/SEC/DOC-NN), uma `GT-ID` já existente, ou uma
   linha da quebra por camada de `plano-implementacao.md`.
2. Se nada foi selecionado/confirmado, registrar isso explicitamente e não
   avançar automaticamente para o Step 07 — confirmar com o usuário se o
   pipeline deve encerrar aqui.
3. Se ao menos um item foi selecionado/confirmado, avançar para o Step 07
   (Geração de Tasks) — exceto em modo retomar-promocao, onde as `GT-*.md`
   já existem: nesse caso o Step 07 vira stub e o pipeline vai direto para o
   Gate de Promoção (Step 08).

## Formato de Salvamento

```markdown
# Achados/Tasks Selecionados

**Data:** YYYY-MM-DD
**Modo:** [auditoria-nova | retomar-promocao | implementacao-direta]

## Aprovados
- [ID do achado (TD/SEC/DOC-NN) | GT-NNNN existente | linha da quebra por camada] — [auditor de origem, ou "Jarvis (planejamento)"] — [descrição curta]

## Não selecionados (registrados para referência futura)
- [ID] — [motivo, se informado pelo usuário]

## Observações do usuário
[qualquer contexto adicional em texto livre]
```
