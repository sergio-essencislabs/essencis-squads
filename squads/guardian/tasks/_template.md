---
id: GT-0000
title:
status: backlog            # espelha a pasta: backlog | active | completed
type: tech-debt | security | documentation | feature
achado_origem: ""          # TD-NN / SEC-NN / DOC-NN, ou "N/A — pedido direto de implementação"
auditor_origem: ""         # Dante Débito / Selma Segurança / Marta Manual / Jarvis (modo implementação direta)
severidade: ""             # herdada do achado original — nunca rebaixada em silêncio
produto: ""                # GeoCloudAI | ELIMS | Ambos
camada: ""                 # backend | frontend | database | documentacao | cross-cutting — preenchido por Jarvis no roteamento (Step 09)
run_origem: ""             # run_id da execução que originou esta task
issue_url: ""              # preenchido só quando a issue é criada (Step 10) — sinal de "promovida"
grupo_execucao: ""         # preenchido por Jarvis: id do grupo de dispatch (paralelo ou sequencial)
owner: ""
created_at:
updated_at:
affected_modules: []
related_adrs: []
contraparte: ""            # caminho do par no repositório de produto, em caminho RELATIVO
                           # (ex.: GeoCloudAI/.agents/tasks/active/GT-NNNN-slug.md) — nunca C:/...
                           # Todo GT nasce em par (.agents/tasks/README.md, linhas 19 e 27):
                           # este campo é o ponteiro, e o par aponta de volta para cá.
                           #
                           # QUANDO NÃO HÁ PAR, use "N/A — <motivo curto>", nunca "" nem —.
                           #   contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia"
                           # Por quê: "" é o valor de campo AINDA NÃO PREENCHIDO, e é o que este
                           # molde entrega. Usar "" para "não há par" torna as duas coisas
                           # indistinguíveis por varredura — foi exatamente o que aconteceu com
                           # `issue_url: ""`, que hoje tem 10 ocorrências sem que se possa dizer
                           # quais nunca tiveram issue e quais têm e não registraram.
                           # "N/A — motivo" é a forma já usada em achado_origem, auditor_origem e
                           # run_origem: diz que a ausência foi decidida, e diz por quê, sem
                           # obrigar a abrir o corpo. A justificativa longa vai no corpo.
                           #
                           # Varredura de ponteiro deve PULAR valores que começam com "N/A" —
                           # eles não são caminho e não devem contar como quebrados.
depende_de: []             # LISTA, sempre — [] quando não depende de nada, ["GT-0139"] quando
                           # depende. Prosa aqui quebra quem lê o campo para montar grafo.
---

# GT-0000 — Título

## Contexto
Por que este achado/pedido importa (herdado do relatório do auditor de origem, ou do pedido do usuário em modo implementação direta).

## Achado original
Evidência arquivo:linha completa, copiada com fidelidade do relatório de auditoria — nunca resumida a ponto de perder a evidência. Em modo implementação direta: o pedido original do usuário, transcrito com fidelidade.

## Objetivo
O que precisa ser verdade depois da correção/implementação.

## Fora de escopo
O que esta task não cobre (evita scope creep durante a implementação).

## Comportamento atual
## Comportamento esperado

## Regras de negócio
- RN-01: ou "N/A — achado técnico/segurança, sem regra de negócio nova" (nunca omitir a seção em silêncio)

## Critérios de aceitação
- [ ] CA-01: (herdado do "Critério de aceite"/"Correção esperada" do relatório original, ou definido por Jarvis no planejamento em modo implementação direta)

## Impacto técnico
### Backend
### Frontend
### Banco de dados
### Integrações
### Segurança

## Plano de implementação
- [ ] Etapa 1

## Estratégia de testes
- [ ] Unitários
- [ ] Integração
- [ ] E2E
- [ ] Manual

## Riscos e rollback

## Registro de execução
### Alterações realizadas
### Arquivos principais
### Decisões
### Divergências
### Pendências

## Validação
Comandos e resultados reais — nunca uma caixa marcada sem evidência ao lado.

## Handoff
Se a run pausou no Gate de Promoção (Step 08), nota aqui: "Aguardando promoção — ver squads/guardian/tasks/backlog/".
