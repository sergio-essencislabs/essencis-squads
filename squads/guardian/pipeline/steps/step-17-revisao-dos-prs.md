---
execution: inline
agent: reviewer
outputFile: squads/guardian/output/revisao-prs.md
---

# Step 17: Revisão dos PRs

## Context Loading

Load these files before executing:
- `squads/guardian/output/implementacao-backend.md` — PRs abertos por Breno Backend (step 11), com branch, arquivos alterados e validação de tenant isolation declarada
- `squads/guardian/output/implementacao-frontend.md` — PRs abertos por Flávia Frontend (step 13), com contrato de API confirmado e componentes implementados
- `squads/guardian/output/implementacao-database.md` — PRs abertos por Rui Register (step 15), com migration, rollback e resultado do database-diff
- `squads/guardian/agents/reviewer.agent.md` — persona/principles de Otávio Review: evidência vs. menção, bloqueio com justificativa rastreável a policy
- `squads/guardian/agents/reviewer/tasks/revisar-prs.md` — processo operacional de revisão
- `squads/guardian/output/roteamento.md` (versão final, pós-consolidação do Step 16) — para reconstituir qual task motivou cada PR, se ela tocava núcleo compartilhado ou segurança, e a ordem de merge final
- As próprias `squads/guardian/tasks/active/GT-*.md` de cada PR revisado — para checar as 3 evidências de fechamento (código, documentação, testes) antes de mover para `completed/`

## Instructions

### Process

1. Reconstituir, para cada PR listado nos três arquivos de implementação (backend/frontend/database), a cadeia completa: qual `GT-NNNN` original, qual agente implementou, o que foi produzido — usando o plano de roteamento consolidado como referência cruzada.
2. Verificar cada PR contra o checklist geral (impacto e duplicação analisados, testes presentes e descritos como passando, docs/schema atualizados quando aplicável) e contra o checklist específico do agente envolvido (ex.: para backend, controle de acesso explícito e ausência de EF Core; para frontend, reaproveitamento de shared e uso de service dedicado; para database, rollback e database-diff citado).
3. Se a tarefa tocou segurança, permissão ou núcleo compartilhado, exigir evidência real de execução do playbook correspondente (fuzz de permissão, avaliação de impacto cross-produto) — menção sem prova é motivo de bloqueio, nunca aceite "foi validado" sem o dado concreto.
4. Classificar cada PR como Aprovado ou Bloqueado, sempre citando a evidência concreta ou a policy violada — nunca um veredito do tipo "parece bom".
5. Registrar pendências não bloqueantes com dono e prioridade, separadas dos motivos de bloqueio.
6. Para todo PR bloqueado, este step direciona o rework de volta ao especialista de camada responsável: PRs de backend retornam ao step 11 (Breno Backend), PRs de frontend ficam registrados aqui como bloqueio a ser tratado por Flávia Frontend na próxima execução do step 13, e PRs de database da mesma forma para o step 15 — o pipeline runner usa o `on_reject: 11` desta etapa como o ponto de retorno mecânico padrão quando o bloqueio é de backend ou cross-cutting; bloqueios isolados de frontend/database são sinalizados explicitamente no relatório para que o usuário decida se reexecuta a etapa específica no checkpoint seguinte.
7. Para cada PR **aprovado**, checar as 3 evidências de fechamento na `GT-NNNN.md` correspondente, nesta ordem: (a) **código** — "Registro de execução → Alterações realizadas" preenchido e PR de fato existente; (b) **documentação** — se a task tocou módulo/endpoint/schema/integração, o doc correspondente foi atualizado (ou há justificativa explícita registrada de por que não se aplica); (c) **testes** — "Validação" tem comando e resultado reais, não uma caixa marcada sem evidência. Se as três passam, mover `tasks/active/GT-NNNN.md` → `tasks/completed/`, atualizando `status: completed` no frontmatter. Se alguma falhar, **não mover** — registrar exatamente o que falta no campo "Pendências" da própria task, nunca em silêncio.
8. Consolidar o veredito final de todos os PRs revisados nesta execução no arquivo de saída.

## Output Format

