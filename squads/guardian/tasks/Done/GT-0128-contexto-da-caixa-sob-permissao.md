---
id: GT-0128
title: "Contexto da caixa condicionado a drillBox.getByDrillHole"
status: completed
type: security
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis (modo implementação direta)"
severidade: alta
produto: GeoCloudAI
camada: backend
run_origem: 2026-09-11-095223
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/588"
grupo_execucao: onda-1-sequencial
owner: Sergio
created_at: 2026-09-11
updated_at: 2026-09-11
affected_modules: [DrillBoxChatContextService, ChatService]
related_adrs: [GADR-0004]
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0128-contexto-da-caixa-sob-permissao.md"
---
# GT-0128 — contexto da caixa sob permissão
## Contexto
O LLM não pode receber dados da caixa para usuário que não a lê.
## Achado original
Evidência: `DrillBoxChatContextService.cs:93-103,245-252` inclui cabeçalho/metadados/foto sem `drillBox.getByDrillHole`.
## Objetivo
Aplicar a chave antes de qualquer contexto derivado de caixa.
## Fora de escopo
Não altera filtros individuais de anotações.
## Comportamento atual
Permissão de chat pode vazar identificação/foto.
## Comportamento esperado
Sem chave, nenhum dado da caixa entra no contexto.
## Regras de negócio
- RN-01: Recusa total ou contexto totalmente redigido deve ser decidido e documentado; parcial é proibido.
## Critérios de aceitação
- [ ] CA-01: ausência de chave não inclui nenhum atributo/imagem.
- [ ] CA-02: chave presente preserva comportamento.
- [ ] CA-03: testes cobrem os dois caminhos.
## Impacto técnico
### Backend
Context service e chat service.
### Frontend
N/A.
### Banco de dados
N/A.
### Integrações
LLM recebe contexto mínimo.
### Segurança
Evita exfiltração.
## Plano de implementação
- [ ] Guardar permissão antes de montagem e testar.
## Estratégia de testes
- [ ] Unitários
- [ ] Integração
- [ ] E2E: N/A
- [ ] Manual
## Riscos e rollback
Validar perfil autorizado e negado.
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
Sequenciar com GT-0126.
## Validação
Pendente.
## Handoff
Aguardando promoção — ver contraparte no GeoCloudAI.
