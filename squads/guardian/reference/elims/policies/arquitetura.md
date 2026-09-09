---
description: Clean Architecture para o backend .NET (Domain/Persistence/Application/API) em ELIMS
globs: **/*.cs
alwaysApply: false
---

# Arquitetura Backend (Clean Architecture)

Direção de dependência obrigatória: `Back.Domain` ← `Back.Persistence` / `Back.Application` ← `Back.API`. Nunca o inverso.

- **Domain** (`Back.Domain/Classes/`): apenas classes POCO de modelo. Sem lógica de acesso a dados, sem atributos de infraestrutura.
- **Persistence** (`Back.Persistence/Repositories/`): Dapper + MySqlConnector, SQL parametrizado manual. **Nunca EF Core** — não é o padrão do projeto.
- **Application** (`Back.Application/Services/`, `Dtos/`): regra de negócio + DTOs + AutoMapper. Não acessa `MySqlConnector`/SQL diretamente.
- **API** (`Back.API/Controllers/`): HTTP, `[Authorize]`, `[RequiredPermission]`, herda `ControllerBaseMiddleware`. Sem lógica de negócio no controller.

Padrão por entidade: `{Nome}Controller` → `I{Nome}Service`/`{Nome}Service` → `I{Nome}Repository`/`{Nome}Repository` → `{Nome}` (Domain) + `{Nome}Dto`.

```csharp
// ✅ BOM — service não acessa SQL diretamente
public class EntityService : IEntityService
{
    private readonly IEntityRepository _repository;
    public async Task<EntityDto> GetByIdAsync(int id) => _mapper.Map<EntityDto>(await _repository.GetByIdAsync(id));
}

// ❌ EVITAR — SQL direto na Application
public class EntityService
{
    public async Task<Entity> GetByIdAsync(int id) => await _connection.QueryFirstAsync<Entity>("select * from entity where id=@id", new { id });
}
```

Antes de criar uma classe/serviço/repositório novo: rode a skill `duplicate-detector` — o núcleo de Conta/Identidade (`Account`, `Entity`, `Profile`, `Functionality`, `User`, etc.) já existe nos dois produtos; nunca recrie uma variação.