The output MUST follow this exact structure:
```markdown
# Revisão dos PRs — {data da execução}

## PRs Aprovados

### PR {referência} — {título}
**Task original:** {GT-NNNN}
**Evidência confirmada:** {lista de evidências verificadas}
**Pendências não bloqueantes:** {lista com dono e prioridade, ou "nenhuma"}
**Fechamento da task:** {"movida para tasks/completed/" | "permanece em tasks/active/ — falta: {o que falta}"}

## PRs Bloqueados

### PR {referência} — {título}
**Task original:** {GT-NNNN}
**Motivo do bloqueio:** {policy violada ou evidência ausente, citada explicitamente}
**Retorna para:** {agente responsável / step}

## Resumo
Total revisado: {N} | Aprovados: {N} | Bloqueados: {N} | Tasks fechadas: {N}
```

## Output Example

```markdown
# Revisão dos PRs — 2026-08-21

## PRs Aprovados

### PR #142 — fix: exigir permissão explícita em POST /Address/add (GT-0001)
**Task original:** GT-0001
**Evidência confirmada:** seed da key `address.create` presente em `PermissionSeeder.cs`; teste `AddressController_Add_Should_Deny_Without_Permission` presente e descrito como passando; `docs/system/permission-rules.md` não precisava de alteração (endpoint já documentado corretamente na seção de permissões pendentes).
**Pendências não bloqueantes:** falta teste de idempotência do seed (dono: Breno Backend, prioridade baixa).
**Fechamento da task:** movida para tasks/completed/.

### PR #144 — chore(db): marcar testsjson como legado em testrequest (GT-0002)
**Task original:** GT-0002
**Evidência confirmada:** migration idempotente (`ADD COLUMN IF NOT EXISTS`), rollback explícito presente, `database-diff` citado como executado com schema conferindo, `docs/system/schema-testrequest.md` atualizado.
**Pendências não bloqueantes:** nenhuma.
**Fechamento da task:** movida para tasks/completed/.

## PRs Bloqueados

### PR #145 — refactor: consolidar modal de endereço duplicado (GT-0003)
**Task original:** GT-0003
**Motivo do bloqueio:** componente novo em `shared/components/address-modal` usa nome de classe Angular em português, violando `policies/nomenclatura.md` que exige inglês para símbolos de código; além disso, a issue original (GT-0003) não é referenciada na descrição do PR.
**Retorna para:** Flávia Frontend (Frontend Architect) — rework a ser tratado na próxima execução do step 13.

## Resumo
Total revisado: 3 | Aprovados: 2 | Bloqueados: 1 | Tasks fechadas: 2
```

## Veto Conditions

Reject and redo if ANY of these are true:
1. Algum PR foi aprovado com base em "parece bom" ou equivalente, sem citar evidência concreta de cada etapa do checklist.
2. Algum PR envolvendo segurança, permissão ou núcleo compartilhado foi aprovado sem evidência real de execução do playbook correspondente (aceitou menção em vez de prova).
3. Algum bloqueio foi justificado apenas por preferência estilística do revisor, sem citar a policy documentada violada.
4. O mérito técnico já decidido por um auditor especializado (Dante Debit, Selma Security, Marta Documentation) foi reaberto ou substituído nesta revisão.
5. Uma pendência não bloqueante foi omitida do relatório, deixando de registrar dono e prioridade.
6. Uma `GT-NNNN.md` foi movida para `completed/` sem as 3 evidências reais (código, documentação, testes) confirmadas.
7. Uma `GT-NNNN.md` de PR aprovado ficou sem decisão de fechamento registrada (nem "movida", nem "permanece — falta X").

## Quality Criteria

- [ ] Nenhum PR aprovado tem pendência bloqueante aberta.
- [ ] Toda aprovação e todo bloqueio citam evidência concreta ou a policy violada.
- [ ] Toda pendência não bloqueante está registrada com dono e prioridade antes do fechamento da revisão.
- [ ] Todo PR bloqueado indica claramente o agente/step de retorno para rework.
- [ ] Toda task de PR aprovado tem decisão de fechamento explícita (movida ou pendência registrada) — nunca em silêncio.
