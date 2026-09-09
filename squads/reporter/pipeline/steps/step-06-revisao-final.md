---
execution: inline
agent: reviewer
outputFile: squads/reporter/output/revisao.md
on_reject: 4
---

# Step 06: Revisão Final

## Context Loading

Load these files before executing:
- `squads/reporter/output/planilha-concorrentes.md` — achados
  estruturados de Diego Dados, com fonte, confiança e relevância competitiva
  por linha
- `squads/reporter/output/resumo-executivo.md` — resumo
  executivo de Beatriz Briefing (versão Markdown)
- `squads/reporter/output/resumo-executivo.html` — versão
  HTML do mesmo resumo, deve ter conteúdo idêntico à versão Markdown
- `squads/reporter/output/research-brief.md` — research brief
  original de Rita Radar, para verificar achados e níveis de confiança na
  origem
- `squads/reporter/agents/reviewer.agent.md` — persona de
  Vitor Veredito, revisor final que confere fonte, confiança e consistência
  antes do checkpoint de aprovação

## Instructions

### Process

1. Ler a planilha estruturada, o resumo executivo (Markdown e HTML) e o
   research brief original, por completo.
2. Verificar que todo achado citado no resumo executivo existe na planilha e
   cita a mesma fonte e o mesmo nível de confiança — nenhuma divergência
   silenciosa entre os dois documentos.
3. Verificar que a versão HTML do resumo tem exatamente o mesmo conteúdo da
   versão Markdown (mesmo texto, mesma priorização, mesma seção de lacunas)
   e que é autocontida (sem CDN/fonte/link externo).
4. Verificar que nenhum achado de confiança baixa ou média foi apresentado
   no resumo como se fosse de alta confiança.
5. Verificar que toda relevância competitiva citada no resumo e na planilha
   tem base real em um `product-capabilities.md` correspondente, não em
   suposição ou material de marketing.
6. Se Paulo Produto atualizou algum `product-capabilities.md` nesta
   execução (ver `squads/reporter/output/atualizacao-produto.md`),
   confirmar que nenhuma operação git (checkout/commit/push) foi executada
   por ele — apenas leitura via worktree e escrita local no documento.
7. Pontuar cada critério de 1 a 10 com justificativa concreta (citando a
   linha/achado específico quando apontar um problema), e aplicar o
   veredito: **APROVAR** se a nota geral for >= 7 e nenhum critério
   individual for < 4; **APROVAR COM RESSALVAS** se houver problema não
   bloqueante; **REJEITAR** caso contrário.
8. Se o veredito for REJEITAR, apontar exatamente o que precisa ser
   corrigido e por qual agente. Como este squad não tem um agente dedicado
   a achados brutos após a planilha, todo REJEITAR desta etapa devolve o
   pipeline ao Step 4 (Estruturação dos Achados, Diego Dados), que deve
   corrigir a planilha e então acionar novamente o Step 5 (Beatriz Briefing
   reescreve o resumo a partir da planilha corrigida) antes de retornar a
   este Step 6.

## Output Format

The output MUST follow this exact structure:
```markdown
==============================
 VEREDITO: {APROVAR / APROVAR COM RESSALVAS / REJEITAR}
==============================
| Critério | Nota | Motivo |
|---|---|---|
| Consistência planilha x resumo | N/10 | {justificativa} |
| Consistência Markdown x HTML | N/10 | {justificativa} |
| Rigor de confiança | N/10 | {justificativa} |
| Base real de relevância | N/10 | {justificativa} |
| Política de git (Paulo Produto) | N/10 | {justificativa, ou "N/A — Paulo Produto não rodou nesta execução"} |
**Geral: X.XX/10**
{ressalva não bloqueante, ou correção obrigatória se REJEITAR, citando linha/achado específico}
```

## Output Example

```markdown
==============================
 VEREDITO: APROVAR COM RESSALVAS
==============================
| Critério | Nota | Motivo |
|---|---|---|
| Consistência planilha x resumo | 9/10 | Todos os achados citados no resumo batem com a planilha em fonte e confiança |
| Consistência Markdown x HTML | 10/10 | Conteúdo idêntico nas duas versões, HTML autocontido sem dependência externa |
| Rigor de confiança | 8/10 | Achado #3 (Micromine) é de confiança baixa na planilha e aparece marcado como "sinal fraco" no resumo, correto |
| Base real de relevância | 10/10 | Toda comparação remete a product-capabilities.md do GeoCloudAI, módulo 17 citado corretamente |
| Política de git (Paulo Produto) | 10/10 | Nenhuma operação git executada por Paulo Produto nesta execução, apenas leitura via worktree |
**Geral: 9.25/10**
Ressalva não bloqueante: a seção de lacunas do resumo poderia citar explicitamente que Datarock e CorePlan não tiveram novidade confirmada nesta semana, como consta no research brief.
```

## Veto Conditions

Reject and redo if ANY of these are true:
1. O veredito foi emitido sem ler a planilha, o resumo (Markdown e HTML) e o
   research brief por completo.
2. Um achado de confiança baixa ou média foi aprovado como se estivesse
   apresentado com o mesmo peso de um de alta confiança, sem correção
   apontada.
3. Uma divergência de conteúdo entre a versão Markdown e a versão HTML do
   resumo passou sem ser sinalizada.
4. Uma operação git não autorizada de Paulo Produto (fora leitura via
   worktree) passou sem bloquear o veredito.
5. Algum critério recebeu nota sem justificativa citando o achado/linha
   específico.

## Quality Criteria

- [ ] Todo critério tem nota (1-10) e justificativa concreta.
- [ ] Nenhuma inconsistência entre planilha e resumo passa sem correção apontada.
- [ ] Consistência entre a versão Markdown e a versão HTML do resumo foi verificada explicitamente.
- [ ] Política de git do Curador de Produto foi verificada quando ele rodou nesta execução.
- [ ] Veredito segue a regra: geral >= 7 e nenhum critério < 4 → aprovar; caso contrário, ressalvas ou rejeição.
