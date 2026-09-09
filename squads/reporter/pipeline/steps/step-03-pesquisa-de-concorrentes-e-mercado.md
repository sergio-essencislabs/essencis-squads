---
execution: subagent
agent: competitor-researcher
inputFile: squads/reporter/output/atualizacao-produto.md
outputFile: squads/reporter/output/research-brief.md
model_tier: powerful
---

# Step 03: Pesquisa de Concorrentes e Mercado

## Context Loading

Load these files before executing:
- `squads/reporter/output/atualizacao-produto.md` — delta de
  capacidades de produto desta execução, usado para saber contra o que
  comparar cada achado de mercado.
- `squads/reporter/output/foco-semanal.md` — escopo da
  semana (produtos em foco, período a cobrir, concorrentes/temas
  prioritários adicionais definidos no checkpoint).
- `squads/reporter/agents/competitor-researcher.agent.md` —
  persona de Rita Radar: coleta e cita, nunca decide ângulo ou prioriza
  conteúdo.
- `squads/reporter/agents/competitor-researcher/tasks/pesquisar-concorrentes-e-mercado.md`
  — processo operacional de busca, verificação cruzada e atribuição de
  confiança.
- `_opensquad/_memory/company.md` — lista oficial de concorrentes monitorados
  e tom/contexto da Essencis para calibrar relevância.
- `product-capabilities.md` atualizado do(s) produto(s) em foco (caminhos
  citados em `atualizacao-produto.md`) — referência real para avaliar se um
  achado tem comparação direta.

## Instructions

### Process

1. Ler o escopo da semana (produtos em foco, período, concorrentes/temas
   prioritários adicionais) em `foco-semanal.md`, e o delta de capacidades
   em `atualizacao-produto.md`.
2. Ler o `product-capabilities.md` atualizado de cada produto em foco, para
   saber contra qual capacidade real comparar cada achado.
3. Para cada concorrente da lista (Datarock, Minerva Intelligence, Seequent,
   Micromine, Acquire, GeoSpark, CorePlan, FastGeo, Kore Geosystems, Earth
   AI, VerAI Discoveries, VRIFY, KoBold Metals, Mariana Minerals — mais
   qualquer item customizado do checkpoint), rodar busca focada (site
   oficial, imprensa especializada, changelog/release notes, LinkedIn
   corporativo) restrita ao período definido.
4. Rodar busca adicional para novidades gerais do setor (exploração mineral,
   análise laboratorial mineral) não atreladas a um concorrente específico.
5. Verificar cada achado contra pelo menos uma fonte independente antes de
   reportar; atribuir nível de confiança (alta/média/baixa) conforme o grau
   de corroboração.
6. Descartar fontes sem autoria/instituição clara ou com mais de 2 anos para
   tema sensível a tempo.
7. Compilar tudo no formato de research brief padrão — Achados-Chave,
   Ângulos em Tendência, Fontes, Lacunas — sem incluir recomendação de
   conteúdo ou estratégia (fora de escopo deste squad).

## Output Format

```markdown
# Research Brief — {período coberto}

## Achados-Chave

### Achado — {título curto do achado}
**Confiança:** {Alta/Média/Baixa} ({justificativa de corroboração})
**Fonte:** {nome da fonte}, {tipo}, {data de publicação}. Acessado: {data de acesso}.
**Fonte 2 (se houver):** {nome}, {tipo}, {data}.
**Relevância para GeoCloudAI/E-LIMS:** {comparação com product-capabilities.md
ou "sem comparação direta"}.

## Ângulos em Tendência
- {padrão ou tendência observada entre múltiplos achados}

## Fontes
- {lista consolidada de todas as fontes usadas, com URL e data de acesso}

## Lacunas
- {o que não foi possível confirmar ou verificar nesta execução}
```

## Output Example

```markdown
# Research Brief — semana de 2026-08-17 a 2026-08-23

## Achados-Chave

### Achado — Seequent lança novo módulo de modelagem implícita com IA
**Confiança:** Alta (fonte oficial + cobertura de imprensa especializada corroborando)
**Fonte:** Seequent.com, comunicado oficial, 2026-08-15. Acessado: 2026-08-23.
**Fonte 2:** Mining Technology, cobertura do lançamento, 2026-08-16.
**Relevância para GeoCloudAI:** GeoCloudAI já tem modelagem geológica
explícita/implícita (ver product-capabilities.md, módulo 17), mas sem
componente de IA nessa etapa específica — GeoMind atua em chat/análise de
caixa, não em geração de modelo. Ponto de atenção competitivo.

### Achado — Micromine estaria testando integração com XRF portátil (não confirmado)
**Confiança:** Baixa (única fonte, fórum de usuários, sem confirmação oficial)
**Fonte:** fórum especializado, post de 2026-08-10. Acessado: 2026-08-23.
**Observação:** não encontrada nenhuma fonte oficial da Micromine corroborando.
Reportado como sinal fraco, não como fato.

## Ângulos em Tendência
- Dois concorrentes diretos (Seequent, KoBold Metals) mostraram movimento em
  IA aplicada à etapa de modelagem/exploração nesta semana.

## Fontes
- seequent.com/news/... — acessado 2026-08-23
- miningtechnology.com/... — acessado 2026-08-23
- crunchbase.com/... — acessado 2026-08-23

## Lacunas
- Não foi possível confirmar oficialmente o rumor de integração XRF da
  Micromine (fonte única, baixa confiança).
```

## Veto Conditions
Reject and redo if ANY of these are true:
- Algum achado foi reportado sem URL de fonte rastreável ou sem data de
  acesso registrada.
- Um achado de alta confiança tem apenas uma fonte, sem corroboração
  independente.
- O brief contém recomendação de ângulo, prioridade ou estratégia de
  conteúdo (fora do escopo deste agente).
- Evidência contraditória entre fontes foi ignorada em vez de reportada.

## Quality Criteria
- [ ] Todo achado tem URL de fonte e data de acesso.
- [ ] Achados de alta confiança têm 2+ fontes independentes corroborando.
- [ ] Lacunas de pesquisa estão documentadas explicitamente.
- [ ] Nenhum achado contém recomendação de conteúdo/estratégia.
- [ ] Todos os concorrentes do escopo (lista padrão ou customizada do
      checkpoint) foram cobertos ou explicitamente marcados sem novidade.
