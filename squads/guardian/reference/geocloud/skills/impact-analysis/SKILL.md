---
name: impact-analysis
description: Mapeia todos os consumidores e efeitos colaterais de uma mudança proposta (entidade, endpoint, DTO, permissão) antes da implementação em GeoCloud. Use antes de alterar qualquer contrato, entidade de domínio, permission key ou schema de banco.
---

# Impact Analysis

## Objetivo

Responder, com evidência de código, "o que quebra se eu mudar X?" antes de qualquer implementação.

## Entradas

- Nome do componente a alterar (classe, DTO, endpoint, coluna, permission key).
- Camada(s) atingida(s). Produto: GeoCloudAI (unico atendido por este framework).

## Saídas

Lista de:
- Arquivos que referenciam o componente (controller, service, repository, DTO, componente Angular, script SQL).
- Se o componente pertence ao núcleo compartilhado (16 classes de Conta/Identidade) — nesse caso, marcar ambos os produtos.
- Testes existentes que cobrem o componente.

## Fluxo

1. `grep`/busca pelo nome exato da classe/coluna/permission key em todas as camadas do produto.
2. Se o nome corresponde a uma das 16 classes do núcleo compartilhado, repetir a busca no produto irmão.
3. Listar cada arquivo encontrado com o tipo de referência (leitura, escrita, contrato).
4. Verificar se existe teste cobrindo o componente (senão, sinalizar como risco).

## Limitações

- Não decide se a mudança deve ser feita — apenas informa o impacto (decisão é do agente que invocou).
- Busca textual/estrutural, não análise semântica profunda de runtime.
- Foco em **contrato/schema/núcleo compartilhado** (existe algo assim? afeta os dois produtos?), usado
  na fase de *triagem*, antes de decidir como implementar. Para o mapeamento de consumidores de
  comportamento/assinatura imediatamente antes de alterar o código (refatoração, correção de bug), usar
  `regression-analysis`, que é mais tático e específico da mudança já decidida.

## Exemplos

- Uso: "vou adicionar um campo em `EntityDto`" → lista todos os métodos que constroem/consomem `EntityDto` nos dois produtos (se `Entity` for núcleo compartilhado) e sinaliza o risco documentado de `AutoMapper.ReverseMap` descartar campos ausentes silenciosamente.

## Quando usar

Antes de qualquer alteração em entidade de domínio, DTO, permission key, coluna de banco ou contrato de endpoint.

## Quando não usar

Para mudanças puramente de estilo/formatação sem efeito em contrato (não há impacto a mapear).
