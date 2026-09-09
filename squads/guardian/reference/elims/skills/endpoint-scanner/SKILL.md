---
name: endpoint-scanner
description: Lista todos os endpoints de um controller ou produto com seu método HTTP, rota, atributo de autorização/permissão e status (AllowAnonymous vs. protegido). Use ao auditar segurança de um controller, ao documentar endpoints, ou ao investigar cobertura de permissão.
---

# Endpoint Scanner

## Objetivo

Dar visão completa e precisa dos endpoints reais (não da documentação, que pode estar desatualizada) para auditoria de segurança e documentação.

## Entradas

- Controller, módulo, ou produto inteiro a escanear.

## Saídas

Tabela: `Método HTTP | Rota | Controller.Action | [Authorize]/[AllowAnonymous] | [RequiredPermission] (chave) | Observação`.

## Fluxo

1. Ler cada `*Controller.cs` do escopo.
2. Extrair `[Http*]`, `[Route]`, `[Authorize]`/`[AllowAnonymous]`, `[RequiredPermission]`.
3. Marcar qualquer `[AllowAnonymous]` sem justificativa em comentário como achado a revisar.

## Limitações

- Não executa em runtime — leitura estática dos atributos. Middleware que altera comportamento dinamicamente não é capturado.
- Não decide se um `[AllowAnonymous]` é aceitável (Security Architect decide).
- Não verifica se a permission key está provisionada no seed nem classifica severidade — isso é
  `permission-matrix-auditor`, que usa esta skill como inventário de entrada.

## Exemplos

- Rodar em `AddressController` retorna a linha `POST /Address/add | [AllowAnonymous] | — | ACHADO: escrita pública sem controle`.

## Quando usar

Auditoria de segurança, documentação de `endpoint-usage.md`, ou investigação de erro 401/403/500 relacionado a permissão.

## Quando não usar

Para controllers ainda não escritos (nada para escanear).
