---
id: GT-0129
title: "Prompt derivado do catálogo de ferramentas concedidas"
status: completed
type: security
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis (modo implementação direta)"
severidade: media
produto: GeoCloudAI
camada: backend
run_origem: 2026-09-11-095223
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/589"
grupo_execucao: onda-1-paralelo-c
owner: Sergio
created_at: 2026-09-11
updated_at: 2026-09-11
affected_modules: [ChatService, GeoChatTools]
related_adrs: [GADR-0004]
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0129-prompt-do-catalogo-concedido.md"
---
# GT-0129 — prompt do catálogo concedido
## Contexto
O modelo só deve conhecer ferramentas já filtradas para o usuário.
## Achado original
Evidência: `ChatService.cs:15-28,790-795` mantém lista literal; `GeoChatTools.cs:127-150` já filtra catálogo.
## Objetivo
Derivar instrução do catálogo efetivamente concedido.
## Fora de escopo
Não remove revalidação em `InvokeAsync`.
## Comportamento atual
Prompt sugere ferramentas ausentes.
## Comportamento esperado
Prompt e catálogo são coerentes.
## Regras de negócio
- RN-01: `InvokeAsync` segue como defesa independente.
## Critérios de aceitação
- [ ] CA-01: prompt não cita ferramenta omitida.
- [ ] CA-02: subconjunto de permissões é coberto em teste.
## Impacto técnico
### Backend
ChatService/GeoChatTools.
### Frontend
N/A.
### Banco de dados
N/A.
### Integrações
Prompt LLM.
### Segurança
Menos tentativa indevida.
## Plano de implementação
- [ ] Formatar instrução do catálogo filtrado e testar.
## Estratégia de testes
- [ ] Unitários
- [ ] Integração
- [ ] E2E: N/A
- [ ] Manual
## Riscos e rollback
Preservar formato de tool calls.
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
