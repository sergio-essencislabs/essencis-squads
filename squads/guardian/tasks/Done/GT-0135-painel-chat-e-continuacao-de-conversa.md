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
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/626"
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

## Divergência de acervo — anotada por Tomás em 12/09/2026, resolvida no mesmo dia

**Não houve trabalho sem registro. Houve registro apontando para o lugar errado.** A distinção é o
ponto desta nota, e é o que ela existe para preservar.

**1. `issue_url` apontava para a issue errada.** O campo trazia `.../issues/569`, que é a issue da
**GT-0116** ("Minimizar o chat em página cheia voltava sempre para a raiz"), não desta task.
Enquanto o campo parecesse preenchido, ninguém tinha motivo para desconfiar: uma varredura que só
conferisse "tem `issue_url`?" daria esta GT por promovida.

**2. Esta GT nunca ganhou issue própria.** O bloco de issues da épica é contínuo — #586 (GT-0126) a
#597 (GT-0138) — e nele não havia entrada para a GT-0135: de #594 (GT-0134) salta para #595
(GT-0136). Ela ficou de fora quando o lote foi criado, e o campo foi preenchido depois com um
número que não era o dela.

Mesmo assim **o trabalho foi mesclado**: commit `0bbd0691`, *"fix(chat): anexo serial, painel
separado da caixa e exportacao resiliente (GT-0134/0135/0136) (#605)"*, junto da GT-0134 (#594) e
da GT-0136 (#595), que ganharam issue própria. O par vive em `.agents/tasks/completed/` na branch
de integração. Por isso o arquivo está em `completed/`.

**Resolução (decisão do Sergio, via Vision, 12/09/2026):** criada a issue retroativa
[#626](https://github.com/Essencis-Labs/GeoCloudAI/issues/626), aberta e fechada no mesmo ato, e o
`issue_url` acima foi reapontado da #569 para ela.

As caixas de critério deste arquivo continuam `- [ ]` porque quem escreveu esta nota não
implementou a GT-0135 e não tem evidência para marcá-las. Marcá-las por dedução seria inventar
prova — e é justamente por assumir sem conferir que esta divergência existiu.

A lacuna maior de que este caso é sintoma — 31 GTs só no produto, 39 só no hub — está mapeada na
**GT-0144**.
