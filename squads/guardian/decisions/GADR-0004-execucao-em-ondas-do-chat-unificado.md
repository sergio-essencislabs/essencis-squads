---
id: GADR-0004
title: "Execução em ondas coesas da revisão do chat unificado"
status: accepted
date: 2026-09-11
deciders: ["Sergio Mendes"]
related_tasks: ["GT-0126", "GT-0127", "GT-0128", "GT-0129", "GT-0130", "GT-0131", "GT-0132", "GT-0133", "GT-0134", "GT-0135", "GT-0136", "GT-0137", "GT-0138"]
produtos_afetados: ["GeoCloudAI"]
---

# GADR-0004 — Execução em ondas coesas da revisão do chat unificado

## Contexto

A issue #582 mantém 25 achados distintos da revisão adversarial do chat unificado depois das
correções #580, #581 e #584. Há três maneiras reais de executá-los: uma task por achado, grandes
lotes por categoria, ou grupos pequenos por causa e contrato compartilhados. O dono do produto
confirmou a terceira opção em 2026-09-11. A execução usa exclusivamente a branch semanal
`feature/fix/refactor-08_09-11_09`; a LLML representa a `main` e não participa desta run.

## Decisão

Executar os 25 achados em 13 GTs coesas, organizadas em quatro ondas por risco e dependência, sem
paralelizar mudanças que compartilhem `ChatService`, `ChatRepository` ou o componente do chat da
caixa.

## Alternativas consideradas

### Alternativa A — 25 tasks e PRs isoladas

Máxima rastreabilidade e rollback independente, mas custo operacional alto e muitas revisões de
arquivos compartilhados, sobretudo `ChatService` e o componente Angular da caixa.

### Alternativa B — seis lotes por categoria

Menos cerimônia, porém PRs grandes misturam defeitos independentes e escondem regressões de
segurança em revisões extensas.

### Alternativa C — 13 tasks coesas em quatro ondas

Mantém testes, rollback e revisão pequenos, ao mesmo tempo em que agrupa apenas alterações com a
mesma causa/contrato. Foi a opção confirmada pelo usuário.

## Consequências

### Positivas

- Segurança do resumo e permissões são tratadas antes de UX.
- Mudanças no mesmo arquivo são sequenciadas, reduzindo conflito e regressão cruzada.
- Cada GT continua verificável com vermelho observado e testes focados.

### Negativas

- São necessárias treze tasks, issues e PRs, em vez de um único pacote.
- GT-0126 introduz armazenamento durável de resumo e exige migration/testes de integração.

### Riscos

- Histórico e resumo têm conteúdo sensível a permissões; todo teste deve afirmar estado persistido,
  não só status HTTP.
- Não há autorização para `main`; todo merge termina na branch semanal.

## Plano de adoção

Onda 1: GT-0126 a GT-0129. Onda 2: GT-0130, GT-0131 e GT-0137. Onda 3: GT-0132 a GT-0134.
Onda 4: GT-0135, GT-0136 e GT-0138. Cada onda só avança depois de revisão e validação consolidada
na semanal.

## Validação

Cada GT observa o defeito em vermelho antes da correção, inclui testes de estado/autorização e roda
a suíte proporcional. Após cada onda mesclada, a validação consolidada ocorre sobre o merge real da
branch semanal.

## Revisão

Revisar esta decisão após cada onda ou se uma task revelar dependência de schema/contrato não
prevista.
