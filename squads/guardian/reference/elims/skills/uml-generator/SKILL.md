---
name: uml-generator
description: Gera diagramas de classes/sequência/fluxo em Mermaid a partir do código real. Use quando o usuário pedir um diagrama, ou quando documentação de arquitetura precisar de visualização.
disable-model-invocation: true
---

# UML Generator

## Objetivo

Produzir diagramas fiéis ao código atual (nunca ao que a documentação *diz* que existe), em **Mermaid** (blocos em `uml/*.md`). Gravá-los em `Documentation/Main/uml/` (branch `main` somente). Não usar PlantUML. Não criar pasta de diagramas para outras branches.

## Entradas

- Escopo do diagrama (uma entidade, um módulo, um fluxo de negócio).
- Branch `main` — pasta `Documentation/Main/uml/`.

## Saídas

- Arquivo `.md` com fence `mermaid`, com legenda explicando o que foi omitido de propósito (ex.: vínculos de auditoria `userId → User`).

## Fluxo

1. Ler as classes/relacionamentos reais no código (não assumir a partir de nome).
2. Gerar Mermaid (flowchart de pacotes, classDiagram por domínio, sequenceDiagram dos fluxos centrais).
3. Declarar explicitamente o que foi omitido para não gerar falsa sensação de incompletude.

## Limitações

- Não gera diagrama de algo que não existe no código (planejado ≠ implementado — diferenciar sempre).
- Diagramas grandes (produto inteiro) devem ser quebrados por domínio.

## Quando usar

Pedido explícito de diagrama, ou ao documentar uma arquitetura nova/alterada.

## Quando não usar

Para descrever uma única classe isolada sem relacionamentos relevantes — texto é mais econômico.
