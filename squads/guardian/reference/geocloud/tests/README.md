# Testes do Framework

O `geocloud-ai-framework` é um repositório de conhecimento/processo, não de código de produto — seus "testes" validam **integridade estrutural**, não comportamento de runtime.

| Teste | O que valida | Como rodar |
|---|---|---|
| `../scripts/validate-framework.ps1` | Frontmatter de skills/policies, tamanho de SKILL.md, seções obrigatórias dos agentes, contagem mínima de componentes | `pwsh ../scripts/validate-framework.ps1` |
| `check-links.ps1` | Todos os links markdown internos apontam para arquivos que existem | `pwsh check-links.ps1` |

Ambos devem passar antes de qualquer commit que altere `agents/`, `skills/`, `policies/`, `playbooks/`, `templates/` ou `knowledge/`.
