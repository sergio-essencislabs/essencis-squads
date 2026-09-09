---
id: ADR-0002
title: Knowledge base federada (não centralizada)
status: aceito
date: 2026-07-30
deciders: Chief Architect, Knowledge Manager
---

## Contexto

GeoCloud já mantém `api/docs/system/*` e `api/docs/implementations/*`. GeoCloud já mantém `.agents/memory/*` (60 lições atômicas + índice `MEMORY.md`) e `docs/*`. Ambos os mecanismos funcionam bem e estão ativos. Centralizar tudo em `geocloud-ai-framework/knowledge/` significaria copiar conteúdo já existente para um segundo lugar, criando exatamente o tipo de drift que a Etapa 1 de descoberta identificou como causa raiz de vários problemas (permissões inertes, `FunctionalityType` divergente, docs de teste desatualizados).

## Decisão

`geocloud-ai-framework/knowledge/` é um **índice e sintetizador cross-projeto**, não um repositório central de fatos. Ele contém:

- `domain/` — o que é genuinamente compartilhado (núcleo de Conta/Identidade, glossário PT↔EN).
- `decisions/` — ADRs do próprio framework.
- `patterns/` — lições cross-projeto (aplicam-se a GeoCloud); lições específicas de um produto continuam em `.agents/memory/` daquele produto.
- `known-issues/` — backlog de dívida técnica já identificada por evidência de código.
- `roadmap/` — visão de evolução cross-projeto.

Fatos específicos de um produto (endpoint X, tabela Y, regra de negócio Z de um domínio) permanecem documentados perto do código daquele produto.

## Consequências

- Nenhuma tarefa precisa carregar a knowledge base inteira; agentes carregam o índice do framework + os docs vivos do produto em que estão trabalhando.
- Risco aceito: uma lição pode começar "local" a um produto e depois se revelar cross-projeto — mitigado pelo playbook `atualizacao-documental.md`, que pede reclassificação quando isso é percebido.
