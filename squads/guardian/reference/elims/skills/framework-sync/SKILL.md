---
name: framework-sync
description: Sincroniza policies/ e skills/ do elims-ai-framework com ELIMS/.cursor/rules e .cursor/skills, e valida a estrutura do framework. Use após qualquer alteração em elims-ai-framework/policies/ ou elims-ai-framework/skills/, ou quando o usuário pedir para "sincronizar o framework com o Cursor".
disable-model-invocation: true
---

# Framework Sync

## Objetivo

Manter `ELIMS/.cursor/` (o que o Cursor efetivamente carrega) sempre gerado a partir da fonte versionada em `elims-ai-framework/`, nunca editado à mão (ver ADR-0001).

## Entradas

- Nenhuma — opera sobre o estado atual de `elims-ai-framework/policies/` e `elims-ai-framework/skills/`.

## Saídas

- `ELIMS/.cursor/rules/*.mdc` (cópia de `policies/*.md`, renomeado).
- `ELIMS/.cursor/skills/*/SKILL.md` (cópia de `skills/*/SKILL.md`).
- `ELIMS/.cursor/skills/agent-*/SKILL.md` (wrapper curto gerado a partir de `agents/*.md`).
- Relatório do que foi sincronizado/removido.

## Fluxo

1. Executar `elims-ai-framework/scripts/sync-cursor.ps1`.
2. Confirmar que cada policy tem frontmatter válido (`description`, `globs` ou `alwaysApply`) antes de copiar.
3. Confirmar que cada SKILL.md tem `name`/`description` válidos e menos de 500 linhas antes de copiar.
4. Gerar wrapper de agente: frontmatter `disable-model-invocation: true` + corpo de 1-2 linhas apontando para `elims-ai-framework/agents/<nome>.md`.
5. Reportar qualquer arquivo em `.cursor/` que não corresponde mais a uma fonte (candidato a remoção — não remove automaticamente).

## Limitações

- Não sincroniza `agents/`, `playbooks/`, `templates/`, `knowledge/` diretamente — só gera os wrappers de agente (esses conteúdos são lidos via `Read`, não via carregamento nativo do Cursor).
- Não decide conteúdo — apenas copia/gera a partir da fonte.

## Exemplos

- Após editar `policies/seguranca.md`, rodar esta skill regenera `ELIMS/.cursor/rules/seguranca.mdc` automaticamente.

## Quando usar

Após qualquer alteração em `elims-ai-framework/policies/` ou `elims-ai-framework/skills/`; pedido explícito de sincronização.

## Quando não usar

Para alterações em `agents/`, `playbooks/`, `templates/`, `knowledge/` que não geram wrapper (não é necessário sync).
