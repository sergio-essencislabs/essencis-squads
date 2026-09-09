---
name: naming-validator
description: Verifica se nomes de classes, métodos, rotas, permission keys, tabelas e colunas seguem as convenções de policies/nomenclatura.md, incluindo o mapeamento PT→EN herdado. Use ao criar qualquer identificador novo.
---

# Naming Validator

## Objetivo

Evitar reintrodução de nomes em português ou fora do padrão já estabelecido (ex.: `Conta` em vez de `Account`, `Empresa` em vez de `Entity`).

## Entradas

- Nome(s) proposto(s) para o componente novo.
- Tipo do componente (classe, método, permission key, tabela/coluna, rota).

## Saídas

- "Conforme" ou "Sugerir `<nome correto>` em vez de `<nome proposto>`", com referência à regra/tabela de `policies/nomenclatura.md` e `knowledge/domain/glossario.md`.

## Fluxo

1. Verificar se o nome proposto está na tabela de mapeamento PT→EN — se sim, usar sempre o termo EN.
2. Verificar padrão de sufixo esperado por tipo (`Controller`, `Service`, `Repository`, `Dto`, `.service.ts`).
3. Verificar padrão de permission key (`{recurso}.{acao}` minúsculo).
4. Verificar padrão de tabela/coluna (minúsculas, sem aspas, FK `{entidade}id`).

## Limitações

- Cobre nomenclatura, não estrutura (uma classe bem nomeada pode ainda estar na camada errada — ver `architecture-validator`).

## Exemplos

- Proposta: classe `Proprietaria` → sugerir `Entity.OwnerAccount` (mapeamento já documentado).
- Proposta: permission key `Entity.Add` → sugerir `entity.add` (minúsculo).

## Quando usar

Ao criar qualquer classe, método, rota, permission key, tabela ou coluna nova.

## Quando não usar

Para nomes de variáveis locais triviais sem significado de domínio.
