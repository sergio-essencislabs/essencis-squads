---
id: GT-0073
title: "Editei uma migration já aplicada, e as chaves novas não chegaram a base nenhuma"
status: completed
type: bug
achado_origem: "N/A — não veio de achado de auditoria; ver Achado original"
auditor_origem: "N/A — cunhada fora de run do Guardian"
severidade: alta
produto: GeoCloudAI
camada: ""
run_origem: "N/A — cunhada fora de run do Guardian"
issue_url: ""
grupo_execucao: ""
owner: sergio-essencislabs
created_at: 2026-09-10
updated_at: 2026-09-10
affected_modules: ["Back.Persistence", "Back.ApiTests"]
related_adrs: []
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0073-chaves-perdidas-por-migration-editada.md"
depende_de: []
---

# GT-0073 — Editei uma migration já aplicada, e as chaves novas não chegaram a base nenhuma

## Contexto
Este arquivo foi criado pela **GT-0147** (reconciliação do acervo, Grupo B) em 12/09/2026, a partir
do par que já existia em `GeoCloudAI/.agents/tasks/completed/GT-0073-chaves-perdidas-por-migration-editada.md`. A GT nasceu direto no repositório de
produto e nunca teve arquivo aqui.

O conteúdo abaixo é derivado do par. Nada foi reconstruído de memória nem inferido: o que o par não
registra, este arquivo também não registra.

## Achado original
Não houve relatório de auditoria — esta GT não veio de run do Guardian. O que o par registra como
origem, transcrito:

> conferência do catálogo depois de subir a API e ver as migrations aplicarem

A evidência técnica está no par, que é onde foi escrita e revisada junto do código. Duplicá-la aqui contrariaria a regra
de que os dois lados descrevem o mesmo trabalho de ângulos diferentes, nunca a mesma coisa duas
vezes.

## Objetivo
O par não traz seção `Objetivo`: foi escrito à mão, fora do molde, e nenhuma das 31 do Grupo B traz essa seção. Deduzir um objetivo a partir do título seria inventar conteúdo, e a RN-01 da GT-0147 veta isso.

O que o par traz, e onde o objetivo real está descrito: `O erro`, `Por que os testes não pegariam`, `A consequência`, `A rede que faltava`, `Regra derivada`.

## Fora de escopo
Reabrir o mérito técnico da GT. Este arquivo responde por que ela entrou na fila; o como fica no par.

## Registro
- Entrega: PR #497
- Issue: sem issue registrada no par
- Estado quando reconciliada: `completed`, em `completed/`
