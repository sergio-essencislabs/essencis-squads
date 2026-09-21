---
id: GT-0012
title: "🚫 BLOCKER — Configurar API Anthropic própria, migrar para Sonnet 5 e habilitar streaming SSE"
status: completed
type: feature
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "Alta — bloqueia o único chat de IA do produto"
produto: GeoCloudAI
camada: backend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/329"
grupo_execucao: "Fora de onda — bloqueado externamente (credencial Anthropic); entra na Onda 1 ao desbloquear"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-02
affected_modules: [chat-ia, AnthropicChatClient, ChatGuardian, GeoChatTools]
related_adrs: [GADR-0003]
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0012 — API Anthropic própria + Sonnet 5 + streaming SSE

## Par no repositório de produto

**Não há par, e ele não foi perdido.** Esta GT é de 2026-09-02; o diretório `.agents/tasks/` do
GeoCloudAI só passou a existir em 2026-09-09, no commit `8e10d774` (TASK-060). O mecanismo de
par não existia quando ela nasceu — o `contraparte:` não é ponteiro quebrado, é ausência
decidida.

**E aqui não haveria de onde derivar um par, mesmo que se quisesse:** este arquivo não cita PR
nem commit do produto. Um par escrito hoje seria conteúdo inventado — o que a RN-01 da GT-0146
veta, porque arquivo fabricado é pior que a ausência: a ausência é visível, a fabricação não.

