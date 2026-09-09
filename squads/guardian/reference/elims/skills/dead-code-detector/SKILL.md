---
name: dead-code-detector
description: Encontra classes, métodos, colunas ou componentes sem nenhum consumidor real no código, incluindo campos JSON legados que convivem com tabelas relacionais novas. Use ao investigar dívida técnica ou antes de remover algo suspeito de estar obsoleto.
---

# Dead Code Detector

## Objetivo

Confirmar, com evidência, que um componente não é mais usado antes de propor remoção — nunca remover por suposição.

## Entradas

- Componente suspeito (classe, método, coluna, campo JSON legado, componente Angular).

## Saídas

- "Sem consumidor encontrado — candidato a remoção" com a lista de locais verificados, **ou**
- "Consumidor encontrado em `<caminho>`" — não é morto.

## Fluxo

1. Buscar todas as referências ao componente (igual à `dependency-mapper`, mas focado em confirmar ausência total).
2. Verificar casos de uso indiretos comuns no projeto: campo JSON legado (`testrequest.testsjson`, `sample.requestedtests`) que pode ainda ser lido por relatório/export mesmo sem ser mais escrito.
3. Verificar se é referenciado em teste (mesmo que não em código de produção — nesse caso, o teste também precisa ser tratado).

## Limitações

- Não encontra uso via reflection/SQL dinâmico/configuração externa.
- Nunca remove sozinho — devolve o achado ao Refactoring Architect.

## Exemplos

- Verificar se `sample.testrequestid` (marcado como legado na lição `symmetric-model`) ainda é lido por algum código antes de confirmar remoção.

## Quando usar

Investigação de dívida técnica, ou antes de qualquer remoção de coluna/classe/componente suspeito de obsolescência.

## Quando não usar

Para código recém-criado na mesma tarefa (obviamente não é morto ainda).
