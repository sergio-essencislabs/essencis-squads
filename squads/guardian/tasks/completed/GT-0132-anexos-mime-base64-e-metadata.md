---
id: GT-0132
title: "Endurecer MIME, Base64 e metadata de anexos"
status: completed
type: security
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis (modo implementação direta)"
severidade: alta
produto: GeoCloudAI
camada: backend
run_origem: 2026-09-11-095223
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/592"
grupo_execucao: onda-3-sequencial
owner: Sergio
created_at: 2026-09-11
updated_at: 2026-09-11
affected_modules: [ChatAttachmentValidator, ChatService]
related_adrs: [GADR-0004]
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0132-anexos-mime-base64-e-metadata.md"
---
# GT-0132 — anexos MIME, Base64 e metadata
## Contexto
Entrada multimodal precisa ser limitada antes de alocar.
## Achado original
Evidência: `ChatAttachmentValidator.cs:70-118`; `ChatService.cs:699-701` aceita MIME/nome/base64 fracos.
## Objetivo
Normalizar MIME, limitar Base64 antes de decodificar e sanear nome.
## Fora de escopo
Não amplia tipos além de JPEG/PNG.
## Comportamento atual
Carga enorme e metadata hostil passam caminho inadequado.
## Comportamento esperado
Inválidos falham cedo; válidos seguem iguais.
## Regras de negócio
- RN-01: comparação de MIME não depende de caixa.
## Critérios de aceitação
- [ ] CA-01: MIME em casing diverso é canônico.
- [ ] CA-02: Base64 gigante não é decodificado.
- [ ] CA-03: nome é limitado antes de metadata/erro.
## Impacto técnico
### Backend
Validador/DTO/serviço.
### Frontend
N/A.
### Banco de dados
N/A.
### Integrações
LLM só recebe anexo válido.
### Segurança
Evita consumo/metadata hostil.
## Plano de implementação
- [ ] Canonicalizar, limitar e testar.
## Estratégia de testes
- [ ] Unitários
- [ ] Integração
- [ ] E2E: N/A
- [ ] Manual
## Riscos e rollback
Preservar clientes válidos.
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
