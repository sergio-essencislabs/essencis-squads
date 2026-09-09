# Quality Criteria — Reporter

## Baseline Compartilhada (todos os agentes)

Estes princípios vêm dos best-practices consultados na criação do squad (researching.md, data-analysis.md, review.md) e se aplicam transversalmente, independente do critério específico de cada agente abaixo:

- **Verificação de fonte** — toda afirmação factual deve remontar a uma fonte rastreável (URL, documento, commit); nunca aceitar boato ou suposição como fato.
- **Nível de confiança explícito** — todo achado/afirmação carrega um nível de confiança (alta/média/baixa), nunca tratado como certeza absoluta sem essa marcação.
- **Insight sobre dado bruto** — nenhum dado é apresentado sem contexto/interpretação de por que ele importa; número ou fato solto não é suficiente.
- **Veredito estruturado** — decisões de aprovação/rejeição são pontuadas por critério, com justificativa, nunca uma impressão geral vaga.

## Paulo Produto — Curador de Conhecimento do Produto

- Toda capacidade nova/alterada cita o commit e o arquivo de evidência real.
- overview.md técnico nunca é alterado por este agente.
- Nenhuma operação git além de leitura via worktree foi executada.
- Worktree temporário removido ao final.

## Rita Radar — Pesquisadora de Concorrentes e Mercado

- Todo achado tem URL de fonte e data de acesso.
- Achados de alta confiança têm 2+ fontes independentes corroborando.
- Lacunas de pesquisa estão documentadas explicitamente.
- Nenhum achado contém recomendação de conteúdo/estratégia — isso é escopo de outro agente.

## Diego Dados — Analista de Dados Competitivos

- Toda linha tem as 7 colunas preenchidas, incluindo relevância.
- Tabela Markdown tem contagem de colunas consistente em todas as linhas.
- Nenhuma relevância competitiva citada sem base em product-capabilities.md.

## Beatriz Briefing — Redatora do Resumo Executivo

- Resumo executivo tem no máximo 5 achados priorizados, nunca a lista completa.
- Toda afirmação de relevância remete a uma linha específica da planilha.
- Seção de lacunas está presente.

## Vitor Veredito — Revisor Final

- Todo critério tem nota e justificativa.
- Nenhuma inconsistência entre planilha e resumo passa sem correção apontada.
- Política de git do Curador de Produto verificada quando aplicável.
