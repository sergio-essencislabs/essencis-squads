---
id: GT-0130
title: "Persistir conversa somente após sucesso do LLM"
status: completed
type: tech-debt
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis (modo implementação direta)"
severidade: alta
produto: GeoCloudAI
camada: backend
run_origem: 2026-09-11-095223
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/590"
grupo_execucao: onda-2-sequencial
owner: Sergio
created_at: 2026-09-11
updated_at: 2026-09-11
affected_modules: [ChatService, ChatRepository]
related_adrs: [GADR-0004]
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0130-persistencia-apos-sucesso-do-llm.md"
---
# GT-0130 — persistência após sucesso do LLM
## Contexto
Erro externo não pode criar histórico enganoso.
## Achado original
Evidência: `ChatService.cs:153-192,224-241,355-401,493-509` persiste antes da resposta.
## Objetivo
Persistir apenas após êxito do LLM em plataforma e caixa.
## Fora de escopo
`Ephemeral` segue sem conversa.
## Comportamento atual
Falha/vazio deixa conversa, mensagem ou ordem falsa.
## Comportamento esperado
Falha não grava nada; sucesso grava pergunta e assistente consistentemente.
## Regras de negócio
- RN-01: Token accounting é preservado.
## Critérios de aceitação
- [ ] CA-01: falha/vazio não persiste conversa, mensagem ou resumo.
- [ ] CA-02: sucesso persiste conjunto consistente nos dois endpoints.
## Impacto técnico
### Backend
ChatService/Repository/testes.
### Frontend
N/A.
### Banco de dados
N/A.
### Integrações
LLM.
### Segurança
N/A.
## Plano de implementação
- [ ] Montar história em memória, chamar LLM e persistir no sucesso.
## Estratégia de testes
- [ ] Unitários
- [ ] Integração
- [ ] E2E: N/A
- [ ] Manual
## Riscos e rollback
Evitar dupla gravação em retry.
## Registro de execução
### Alterações realizadas
Pendente.
### Arquivos principais
Pendente.
### Decisões
Pendente.
### Divergências
Nenhuma.
### Pendências
Depende de GT-0126.
## Validação
Pendente.
## Handoff
Aguardando promoção — ver contraparte.
