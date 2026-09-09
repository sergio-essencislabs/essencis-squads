---
playbook: Onboarding de nova base de produto
gatilho: criação de uma nova pasta/repositório de desenvolvimento a partir de um produto já existente (cópia limpa para experimento ou fork interno)
---

# Playbook — Onboarding de Nova Base

Usado quando for necessário criar uma **cópia de trabalho** a partir de `GeoCloudAI`
ou `GeoCloudAI` (ou outro produto já atendido pelo framework), sem alterar a origem.

1. **Database Architect + Backend Architect** confirmam o commit de origem (SHA) do produto a ser usado como baseline.
2. **scripts/bootstrap-new-base.ps1** copia o código-fonte, excluindo artefatos regeneráveis: `node_modules`, `bin`, `obj`, `.angular`, `TestResults`, resultados de fuzz (`v7-results`), `.git` (histórico não é copiado — a nova base começa com git próprio).
3. Criar `BASELINE.md` na raiz da nova base registrando: produto de origem, caminho, commit SHA, data da cópia, exclusões aplicadas.
4. `git init` na nova base + commit inicial "Baseline copiado de `<produto>` @ `<sha>`".
5. Incluir o caminho da nova base em `$deployTargets` de `scripts/sync-cursor.ps1` e rodar o sync.
6. **Documentation Architect** confirma que `docs/`/`.agents/memory/` foram copiados junto (conhecimento não se perde na transição).
7. **QA Architect** tenta build (`dotnet build`, `npm install`) para confirmar que a baseline compila antes de qualquer modificação.
8. **Chief Architect** registra a criação da base como entrada em `FRAMEWORK_ROADMAP.md`/`CHANGELOG.md`.
9. A partir daqui, toda mudança na nova base segue os playbooks normais (`nova-feature.md`, `correcao-de-bug.md`, etc.).

## Não fazer

- Copiar `node_modules`/`bin`/`obj` (aumenta o tamanho sem necessidade — são regenerados por `npm install`/`dotnet build`).
- Preservar o histórico completo de git da origem sem necessidade explícita (a nova base é deliberadamente um novo começo, rastreável via `BASELINE.md`, não via histórico herdado).
- Alterar o ambiente original (`GeoCloudAI`, `GeoCloudAI`) durante este processo — é somente leitura para a origem.
- Recriar as bases experimentais descontinuadas na release 0.8.0.
