---
id: GT-0138
title: "Sinalizar campos omitidos no resumo"
status: completed
type: security
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis (modo implementação direta)"
severidade: media
produto: GeoCloudAI
camada: frontend
run_origem: 2026-09-11-095223
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/597"
grupo_execucao: onda-4-sequencial
owner: Sergio
created_at: 2026-09-11
updated_at: 2026-09-11
affected_modules: [DrillBoxChatDto, drill-box-ai-chat.component]
related_adrs: [GADR-0004]
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0138-sinalizacao-de-campos-omitidos.md"
---
# GT-0138 — sinalização de campos omitidos
## Contexto
Redação autorizada deve ser explícita, sem inferência.
## Achado original
Evidência: `DrillBoxChatDto.cs:61-90`, `ChatService.cs:554-562`, componente `:451-477` não exibem `omittedKinds`.
## Objetivo
Mapear e renderizar aviso acessível para omissões.
## Fora de escopo
Não mostrar/preencher conteúdo omitido.
## Comportamento atual
Usuário não distingue resumo redigido de completo.
## Comportamento esperado
Lista não vazia mostra aviso persistente; vazia não polui UI.
## Regras de negócio
- RN-01: aviso depende apenas de `omittedKinds`.
## Critérios de aceitação
- [ ] CA-01: omissão tem indicação inequívoca e acessível.
- [ ] CA-02: vazio não exibe aviso.
## Impacto técnico
### Backend
Contrato da GT-0126.
### Frontend
Modelo/HTML/spec.
### Banco de dados
N/A.
### Integrações
N/A.
### Segurança
Transparência sem vazamento.
## Plano de implementação
- [ ] Mapear campo, renderizar e testar os dois estados.
## Estratégia de testes
- [ ] Unitários
- [ ] Integração: N/A
- [ ] E2E
- [ ] Manual
## Riscos e rollback
Não alterar caso sem omissão.
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
