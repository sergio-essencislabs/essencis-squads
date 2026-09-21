---
id: GT-0137
title: "Rotular conversa legada pelo número da caixa"
status: completed
type: tech-debt
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis (modo implementação direta)"
severidade: baixa
produto: GeoCloudAI
camada: backend
run_origem: 2026-09-11-095223
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/596"
grupo_execucao: onda-2-sequencial
owner: Sergio
created_at: 2026-09-11
updated_at: 2026-09-11
affected_modules: [ChatRepository, drill-box-ai-chat.component]
related_adrs: [GADR-0004]
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0137-rotulo-legado-pelo-numero-da-caixa.md"
---
# GT-0137 — rótulo legado pelo número da caixa
## Contexto
Histórico deve falar o número da caixa, não ID interno.
## Achado original
Evidência: componente `:263-266`; `ChatRepository.cs:76-84` usa fallback inadequado.
## Objetivo
Resolver número real no repositório e usá-lo para legado.
## Fora de escopo
Não muda criação de conversa.
## Comportamento atual
Legado sem metadata exibe ID.
## Comportamento esperado
Número real, metadata moderna preferencial e sem N+1.
## Regras de negócio
- RN-01: metadata moderna vence fallback.
## Critérios de aceitação
- [ ] CA-01: legado mostra número real.
- [ ] CA-02: consulta não adiciona N+1.
## Impacto técnico
### Backend
Consulta/mapeamento.
### Frontend
Rótulo.
### Banco de dados
Join/lote a avaliar.
### Integrações
N/A.
### Segurança
Escopo preservado.
## Plano de implementação
- [ ] Resolver fallback no repositório e testar.
## Estratégia de testes
- [ ] Unitários
- [ ] Integração
- [ ] E2E: N/A
- [ ] Manual
## Riscos e rollback
Preservar metadata atual.
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
Depende de GT-0131.
## Validação
Pendente.
## Handoff
Aguardando promoção — ver contraparte.
