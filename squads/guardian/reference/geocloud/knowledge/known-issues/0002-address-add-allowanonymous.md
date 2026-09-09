---
id: KI-0002
title: "POST /Address/add público (BOLA herdado do GeoCloud)"
severidade: crítica
status: aberta
produto: GeoCloud + GeoCloud
---

## Descrição

`AddressController.Add` tem `[AllowAnonymous]` no método apesar da classe ter `[Authorize]` — permite escrita pública sem autenticação, herdado do GeoCloud e replicado.

## Evidência

```25:28:C:\Software\GeoCloud\GeoCloudAI\api\src\Back.API\Controllers\AddressController.cs
[HttpPost]
[Route("add")]
[AllowAnonymous]
public async Task<IActionResult> Add(AddressDto addressDto)
```

## Ação recomendada

`playbooks/novo-endpoint.md` (revisão) — remover `[AllowAnonymous]`, adicionar `[RequiredPermission("address.add")]`, validar isolamento de tenant.

## Dono

Security Architect + Backend Architect.
