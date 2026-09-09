# Roadmap do Framework

## v0.1.0 (atual) — Fundação

- Estrutura completa: agentes, skills, policies, playbooks, templates, knowledge base.
- Scaffold de `GeoCloud` e `GeoCloud`.
- Sync com `.cursor/` funcional.

## v0.2.0 (próximo) — Adoção e ajuste fino

- Rodar o framework em pelo menos 3 tarefas reais (uma por tipo: bug, feature, integração) em `GeoCloud`/`GeoCloud` e ajustar agentes/skills conforme fricção real observada.
- Popular `knowledge/known-issues/` com o backlog completo de dívida técnica já identificado (permissões inertes, `Address/add` anônimo, `FunctionalityType` divergente, ausência de ferramenta de migration real) como itens rastreáveis, com playbook de correção associado a cada um.
- Automatizar `sync-cursor.ps1` e `validate-framework.ps1` como Cursor Automation (gatilho: push em `geocloud-ai-framework`).

## v0.3.0 — Integrações

- Avaliar MCP server de MySQL para a skill `database-diff` (hoje baseada em leitura de scripts SQL).
- Formalizar o playbook `integracao-externa.md` com o caso real de e-mail (SMTP) e IA (Anthropic/OpenAI Vision).

## v1.0.0 — Framework maduro

- Todos os 13 agentes e 19 skills usados em produção por pelo menos um ciclo completo de feature.
- Zero drift entre `policies/` e `.cursor/rules/` (validado por `validate-framework.ps1` em CI).
- Parity entre GeoCloud para o núcleo compartilhado formalmente restaurada e monitorada pela skill `parity-diff`.

## Critérios de aceite para avançar de versão

Ver `MASTER_PROMPT.md` §10. Nenhuma versão avança sem `CHANGELOG.md` atualizado e sem `validate-framework.ps1` passando.

## Fora de escopo (por ora)

- Reescrever ou refatorar o código de produto durante a criação deste framework (o framework guia refatorações futuras, não as executa preventivamente).
- Migrar dados entre os bancos `geocloudai` e `geocloudai`.
- Automação de deploy/CI real (GitHub Actions) — nenhum dos produtos tem CI hoje; é uma oportunidade registrada em `knowledge/known-issues/`, não uma entrega deste framework.
