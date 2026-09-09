# Research Brief — Guardian

## Fonte do conhecimento operacional

Conhecimento operacional extraído diretamente dos arquivos-fonte que hoje
vivem no material de referência interno do squad, em
`C:\Software\ClaudeCode\squads\guardian\reference\{geocloud|elims}\`
(`agents/*.md`, `policies/seguranca.md`,
`policies/qualidade.md`, `policies/documentacao.md`,
`playbooks/revisao-tecnica.md`, `playbooks/refatoracao.md`,
`playbooks/atualizacao-documental.md`) — não de pesquisa web genérica,
já que a fonte primária é mais precisa e específica ao produto.
(Material internalizado dos antigos frameworks de produto em 2026-08-28 —
o squad não depende de nenhum diretório fora de `squads/guardian/`.)

## Baseline de qualidade (aplicável a todos os agentes)

- **DRY** — procurar equivalente antes de criar qualquer classe, componente,
  migration ou documento novo.
- **KISS/YAGNI** — sem abstração sem evidência concreta de necessidade.
- **SOLID / Separation of Concerns** — cada camada com responsabilidade única.
- Toda regra de negócio nova exige teste.
- Refatoração e feature nova nunca na mesma tarefa.

## Checklist de segurança

Usado por Security Auditor (Selma Security) e Reviewer (Otávio Review):

- Autorização explícita em todo endpoint.
- Permission key provisionada no seed.
- Tenant isolation via token JWT (nunca via valor de body/query string).
- Zero segredo em texto claro versionado.
- Validação de issuer/audience JWT em produção.

## Escopo de produto

- **GeoCloudAI** — mineração/geociências.
- **E-LIMS** — gestão de laboratório.
- Ambos compartilham um núcleo de Conta/Identidade (Account, Entity, Profile,
  Functionality, User) que exige tratamento especial sempre que um achado o
  atravessa.

## Skills instaladas

- file read/write (nativo)
- code execution / grep / bash (nativo)
- gh CLI (já autenticado, scopes: `project`, `repo`, `read:org`)
