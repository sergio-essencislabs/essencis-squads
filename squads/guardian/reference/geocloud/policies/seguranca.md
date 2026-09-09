---
description: Regras de segurança obrigatórias (autenticação, autorização, tenant isolation, segredos)
globs:
alwaysApply: true
---

# Segurança

- Todo endpoint tem `[Authorize]` + `[RequiredPermission("recurso.acao")]` explícitos, **ou** `[AllowAnonymous]` com justificativa escrita no código (comentário) e registrada em `knowledge/known-issues/`. Sem exceção silenciosa.
- Toda permission key referenciada precisa existir provisionada no seed (`seed_functionality_keys.sql`) — senão o endpoint falha em runtime (500/403) mesmo com o código "correto".
- Toda query que filtra por `accountId`/`entityId` usa o valor do **token JWT** (via `ControllerBaseMiddleware`), nunca um valor recebido do corpo/query string sem validar propriedade — falha conhecida como BOLA/IDOR (já identificada em `POST /Address/add`).
- Nenhum segredo (connection string, SMTP, `TokenKey`) em texto plano em arquivo versionado. Usar variável de ambiente/`appsettings.Development.json` fora do controle de versão.
- JWT: validar issuer/audience em produção; não usar `RequireHttpsMetadata = false` fora de desenvolvimento local.

```csharp
// ❌ CRÍTICO — grava endereço sem checar dono, endpoint público
[HttpPost, Route("add"), AllowAnonymous]
public async Task<IActionResult> Add(AddressDto dto) { ... }

// ✅ BOM
[HttpPost, Route("add"), RequiredPermission("address.add")]
public async Task<IActionResult> Add(AddressDto dto) { ... EntityIdToken ... }
```

Toda mudança nesta área passa pelo Security Architect antes de merge.
