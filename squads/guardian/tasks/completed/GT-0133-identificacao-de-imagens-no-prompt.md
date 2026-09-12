---
id: GT-0133
title: "Identificar cada imagem no prompt multimodal"
status: completed
type: tech-debt
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis (modo implementação direta)"
severidade: media
produto: GeoCloudAI
camada: backend
run_origem: 2026-09-11-095223
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/593"
grupo_execucao: onda-3-sequencial
owner: Sergio
created_at: 2026-09-11
updated_at: 2026-09-11
affected_modules: [ChatService]
related_adrs: [GADR-0004]
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0133-identificacao-de-imagens-no-prompt.md"
---
# GT-0133 — identificação de imagens no prompt
## Contexto
Imagem precisa ter proveniência compreensível para o modelo.
## Achado original
Evidência: `ChatService.cs:476-490` monta blocos sem rótulo individual.
## Objetivo
Rotular e ordenar foto da caixa e anexos do usuário.
## Fora de escopo
Não altera validação.
## Comportamento atual
Múltiplas imagens são ambíguas.
## Comportamento esperado
Cada bloco tem origem/ordinal e o texto permanece associado.
## Regras de negócio
- RN-01: Foto do testemunho é distinta de anexo do usuário.
## Critérios de aceitação
- [ ] CA-01: sequência contém rótulo inequívoco por imagem.
## Impacto técnico
### Backend
ChatService.
### Frontend
N/A.
### Banco de dados
N/A.
### Integrações
Prompt LLM.
### Segurança
N/A.
## Plano de implementação
- [ ] Inserir textos rotulados e testar sequência.
## Estratégia de testes
- [ ] Unitários
- [ ] Integração: N/A
- [ ] E2E: N/A
- [ ] Manual
## Riscos e rollback
Preservar formato do provedor.
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
