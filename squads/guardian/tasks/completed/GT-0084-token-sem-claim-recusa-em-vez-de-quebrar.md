---
id: GT-0084
title: "Token válido sem claim obrigatória: recusar com 401 em vez de quebrar com 500"
status: completed
type: security
achado_origem: "N/A — não veio de achado de auditoria; ver Achado original"
auditor_origem: "N/A — cunhada fora de run do Guardian"
severidade: media
produto: GeoCloudAI
camada: ""
run_origem: "N/A — cunhada fora de run do Guardian"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/510"
grupo_execucao: ""
owner: sergio-essencislabs
created_at: 2026-09-10
updated_at: 2026-09-10
affected_modules: ["Back.API", "Back.ApiTests"]
related_adrs: []
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0084-token-sem-claim-recusa-em-vez-de-quebrar.md"
depende_de: []
---

# GT-0084 — Token válido sem claim obrigatória: recusar com 401 em vez de quebrar com 500

## Contexto
Este arquivo foi criado pela **GT-0147** (reconciliação do acervo, Grupo B) em 12/09/2026, a partir
do par que já existia em `GeoCloudAI/.agents/tasks/completed/GT-0084-token-sem-claim-recusa-em-vez-de-quebrar.md`. A GT nasceu direto no repositório de
produto e nunca teve arquivo aqui.

O conteúdo abaixo é derivado do par. Nada foi reconstruído de memória nem inferido: o que o par não
registra, este arquivo também não registra.

## Achado original
Não houve relatório de auditoria — esta GT não veio de run do Guardian. O que o par registra como
origem, transcrito:

> achado F5 do geocloud-permission-auditor na revisão do PR #509 (GT-0083)

A evidência técnica está no par, que é onde foi escrita e revisada junto do código. Duplicá-la aqui contrariaria a regra
de que os dois lados descrevem o mesmo trabalho de ângulos diferentes, nunca a mesma coisa duas
vezes.

## Objetivo
O par não traz seção `Objetivo`: foi escrito à mão, fora do molde, e nenhuma das 31 do Grupo B traz essa seção. Deduzir um objetivo a partir do título seria inventar conteúdo, e a RN-01 da GT-0147 veta isso.

O que o par traz, e onde o objetivo real está descrito: `O defeito`, `Por que isto é achado de segurança e não de robustez`, `O que a reversão do guard mostrou, e que é a parte que eu não esperava`, `Onde a correção mora`, `Por que recusar é seguro`, `Duas fronteiras deliberadas, documentadas em teste`, `O `!` no `ControllerBaseMiddleware``, `Critérios de aceitação`.

## Fora de escopo
Reabrir o mérito técnico da GT. Este arquivo responde por que ela entrou na fila; o como fica no par.

## Registro
- Entrega: sem PR registrado no par
- Issue: #510
- Estado quando reconciliada: `completed`, em `completed/`
