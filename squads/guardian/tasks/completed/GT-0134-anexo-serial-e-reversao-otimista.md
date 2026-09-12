---
id: GT-0134
title: "Serializar anexo e reverter turno otimista em falhas"
status: completed
type: tech-debt
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis (modo implementação direta)"
severidade: media
produto: GeoCloudAI
camada: frontend
run_origem: 2026-09-11-095223
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/594"
grupo_execucao: onda-3-frontend
owner: Sergio
created_at: 2026-09-11
updated_at: 2026-09-11
affected_modules: [drill-box-ai-chat.component]
related_adrs: [GADR-0004]
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0134-anexo-serial-e-reversao-otimista.md"
---
# GT-0134 — anexo serial e reversão otimista
## Contexto
Estado de UI não pode sobreviver a envio inválido.
## Achado original
Evidência: `drill-box-ai-chat.component.ts:307-330,405-484,487-512`; `FileReader` corre e falha deixa turno.
## Objetivo
Serializar leitura e reverter turno em erro HTTP, `success:false` ou recusa.
## Fora de escopo
Não muda MIME da GT-0132.
## Comportamento atual
Arquivo antigo pode sobrescrever novo e turno fantasma permanecer.
## Comportamento esperado
Só arquivo atual é enviado e falhas limpam estado.
## Regras de negócio
- RN-01: anexo recusado não acompanha envio posterior.
## Critérios de aceitação
- [ ] CA-01: dispatch espera leitura.
- [ ] CA-02: callback antigo não sobrescreve seleção.
- [ ] CA-03: ambos fluxos removem turno em falha.
## Impacto técnico
### Backend
N/A.
### Frontend
Componente/spec/modelo.
### Banco de dados
N/A.
### Integrações
API chat.
### Segurança
Evita reenvio involuntário.
## Plano de implementação
- [ ] Estado versionado e helper único de rollback.
## Estratégia de testes
- [ ] Unitários
- [ ] Integração: N/A
- [ ] E2E
- [ ] Manual
## Riscos e rollback
Não bloquear texto sem anexo.
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
Depende de GT-0132.
## Validação
Pendente.
## Handoff
Aguardando promoção — ver contraparte.
