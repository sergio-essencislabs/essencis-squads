---
playbook: Atualização Documental
gatilho: qualquer tarefa concluída que alterou contrato, entidade, permissão ou fluxo; ou documentação identificada como desatualizada
---

# Playbook — Atualização Documental

1. **Documentation Sync** (skill) — localizar todos os documentos que mencionam a área alterada.
2. Se a mudança afeta entidade/DTO/controller/permissão, rodar também **Structural Spreadsheet Sync** (skill) para atualizar a planilha estrutural canônica do produto correspondente.
3. **Documentation Architect** avalia cada um: atualizar, ou remover se irremediavelmente desatualizado (preferir remover a deixar enganoso — lição com os docs de plano pré-P0).
4. Distinguir claramente "planejado" de "implementado" em qualquer texto novo/editado.
5. **Knowledge Manager** avalia se algo da mudança é cross-projeto (vai para `knowledge/patterns/`) ou específico do produto (`.agents/memory/`).
6. Atualizar o índice correspondente (`MEMORY.md` do produto, `FRAMEWORK_DECISIONS.md` do framework).
7. Se a mudança revela uma decisão arquitetural implícita nunca registrada, criar o ADR retroativamente.

## Não fazer

- Deixar documentação "quase certa" como está — corrigir ou remover.
- Duplicar a mesma lição em `.agents/memory/` do produto e em `knowledge/patterns/` do framework.
