---
playbook: Novo Endpoint
gatilho: necessidade de uma nova rota HTTP em um controller (existente ou novo)
---

# Playbook — Novo Endpoint

1. **Duplicate Detector** — confirmar que não existe endpoint equivalente (mesmo produto e produto irmão, se envolver núcleo compartilhado).
2. **Backend Architect** define a permission key (`{recurso}.{acao}`) — se nova, coordenar com Security Architect para adicionar ao seed correspondente.
3. Implementar seguindo o padrão de 4 camadas (`policies/arquitetura.md`): Domain (se entidade nova) → Repository → Service/DTO → Controller com `[Authorize]` + `[RequiredPermission]`.
4. **Isolamento de tenant**: toda query usa `accountId`/`entityId` do token (`ControllerBaseMiddleware`), nunca valor do payload sem validar propriedade.
5. **Endpoint Scanner** (skill) — confirmar que o endpoint aparece corretamente classificado (não `[AllowAnonymous]` por acidente).
6. **Permission Matrix Auditor** (skill) — confirmar chave provisionada no seed.
7. **QA Architect** — fuzz runner para a permission key (padrão `Back.ApiTests`).
8. **Documentation Architect** — atualizar `docs/system/endpoint-usage.md` e `permission-rules.md`, e rodar **Structural Spreadsheet Sync** (skill) para atualizar a aba `Permissões`/`Metodos_Back` da planilha estrutural canônica.
9. Se o frontend consome o endpoint, acionar `nova-tela.md`/Frontend Architect com o contrato definitivo.

## Não fazer

- Criar endpoint sem `[RequiredPermission]` "temporariamente" — não existe endpoint temporário sem controle de acesso.
- Reaproveitar uma permission key de outro recurso "porque é parecida".
