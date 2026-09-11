---
execution: subagent
agent: database-architect
inputFile: squads/guardian/output/roteamento.md
outputFile: squads/guardian/output/implementacao-database.md
model_tier: powerful
---

# Step 15: Implementação Database

Este step normalmente roda depois da Arbitragem Pós-Frontend (Step 14), já
que schema costuma ser dependência de backend — mas o Step 14 pode
reclassificar o grupo de database como paralelizável com backend/frontend se
não houver dependência real declarada.

## Context Loading

Load these files before executing:
- `squads/guardian/output/roteamento.md` (versão mais recente — pode já
  refletir as duas arbitragens anteriores) — plano de roteamento do Jarvis:
  quais tasks desta camada (database) devem ser implementadas, em qual
  grupo/ordem, e quais tocam o núcleo compartilhado de Conta/Identidade
  exigindo o playbook de sincronização
- As próprias `squads/guardian/tasks/active/GT-*.md` com `camada: database` —
  texto completo de cada task, fonte única de verdade da implementação
- `squads/guardian/agents/database-architect.agent.md` — persona/principles de Rui Register: migration idempotente, plano de rollback obrigatório, proibição de EF Core Migrations/FluentMigrator
- `squads/guardian/agents/database-architect/tasks/implementar-database.md` — processo operacional de implementação de schema
- Codebase de produto relevante (`C:\Software\GeoCloud\GeoCloudAI` e/ou `C:\Software\ELIMS\ELIMS`, conforme a task roteada) — scripts de schema, seeds de dados de referência, documentação de schema existente

## Instructions

> **Independência de `.claude`/`.cursor`:** `database-diff` não é skill nativa deste squad — é a metodologia em `C:/Software/ClaudeCode/squads/guardian/reference/{geocloud|elims}/skills/database-diff/SKILL.md` (caminho absoluto, conforme produto da task). Ler o `SKILL.md` correspondente e aplicar o método diretamente via Bash/Read, sem depender do Skill tool nem de `.claude/`/`.cursor/` do repositório de produto.

### Process

1. Ler o plano de roteamento e filtrar apenas as tasks `active/` atribuídas à camada database nesta execução; para cada uma, confirmar que a mudança não duplica coluna/tabela/relacionamento já existente.
2. Se a task toca o núcleo compartilhado de Conta/Identidade, acionar o playbook de sincronização e confirmar avaliação de impacto no produto irmão (e o GADR relacionado) antes de escrever qualquer migration.
3. Para cada task (ou pequeno lote relacionado), criar uma branch dedicada `fix/{descrição-curta}` ou `migration/{descrição-curta}`, escrever a migration de forma idempotente (`CREATE ... IF NOT EXISTS` / `ADD COLUMN IF NOT EXISTS`) e sempre acompanhada de um script de rollback explícito — nunca uma migration destrutiva sem plano de reversão e aprovação do Chief Architect.
4. Seguir a convenção fixa do produto: tabelas/colunas em minúsculas sem aspas, FK por convenção de nome; tornar seeds de dados de referência idempotentes.
5. Rodar database-diff após aplicar a migration em ambiente de teste, confirmando que o schema vivo corresponde exatamente ao esperado — citar a saída como evidência.
6. Atualizar a documentação de schema do produto (docs/system ou planilha estrutural equivalente) na mesma tarefa, nunca deixar para depois.
7. Abrir um Pull Request por branch (NUNCA push direto em main/master), notificando explicitamente o Backend Architect para implementar/ajustar a camada Persistence sobre o schema novo.
8. Atualizar, na própria `GT-NNNN.md` em `tasks/active/`, as seções "Registro de execução" e "Validação" — com comando e resultado reais.

> **Onde escrever o Registro de execução:** se a `GT-NNNN` tem `contraparte` no front-matter, o Registro de execução e a Validação vão **no par do repositório de produto** (`<repo>/.agents/tasks/active/GT-NNNN.md`) — é ele que viaja na branch e é revisado no mesmo PR do código. O GT do hub guarda o porquê (achado, evidência, severidade) e **não** recebe registro de execução. Sem `contraparte`, tudo no hub, como antes. Ver `agents/task-curator/tasks/gerar-tasks.md`, passo 5.

## Output Format

The output MUST follow this exact structure:
```markdown
# Implementação Database — {data da execução}

## Tasks Implementadas

### {GT-NNNN} — {título curto}
**Branch:** `{nome-da-branch}`
**Migration:** {DDL aplicado}
**Script de rollback:** {DDL de reversão}
**database-diff executado:** {resultado — schema vivo confere / divergência encontrada e corrigida}
**Núcleo compartilhado envolvido:** {sim, com detalhe do playbook de sincronização / não}
**Documentação de schema atualizada:** {arquivo atualizado}
**PR:** {título do PR} — {url do PR, placeholder se ainda não disponível}
**Coordenação necessária:** {Backend Architect e o que precisa ajustar}

(repetir bloco para cada task implementada)

## Tasks Não Implementadas / Bloqueadas
{lista de tasks roteadas para database que não puderam ser implementadas nesta execução, com motivo}
```

## Output Example

```markdown
# Implementação Database — 2026-08-21

## Tasks Implementadas

### GT-0002 — Campo JSON legado convivendo com tabela relacional nova
**Branch:** `migration/testrequest-mark-legacy-json-deprecated`
**Migration:** `ALTER TABLE testrequest ADD COLUMN IF NOT EXISTS testsjson_deprecated_at TIMESTAMP NULL;`
**Script de rollback:** `ALTER TABLE testrequest DROP COLUMN IF EXISTS testsjson_deprecated_at;`
**database-diff executado:** schema vivo confirmado igual ao esperado após aplicação em ambiente de teste.
**Núcleo compartilhado envolvido:** não.
**Documentação de schema atualizada:** `docs/system/schema-testrequest.md`, seção "campos legados", marcado `testsjson` como em descontinuação.
**PR:** "chore(db): marcar testsjson como legado em testrequest (GT-0002)" — https://github.com/Essencis-Labs/GeoCloudAI/pull/000 (placeholder)
**Coordenação necessária:** Breno Backend precisa remover a escrita legada no service correspondente (já coberto no PR de GT-0002 do backend).

## Tasks Não Implementadas / Bloqueadas
Nenhuma.
```

## Veto Conditions

Reject and redo if ANY of these are true:
1. Qualquer commit foi feito direto em main/master sem passar por PR.
2. Uma migration destrutiva foi aplicada sem script de rollback explícito e sem aprovação do Chief Architect.
3. Foi introduzido um framework de migration (EF Core Migrations, FluentMigrator) em vez de SQL manual idempotente.
4. Uma migration foi assumida como já aplicada sem verificação real contra o banco (database-diff não executado ou não citado).
5. Uma task de núcleo compartilhado foi implementada sem acionar o playbook de sincronização e sem avaliação de impacto no produto irmão.
6. A `GT-NNNN.md` correspondente não foi atualizada com "Registro de execução" e "Validação" reais.

## Quality Criteria

- [ ] Toda migration tem plano de rollback explícito citado.
- [ ] database-diff foi executado e citado como evidência após cada migration aplicada.
- [ ] Documentação de schema do produto reflete o schema vivo ao final da tarefa.
- [ ] Toda PR aberta notifica explicitamente o Backend Architect quando a camada Persistence precisa de ajuste.
- [ ] Toda `GT-NNNN.md` implementada tem "Registro de execução" e "Validação" preenchidos com evidência real.
