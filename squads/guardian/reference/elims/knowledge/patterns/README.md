# Padrões e Lições Aprendidas

Lições transversais do ELIMS — as que valem para mais de uma área do produto e por
isso não pertencem a um playbook específico.

Formato: frontmatter `name`/`description` + corpo curto com o "porquê" e o "como aplicar",
no mesmo padrão atômico validado em `.agents/memory/`. Use `scripts/new-memory.ps1` para
criar uma entrada nova.

## Índice

| Padrão | Descrição |
|---|---|
| [documentacao-descreve-codigo-que-nao-existe-mais](documentacao-descreve-codigo-que-nao-existe-mais.md) | SOP e documentação envelhecem em silêncio; três premissas erradas encontradas de uma vez (PostgreSQL, `RETURNING`, soft-delete) e como evitar propagá-las. |

## Quando registrar aqui

- A lição vale para mais de um módulo ou camada.
- A lição corrige uma premissa que estava documentada errada.
- A lição custou tempo para ser descoberta e vai custar de novo se não for registrada.

Lição que só vale para um arquivo ou um endpoint específico não entra aqui — vai no
comentário do código ou no playbook que a governa.
