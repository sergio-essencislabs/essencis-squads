---
playbook: Refatoração
gatilho: dívida técnica identificada (duplicação, code smell, dead code) sem mudança de comportamento pretendida
---

# Playbook — Refatoração

1. **Refactoring Architect** confirma o achado com skill de detecção (`duplicate-detector`, `code-smell-detector`, `dead-code-detector`) — nunca refatorar por impressão subjetiva.
2. **Dependency Mapper** (skill) — mapear todos os consumidores antes de tocar no componente.
3. Quebrar em etapas pequenas e reversíveis (`refactoring-assistant`).
4. Para cada etapa: rodar teste de regressão antes e depois.
5. **Nunca misturar com feature nova** — se durante a refatoração surgir necessidade de mudança de comportamento, parar e abrir uma tarefa de feature separada (`nova-feature.md`).
6. **Knowledge Manager** atualiza `knowledge/known-issues/` com o progresso (aberta → em progresso → resolvida).
7. **Reviewer** confirma que nenhum comportamento observável mudou.

## Não fazer

- Refatorar e mudar comportamento na mesma tarefa.
- Refatorar sem mapear consumidores primeiro.
- Refatorar o núcleo compartilhado fora do playbook `sincronizacao-nucleo-compartilhado.md`.
