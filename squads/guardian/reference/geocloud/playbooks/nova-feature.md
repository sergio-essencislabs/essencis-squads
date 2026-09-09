---
playbook: Nova Feature
gatilho: pedido de funcionalidade nova (não é bug, não é apenas um endpoint isolado)
---

# Playbook — Nova Feature

1. **Planner** decompõe o pedido em tarefas por camada (ver `agents/planner.md`), usando os playbooks específicos abaixo como sub-etapas (`nova-entidade.md`, `novo-endpoint.md`, `nova-tela.md`, `migration.md` conforme necessário).
2. **Duplicate Detector** (skill) — confirmar que a feature (ou parte dela) não já existe no produto ou no produto irmão.
3. **Chief Architect** avalia se a feature introduz um padrão arquitetural novo (nesse caso, ADR antes de prosseguir).
4. Executar sub-playbooks na ordem de dependência: schema → Domain → Persistence → Application/API → Frontend.
5. **Security Architect** revisa toda superfície de API nova.
6. **QA Architect** garante teste de regra de negócio + fuzz de permissão se aplicável.
7. **Documentation Architect** atualiza `docs/system/business-requirements.md` e demais docs afetados.
8. **Reviewer** confirma a cadeia completa antes de considerar concluído.

## Não fazer

- Implementar a feature inteira em uma única tarefa monolítica sem decomposição do Planner.
- Pular a checagem de duplicação por "parecer óbvio que é novo".
