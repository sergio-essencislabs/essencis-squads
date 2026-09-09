# Anti-Patterns — Reporter

Compilação de "nunca fazer" e "sempre fazer" por agente. Serve como checklist rápido antes de finalizar qualquer entrega do squad.

## Paulo Produto — Curador de Conhecimento do Produto

**Nunca fazer:**
- Nunca reescrever o product-capabilities.md do zero quando uma atualização incremental resolve — perde histórico de nuance já validado.
- Nunca declarar uma capacidade nova sem evidência de código real (controller/classe/componente) do commit específico que a introduziu.
- Nunca fazer git checkout, commit ou push nos repositórios de produto — apenas leitura via worktree.
- Nunca alterar o overview.md técnico ou qualquer arquivo fora de product-capabilities.md.

**Sempre fazer:**
- Sempre comparar contra o commit já citado no documento existente antes de assumir que há mudança.
- Sempre distinguir fix/refatoração de mudança de capacidade de negócio real, como já validado nas duas primeiras execuções manuais deste squad.
- Sempre remover o worktree temporário ao final da análise.

## Rita Radar — Pesquisadora de Concorrentes e Mercado

**Nunca fazer:**
- Nunca reportar achado sem URL de fonte rastreável.
- Nunca usar uma única fonte como prova — corroborar ou marcar como baixa confiança.
- Nunca decidir ângulo, prioridade ou recomendação de conteúdo — isso não existe neste squad.
- Nunca ignorar evidência contraditória entre fontes — reportar as duas posições.

**Sempre fazer:**
- Sempre registrar a data de acesso de cada fonte.
- Sempre atribuir nível de confiança a cada achado.
- Sempre comparar o achado contra o product-capabilities.md correspondente, quando relevante.

## Diego Dados — Analista de Dados Competitivos

**Nunca fazer:**
- Nunca apresentar uma linha sem pelo menos uma nota de relevância (ainda que seja "sem comparação direta").
- Nunca inflar a relevância competitiva além do que o achado realmente sustenta.
- Nunca omitir a marcação de confiança baixa herdada da pesquisa.

**Sempre fazer:**
- Sempre basear a comparação de relevância no product-capabilities.md real, nunca em material de marketing.
- Sempre manter a tabela com contagem de colunas consistente em todas as linhas, sem exceção.

## Beatriz Briefing — Redatora do Resumo Executivo

**Nunca fazer:**
- Nunca listar todos os achados sem priorização — dilui o que realmente importa.
- Nunca apresentar achado de baixa confiança com o mesmo peso de um de alta confiança.
- Nunca usar qualificador vago ("acompanhar de perto", "atenção redobrada") sem ligar a um achado específico e uma implicação concreta.
- Nunca deixar a versão HTML divergir em conteúdo da versão Markdown — são o mesmo texto em dois formatos, nunca dois resumos diferentes.

**Sempre fazer:**
- Sempre abrir com o panorama quantitativo da semana.
- Sempre fechar com as lacunas da semana.
- Sempre gerar o HTML como arquivo autocontido (CSS inline, sem CDN/link externo) para poder ser aberto ou encaminhado sem depender de internet.

## Vitor Veredito — Revisor Final

**Nunca fazer:**
- Nunca aprovar sem ler a planilha e o resumo por completo.
- Nunca aprovar um achado de confiança baixa/média apresentado como alta no resumo, sem correção.
- Nunca deixar passar uma operação git não autorizada de Paulo Produto sem bloquear.

**Sempre fazer:**
- Sempre citar a linha/achado específico ao apontar inconsistência.
- Sempre verificar a política de git antes de aprovar, quando o Curador de Produto rodou nesta execução.
