---
id: GT-0109
title: "Tres modulos fora do MVP: dormentes no codigo, invisiveis na interface"
status: completed
type: chore
achado_origem: "N/A — não veio de achado de auditoria; ver Achado original"
auditor_origem: "N/A — cunhada fora de run do Guardian"
severidade: media
produto: GeoCloudAI
camada: ""
run_origem: "N/A — cunhada fora de run do Guardian"
issue_url: ""
grupo_execucao: ""
owner: sergio-essencislabs
created_at: 2026-09-10
updated_at: 2026-09-10
affected_modules: ["web/pages", "web/services"]
related_adrs: []
contraparte: "GeoCloudAI/.agents/tasks/active/GT-0109-encolher-a-superficie-do-mvp.md"
depende_de: []
---

# GT-0109 — Tres modulos fora do MVP: dormentes no codigo, invisiveis na interface

## Contexto
Este arquivo foi criado pela **GT-0147** (reconciliação do acervo, Grupo B) em 12/09/2026, a partir
do par que já existia em `GeoCloudAI/.agents/tasks/active/GT-0109-encolher-a-superficie-do-mvp.md`. A GT nasceu direto no repositório de
produto e nunca teve arquivo aqui.

O conteúdo abaixo é derivado do par. Nada foi reconstruído de memória nem inferido: o que o par não
registra, este arquivo também não registra.

## Achado original
Não houve relatório de auditoria — esta GT não veio de run do Guardian. O que o par registra como
origem, transcrito:

> decisao do dono do produto em 10/09, ao revisar o que falta para o MVP

A evidência técnica está no par, que é onde foi escrita e revisada junto do código. Duplicá-la aqui contrariaria a regra
de que os dois lados descrevem o mesmo trabalho de ângulos diferentes, nunca a mesma coisa duas
vezes.

## Objetivo
O par não traz seção `Objetivo`: foi escrito à mão, fora do molde, e nenhuma das 31 do Grupo B traz essa seção. Deduzir um objetivo a partir do título seria inventar conteúdo, e a RN-01 da GT-0147 veta isso.

O que o par traz, e onde o objetivo real está descrito: `A decisao`, `O que "dormente" significa, exatamente`, `Por que o backend fica`, `Regras de negocio`, `Critérios de aceitação`, `Registro de execução`, `Validação`.

## Fora de escopo
Reabrir o mérito técnico da GT. Este arquivo responde por que ela entrou na fila; o como fica no par.

## Registro
- Entrega: sem PR registrado no par
- Issue: sem issue registrada no par
- Estado quando reconciliada: `active`, em `active/`

---

## Reconciliacao - 21/09/2026 (GT-0156)

**Resolvido.** Commit `82cdf039` (PR #561), ancestral de origin/main do produto. Rotas removidas:
`web/src/app/pages/pages.routes.ts:328-329`. Teste versionado: `pages.routes.spec.ts` - 3 provas de
rota removida + 1 controle em /chat, confirmado por mutacao (reintroduzir a rota fez o teste
falhar). CA-01..CA-07 todos [x]. Validacao com saida real: TOTAL: 490 SUCCESS.

Nota de temporizacao: o arquivo de tarefa do produto ja foi movido para completed/ (commit
`2662a008`, 17/09), mas isso esta so na branch semanal feat/fix/refactor-14_09-18_09, ainda nao em
origin/main do produto no momento desta reconciliacao. A evidencia de codigo (commit mesclado +
teste versionado, ambos em origin/main) ja e suficiente para o veredito, independente disso.

Correcao a premissa original desta reconciliacao: o briefing citava GT-0109/GT-0110 como
"ponteiros pendurados" pela GT-0151 (produto: GT-0663 desde 2026-09-22). Verificado: nao procede -
a GT-0151 nunca cita GT-0109 nem GT-0110; os auto-ponteiros catalogados la sao outros
(GT-0049/50/51). Os dois arquivos existem no hub com nome completo e os contraparte: resolvem nos
dois sentidos hoje.

Evidencia completa no relatorio da reconciliacao GT-0156.
