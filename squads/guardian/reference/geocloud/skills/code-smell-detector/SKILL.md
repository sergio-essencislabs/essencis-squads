---
name: code-smell-detector
description: Identifica code smells concretos (método longo, classe com múltiplas responsabilidades, parâmetro booleano de controle de fluxo, condicional duplicada) em código C#/TypeScript alterado. Use ao revisar código antes de considerar uma tarefa concluída, especialmente em services e componentes grandes.
---

# Code Smell Detector

## Objetivo

Sinalizar problemas concretos de manutenibilidade, sem exigir reescrita — decisão de agir fica com Refactoring Architect/Reviewer.

## Entradas

- Arquivo(s) alterado(s)/criado(s).

## Saídas

Lista de achados com localização e o smell específico (não "está feio" — o padrão concreto: ex. "método com 5+ responsabilidades distintas", "8+ parâmetros", "condicional aninhada 4+ níveis").

## Fluxo

1. Ler o(s) arquivo(s) alterado(s).
2. Verificar tamanho de método/classe fora do padrão do resto do arquivo/produto.
3. Verificar duplicação de bloco condicional/lógica dentro do mesmo arquivo.
4. Verificar acoplamento excessivo (muitas dependências injetadas em um único service).

## Limitações

- Heurístico — nem todo achado exige ação; contextualizar com o padrão já existente no arquivo/produto antes de sinalizar como problema.
- Não decide prioridade de correção.

## Exemplos

- `UserService.Register` (GeoCloud) encadeando Account→Entity→Profile→User→UserProfile sem transação nem método auxiliar — sinalizado como candidato a extração de método + risco de rollback parcial (já catalogado como known-issue).

## Quando usar

Ao revisar service/componente com mais de ~80 linhas ou mais de 3 responsabilidades aparentes.

## Quando não usar

Para arquivos de configuração/DTO simples (poucos smells aplicáveis).
