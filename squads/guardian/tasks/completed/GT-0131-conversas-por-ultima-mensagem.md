---
id: GT-0131
title: "Ordenar conversas pela última mensagem"
status: completed
type: tech-debt
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis (modo implementação direta)"
severidade: media
produto: GeoCloudAI
camada: backend
run_origem: 2026-09-11-095223
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/591"
grupo_execucao: onda-2-sequencial
owner: Sergio
created_at: 2026-09-11
updated_at: 2026-09-11
affected_modules: [ChatRepository, ChatService]
related_adrs: [GADR-0004]
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0131-conversas-por-ultima-mensagem.md"
---
# GT-0131 — conversas por última mensagem
## Contexto
A pilha precisa expressar atividade real.
## Achado original
Evidência: `ChatRepository.cs:142-154`; `ChatService.cs:258-259,539` usam data de criação.
## Objetivo
Ordenar pela última mensagem com desempate estável.
## Fora de escopo
Não altera escopo tenant da GT-0125.
## Comportamento atual
Conversa antiga recém-atualizada fica abaixo de conversa nova.
## Comportamento esperado
Atividade recente vem primeiro e isolamento permanece.
## Regras de negócio
- RN-01: Sem mensagem fica abaixo de atividade recente.
## Critérios de aceitação
- [ ] CA-01: ordem segue última mensagem, com desempate estável.
- [ ] CA-02: filtro por usuário/conta permanece.
## Impacto técnico
### Backend
Consulta e testes.
### Frontend
N/A.
### Banco de dados
Índice/consulta a avaliar.
### Integrações
N/A.
### Segurança
Isolamento preservado.
## Plano de implementação
- [ ] Ajustar SQL e teste com datas divergentes.
## Estratégia de testes
- [ ] Unitários
- [ ] Integração
- [ ] E2E: N/A
- [ ] Manual
## Riscos e rollback
Evitar N+1.
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
Depende de GT-0130.
## Validação
Pendente.
## Handoff
Aguardando promoção — ver contraparte.
