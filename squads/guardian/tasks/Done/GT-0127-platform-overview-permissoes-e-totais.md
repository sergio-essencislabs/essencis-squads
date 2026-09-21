---
id: GT-0127
title: "Platform overview com permissões e totais reais"
status: completed
type: security
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis (modo implementação direta)"
severidade: alta
produto: GeoCloudAI
camada: backend
run_origem: 2026-09-11-095223
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/587"
grupo_execucao: onda-1-paralelo-b
owner: Sergio
created_at: 2026-09-11
updated_at: 2026-09-11
affected_modules: [GeoChatTools, GeoChatToolsPermissionTests]
related_adrs: [GADR-0004]
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0127-platform-overview-permissoes-e-totais.md"
---
# GT-0127 — platform overview com permissões e totais reais
## Contexto
O catálogo de plataforma precisa refletir só o domínio autorizado.
## Achado original
Evidência: `GeoChatTools.cs:88,101-109,313-338,790`; chave de caixas não corresponde à contagem e `BigPage` é tratado como total.
## Objetivo
Usar autorização correta e contagem integral por domínio.
## Fora de escopo
Não criar permissão nova.
## Comportamento atual
Resposta pode ter chave inadequada ou total de primeira página.
## Comportamento esperado
Domínios sem acesso ficam apenas em `omitted`; totais são reais.
## Regras de negócio
- RN-01: Permissão de contagem é distinta de listagem.
## Critérios de aceitação
- [ ] CA-01: `drill_boxes` usa chave correta.
- [ ] CA-02: total além de uma página é correto.
- [ ] CA-03: teste negativo detecta regressão.
## Impacto técnico
### Backend
GeoChatTools/testes.
### Frontend
N/A.
### Banco de dados
N/A.
### Integrações
N/A.
### Segurança
Evita inferência de domínio.
## Plano de implementação
- [ ] Separar permissão de catálogo da estratégia de contagem e testar.
## Estratégia de testes
- [ ] Unitários
- [ ] Integração
- [ ] E2E: N/A
- [ ] Manual
## Riscos e rollback
Formato de resposta preservado.
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
