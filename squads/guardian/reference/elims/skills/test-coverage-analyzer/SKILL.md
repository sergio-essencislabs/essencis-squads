---
name: test-coverage-analyzer
description: Avalia se uma área de código alterada tem cobertura de teste real (unitário, integração ou fuzz de permissão), comparando com o padrão já estabelecido no produto. Use ao final de qualquer implementação de regra de negócio ou permissão, antes da revisão final.
---

# Test Coverage Analyzer

## Objetivo

Confirmar cobertura real (não presumida) da área alterada, seguindo os padrões já estabelecidos (`Back.UnitTests`, `Back.IntegrationTests`/`Back.Tests`, `Back.ApiTests` de fuzz).

## Entradas

- Área/classe/endpoint alterado.

## Saídas

- Lista de testes existentes que cobrem a área, com o tipo (unitário/integração/fuzz).
- Lacunas identificadas (ex.: regra de negócio nova sem teste; permission key nova sem fuzz runner).

## Fluxo

1. Buscar testes que referenciam a classe/endpoint alterado.
2. Classificar por tipo (unitário/integração/fuzz).
3. Comparar com o padrão esperado por tipo de mudança (`policies/testes.md`): transição de status → matriz válido/inválido/idempotente; permissão → fuzz runner.
4. Reportar lacuna concreta, não "cobertura baixa" genérica.

## Limitações

- Não gera o teste (isso é do QA Architect) — apenas identifica a lacuna.
- Métrica de cobertura de linha não é o foco; o foco é cobertura de *caso* (válido/inválido/idempotente/permissão).

## Exemplos

- `AnalysisRequest` tem `StatusTransitionServiceTests` cobrindo transições, mas nenhuma permission key nova de `AnalysisRequestController` tem fuzz runner → lacuna reportada.

## Quando usar

Ao final de implementação de regra de negócio, transição de status ou permissão, antes da revisão final.

## Quando não usar

Para código sem regra de negócio (ex.: DTO puro sem lógica).
