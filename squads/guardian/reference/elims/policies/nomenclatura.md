---
description: Convenções de nomenclatura (backend, frontend, banco) e mapeamento PT/EN
globs:
alwaysApply: true
---

# Nomenclatura

- Identificadores de código sempre em **inglês**, mesmo quando a UI/comentários/commits são em português.
- Backend: `{Nome}Controller`, `I{Nome}Service`/`{Nome}Service`, `I{Nome}Repository`/`{Nome}Repository`, `{Nome}Dto`. Projetos prefixados `Back.*`.
- Permission keys: `{recurso}.{acao}` em minúsculas (ex.: `entity.add`, `profileFunctionality.getById`).
- Banco: tabelas/colunas minúsculas sem aspas; FK `{entidade}id`.
- Frontend: services `{recurso}.service.ts`; componentes standalone; rotas em `kebab-case`.
- Mapeamento herdado PT→EN (não reintroduzir nomes em português no código novo):

| PT (legado) | EN (padrão atual) |
|---|---|
| Conta | Account |
| Empresa | Entity (não "Company") |
| Usuario | User |
| Perfil | Profile |
| Funcionalidade | Functionality |
| Proprietaria | Entity.OwnerAccount |

Ver `knowledge/domain/glossario.md` para a lista completa.
