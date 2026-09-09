---
execution: subagent
agent: data-analyst
inputFile: squads/reporter/output/research-brief.md
outputFile: squads/reporter/output/planilha-concorrentes.md
model_tier: fast
---

# Step 04: Estruturação dos Achados

## Context Loading

Load these files before executing:
- `squads/reporter/output/research-brief.md` — achados brutos
  de Rita Radar (concorrente/tema, confiança, fontes, relevância inicial)
  que serão estruturados em tabela.
- `squads/reporter/agents/data-analyst.agent.md` — persona de
  Diego Dados: nunca números sem interpretação, sempre contexto de
  relevância competitiva.
- `squads/reporter/agents/data-analyst/tasks/estruturar-achados.md`
  — processo operacional de extração de campos e atribuição de relevância.
- `product-capabilities.md` relevante(s) do(s) produto(s) em foco (referência
  usada para avaliar relevância competitiva — nunca material de marketing).

## Instructions

### Process

1. Ler o research brief de Rita Radar e o(s) `product-capabilities.md`
   relevante(s) para o(s) produto(s) em foco.
2. Para cada achado do brief, extrair: concorrente/tema, novidade (1 frase),
   data, fonte (URL), categoria (produto/mercado/financeiro/parceria/outro).
3. Adicionar uma coluna de relevância competitiva para cada linha: comparar
   a novidade contra uma capacidade real do GeoCloudAI/E-LIMS usando
   `product-capabilities.md` como única referência — nunca material de
   marketing ou suposição.
4. Nunca inventar categoria ou relevância sem base no achado original — se
   não for possível avaliar relevância de forma honesta, marcar
   explicitamente "sem comparação direta" em vez de forçar uma comparação.
5. Consolidar tudo em uma única tabela Markdown no `outputFile`, agrupada
   por concorrente/tema e ordenada por confiança (alta primeiro, depois
   média, depois baixa).
6. Sinalizar visualmente qualquer achado de confiança baixa (ex.: nota ou
   marcação na própria linha) — nunca misturá-lo com achados de alta
   confiança sem essa marcação.

## Output Format

```markdown
# Planilha de Concorrentes — {período coberto}

| Concorrente | Novidade | Data | Fonte | Categoria | Confiança | Relevância vs. nosso produto |
|---|---|---|---|---|---|---|
| {concorrente/tema} | {1 frase} | {AAAA-MM-DD} | {URL} | {Produto/Mercado/Financeiro/Parceria/Outro} | {Alta/Média/Baixa} | {comparação com product-capabilities.md ou "sem comparação direta"} |
```

## Output Example

```markdown
# Planilha de Concorrentes — semana de 2026-08-17 a 2026-08-23

| Concorrente | Novidade | Data | Fonte | Categoria | Confiança | Relevância vs. nosso produto |
|---|---|---|---|---|---|---|
| Seequent | Lançou módulo de modelagem implícita com IA | 2026-08-15 | seequent.com/news/... | Produto | Alta | GeoCloudAI tem modelagem implícita (mód. 17) mas sem IA nessa etapa — GeoMind atua só em chat/análise de caixa |
| KoBold Metals | Rodada de investimento de US$XXXM | 2026-08-10 | crunchbase.com/... | Financeiro | Alta | Sem comparação direta — não é capacidade de produto |
| Micromine | Estaria testando integração com XRF portátil (não confirmado) | 2026-08-10 | fórum especializado (sem link oficial) | Produto | Baixa (sinal fraco, fonte única) | Sem comparação direta — rumor não confirmado por fonte oficial |
```

## Veto Conditions
Reject and redo if ANY of these are true:
- Alguma linha foi apresentada sem nota de relevância (nem mesmo "sem
  comparação direta").
- A relevância competitiva de alguma linha foi inflada além do que o
  achado original sustenta.
- A marcação de confiança baixa herdada da pesquisa foi omitida ou
  misturada sem distinção visual com achados de alta confiança.

## Quality Criteria
- [ ] Toda linha tem as 7 colunas preenchidas, incluindo relevância.
- [ ] Tabela Markdown tem contagem de colunas consistente em todas as linhas.
- [ ] Nenhuma relevância competitiva citada sem base em product-capabilities.md.
- [ ] Tabela está ordenada por confiança (alta primeiro) e agrupada por
      concorrente/tema.
