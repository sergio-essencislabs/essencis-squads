---
id: GT-0066
title: "Travessia de caminho e ausência de isolamento entre contas no sistema de arquivos"
status: completed
type: security
achado_origem: "N/A — não veio de achado de auditoria; ver Achado original"
auditor_origem: "N/A — cunhada fora de run do Guardian"
severidade: critica
produto: GeoCloudAI
camada: ""
run_origem: "N/A — cunhada fora de run do Guardian"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/295"
grupo_execucao: ""
owner: sergio-essencislabs
created_at: 2026-09-09
updated_at: 2026-09-10
affected_modules: ["Back.API", "Back.Application", "Back.Persistence"]
related_adrs: []
contraparte: "GeoCloudAI/.agents/tasks/completed/GT-0066-caminho-de-arquivo-confinado-ao-tenant.md"
depende_de: []
---

# GT-0066 — Travessia de caminho e ausência de isolamento entre contas no sistema de arquivos

## Contexto
Este arquivo foi criado pela **GT-0147** (reconciliação do acervo, Grupo B) em 12/09/2026, a partir
do par que já existia em `GeoCloudAI/.agents/tasks/completed/GT-0066-caminho-de-arquivo-confinado-ao-tenant.md`. A GT nasceu direto no repositório de
produto e nunca teve arquivo aqui.

O conteúdo abaixo é derivado do par. Nada foi reconstruído de memória nem inferido: o que o par não
registra, este arquivo também não registra.

## Achado original
Não houve relatório de auditoria — esta GT não veio de run do Guardian. O que o par registra como
origem, transcrito:

> issue #295, aberta a partir da auditoria da planilha Metodos_Back; ampliada em cinco rodadas, duas delas por auditoria do geocloud-permission-auditor sobre o próprio PR

A evidência técnica está no par, que é onde foi escrita e revisada junto do código. Duplicá-la aqui contrariaria a regra
de que os dois lados descrevem o mesmo trabalho de ângulos diferentes, nunca a mesma coisa duas
vezes.

## Objetivo
O par não traz seção `Objetivo`: foi escrito à mão, fora do molde, e nenhuma das 31 do Grupo B traz essa seção. Deduzir um objetivo a partir do título seria inventar conteúdo, e a RN-01 da GT-0147 veta isso.

O que o par traz, e onde o objetivo real está descrito: `Contexto`, `As cinco rodadas`, `O padrão dos meus erros`, `Três testes meus que passaram por acidente`, `Um defeito que os testes pegaram antes do commit`, `Um comentário que afirmava invariante falso`, `Critérios de aceitação`, `Fora de escopo, e virou issue`.

## Fora de escopo
Reabrir o mérito técnico da GT. Este arquivo responde por que ela entrou na fila; o como fica no par.

## Registro
- Entrega: PR #487
- Issue: #295
- Estado quando reconciliada: `completed`, em `completed/`
