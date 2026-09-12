---
id: GT-0041
title: Selo MOCK no cabeçalho do canvas também na coluna de caixas molhadas
status: completed
severidade: baixa
origem: revisão do board pelo dono do produto (CA-02 da #338)
run_origem: —
produto: GeoCloudAI
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/338"
contraparte: GeoCloudAI/.agents/tasks/completed/GT-0041-selo-mock-caixas-molhadas.md
camada: frontend
created_at: 2026-09-09
updated_at: 2026-09-09
---

# GT-0041 — Selo MOCK na coluna de caixas molhadas

## Por que isto entrou na fila

Pedido do dono do produto ao revisar o board, para fechar o CA-02 da #338. A descrição dizia que o
RQD não tinha marca de mock nem no seletor nem no cabeçalho do canvas.

## Evidência — a premissa estava invertida

Levantamento no código da branch da semana:

- RQD sinalizado no **seletor** (`component.html:166`), na **legenda HTML** (`:28`) e no
  **cabeçalho do canvas** (`component.ts:2020`, `mock: true`). Tudo entrou no commit `8371ffd6`
  (PR #421), feito pelo próprio dono do produto, e já está na `main`.
- **Caixas molhadas**: sinalizada no seletor (`:152`), mas a chamada do cabeçalho do canvas
  (`component.ts:2017`) passava seis argumentos — `mock` caía no default `false`.

A lacuna real era a inversa da descrita.

## Severidade

Baixa. Não é dado errado, é dado simulado sem aviso num dos três pontos. Importa porque esta tela
circula por captura de tela: o selo do seletor não acompanha o print, o do canvas acompanha — e o
próprio comentário do helper já dizia isso desde a GT-0039.

## Roteamento

Camada única, frontend. Um argumento e três specs.

## Resultado

Concluída. Detalhe e prova: ver a contraparte no repositório de produto.

Issue #338 **permanece aberta** aguardando confirmação do Sergio e do Matheus após teste manual.

## Não resolvido, e deliberadamente

O RQD continua sendo `Math.random()`. Esta GT sinaliza que é mock, não o torna real — não existe
dado de RQD no domínio (`DrillBox`, `DrillCore`, `DrillHoleRun` não têm o campo). Torná-lo real é
decisão de produto com mudança de schema.
