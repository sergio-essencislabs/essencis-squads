---
description: Convenções de versionamento e commits para produtos e para o framework
globs:
alwaysApply: true
---

# Versionamento

- `elims-ai-framework` segue SemVer (`VERSION` + `CHANGELOG.md`); produtos (`ELIMS`/`ELIMS`) mantêm seu próprio histórico de commits em português, no estilo já usado (mensagens curtas e descritivas do que mudou).
- Toda decisão arquitetural relevante (do framework ou de um produto) gera um ADR (`templates/adr.md`) antes do merge, não depois.
- Mudança que remove/quebra um agente, skill, policy ou playbook existente do framework é `MAJOR`; adição é `MINOR`; correção de conteúdo é `PATCH`.
- Branches de feature/correção não se misturam com branches de exploração/spike — squashing ou rebase claro antes de considerar "pronto para revisão".
- Nunca reverter uma correção de segurança sem um ADR explicando por quê (já ocorreu no histórico do ELIMS — 9 reverts de correções de segurança sem esse registro).

Commits que alteram `policies/` ou `skills/` do framework devem, no mesmo commit ou no imediatamente seguinte, rodar `scripts/sync-cursor.ps1` e `scripts/validate-framework.ps1`.
