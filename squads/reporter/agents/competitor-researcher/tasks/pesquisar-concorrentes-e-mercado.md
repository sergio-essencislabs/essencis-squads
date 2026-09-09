---
task: "Pesquisar Concorrentes e Mercado"
order: 1
input: |
  - foco_semanal: escopo do checkpoint "Foco da Pesquisa Semanal" (produtos em foco, período, concorrentes/temas prioritários adicionais)
  - product_capabilities: product-capabilities.md atualizado de cada produto em foco (GeoCloudAI, E-LIMS)
  - lista_concorrentes: Datarock, Minerva Intelligence, Seequent, Micromine, Acquire, GeoSpark, CorePlan, FastGeo, Kore Geosystems, Earth AI, VerAI Discoveries, VRIFY, KoBold Metals, Mariana Minerals (ou lista customizada do checkpoint)
output: |
  - research_brief: squads/reporter/output/research-brief.md com Achados-Chave, Ângulos em Tendência, Fontes, Lacunas
---

# Pesquisar Concorrentes e Mercado

Busca novidades de cada concorrente conhecido do GeoCloudAI/E-LIMS e do setor de exploração mineral/análise laboratorial em geral, sempre com verificação cruzada de fontes e atribuição explícita de nível de confiança por achado. Não decide ângulo, prioridade ou recomendação de conteúdo — apenas coleta, verifica e compila.

## Process

1. Ler o escopo da semana (produtos em foco, período, concorrentes/temas prioritários adicionais) definido no checkpoint anterior.
2. Ler o `product-capabilities.md` atualizado de cada produto em foco, para saber contra o que comparar cada achado.
3. Para cada concorrente da lista (Datarock, Minerva Intelligence, Seequent, Micromine, Acquire, GeoSpark, CorePlan, FastGeo, Kore Geosystems, Earth AI, VerAI Discoveries, VRIFY, KoBold Metals, Mariana Minerals — ou lista customizada do checkpoint), rodar busca focada (site oficial, imprensa, changelog/release notes, LinkedIn corporativo) pelo período definido.
4. Rodar busca adicional para novidades gerais do setor (exploração mineral, análise laboratorial mineral) não atreladas a um concorrente específico.
5. Verificar cada achado contra pelo menos uma fonte independente antes de reportar; atribuir nível de confiança (alta/média/baixa).
6. Descartar fontes sem autoria/instituição clara ou com mais de 2 anos para tema sensível a tempo.
7. Compilar no formato de research brief padrão: Achados-Chave, Ângulos em Tendência, Fontes, Lacunas — sem recomendação de conteúdo (isso não é um squad de conteúdo).

## Output Format

```yaml
periodo: "<data inicio> a <data fim>"
concorrentes_monitorados: <int>
achados:
  - concorrente: "<nome ou 'setor geral'>"
    titulo: "<achado em uma frase>"
    confianca: "alta | media | baixa"
    fontes:
      - url: "<url>"
        tipo: "oficial | imprensa | changelog | linkedin | forum | outro"
        data_publicacao: "YYYY-MM-DD"
        data_acesso: "YYYY-MM-DD"
    relevancia_para_produto: "<comparação objetiva com product-capabilities.md, ou 'sem comparação direta'>"
    evidencia_contraditoria: "<se houver, descrever as duas posições; caso contrário, 'nenhuma encontrada'>"
angulos_em_tendencia:
  - "<padrão observado entre múltiplos concorrentes>"
lacunas:
  - "<o que não foi possível confirmar nesta execução>"
```

## Output Example

### Exemplo 1 — Achado de concorrente com fonte oficial

### Achado — Seequent lança novo módulo de modelagem implícita com IA
**Concorrente:** Seequent
**Confiança:** Alta (fonte oficial + cobertura de imprensa especializada corroborando)

**Fontes:**
- Seequent.com, comunicado oficial de lançamento, publicado em 2026-08-15. Acessado em 2026-08-23.
- Mining Technology, cobertura do lançamento, publicado em 2026-08-16. Acessado em 2026-08-23.

**O que aconteceu:** Seequent anunciou um novo módulo de modelagem geológica implícita com componente de IA generativa, capaz de sugerir camadas geológicas a partir de dados esparsos de sondagem.

**Relevância para GeoCloudAI:** GeoCloudAI já tem modelagem geológica explícita/implícita (ver `product-capabilities.md`, módulo 17), mas sem componente de IA nessa etapa específica — o GeoMind atua hoje em chat/análise de caixa, não em geração de modelo. Ponto de atenção competitivo para o roadmap de IA do produto.

**Evidência contraditória:** Nenhuma encontrada — as duas fontes corroboram o mesmo lançamento sem divergência de detalhes relevantes.

### Exemplo 2 — Achado sem segunda fonte (baixa confiança)

### Achado — Micromine estaria testando integração com XRF portátil (não confirmado)
**Concorrente:** Micromine
**Confiança:** Baixa (única fonte, fórum de usuários, sem confirmação oficial)

**Fontes:**
- Fórum especializado de geologia/mineração, post de usuário, publicado em 2026-08-10. Acessado em 2026-08-23.

**O que aconteceu:** Um post em fórum especializado menciona que a Micromine estaria testando integração direta com equipamentos XRF portáteis para leitura de dados geoquímicos em campo.

**Verificação realizada:** Busca adicional no site oficial da Micromine, changelog público e páginas de imprensa não encontrou nenhuma confirmação oficial corroborando o rumor.

**Observação:** não encontrada nenhuma fonte oficial da Micromine corroborando. Reportado como sinal fraco na seção de Lacunas do research brief, não como fato de mercado confirmado.

## Quality Criteria

- Todo achado tem URL de fonte e data de acesso.
- Achados de alta confiança têm 2+ fontes independentes corroborando.
- Lacunas de pesquisa estão documentadas explicitamente.
- Nenhum achado contém recomendação de conteúdo/estratégia — isso é escopo de outro agente.

## Veto Conditions

Reject and redo if ANY are true:
- Qualquer achado foi reportado sem URL de fonte rastreável.
- Um achado com fonte única foi apresentado como confiança alta ou média, sem marcação explícita de baixa confiança.
- O research brief contém qualquer recomendação de ângulo, prioridade ou conteúdo — fora do escopo deste agente.
- Evidência contraditória entre fontes foi omitida em vez de reportada.
