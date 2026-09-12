---
id: GT-0086
title: "Convidar usuário respondia 500, e convite expirado era aceito"
status: completed
type: bug
achado_origem: "N/A — não veio de achado de auditoria; ver Achado original"
auditor_origem: "N/A — cunhada fora de run do Guardian"
severidade: alta
produto: GeoCloudAI
camada: ""
run_origem: "N/A — cunhada fora de run do Guardian"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/515"
grupo_execucao: ""
owner: sergio-essencislabs
created_at: 2026-09-10
updated_at: 2026-09-10
affected_modules: ["Back.Application", "Back.Persistence", "Back.ApiTests"]
related_adrs: []
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0086-convite-de-usuario-quebrado-por-fuso.md"
depende_de: []
---

# GT-0086 — Convidar usuário respondia 500, e convite expirado era aceito

## Contexto
Este arquivo foi criado pela **GT-0147** (reconciliação do acervo, Grupo B) em 12/09/2026, a partir
do par que já existia em `GeoCloudAI/.agents/tasks/completed/GT-0086-convite-de-usuario-quebrado-por-fuso.md`. A GT nasceu direto no repositório de
produto e nunca teve arquivo aqui.

O conteúdo abaixo é derivado do par. Nada foi reconstruído de memória nem inferido: o que o par não
registra, este arquivo também não registra.

## Achado original
Não houve relatório de auditoria — esta GT não veio de run do Guardian. O que o par registra como
origem, transcrito:

> varredura de DateTime.Today|Now feita depois de o mesmo defeito derrubar três caminhos do módulo financeiro na GT-0083

A evidência técnica está no par, que é onde foi escrita e revisada junto do código. Duplicá-la aqui contrariaria a regra
de que os dois lados descrevem o mesmo trabalho de ângulos diferentes, nunca a mesma coisa duas
vezes.

## Objetivo
O par não traz seção `Objetivo`: foi escrito à mão, fora do molde, e nenhuma das 31 do Grupo B traz essa seção. Deduzir um objetivo a partir do título seria inventar conteúdo, e a RN-01 da GT-0147 veta isso.

O que o par traz, e onde o objetivo real está descrito: `Como isto apareceu: a pergunta, não o relato`, `Os dois defeitos, e o segundo é o pior`, `Mais um, do mesmo fuso`, `O que os testes afirmam`, `Uma ressalva escrita no próprio teste`, `Um erro meu no caminho`, `Critérios de aceitação`.

## Fora de escopo
Reabrir o mérito técnico da GT. Este arquivo responde por que ela entrou na fila; o como fica no par.

## Registro
- Entrega: sem PR registrado no par
- Issue: #515
- Estado quando reconciliada: `completed`, em `completed/`
