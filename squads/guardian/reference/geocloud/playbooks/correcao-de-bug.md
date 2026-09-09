---
playbook: Correção de Bug
gatilho: bug reportado ou encontrado (comportamento observado ≠ esperado)
---

# Playbook — Correção de Bug

1. **Reproduzir e isolar** — confirmar o comportamento incorreto com evidência (log, teste que falha, passo a passo). Nunca corrigir "no escuro".
2. **Impact Analysis** (skill) — mapear onde o bug se origina e quem consome o componente afetado.
3. **Classificar**: bug de lógica de negócio (Backend/Frontend Architect), de segurança (Security Architect — prioridade máxima), de schema (Database Architect), ou de documentação enganosa (Documentation Architect).
4. **Regression Analysis** (skill) — antes de corrigir, mapear consumidores para garantir que a correção não quebra outro fluxo que "dependia" do bug (acontece — ver lição `sample-journey-reconcile`: jornada é derivada dos dados reais, não de cliques manuais).
5. **Corrigir** na camada correta, sem "consertar" em uma camada superior o que é causado por uma camada inferior (ex.: não filtrar no frontend um dado que devia ser filtrado no backend).
6. **Teste de regressão** — QA Architect cria/adapta teste que falha antes da correção e passa depois.
7. **Se o bug for de segurança** (BOLA, permissão inerte, segredo exposto) — Security Architect registra em `knowledge/known-issues/` mesmo após corrigido, com a causa raiz.
8. **Documentation Sync** (skill) — se a documentação afirmava o comportamento incorreto como correto, corrigir.
9. **Reviewer** confirma todos os passos antes de considerar concluído.

## Não fazer

- Corrigir sintoma sem identificar causa raiz (ex.: adicionar `try/catch` silencioso em vez de corrigir a condição de erro).
- Reverter uma correção de segurança sem ADR explicando o motivo (já ocorreu no histórico — nunca repetir sem registro).
