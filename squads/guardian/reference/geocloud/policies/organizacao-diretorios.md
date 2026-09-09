---
description: Organização de diretórios consistente entre GeoCloud
globs:
alwaysApply: true
---

# Organização de Diretórios

Backend (`api/` ou `backend/`):
```
src/
  Back.Domain/Classes/
  Back.Persistence/{Repositories,Contracts}/
  Back.Application/{Services,Contracts,Dtos}/
  Back.API/{Controllers,Middlewares,Scripts}/
tests/ (ou Back.Tests/)
docs/system/
```

Frontend (`web/` ou `frontend/`):
```
src/app/
  account/ core/ layouts/ models/ pages/ services/ shared/ shared-modules/ store/ ui/
```

Nunca crie uma nova pasta de topo em `src/app/` ou `Back.*` sem verificar se o conceito já se encaixa em uma existente. Divergência entre GeoCloud nesta estrutura exige ADR do Chief Architect.
