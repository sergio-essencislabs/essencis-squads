---
id: GT-0126
title: "Resumo durável da caixa e acesso histórico"
status: completed
type: security
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis (modo implementação direta)"
severidade: alta
produto: GeoCloudAI
camada: database + backend
run_origem: 2026-09-11-095223
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/586"
grupo_execucao: onda-1-sequencial
owner: Sergio
created_at: 2026-09-11
updated_at: 2026-09-11
affected_modules: [ChatService, ChatRepository, DrillBoxChatDto, FluentMigrator]
related_adrs: [GADR-0004]
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0126-resumo-duravel-e-acesso-historico.md"
---
# GT-0126 — resumo durável da caixa e acesso histórico
## Contexto
O planejamento aprovado agrupa a proteção do resumo da caixa em registro durável e audível.
## Achado original
Pedido do usuário: triagem/correção dos 25 achados. Evidência: `ChatService.cs:367-388,574-605`; `ChatRepository.cs:220-238` selecionam o último resumo e não guardam regra histórica completa.
## Objetivo
Registrar resumo independente da conversa; selecionar o legível de maior cobertura e, em empate, o mais recente; declarar `omittedKinds`.
## Fora de escopo
Não muda núcleo compartilhado de identidade nem cria permissão nova.
## Comportamento atual
Último registro pode vencer um mais completo e não expressa omissões.
## Comportamento esperado
Nenhuma existência/conteúdo é revelada sem união das permissões históricas exigidas.
## Regras de negócio
- RN-01: Cobertura vence; recência desempata; omissões nunca viram valores inferidos.
## Critérios de aceitação
- [ ] CA-01: migration idempotente e armazenamento durável implementados.
- [ ] CA-02: seleção/autorização por cobertura, recência e união histórica coberta por teste.
- [ ] CA-03: contrato retorna somente os tipos omitidos.
## Impacto técnico
### Backend
ChatService/ChatRepository/DTO.
### Frontend
Contrato para GT-0138.
### Banco de dados
Novo modelo/migration a decidir e registrar.
### Integrações
N/A.
### Segurança
Evita revelação parcial.
## Plano de implementação
- [ ] Definir schema e migration; migrar leitura/escrita; testar seleção e permissão.
## Estratégia de testes
- [ ] Unitários
- [ ] Integração
- [ ] E2E: N/A
- [ ] Manual
## Riscos e rollback
Schema próprio versus estrutura equivalente deve ser decidido com rollback reversível.
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
Nenhuma.
## Validação
Pendente.
## Handoff
Aguardando promoção — ver contraparte no GeoCloudAI.
