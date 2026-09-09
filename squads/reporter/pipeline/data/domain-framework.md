# Domain Framework — Reporter

Este documento compila o framework operacional de cada agente do squad. Cada seção descreve o passo a passo que o agente segue ao executar sua tarefa.

## Paulo Produto — Curador de Conhecimento do Produto

1. Ler o escopo definido no checkpoint (quais produtos estão em foco nesta execução).
2. Para cada produto no escopo, criar um git worktree somente leitura na branch main atual (nunca tocar no checkout de trabalho ativo).
3. Comparar a main atual contra o commit citado no product-capabilities.md existente — se não houver commits novos, apenas confirmar validade e não reescrever o documento.
4. Se houver commits novos, inspecioná-los (git log/git show) para separar mudanças de negócio reais de fixes/refatoração sem impacto de capacidade.
5. Atualizar (nunca recriar do zero) o product-capabilities.md: adicionar capacidades novas confirmadas, corrigir capacidades que mudaram, remover o que foi confirmado como removido — cada mudança com evidência de código real.
6. Nunca alterar o overview.md técnico nem qualquer outro arquivo do repositório de produto.
7. Remover o worktree temporário ao final; nunca fazer commit/push — isso é decidido no checkpoint de aprovação final do squad.

## Rita Radar — Pesquisadora de Concorrentes e Mercado

1. Ler o escopo da semana (produtos em foco, período, concorrentes/temas prioritários adicionais) do checkpoint anterior.
2. Ler product-capabilities.md atualizado de cada produto em foco, para saber contra o que comparar.
3. Para cada concorrente da lista (Datarock, Minerva Intelligence, Seequent, Micromine, Acquire, GeoSpark, CorePlan, FastGeo, Kore Geosystems, Earth AI, VerAI Discoveries, VRIFY, KoBold Metals, Mariana Minerals — ou lista customizada do checkpoint), rodar busca focada (site oficial, imprensa, changelog/release notes, LinkedIn corporativo) pelo período definido.
4. Rodar busca adicional para novidades gerais do setor (exploração mineral, análise laboratorial mineral) não atreladas a um concorrente específico.
5. Verificar cada achado contra pelo menos uma fonte independente antes de reportar; atribuir nível de confiança (alta/média/baixa).
6. Descartar fontes sem autoria/instituição clara ou com mais de 2 anos para tema sensível a tempo.
7. Compilar no formato de research brief padrão: Achados-Chave, Ângulos em Tendência, Fontes, Lacunas — sem recomendação de conteúdo (isso não é um squad de conteúdo).

## Diego Dados — Analista de Dados Competitivos

1. Ler o research brief de Rita Radar e o(s) product-capabilities.md relevante(s).
2. Para cada achado, extrair: concorrente/tema, novidade (1 frase), data, fonte (URL), categoria (produto/mercado/financeiro/parceria/outro).
3. Adicionar uma coluna de relevância competitiva: como essa novidade se compara a uma capacidade real do GeoCloudAI/E-LIMS (usar product-capabilities.md como referência, nunca material de marketing).
4. Nunca inventar categoria ou relevância sem base no achado original — se não for possível avaliar relevância, marcar explicitamente "sem comparação direta".
5. Consolidar em uma única tabela Markdown (squads/reporter/output/planilha-concorrentes.md), agrupada por concorrente/tema e ordenada por confiança (alta primeiro).
6. Sinalizar qualquer achado com confiança baixa distintamente na planilha (não misturar com achados de alta confiança sem marcação).

## Beatriz Briefing — Redatora do Resumo Executivo

1. Ler a planilha estruturada e o research brief original de Rita Radar.
2. Identificar os 3-5 achados de maior relevância competitiva real (nunca todos os achados — priorizar).
3. Para cada achado priorizado, escrever 1-2 frases: o que aconteceu + por que importa para GeoCloudAI/E-LIMS.
4. Escrever um parágrafo de abertura com o panorama da semana (quantos concorrentes monitorados, quantos achados, algum padrão emergente).
5. Nunca incluir achado de baixa confiança no resumo executivo sem marcar explicitamente como sinal fraco.
6. Fechar com uma nota de lacunas — o que não foi possível confirmar essa semana.
7. Salvar a versão em Markdown (resumo-executivo.md) e, com o MESMO conteúdo (nunca resumir mais nem menos entre as duas versões), gerar um arquivo HTML autocontido (resumo-executivo.html) — CSS inline, sem dependência externa, legível tanto em claro quanto escuro, pronto para abrir direto no navegador ou anexar/encaminhar.

## Vitor Veredito — Revisor Final

1. Ler a planilha estruturada, o resumo executivo, e o research brief original.
2. Verificar que todo achado citado no resumo existe na planilha e cita a mesma fonte/confiança.
3. Verificar que nenhum achado de baixa confiança foi apresentado como se fosse de alta confiança.
4. Verificar que toda relevância competitiva citada tem base real em product-capabilities.md, não em suposição.
5. Se Paulo Produto atualizou algum product-capabilities.md nesta execução, confirmar que nenhuma operação git foi executada por ele (apenas leitura/escrita local).
6. Pontuar cada critério de 1-10 com justificativa; aplicar veredito (APROVAR / APROVAR COM RESSALVAS / REJEITAR) conforme regra: geral >=7 e nenhum critério <4 → aprovar.
7. Se rejeitar, apontar exatamente o que corrigir e devolver ao agente responsável (Diego Dados ou Beatriz Briefing).
