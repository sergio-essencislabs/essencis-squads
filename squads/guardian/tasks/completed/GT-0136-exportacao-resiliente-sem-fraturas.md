---
id: GT-0136
title: "Exportar mesmo sem acesso a fraturas"
status: completed
type: tech-debt
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis (modo implementação direta)"
severidade: media
produto: GeoCloudAI
camada: frontend
run_origem: 2026-09-11-095223
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/595"
grupo_execucao: onda-4-paralelo
owner: Sergio
created_at: 2026-09-11
updated_at: 2026-09-11
affected_modules: [drill-box-ai-chat.component]
related_adrs: [GADR-0004]
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0136-exportacao-resiliente-sem-fraturas.md"
---
# GT-0136 — exportação resiliente sem fraturas
## Contexto
Uma seção não autorizada não deve abortar o arquivo inteiro.
## Achado original
Evidência: `drill-box-ai-chat.component.ts:365-386,516-522`; erro de fraturas aborta exportação.
## Objetivo
Recuperar localmente indisponibilidade de fraturas.
## Fora de escopo
Não mascarar erro genuíno do gerador.
## Comportamento atual
403 impede PDF/Word/Excel completos.
## Comportamento esperado
Seção é omitida/indicada, demais análise continua.
## Regras de negócio
- RN-01: nunca inventar dado indisponível.
## Critérios de aceitação
- [ ] CA-01: 403 não aborta cada formato.
- [ ] CA-02: erro real ainda aparece.
## Impacto técnico
### Backend
N/A.
### Frontend
Componente/spec/serviço.
### Banco de dados
N/A.
### Integrações
Geradores de arquivo.
### Segurança
Não contorna permissão.
## Plano de implementação
- [ ] Isolar chamada com recuperação local.
## Estratégia de testes
- [ ] Unitários
- [ ] Integração: N/A
- [ ] E2E
- [ ] Manual
## Riscos e rollback
Escopo da recuperação deve ser só fraturas.
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
Aguardando promoção — ver contraparte.
