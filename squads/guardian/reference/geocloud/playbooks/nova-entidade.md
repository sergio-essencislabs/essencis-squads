---
playbook: Nova Entidade
gatilho: necessidade de um novo conceito de domínio persistido (nova classe Domain + tabela)
---

# Playbook — Nova Entidade

## Roteiro por agente

1. **Duplicate Detector** — confirmar que a entidade não existe já. Se for algo como
   "papel"/"perfil"/"endereço", provavelmente já está no núcleo de Conta/Identidade.
2. **Database Architect** — `migration.md` para criar a tabela.
3. **Backend Architect** — as quatro camadas, na ordem de dentro para fora (detalhe abaixo).
4. **Naming Validator** (skill) — nomenclatura em inglês, sufixos corretos, permission keys no padrão.
5. **Security Architect** — isolamento de tenant desde a primeira query.
6. **QA Architect** — teste unitário do service + teste de integração do repository.
7. **Documentation Architect** — entidade em `attribute-mapping.md` e `business-requirements.md`,
   e **Structural Spreadsheet Sync** (skill) para a planilha estrutural canônica.

---

## Referência canônica viva: a feature `Color`

Antes de escrever qualquer linha, leia a `Color` inteira e copie a estrutura, trocando
`Color`/`color` por `{Entity}`/`{entity}`. É a vertical mais limpa do repositório.

| Camada | Arquivo |
|---|---|
| Domain | `api/src/Back.Domain/Classes/Color.cs` |
| Persistence | `api/src/Back.Persistence/Contracts/IColorRepository.cs` · `Repositories/ColorRepository.cs` |
| Application | `api/src/Back.Application/Dtos/ColorDto.cs` · `Contracts/IColorService.cs` · `Services/ColorService.cs` |
| API | `api/src/Back.API/Controllers/ColorController.cs` |
| Frontend | `web/src/app/models/Color.ts` · `services/color.service.ts` · `pages/settings/colors/` |

## Backend — ordem obrigatória, de dentro para fora

### 1. Domain — `Back.Domain/Classes/{Entity}.cs`

POCO simples: `Id`, `AccountId`, `Account?`, os campos do negócio, `UserId`, `User?`,
`Register`. Sem atributos, sem herança, sem lógica.

### 2. Persistence — contrato + repositório

Contrato com `Add`, `Update`, `Delete(int id, int? userId)`, `Get(PageParams)`,
`GetByAccount(int, PageParams)`, `GetById(int)` e `GetByName({Entity})` para a regra de
unicidade. O repositório injeta `DbSession` e segue o `ColorRepository`:

- `OrderableColumns` — whitelist estática consumida por `SqlSort.OrderBy`. É a defesa
  contra injeção via campo de ordenação; nunca passe entrada do usuário direto.
- `Add` — `INSERT ...; SELECT LAST_INSERT_ID()` dentro de `TransactionScope`.
- `Get`/`GetByAccount` — multi-mapping Dapper com `'split' AS split` e `splitOn: "split"`,
  fechando com `PageList<{Entity}>.CreateAsync(...)`.
- Sempre parâmetros Dapper (`@Param`); nunca interpolação de string.

### 3. Application — DTO, contrato, service, AutoMapper

- DTO com DataAnnotations (`[Required]`, `[MinLength]`, `[MaxLength]`), como `ColorDto`.
- Service injeta repositório + `IMapper`, mapeia DTO↔Domain e aplica a regra de negócio
  (tipicamente nome único por conta via `GetByName`).
- Mutations devolvem `ResultService<{Entity}Dto?>` (`.Ok`/`.Fail`); queries devolvem
  `PageList<{Entity}Dto>?` ou `{Entity}Dto?`.
- `Helpers/BackProfile.cs`: `CreateMap<{Entity}, {Entity}Dto>().ReverseMap();`

### 4. API — controller

Herda `ControllerBaseMiddleware`, com `[Authorize] [ApiController] [Route("api/[controller]")]`.
Ações espelhando o `ColorController`, cada uma com `[RequiredPermission("{entity}.acao")]`,
isolamento de tenant (`AccountIdToken` vs `dto.AccountId` → `Forbid()`) e
`Response.AddPagination(...)` nas listagens.

### 5. DI — `Back.API/Startup.cs`

Sem este par a injeção falha em runtime, e o erro só aparece na primeira requisição:

```csharp
services.AddScoped<I{Entity}Repository, {Entity}Repository>();
services.AddScoped<I{Entity}Service, {Entity}Service>();
```

### 6. Permissões — senão o endpoint responde 403

`PermissionMiddleware` resolve `userprofile → profilefunctionality → functionality.key`.
Chave ausente = 403, mesmo com o código correto. Cadastre as chaves
`{entity}.add/update/delete/get/getByAccount/getById` em `functionality`
(`typeId = 2`, nome no formato `"{Entity} - Ação"`) e vincule ao perfil.

### 7. Validar

`dotnet build api/Back.sln` antes de tocar no frontend.

## Frontend

8. **Model** em `web/src/app/models/{Entity}.ts` — classe simples espelhando o DTO.
9. **Serviço** em `services/{entity}.service.ts` — `@Injectable({ providedIn: 'root' })`,
   métodos `post/put/delete/getById` com `.pipe(take(1))`, e `get/getByAccount` devolvendo
   `PaginatedResult<{Entity}[]>` a partir do header `Pagination`. URLs por
   `GlobalComponent.baseUrl`.
10. **Página** standalone reutilizando `src/app/ui` (`DataTableComponent`,
    `AppPageHeaderComponent`), `NgbModal`, ReactiveForms e `Swal`.
11. **Rota lazy** em `pages/pages.routes.ts` com `loadComponent`. Nunca import estático.
12. `cd web && npm run build`.

## Não fazer

- Criar entidade duplicando conceito já coberto pelo núcleo de Conta/Identidade.
- Pular a migration achando que "a tabela já deve existir".
- **Assumir soft-delete.** Ver a armadilha abaixo.

## Armadilhas confirmadas no código (2026-08-15)

Duas premissas antigas circulam em documentação e em SOPs herdados, e **as duas estão
erradas** para o código atual. Verificado contra o repositório e o banco vivo:

| Premissa herdada | Realidade |
|---|---|
| `INSERT ... RETURNING id` (PostgreSQL) | MySQL: `INSERT ...; SELECT LAST_INSERT_ID()` |
| Soft-delete via `deleted_at`/`deleted_by`, filtro `deleted_at IS NULL`, `ISoftDeletableEntity` | **Não existe.** 94 repositórios fazem `DELETE FROM` direto; zero usam `deleted_at`; a interface `ISoftDeletableEntity` foi removida; nenhuma coluna `deleted_at` no schema |

O que sobreviveu da camada de auditoria é apenas `register` (presente em 118 colunas) e
`userId`. Se a feature nova precisa de trilha de exclusão, isso é uma **decisão de
arquitetura a tomar** (ADR), não um padrão a seguir.
