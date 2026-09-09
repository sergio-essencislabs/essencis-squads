---
id: GT-0040
title: Remover o provedor Anthropic; OpenAI como único cliente de LLM
status: completed
severidade: media
origem: pedido direto do dono do produto (não veio de run de auditoria)
run_origem: —
produto: GeoCloudAI
issue: 329
contraparte: GeoCloudAI/.agents/tasks/completed/GT-0040-remover-provedor-anthropic.md
camada: backend
created_at: 2026-09-09
updated_at: 2026-09-09
---

# GT-0040 — Remover o provedor Anthropic

## Por que isto entrou na fila

Não veio de auditoria. Veio de decisão do dono do produto ao revisar o board:

> "329 - precisa ser revertida. Não precisamos de nada sobre a Anthropic, pois já temos o chat
> funcionando com API KEY OPEN AI. Após reversão e remoção de qualquer coisa sobre configuração
> com anthropic, pode jogar em DONE. NÃO ALTERAR O CHAT QUE JÁ ESTÁ FUNCIONANDO COM API KEY OPEN AI."

## Evidência

A issue #329 estava em `Development` como BLOCKER desde 03/09, esperando credencial Anthropic.
Estado real do código na branch da semana quando a decisão foi tomada:

- `appsettings.json` e `appsettings.Development.json`: `Ai:Provider = "OpenAI"`, modelo
  `gpt-5.6-luna`. O chat em produção nunca usou a Anthropic depois da migração.
- `AnthropicChatClient.cs` presente, **sem nenhum teste**: a suíte de adaptador
  (`OpenAiChatClientTests`, 37 casos) cobre só o OpenAI. Sem credencial, também não havia teste de
  integração possível.
- `AiOptions` com defaults `Anthropic` / `claude-sonnet-4-5` — apontando para um provedor que o
  produto não usava havia seis dias.

Ou seja: um adaptador que ninguém executava, que nenhum teste protegia, e cujos defaults ainda
mandavam o produto para ele se a configuração falhasse.

## Severidade

Média. Não havia falha em produção — o caminho vivo é o OpenAI. O risco era de manutenção: código
não exercitado que a suíte não protege apodrece em silêncio, e o default apontando para provedor
inexistente é uma armadilha para o dia em que a seção `Ai` sumir da configuração.

## Roteamento

Camada única, backend. A governança do `ai-chat-integration.md` (ação proibida nº 44) exige ADR
para troca de provedor — atendida pela ADR-004, que supersede a ADR-002.

## Resultado

Concluída. Detalhe da execução, decisões e prova de que o chat não foi tocado: ver a contraparte no
repositório de produto.

Issue #329 **permanece aberta** aguardando confirmação do Sergio e do Matheus após teste manual,
conforme a regra em vigor — o Guardian não fecha issue.
