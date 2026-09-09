---
name: context-builder
description: Monta o conjunto mínimo de arquivos/documentos necessários para entender uma área do código antes de trabalhar nela, priorizando índices sobre leitura exaustiva. Use ao iniciar qualquer tarefa em uma área do GeoCloud ainda não lida na sessão atual.
---

# Context Builder

## Objetivo

Reduzir tokens gastos em exploração, montando o contexto mínimo suficiente em vez de ler diretórios inteiros.

## Entradas

- Área/feature/entidade alvo da tarefa.
- Camada(s) envolvida(s). Produto: GeoCloudAI (unico atendido por este framework).

## Saídas

Lista ordenada de arquivos/documentos a ler, do mais geral ao mais específico:
1. Índice (`docs/system/README.md`, `.agents/memory/MEMORY.md`, `knowledge/` do framework se cross-projeto).
2. Doc específico da área (`endpoint-usage.md`, `attribute-mapping.md`, ou lição atômica relevante em `.agents/memory/`).
3. Código: Domain → Persistence → Application → API (só as camadas relevantes à tarefa, não todas).

## Fluxo

1. Identificar produto(s) e camada(s) envolvidas.
2. Buscar entradas de índice relevantes (não ler o índice inteiro se ele já tiver um item específico).
3. Priorizar arquivos citados nesses índices sobre busca exploratória ampla.
4. Só cair para busca ampla (`grep`/`glob` sem alvo) se os índices não cobrirem a área.

## Limitações

- Depende da qualidade dos índices existentes — se um índice estiver desatualizado, sinalizar ao Documentation Architect em vez de compensar lendo tudo.
- Não substitui a leitura do código quando a tarefa exige entender comportamento exato.

## Exemplos

- "Vou implementar um endpoint novo em Sample" → ler `docs/system/endpoint-usage.md` (seção Sample, se existir) antes de abrir `SampleController.cs`, `SampleService.cs`, etc.

## Quando usar

No início de qualquer tarefa em área não lida ainda nesta sessão.

## Quando não usar

Quando a área já foi lida nesta mesma sessão e não houve mudança - reler é desperdício de tokens.
