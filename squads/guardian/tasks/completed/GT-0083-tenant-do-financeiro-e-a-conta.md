---
id: GT-0083
title: "Módulo financeiro usava o id do usuário como chave de tenant"
status: completed
type: security
achado_origem: "N/A — não veio de achado de auditoria; ver Achado original"
auditor_origem: "N/A — cunhada fora de run do Guardian"
severidade: critica
produto: GeoCloudAI
camada: ""
run_origem: "N/A — cunhada fora de run do Guardian"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/508"
grupo_execucao: ""
owner: sergio-essencislabs
created_at: 2026-09-10
updated_at: 2026-09-10
affected_modules: ["Back.API", "Back.Persistence", "Back.ApiTests"]
related_adrs: []
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0083-tenant-do-financeiro-e-a-conta.md"
depende_de: []
---

# GT-0083 — Módulo financeiro usava o id do usuário como chave de tenant

## Contexto
Este arquivo foi criado pela **GT-0147** (reconciliação do acervo, Grupo B) em 12/09/2026, a partir
do par que já existia em `GeoCloudAI/.agents/tasks/completed/GT-0083-tenant-do-financeiro-e-a-conta.md`. A GT nasceu direto no repositório de
produto e nunca teve arquivo aqui.

O conteúdo abaixo é derivado do par. Nada foi reconstruído de memória nem inferido: o que o par não
registra, este arquivo também não registra.

## Achado original
Não houve relatório de auditoria — esta GT não veio de run do Guardian. O que o par registra como
origem, transcrito:

> leitura da propriedade Tenant do FinanceController durante a varredura de autorização da noite; confirmado com dados reais do banco de desenvolvimento

A evidência técnica está no par, que é onde foi escrita e revisada junto do código. Duplicá-la aqui contrariaria a regra
de que os dois lados descrevem o mesmo trabalho de ângulos diferentes, nunca a mesma coisa duas
vezes.

## Objetivo
O par não traz seção `Objetivo`: foi escrito à mão, fora do molde, e nenhuma das 31 do Grupo B traz essa seção. Deduzir um objetivo a partir do título seria inventar conteúdo, e a RN-01 da GT-0147 veta isso.

O que o par traz, e onde o objetivo real está descrito: `O defeito`, `Por que ninguém viu`, `O `?? 1` também saiu`, `Três defeitos de permissão no mesmo arquivo`, `O backfill: estreitamento em 4 chaves, ampliação em 2`, `O que a auditoria achou depois, e por que ela achou`, `Duas chaves feias que ficaram`, `Critérios de aceitação`, `Fora de escopo, e virou issue`, `Uma conferência que fica para o deploy`.

## Fora de escopo
Reabrir o mérito técnico da GT. Este arquivo responde por que ela entrou na fila; o como fica no par.

## Registro
- Entrega: sem PR registrado no par
- Issue: #508
- Estado quando reconciliada: `completed`, em `completed/`
