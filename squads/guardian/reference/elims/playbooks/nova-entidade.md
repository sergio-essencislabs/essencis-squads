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

## Referência canônica viva — **a definir**

> **Pendência.** Este playbook foi derivado do `geocloud-ai-framework`, onde a referência
> canônica é a feature `Color`. **Essa feature é do GeoCloud, não do ELIMS** — não a use
> aqui. Falta eleger a vertical mais limpa do ELIMS e preencher a tabela abaixo.
>
> Critério para eleger: entidade simples, com as quatro camadas completas, permission keys
> cadastradas e tela funcionando. Depois de escolhida, registre-a aqui e o resto do
> playbook passa a ter uma âncora concreta.

| Camada | Arquivo |
|---|---|
| Domain | `backend/src/Back.Domain/Classes/{?}.cs` |
| Persistence | `backend/src/Back.Persistence/Contracts/I{?}Repository.cs` · `Repositories/{?}Repository.cs` |
| Application | `backend/src/Back.Application/Dtos/{?}Dto.cs` · `Contracts/I{?}Service.cs` · `Services/{?}Service.cs` |
| API | `backend/src/Back.API/Controllers/{?}Controller.cs` |
| Frontend | `frontend/src/app/models/{?}.ts` · `services/{?}.service.ts` |

A estrutura descrita abaixo vale para o ELIMS — as duas bases compartilham a mesma Clean
Architecture e o mesmo padrão Dapper. O que falta é só a entidade de exemplo.

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

`dotnet build backend/Back.sln` antes de tocar no frontend.

## Frontend

8. **Model** em `frontend/src/app/models/{Entity}.ts` — classe simples espelhando o DTO.
9. **Serviço** em `services/{entity}.service.ts` — `@Injectable({ providedIn: 'root' })`,
   métodos `post/put/delete/getById` com `.pipe(take(1))`, e `get/getByAccount` devolvendo
   `PaginatedResult<{Entity}[]>` a partir do header `Pagination`. URLs por
   `GlobalComponent.baseUrl`.
10. **Página** standalone reutilizando `src/app/ui` (`DataTableComponent`,
    `AppPageHeaderComponent`), `NgbModal`, ReactiveForms e `Swal`.
11. **Rota lazy** em `pages/pages.routes.ts` com `loadComponent`. Nunca import estático.
12. `cd frontend && npm run build`.

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
| Soft-delete via `deleted_at`/`deleted_by`, filtro `deleted_at IS NULL` | **Praticamente não existe.** Dos 57 repositórios do ELIMS, **52 fazem `DELETE FROM` direto** e apenas **1** menciona `deleted_at` — ou seja, a exceção, não a regra. Não assuma soft-delete; se a feature precisar dele, isso é um ADR a tomar |

O que sobreviveu da camada de auditoria é apenas `register` (presente em 118 colunas) e
`userId`. Se a feature nova precisa de trilha de exclusão, isso é uma **decisão de
arquitetura a tomar** (ADR), não um padrão a seguir.
