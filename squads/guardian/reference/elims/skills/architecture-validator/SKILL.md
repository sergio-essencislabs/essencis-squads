---
name: architecture-validator
description: Verifica se um código novo/alterado respeita a direção de dependência do Clean Architecture (Domain/Persistence/Application/API) e as convenções de policies/arquitetura.md. Use antes de considerar uma implementação backend concluída.
---

# Architecture Validator

## Objetivo

Detectar violação de camada (ex.: Domain referenciando Persistence, Application executando SQL direto) antes do merge.

## Entradas

- Arquivos alterados/criados na tarefa.

## Saídas

- "Conforme" ou lista de violações com arquivo:linha e a regra de `policies/arquitetura.md` violada.

## Fluxo

1. Para cada classe em `Back.Domain`, verificar que não há `using Back.Persistence`/`using MySqlConnector`/`using Dapper`.
2. Para cada classe em `Back.Application`, verificar que acesso a dados passa por uma interface `I{Nome}Repository`, nunca `IDbConnection` direto.
3. Para cada controller, verificar que não há lógica de negócio inline (mais que orquestração simples de chamada ao service).

## Limitações

- Análise estrutural/textual; não impede violação via reflection ou injeção dinâmica incomum.
- Não corrige — apenas reporta ao Backend Architect.
- Não verifica nomenclatura (isso é `naming-validator`) — foco exclusivo em direção de dependência/camada.

## Exemplos

- Encontra `Back.Domain/Classes/Entity.cs` com `using MySqlConnector;` → violação crítica (Domain não deve conhecer infraestrutura).

## Quando usar

Antes de considerar qualquer implementação backend concluída (parte do checklist do Backend Architect).

## Quando não usar

Para código puramente frontend (usar `naming-validator`/revisão manual das boas práticas de frontend).
