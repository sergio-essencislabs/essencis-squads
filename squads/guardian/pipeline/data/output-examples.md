# Output Examples — Guardian

> Nomes de ferramenta citados nos exemplos abaixo não são skills nativas — ver a
> nota de independência de `.claude`/`.cursor` em `domain-framework.md`.

Três exemplos que ilustram, em conjunto, o ciclo completo de um achado real:
detecção de segurança → criação de issue → implementação da correção via PR.

## 1. Achado de segurança (Selma Security — security-auditor)

**Cenário:** Endpoint sem controle de acesso.

```
### Achado SEC-01 — Severidade: Crítica (BOLA)
**Endpoint:** `POST /Address/add`
**Evidência:** endpoint-scanner — `[AllowAnonymous]` presente, sem justificativa escrita no código nem registro em known-issues.
**Risco:** qualquer chamador não autenticado pode criar endereço associado a `accountId` arbitrário.
**Correção esperada:** aplicar `[Authorize]` + `[RequiredPermission("address.create")]`, confirmar key provisionada no seed.
```

## 2. Criação de issue (Tomás Ticket — task-curator)

**Cenário:** Issue nova a partir do achado SEC-01.

```
**Título:** GeoCloud - Corrigir AllowAnonymous sem justificativa em POST /Address/add
**Corpo:**
### Contexto
Achado pela auditoria de segurança (Selma Security) do squad guardian.
### Achado
`[AllowAnonymous]` presente em `Controllers/AddressController.cs:47`, sem justificativa escrita, permitindo criação de endereço por chamador não autenticado.
### Severidade
Crítica (BOLA)
### Critério de aceite
Endpoint exige `[Authorize]` + `[RequiredPermission("address.create")]`; key confirmada no seed; teste de permissão cobrindo caso negado.
### Camada
Backend
**Labels:** `security`, `backend`, `geocloud`
```

## 3. Implementação via PR (Breno Backend — backend-architect)

**Cenário:** Correção do achado SEC-01.

```
Branch: `fix/address-add-authorization`
Diff: adiciona `[Authorize]` + `[RequiredPermission("address.create")]` em `AddressController.Add`; adiciona seed da key `address.create` em `PermissionSeeder.cs`; adiciona teste `AddressController_Add_Should_Deny_Without_Permission`.
PR aberto: "fix: exigir permissão explícita em POST /Address/add (SEC-01)" — descrição linka a issue criada por Tomás Ticket.
```
