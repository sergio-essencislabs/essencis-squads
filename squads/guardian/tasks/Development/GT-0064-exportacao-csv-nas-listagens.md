---
id: GT-0064
title: "Exportação CSV nas listagens, com a importação deliberadamente fora"
status: active
type: feature
achado_origem: "N/A — não veio de achado de auditoria; ver Achado original"
auditor_origem: "N/A — cunhada fora de run do Guardian"
severidade: baixa
produto: GeoCloudAI
camada: ""
run_origem: "N/A — cunhada fora de run do Guardian"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/203"
grupo_execucao: ""
owner: matheus-essencislabs
created_at: 2026-09-09
updated_at: 2026-09-10
affected_modules: ["web"]
related_adrs: []
contraparte: "GeoCloudAI/.agents/tasks/active/GT-0064-exportacao-csv-nas-listagens.md"
depende_de: []
---

# GT-0064 — Exportação CSV nas listagens, com a importação deliberadamente fora

## Contexto
Este arquivo foi criado pela **GT-0147** (reconciliação do acervo, Grupo B) em 12/09/2026, a partir
do par que já existia em `GeoCloudAI/.agents/tasks/active/GT-0064-exportacao-csv-nas-listagens.md`. A GT nasceu direto no repositório de
produto e nunca teve arquivo aqui.

O conteúdo abaixo é derivado do par. Nada foi reconstruído de memória nem inferido: o que o par não
registra, este arquivo também não registra.

## Achado original
Não houve relatório de auditoria — esta GT não veio de run do Guardian. O que o par registra como
origem, transcrito:

> issue #203, em TO DO

A evidência técnica está no par, que é onde foi escrita e revisada junto do código. Duplicá-la aqui contrariaria a regra
de que os dois lados descrevem o mesmo trabalho de ângulos diferentes, nunca a mesma coisa duas
vezes.

## Objetivo
O par não traz seção `Objetivo`: foi escrito à mão, fora do molde, e nenhuma das 31 do Grupo B traz essa seção. Deduzir um objetivo a partir do título seria inventar conteúdo, e a RN-01 da GT-0147 veta isso.

O que o par traz, e onde o objetivo real está descrito: `Decisão de desenho`, `Regras de negócio`, `Critérios de aceitação`, `Limitação conhecida, e ela está no rótulo`, `Aguardando decisão — por isso `status: partial``.

## Fora de escopo
Reabrir o mérito técnico da GT. Este arquivo responde por que ela entrou na fila; o como fica no par.

## Registro
- Entrega: PR #484
- Issue: #203
- Estado quando reconciliada: `partial`, em `active/`

---

## Reconciliacao - 21/09/2026 (GT-0156)

**Parcialmente resolvido - permanece active, nos dois lados.**

A exportacao CSV esta feita, com prova dupla: commit 88b5ec7a (PR #484), ancestral de
origin/main. Teste versionado: app-data-table.export.spec.ts, ~20 casos, incluindo o controle
negativo do CA-02 ("NAO oferece exportacao quando nenhuma coluna alcanca valor"). CA-01..CA-04 todos
[x] do lado produto.

O que trava o fechamento nao e codigo, e decisao. A issue #203 original pedia exportacao E
importacao. Tres saidas foram propostas (recomendacao (c)+(a)), e nenhuma decisao sobre a
importacao foi registrada em lugar nenhum. Nao existe GT de importacao no acervo do produto.

Pergunta direta para o Sergio: o escopo desta GT ja era so exportacao (e importacao vira demanda
nova, separada), ou a importacao continua pendente dentro desta mesma GT? Se for a primeira leitura,
esta GT fecha hoje. Se for a segunda, ela segue aberta ate a importacao existir.

Evidencia completa no relatorio da reconciliacao GT-0156.