Apurado na GT-0146 (issue #634), CA-07, em 12/09/2026.

## Contexto
O chat de IA já está implementado ponta a ponta (guia Images do DrillBox + widget global `/chat`), mas não responde porque o provedor não está configurado — `AnthropicChatClient` lança `InvalidOperationException` na primeira chamada por falta das variáveis de ambiente.

## Achado original
Corpo completo (extenso, com risco 1-11 detalhados) em https://github.com/Essencis-Labs/GeoCloudAI/issues/329. Resumo das 3 decisões já fechadas no próprio corpo da issue:
1. Conta Anthropic própria do Essencis Labs (nada de proxy Replit) — `BASE_URL` = `https://api.anthropic.com`.
2. Modelo `claude-sonnet-5`.
3. `Ai:MaxTokens` = `64000` — exige streaming.

## Objetivo
Chat responde de ponta a ponta com a conta própria, modelo novo, sem estourar timeout.

## Fora de escopo
Streaming token-a-token até o navegador (issue separada, já registrada no corpo da issue original).

## Comportamento atual
Chat não responde — `InvalidOperationException` na primeira chamada.

## Comportamento esperado
Chat responde nas duas superfícies (Images/DrillBox e widget global), sem timeout, com Sonnet 5.

## Regras de negócio
- RN-01: N/A — mudança de infraestrutura de IA, sem regra de negócio nova.

## Critérios de aceitação
*Desbloqueio*
- [ ] CA-01: Chave da conta Anthropic do Essencis Labs fornecida e label `status:blocker` removido.

*Parte 1 — credenciais*
- [ ] CA-02: Variáveis renomeadas para `ANTHROPIC_API_KEY`/`ANTHROPIC_BASE_URL`, configuradas em dev e homologação, sem segredo versionado.
- [ ] CA-03: `BASE_URL` = `https://api.anthropic.com`, sem referência remanescente ao proxy Replit.
- [ ] CA-04: Limite de gasto configurado na console Anthropic antes da liberação em homologação.
- [ ] CA-05: Chat da guia Images (DrillBox) e widget global respondem com conteúdo real.
- [ ] CA-06: Falha de configuração produz mensagem de erro clara na UI.
- [ ] CA-07: Passo a passo documentado em `docs/ai/README.md`.

*Parte 2 — Sonnet 5*
- [ ] CA-08: `Ai:Model` = `claude-sonnet-5`, `Ai:MaxTokens` = `64000` nos dois appsettings.
- [ ] CA-09: Decisão do GADR-0003 (tratar blocos `thinking`) registrada antes do início da implementação.
- [ ] CA-10: Loop de tool-use validado com ≥2 iterações, sem 400.
- [ ] CA-11: `stop_reason: "max_tokens"` tratado — sem resposta truncada em silêncio.
- [ ] CA-12: Custo re-baselinado com `count_tokens` contra `claude-sonnet-5`.

*Parte 3 — streaming*
- [ ] CA-13: Decisão SDK oficial × parser manual registrada (GADR-0003).
- [ ] CA-14: Conversa que hoje estoura 120s completa normalmente.
- [ ] CA-15: `ChatService` continua funcionando sem mudança de código.
- [ ] CA-16: Resposta final equivalente à não-streaming, incluindo caso com tool call.
- [ ] CA-17: `dotnet build Back.sln && dotnet test Back.sln` passam sem novos erros/warnings.

## Impacto técnico
### Backend
`AnthropicChatClient.cs`, `ILlmChatClient.cs` (só se GADR-0003 optar por tratar thinking), `Startup.cs` (timeout), `appsettings*.json`.
### Frontend
Nenhuma mudança — contrato de `ChatService`/Controller não muda.
### Banco de dados
N/A.
### Integrações
API Anthropic direta (`api.anthropic.com`), possivelmente SDK oficial `Anthropic` para .NET (ver GADR-0003).
### Segurança
Segredo (`ANTHROPIC_API_KEY`) fora do repositório, nunca em `appsettings*.json`.

## Plano de implementação
- [ ] **Bloqueante**: aguardar credencial da conta Anthropic.
- [ ] Renomear variáveis, apontar BASE_URL.
- [ ] Decidir e implementar GADR-0003 (thinking blocks + SDK oficial).
- [ ] Implementar streaming SSE.
- [ ] Ajustar timeout e MaxTokens.
- [ ] Re-baselinar custo.

## Estratégia de testes
- [ ] Unitários — parsing SSE, remontagem de `LlmResponse`.
- [ ] Integração — loop de tool-use com ≥2 iterações.
- [ ] Manual — conversa longa sem timeout, nas duas superfícies de chat.
- [ ] `dotnet build && dotnet test` sem regressão.

## Riscos e rollback
Ver corpo completo da issue #329 — 11 riscos detalhados (thinking blocks quebrando tool-use com 400, custo de tokenizer novo, `tool_use` fatiado, erro no meio do stream, etc.). Nenhum requer rollback de schema — é mudança de configuração + lógica de client HTTP.

## Registro de execução
### Alterações realizadas
### Arquivos principais
### Decisões
### Divergências
### Pendências
Bloqueado externamente — aguardando `ANTHROPIC_API_KEY`/confirmação de `BASE_URL`.

## Validação

## Handoff
Fora de qualquer onda até desbloquear; ao desbloquear, entra na Onda 1 (é backend puro, sem dependência com o resto do projeto frontend).

---

## Reconciliacao - 21/09/2026 (GT-0156)

**Obsoleto - cancelado por decisao do dono do produto, nao implementado.**

Anthropic foi removida por completo do produto por ordem explicita do Sergio. Decisao registrada em
`GeoCloudAI/.agents/decisions/004-openai-como-unico-provedor-de-llm.md` (`status: accepted`,
`date: 2026-09-09`, `deciders: [sergio.mendes]`, supersede `ADR-002`). Commit `f9cecc26` (2026-09-09,
GT-0040) removeu `AnthropicChatClient.cs`; nenhum arquivo-fonte Anthropic resta em `origin/main`.
Configuracao atual: `Provider: "OpenAI"`, `Model: "gpt-5.6-luna"`.

O streaming SSE (Parte 3 desta GT) foi entregue, mas contra OpenAI, nao Anthropic:
`api/src/Back.Application/Services/ChatClient.cs:380` (`ParseStreamAsync`), com 5 testes versionados
em `api/tests/Back.UnitTests/Ai/ChatClientTests.cs`. A intencao dos CA-13..CA-17 foi atendida por
outra rota - nao carimbo esses CAs como cumpridos, porque eram Anthropic-especificos.

Achado lateral, nao corrigido aqui: `squads/guardian/decisions/GADR-0003-anthropic-thinking-blocks-sdk.md`
continua `status: accepted`, decidindo sobre um SDK Anthropic que nao existe mais no codigo. Candidato a
`superseded` pela ADR-004 do produto - fica para o Sergio confirmar.

Evidencia completa no relatorio da reconciliacao GT-0156.
