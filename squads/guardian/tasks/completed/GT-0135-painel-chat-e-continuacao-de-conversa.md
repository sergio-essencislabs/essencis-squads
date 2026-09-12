---
id: GT-0135
title: "Separar painel/chat e preservar conversa na página cheia"
status: completed
type: tech-debt
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis (modo implementação direta)"
severidade: media
produto: GeoCloudAI
camada: frontend
run_origem: 2026-09-11-095223
issue_url: ""   # ver "Divergência de acervo" no fim deste arquivo — o #569 aqui anotado era da GT-0116
grupo_execucao: onda-4-sequencial
owner: Sergio
created_at: 2026-09-11
updated_at: 2026-09-11
affected_modules: [drill-box-ai-chat.component, chat-page.component]
related_adrs: [GADR-0004]
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0135-painel-chat-e-continuacao-de-conversa.md"
---
# GT-0135 — painel e continuidade de conversa
## Contexto
Navegação entre montagens deve conservar a mesma thread.
## Achado original
Evidência: componente `:203-212,223-228`, `chat-page.component.ts:53-55`, SCSS `:1-35` misturam modos.
## Objetivo
Separar painel/chat e preservar `conversationId` em página cheia.
## Fora de escopo
Não muda conteúdo de chat.
## Comportamento atual
Modo caixa herda painel e perde conversa.
## Comportamento esperado
Minimizar retorna ao host certo e full page mantém thread.
## Regras de negócio
- RN-01: decidir/documentar continuidade em refresh/deep-link.
## Critérios de aceitação
- [ ] CA-01: caixa não herda fixed/resizable.
- [ ] CA-02: minimizar e abrir página cheia preservam conversa.
## Impacto técnico
### Backend
N/A.
### Frontend
Componente, estilos, rota, specs.
### Banco de dados
N/A.
### Integrações
N/A.
### Segurança
ID validado pelo contrato existente.
## Plano de implementação
- [ ] Separar classes e transportar identidade validada.
## Estratégia de testes
- [ ] Unitários
- [ ] Integração: N/A
- [ ] E2E
- [ ] Manual
## Riscos e rollback
Não criar conversa ao navegar.
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

## Divergência de acervo — anotada por Tomás em 12/09/2026
Dois problemas encontrados ao commitar o acervo pendente do hub (Frente 3 do despacho da Vision).
Nenhum dos dois foi "consertado" por dedução; ficam registrados para a Vision decidir.

**1. `issue_url` apontava para a issue errada.** O campo trazia
`.../issues/569`, que é a issue da **GT-0116** ("Minimizar o chat em página cheia voltava sempre
para a raiz"), não desta task. O ponteiro foi esvaziado: deixar um link que leva o leitor a outra
GT é pior do que declarar que não se sabe.

**2. Esta GT parece nunca ter ganhado issue própria.** O bloco de issues da épica é contínuo —
#586 (GT-0126) a #597 (GT-0138) — e nele **não há** issue para a GT-0135: o #595 é a GT-0136 e o
#596 é a GT-0137. Uma busca por `painel continuacao conversa pagina cheia` em todos os estados
retorna só o #569.

Mesmo assim **o trabalho foi mesclado**: commit `0bbd0691`, *"fix(chat): anexo serial, painel
separado da caixa e exportacao resiliente (GT-0134/0135/0136) (#605)"*, e o par vive em
`.agents/tasks/completed/` na branch de integração. Por isso o arquivo vai para `completed/`.

Criar uma issue retroativa para trabalho já entregue é decisão da Vision, não minha — não foi
feito. As caixas de critério deste arquivo continuam `- [ ]` porque não implementei esta GT e não
tenho evidência para marcá-las; marcá-las por dedução seria inventar prova.
