---
id: GT-0072
title: "Validade da senha: a configuração existia e nunca era lida"
status: completed
type: feature
achado_origem: "N/A — não veio de achado de auditoria; ver Achado original"
auditor_origem: "N/A — cunhada fora de run do Guardian"
severidade: media
produto: GeoCloudAI
camada: ""
run_origem: "N/A — cunhada fora de run do Guardian"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/209"
grupo_execucao: ""
owner: matheus-essencislabs
created_at: 2026-09-10
updated_at: 2026-09-10
affected_modules: ["Back.Application", "Back.Persistence", "Back.Domain"]
related_adrs: []
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0072-validade-da-senha-no-login.md"
depende_de: []
---

# GT-0072 — Validade da senha: a configuração existia e nunca era lida

## Contexto
Este arquivo foi criado pela **GT-0147** (reconciliação do acervo, Grupo B) em 12/09/2026, a partir
do par que já existia em `GeoCloudAI/.agents/tasks/completed/GT-0072-validade-da-senha-no-login.md`. A GT nasceu direto no repositório de
produto e nunca teve arquivo aqui.

O conteúdo abaixo é derivado do par. Nada foi reconstruído de memória nem inferido: o que o par não
registra, este arquivo também não registra.

## Achado original
Não houve relatório de auditoria — esta GT não veio de run do Guardian. O que o par registra como
origem, transcrito:

> issue #209, em TO DO. Estava travada porque ligar a política trancaria fora do sistema todo usuário antigo

A evidência técnica está no par, que é onde foi escrita e revisada junto do código. Duplicá-la aqui contrariaria a regra
de que os dois lados descrevem o mesmo trabalho de ângulos diferentes, nunca a mesma coisa duas
vezes.

## Objetivo
O par não traz seção `Objetivo`: foi escrito à mão, fora do molde, e nenhuma das 31 do Grupo B traz essa seção. Deduzir um objetivo a partir do título seria inventar conteúdo, e a RN-01 da GT-0147 veta isso.

O que o par traz, e onde o objetivo real está descrito: `Problema`, `O bloqueio, e como ele deixou de existir`, `Regras de negócio`, `Critérios de aceitação`, `O que a realidade corrigiu`, `Aguardando decisão`.

## Fora de escopo
Reabrir o mérito técnico da GT. Este arquivo responde por que ela entrou na fila; o como fica no par.

## Registro
- Entrega: PR #496
- Issue: #209
- Estado quando reconciliada: `completed`, em `completed/`
