---
name: refactoring-assistant
description: Executa uma refatoração mecânica (extrair método, mover classe, renomear com todas as referências, consolidar duplicação já identificada) de forma incremental e reversível. Use quando o Refactoring Architect já decidiu o quê refatorar e precisa da execução passo a passo.
disable-model-invocation: true
---

# Refactoring Assistant

## Objetivo

Executar a mecânica de uma refatoração já decidida, em etapas pequenas e testáveis — nunca decide *o quê* refatorar (isso é do Refactoring Architect).

## Entradas

- Refatoração decidida (ex.: "consolidar `EntityValidator` duplicado entre ELIMS").
- Mapa de consumidores (saída da skill `dependency-mapper`).

## Saídas

- Sequência de mudanças pequenas, cada uma com o teste correspondente rodado antes/depois.
- Registro do que foi movido/renomeado/consolidado para atualização de `knowledge/known-issues/`.

## Fluxo

1. Confirmar mapa de consumidores completo (não iniciar sem ele).
2. Executar a menor etapa possível (ex.: extrair método antes de mover classe).
3. Rodar teste relevante após cada etapa.
4. Só prosseguir para a próxima etapa se a anterior não introduziu regressão.

## Limitações

- Não decide prioridade ou escopo da refatoração.
- Se uma etapa quebra teste existente, para e reporta — não "força" a próxima etapa.

## Exemplos

- Renomear `EntidadeService` (legado PT) para `EntityService`: atualizar todas as referências (controller, DI, testes) em uma única etapa atômica, rodar suíte, confirmar verde.

## Quando usar

Quando uma refatoração já foi decidida e mapeada, para execução mecânica segura.

## Quando não usar

Para decidir se algo deve ser refatorado (isso é do Refactoring Architect) ou para mudanças que alteram comportamento observável (isso não é refatoração).
