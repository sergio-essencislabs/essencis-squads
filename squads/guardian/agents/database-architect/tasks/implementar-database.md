---
task: "Implementar Database"
order: 1
input: |
  - achado: achado de banco de dados roteado pelo Jarvis (id, camada, descrição, severidade, tabela/coluna afetada)
  - plano_roteamento: squads/guardian/output/roteamento.md (contexto de ordem/dependência entre achados)
output: |
  - implementacao: squads/guardian/output/implementacao-database.md (branch, migration, script de rollback, resultado do database-diff, PR aberto)
---

# Implementar Database

Implementa a migration ou correção de schema roteada pelo Jarvis para um achado aprovado, em branch dedicada, garantindo idempotência ou rollback explícito, e abre PR — nunca push direto em main/master.

> `database-diff` = metodologia em `C:\Software\ClaudeCode\squads\guardian\reference\{geocloud|elims}\skills\database-diff\SKILL.md` (caminho absoluto, conforme produto do achado) — ler e aplicar diretamente via Bash/Read, sem depender de `.claude`/`.cursor` do produto.

## Process

1. Confirmar que a mudança proposta não duplica coluna, tabela ou relacionamento já existente — inspecionar o schema vivo antes de escrever qualquer DDL.
2. Se a mudança toca o núcleo compartilhado de Conta/Identidade (Account, Entity, Profile, Functionality, User), acionar o playbook de sincronização entre GeoCloudAI e E-LIMS antes de escrever a migration.
3. Escrever a migration de forma idempotente (`CREATE ... IF NOT EXISTS`, `ADD COLUMN IF NOT EXISTS`) ou, quando não for possível, acompanhá-la de um script de rollback explícito.
4. Seguir a convenção fixa do projeto: tabelas e colunas em minúsculas sem aspas, chaves estrangeiras nomeadas por convenção consistente.
5. Aplicar a migration e rodar database-diff imediatamente após, confirmando que o schema vivo corresponde exatamente ao esperado.
6. Atualizar a documentação de schema do produto na mesma tarefa, refletindo o estado pós-migration.
7. Notificar o Backend Architect para implementar a camada Persistence sobre o schema novo, quando aplicável.
8. Abrir Pull Request: nunca fazer push direto em main/master. Criar branch dedicada, comitar a migration com o script de rollback e o resultado do database-diff documentado, e abrir PR. Parar aqui e aguardar o checkpoint de revisão (Otávio Review) e a aprovação humana antes de qualquer merge.

## Output Format

```yaml
branch_name: string             # ex.: fix/testrequest-drop-legacy-json-column
files_changed:
  - path: string
    change_summary: string
migration_sql: string            # DDL idempotente aplicado
rollback_sql: string             # script de rollback explícito
database_diff_result: string     # resultado citado da verificação pós-aplicação
pr_title: string
pr_description: string
pr_url: string                    # placeholder até a criação real via gh CLI
tests_added:
  - name: string
    covers: string
```

## Output Example

```yaml
branch_name: fix/testrequest-drop-legacy-json-column
files_changed:
  - path: migrations/2026-08-21_testrequest_migrated_at.sql
    change_summary: "Adiciona coluna migrated_at para rastrear migração do campo JSON legado"
  - path: docs/system/schema-testrequest.md
    change_summary: "Documenta nova coluna migrated_at e o plano de remoção da escrita legada"
migration_sql: "ALTER TABLE testrequest ADD COLUMN IF NOT EXISTS migrated_at TIMESTAMP NULL;"
rollback_sql: "ALTER TABLE testrequest DROP COLUMN IF EXISTS migrated_at;"
database_diff_result: "Schema vivo confirmado igual ao esperado após aplicação — coluna migrated_at presente, tipo TIMESTAMP NULL, sem impacto em constraints existentes."
pr_title: "fix: adicionar coluna migrated_at para rastrear migração do campo JSON legado (TD-01)"
pr_description: >
  Corrige achado TD-01 (Dante Debit): adiciona coluna migrated_at à
  tabela testrequest para permitir rastreamento da migração do campo
  JSON legado para as tabelas relacionais novas de testes, sem alterar
  comportamento existente. Migration idempotente, rollback incluído,
  database-diff executado e citado. Notifica Breno Backend para
  implementar a camada Persistence que passará a popular esta coluna.
pr_url: "PENDING"
tests_added:
  - name: Migration_TestRequest_MigratedAt_Should_Be_Idempotent
    covers: "Aplicar a migration duas vezes não gera erro nem efeito duplicado"
```

## Quality Criteria

- Zero migration sem plano de reversão explícito.
- database-diff executado e citado como evidência após cada migration aplicada.
- Schema documentado reflete o schema vivo ao final da tarefa.

## Veto Conditions

Reject and redo if ANY are true:
- Qualquer push direto em main/master (sem branch dedicada + PR) — reject automático, sem exceção.
- Migration destrutiva aplicada sem plano de rollback e sem aprovação explícita do Chief Architect.
- Migration declarada concluída sem execução e citação do resultado do database-diff.
- Introdução de mecanismo de migration que não seja o padrão oficial do produto: no GeoCloudAI o padrão É FluentMigrator (`MXXX_*.cs`, numeração por timestamp UTC); no E-LIMS é script SQL manual em `backend/src/Back.API/Scripts/` (ADR-0004 — nenhum migrador). Introduzir EF Core em qualquer um, ou FluentMigrator no E-LIMS, exige veto.
- Mudança de schema que toca o núcleo compartilhado de Conta/Identidade sem acionar o playbook de sincronização entre GeoCloudAI e E-LIMS.
