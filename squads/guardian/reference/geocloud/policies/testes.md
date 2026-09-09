---
description: Convenções de teste (xUnit backend, Karma frontend) e fuzz de permissão
globs: **/*Tests.cs, **/*.spec.ts
alwaysApply: false
---

# Testes

- Unitário: xUnit + FluentAssertions + NSubstitute. Testa regra de negócio isolada, sem banco.
- Integração: MySQL real efêmero (`MySQLTestDatabase`), **nunca mock de banco** — Docker/Testcontainers não são usados neste ambiente (restrição conhecida do Replit).
- Fuzz de permissão: toda `[RequiredPermission]` nova ou alterada precisa de um fuzz runner (padrão de `Back.ApiTests` do GeoCloud) antes de ser considerada segura.
- Transição de status: matriz válido/inválido/idempotente (padrão de `StatusTransitionServiceTests`).
- `docs/testing.md` do produto reflete a suíte real (números reais, não aspiracionais) — atualizar a cada mudança relevante de teste.

```csharp
// ✅ BOM — integração com banco real efêmero
public class UserRepositoryTests : IClassFixture<MySQLTestDatabase> { ... }

// ❌ EVITAR — mock de banco em teste de integração
var mockConnection = Substitute.For<IDbConnection>();
```
