---
name: regression-analysis
description: Identifica todos os consumidores de um componente antes de uma refatoração ou correção, para garantir que nenhum comportamento existente quebre. Use antes de refatorar, corrigir bug em código compartilhado, ou alterar assinatura de método/contrato.
---

# Regression Analysis

## Objetivo

Garantir que uma mudança não quebra comportamento observável já dependido por outro código.

## Entradas

- Componente a alterar (método, classe, endpoint, componente Angular).
- Comportamento atual observável (assinatura, contrato de resposta, efeito colateral).

## Saídas

- Lista de consumidores diretos e indiretos.
- Lista de testes existentes que exercitam o comportamento atual (para rodar antes/depois).
- Sinalização de consumidores sem teste (risco de regressão silenciosa).

## Fluxo

1. Mapear consumidores diretos (quem chama o método/endpoint/componente).
2. Mapear consumidores indiretos (quem depende do consumidor direto).
3. Verificar cobertura de teste de cada consumidor.
4. Recomendar rodar a suíte de teste relevante antes e depois da mudança.

## Limitações

- Não executa a correção — apenas mapeia o risco.
- Cobertura de teste insuficiente é um achado, não um bloqueio automático (decisão fica com QA Architect/Reviewer).
- Foco em **assinatura/comportamento observável** de um componente já escolhido para mudar, executado
  imediatamente antes da implementação (refatoração/correção de bug). Para a triagem inicial mais ampla
  de contrato/schema/núcleo compartilhado entre produtos, usar `impact-analysis`.

## Exemplos

- Antes de mudar a assinatura de `IEntityRepository.GetByAccount`, listar todos os services que chamam esse método nos dois produtos (se `Entity` for núcleo compartilhado).

## Quando usar

Antes de qualquer refatoração, correção de bug em código compartilhado, ou mudança de assinatura/contrato.

## Quando não usar

Para código novo sem consumidores existentes ainda.
