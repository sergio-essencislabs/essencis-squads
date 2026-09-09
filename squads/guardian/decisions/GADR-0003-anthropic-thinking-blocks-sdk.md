---
id: GADR-0003
title: Tratamento de blocos "thinking" do Sonnet 5 e adoção do SDK oficial Anthropic
status: accepted
date: 2026-09-02
deciders: [Sergio Mendes]
related_tasks: [GT-0012]
produtos_afetados: [GeoCloudAI]
---

# GADR-0003 — Blocos `thinking` (Sonnet 5) e SDK oficial

## Contexto
A migração do chat de IA para conta Anthropic própria + `claude-sonnet-5` + streaming SSE (issue #329, E2-08) tem duas decisões técnicas reais, já mapeadas com opções e trade-offs no próprio corpo da issue:
1. O Sonnet 5 liga *adaptive thinking* por padrão; o parser atual descarta blocos `thinking`, o que pode quebrar o loop de tool-use com HTTP 400.
2. Com conta própria, o SDK oficial `Anthropic` para .NET vira viável (antes travado pelo proxy Replit).

## Decisão
**Decidido por completo (2026-09-02)**:
- **Thinking blocks → Alternativa (a) aceita**: tratar os blocos — adicionar campos ao `LlmContentBlock`, capturar e devolver verbatim. Contrato `ILlmContentBlock` muda como consequência aceita.
- **Cliente HTTP → Alternativa (a) aceita**: SDK oficial `Anthropic` para .NET, com (b) (parser manual) como plano B explícito caso o SDK tenha alguma limitação não prevista durante a implementação — não é preciso reabrir esta decisão se isso acontecer, só cair para o plano B já registrado.

Issue #329/GT-0012 segue bloqueada externamente (credencial da conta Anthropic) — a decisão fica pronta para quando desbloquear, sem exigir nova rodada de decisão.

## Alternativas consideradas
### Thinking blocks
- **(a) Tratar blocos `thinking`** — adicionar campos ao `LlmContentBlock`, capturar e devolver verbatim. Preserva o ganho de qualidade do Sonnet 5 (motivo da migração). Custo: muda o contrato `ILlmContentBlock`.
- **(b) Enviar `thinking: {"type": "disabled"}`** — mantém contrato intacto, mas abre mão da principal melhoria do Sonnet 5.
**Recomendação:** (a) — desabilitar thinking anula o motivo da migração.

### Cliente HTTP
- **(a) SDK oficial `Anthropic` para .NET** — `client.Messages.CreateStreaming`, resolve o parsing de `thinking` nativamente, substitui ~100 linhas de acumulação manual.
- **(b) Parser manual SSE** — já especificado em detalhe no corpo da issue, mantém controle total mas replica lógica que o SDK já resolve.
**Recomendação:** (a), com (b) como plano B caso o SDK tenha alguma limitação não prevista.

## Consequências
### Positivas
Ganho de qualidade do Sonnet 5 preservado (opção a de thinking); menos código para manter (SDK oficial).
### Negativas
Mudança de contrato em `ILlmContentBlock` (efeito colateral da opção 1a).
### Riscos
`max_tokens` é teto de thinking+texto somados — sem checar `StopReason`, resposta pode ser entregue truncada em silêncio (risco já mapeado na issue).

## Plano de adoção
GT-0012 (E2-08) implementa as duas decisões juntas — está bloqueada externamente até a credencial da conta Anthropic chegar.

## Validação
Loop de tool-use com pelo menos 2 iterações não falha com 400; conversa que hoje estoura 120s completa via streaming.

## Revisão
Reavaliar se o SDK oficial cobre 100% do parsing necessário assim que a implementação começar — se não cobrir, cai para o plano B (parser manual) sem reabrir a decisão de thinking blocks.
