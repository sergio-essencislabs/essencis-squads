---
task: "Estruturar Achados"
order: 1
input: |
  - research_brief: research brief de Rita Radar
  - product_capabilities: product-capabilities.md relevante(s)
output: |
  - planilha_concorrentes: tabela Markdown estruturada (squads/reporter/output/planilha-concorrentes.md)
---

# Estruturar Achados

Transforma o research brief de Rita Radar em uma planilha Markdown comparativa (concorrente, novidade, data, fonte, categoria, confiança) com uma nota de relevância competitiva por linha, sempre ancorada no product-capabilities.md real de GeoCloudAI/E-LIMS.

## Process

1. Ler o research brief de Rita Radar e o(s) product-capabilities.md relevante(s) do produto em foco.
2. Para cada achado, extrair: concorrente/tema, novidade (1 frase), data, fonte (URL), categoria (produto/mercado/financeiro/parceria/outro).
3. Adicionar uma coluna de relevância competitiva: comparar a novidade contra uma capacidade real do GeoCloudAI/E-LIMS, usando product-capabilities.md como referência — nunca material de marketing.
4. Se não for possível avaliar relevância com base real, marcar explicitamente "sem comparação direta" — nunca inventar categoria ou relevância sem base no achado original.
5. Consolidar todas as linhas em uma única tabela Markdown, agrupada por concorrente/tema e ordenada por confiança (alta primeiro).
6. Sinalizar distintamente qualquer achado com confiança baixa herdada da pesquisa — nunca misturar sem marcação com achados de alta confiança.
7. Salvar o resultado em `squads/reporter/output/planilha-concorrentes.md`.

## Output Format

```yaml
planilha:
  - concorrente_tema: string
    novidade: string          # 1 frase
    data: string               # YYYY-MM-DD
    fonte: string               # URL
    categoria: string           # produto | mercado | financeiro | parceria | outro
    confianca: string           # alta | media | baixa
    relevancia: string           # comparação vs. product-capabilities.md, ou "sem comparação direta"
```

## Output Example

```markdown
| Concorrente | Novidade | Data | Fonte | Categoria | Confiança | Relevância vs. nosso produto |
|---|---|---|---|---|---|---|
| Seequent | Lançou módulo de modelagem implícita com IA | 2026-08-15 | seequent.com/news/... | Produto | Alta | GeoCloudAI tem modelagem implícita (mód. 17) mas sem IA nessa etapa — GeoMind atua só em chat/análise de caixa |
| Seequent | Cobertura de imprensa especializada corrobora o lançamento | 2026-08-16 | miningtechnology.com/... | Produto | Alta | Mesmo achado acima, segunda fonte independente |
| Datarock | Anunciou parceria com laboratório australiano para análise de testemunhos | 2026-08-12 | datarock.com.au/news/... | Parceria | Alta | E-LIMS já cobre análise de testemunhos localmente; parceria amplia alcance geográfico do concorrente, não capacidade técnica nova |
| Minerva Intelligence | Publicou novo release notes com módulo de classificação litológica automática | 2026-08-11 | minervaintelligence.com/changelog | Produto | Média | Sem release público detalhado — GeoCloudAI já tem classificação litológica assistida (mód. 9), comparação parcial |
| VRIFY | Lançou dashboard 3D interativo para investidores | 2026-08-09 | vrify.com/press | Produto | Alta | Sem comparação direta — foco em visualização para investidores, não em análise técnica de exploração |
| KoBold Metals | Rodada de investimento de US$XXXM | 2026-08-10 | crunchbase.com/... | Financeiro | Alta | Sem comparação direta — não é capacidade de produto |
| Earth AI | Reportou expansão de equipe de dados em 20% | 2026-08-08 | linkedin.com/company/earth-ai | Mercado | Média | Sem comparação direta — sinaliza investimento em capacidade de IA, monitorar próximos lançamentos |
| Micromine | Estaria testando integração com XRF portátil (não confirmado) | 2026-08-10 | fórum especializado | Produto | Baixa | Sem comparação direta — achado não confirmado oficialmente, sinal fraco |
| Mariana Minerals | Sem novidades relevantes no período monitorado | 2026-08-23 | site oficial (verificação de rotina) | Outro | Alta | Sem comparação direta — nenhuma capacidade de produto foi anunciada |
```

## Quality Criteria

- Toda linha tem as 7 colunas preenchidas, incluindo relevância.
- Tabela Markdown tem contagem de colunas consistente em todas as linhas.
- Nenhuma relevância competitiva citada sem base em product-capabilities.md.

## Veto Conditions

Reject and redo if ANY are true:
- Qualquer linha sem nota de relevância (mesmo que seja "sem comparação direta").
- Relevância competitiva inflada além do que o achado realmente sustenta.
- Marcação de confiança baixa herdada da pesquisa omitida ou misturada sem distinção com achados de alta confiança.
- Categoria ou relevância inventada sem base no achado original do research brief.
