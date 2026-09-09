---
description: Critérios de revisão técnica obrigatórios antes de considerar uma tarefa concluída
globs:
alwaysApply: false
---

# Revisão

- Toda tarefa passa pelo agente Reviewer antes de ser marcada como concluída (ver `agents/reviewer.md`).
- Revisão confirma **evidência**, não impressão: análise de impacto/duplicação feita, testes passando, docs atualizados, segurança avaliada quando aplicável.
- Pendência bloqueante (ex.: endpoint sem controle de acesso, migration sem rollback, núcleo compartilhado alterado sem sincronização) impede aprovação — não é "aprovar com nota".
- Pendência não bloqueante vai para `knowledge/known-issues/` com dono e prioridade, nunca é apenas esquecida.

Use `templates/review.md` para registrar o resultado da revisão de forma padronizada.
