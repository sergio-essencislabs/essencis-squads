---
playbook: Revisão Técnica
gatilho: qualquer tarefa antes de ser considerada concluída
---

# Playbook — Revisão Técnica

1. **Reviewer** reconstitui a cadeia: qual playbook foi usado, quais agentes/skills foram acionados.
2. Confirmar checklist do `MASTER_PROMPT.md` §10 (impacto/duplicação analisados, testes passando, docs atualizados, knowledge base atualizada se aplicável).
3. Confirmar checklist específico do(s) agente(s) de implementação envolvidos.
4. Se a tarefa tocou segurança, permissão ou núcleo compartilhado — confirmar que Security Architect/playbook de sincronização foram de fato executados, não apenas mencionados.
5. Registrar pendências não bloqueantes em `knowledge/known-issues/` com dono e prioridade.
6. Aprovar ou bloquear com justificativa concreta.

## Não fazer

- Aprovar por "parece bom" sem evidência de cada etapa.
- Bloquear por preferência estilística sem base em `policies/`.
