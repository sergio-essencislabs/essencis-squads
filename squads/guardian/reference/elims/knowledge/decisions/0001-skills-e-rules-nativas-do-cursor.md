---
id: ADR-0001
title: Adotar Skills e Rules nativas do Cursor como camada de execução
status: aceito
date: 2026-07-30
deciders: Chief Architect
---

## Contexto

O mandato original do framework pede "skills" e "policies" como componentes próprios. Durante a Etapa 2 (análise do Cursor), verificou-se que o Cursor já possui dois recursos nativos com exatamente essa forma:

- **Project Rules** (`.cursor/rules/*.mdc`, com `globs`/`alwaysApply`) — carregamento condicional, sem custo de contexto quando não aplicável.
- **Agent Skills** (`.cursor/skills/<nome>/SKILL.md`) — descoberta por nome/descrição, com progressive disclosure documentada oficialmente (`create-skill` skill em `~/.cursor/skills-cursor/`).

Recriar esses mecanismos como arquivos markdown "passivos" (sem integração real com o carregamento de contexto do Cursor) duplicaria funcionalidade nativa e desperdiçaria exatamente o recurso que o framework deveria economizar: tokens/contexto.

## Decisão

`policies/` e `skills/` do framework são escritos **diretamente no formato nativo do Cursor** (frontmatter `.mdc` para policies, `SKILL.md` para skills). Um script (`scripts/sync-cursor.ps1`) copia essa fonte versionada para `ELIMS/.cursor/rules/` e `ELIMS/.cursor/skills/`, que é o diretório que o Cursor efetivamente carrega.

## Consequências

- `ELIMS/.cursor/` nunca é editado manualmente — apenas gerado.
- O framework permanece um repositório independente (`elims-ai-framework/.git`) mesmo com seu output vivendo fora dele (em `ELIMS/.cursor/`), porque o output é regenerável a qualquer momento a partir da fonte.
- Ganho direto de economia de contexto: rules com `globs` só entram quando um arquivo correspondente está aberto; skills só carregam por nome/descrição.

## Alternativas consideradas

- Sistema de skills/policies customizado, interpretado por instrução em `MASTER_PROMPT.md` (rejeitado: duplica funcionalidade nativa e não se beneficia do carregamento lazy do Cursor).
