---
id: ADR-0003
title: Agentes como personas de prompt, não como motor de orquestração
status: aceito
date: 2026-07-30
deciders: Chief Architect
---

## Contexto

O ambiente de execução (Cursor) não expõe uma API para o usuário definir novos "tipos" de subagente com estado/ferramentas próprias — os subagentes disponíveis (`generalPurpose`, `explore`, `shell`, etc.) são fixos. Portanto um "agente" deste framework não pode ser um componente de software executável isoladamente.

## Decisão

Os 13 agentes (`agents/*.md`) são **especificações de persona/comportamento**: missão, responsabilidades, entradas/saídas, checklist e critérios de qualidade, escritos para que qualquer sessão de IA (a conversa principal, ou um subagente `generalPurpose` com esse arquivo colado no prompt) adote esse papel de forma consistente. Cada agente tem um wrapper curto em `.cursor/skills/agent-<nome>/SKILL.md` para invocação nomeada dentro do Cursor.

## Consequências

- Nenhuma tentativa de recriar um "runtime multiagente" customizado.
- A consistência entre invocações depende da qualidade do arquivo de especificação, não de um mecanismo de estado — por isso os agentes seguem um formato rígido (Missão/Objetivo/Responsabilidades/Entradas/Saídas/Fluxo interno/Critérios/Limitações/Integrações/Checklist/Formato de resposta/Critérios de qualidade).
