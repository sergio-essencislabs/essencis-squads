---
type: checkpoint
outputFile: squads/guardian/output/licoes-aprendidas.md
---

# Step 22: Lições Aprendidas

## Context Loading

Load these files before presenting this checkpoint:
- `squads/guardian/output/revisao-prs.md` — veredito completo de Otávio Review sobre todos os PRs desta execução, com motivos de bloqueio citando evidência/policy e pendências não bloqueantes
- `squads/guardian/output/aprovacao-prs.md` — decisão do usuário, incluindo qualquer divergência do veredito de Otávio (PR aprovado por ele mas rejeitado pelo usuário, ou vice-versa)
- `squads/guardian/output/achados-selecionados.md` — decisão do usuário no Step 06, incluindo achados não selecionados com motivo, quando informado
- `squads/guardian/pipeline/data/anti-patterns.md` — regras "Nunca/Sempre" atuais de cada persona
- `squads/guardian/pipeline/data/quality-criteria.md` — critérios de qualidade atuais de cada persona

## Purpose

Este squad já registra preferências explícitas do usuário em `_memory/memories.md` ao final de cada execução (mecanismo automático do pipeline runner). Este checkpoint é diferente e complementar: em vez de preferências, ele busca lacunas na régua de qualidade dos próprios agentes — quando um bloqueio, uma ressalva ou uma divergência desta execução revela um padrão de erro que `anti-patterns.md`/`quality-criteria.md` ainda não cobre, essa lacuna vira uma regra permanente para as próximas execuções, sempre com aprovação explícita do usuário antes de qualquer escrita.

## Instructions

### Process

1. Reunir todos os "Motivo do bloqueio" e "Pendências não bloqueantes" de `revisao-prs.md`, toda divergência registrada em `aprovacao-prs.md`, e todo achado não selecionado em `achados-selecionados.md` que tenha motivo explícito do usuário.
2. Para cada item reunido, verificar se o padrão de erro já está coberto por uma regra existente em `anti-patterns.md` (Nunca/Sempre da persona responsável) ou um critério em `quality-criteria.md`:
   - Se está coberto e a regra existente já cita exatamente esse padrão → não é lição nova, a régua funcionou como esperado. Descartar.
   - Se está coberto mas de forma vaga/ambígua, a ponto de não ter evitado o problema → candidato a **ajuste** da regra existente.
   - Se não está coberto por nenhuma regra → candidato a **regra nova**.
3. Deduplicar candidatos que descrevem o mesmo padrão subjacente, mesmo vindos de PRs diferentes.
4. Formular cada candidato como uma única linha no estilo exato do arquivo alvo (bullet "Nunca ..." / "Sempre ..." para `anti-patterns.md`, ou item de checklist para `quality-criteria.md`), atribuída à persona correta e concreta o bastante para ser verificável na próxima execução (nunca vaga).
5. Se nenhum candidato restar após a deduplicação e checagem de cobertura, ainda apresentar o checkpoint, mas apenas para confirmar "nenhuma lição nova identificada nesta execução" — não fazer nenhuma pergunta de aprovação.
6. Se houver candidatos, apresentar cada um numerado ao usuário com: persona, arquivo alvo, trecho do veredito/decisão que motivou, e o texto proposto (atual vs. proposto, quando for ajuste).
7. Perguntar ao usuário, por candidato: Aprovar como está / Ajustar (usuário reformula o texto) / Descartar (foi caso isolado, não deve virar regra).
8. Para cada candidato Aprovado ou Ajustado, usar o Edit tool para escrever a regra na seção correta da persona no arquivo alvo — **apenas adicionar** a linha nova (ou substituir a linha existente no caso de ajuste de regra já candidata), nunca remover ou reescrever qualquer outra regra já presente no arquivo.

## Output Format

The output MUST follow this exact structure:
```markdown
# Lições Aprendidas — {data da execução}

## Candidatos Identificados
{lista numerada, ou "Nenhum candidato identificado nesta execução — todos os bloqueios, ressalvas e divergências já estavam cobertos pelas regras existentes."}

### Candidato {N} — {persona}
**Arquivo alvo:** pipeline/data/anti-patterns.md | pipeline/data/quality-criteria.md
**Origem:** {trecho do veredito/decisão que motivou}
**Regra proposta:** {texto no estilo Nunca/Sempre, ou critério de qualidade}
**Decisão do usuário:** {Aprovado como está / Ajustado: "{texto final}" / Descartado}

## Alterações Aplicadas
{lista dos arquivos efetivamente editados nesta execução e a regra adicionada em cada um, ou "nenhuma alteração aplicada nesta execução"}
```

## Output Example

```markdown
# Lições Aprendidas — 2026-08-24

## Candidatos Identificados

### Candidato 1 — Breno Backend (backend-architect)
**Arquivo alvo:** pipeline/data/anti-patterns.md
**Origem:** PR #145 bloqueado por Otávio Review por reintroduzir extração de claims direto no controller, fora do middleware de identidade — não havia regra explícita citável, o bloqueio foi justificado só pelo raciocínio do revisor.
**Regra proposta:** "Nunca extrair claims de identidade em um controller — sempre passar pelo middleware de identidade, mesmo em endpoints novos criados rapidamente para uma task de segurança."
**Decisão do usuário:** Aprovado como está.

### Candidato 2 — Dante Debit (tech-debt-auditor)
**Arquivo alvo:** pipeline/data/quality-criteria.md
**Origem:** Achado TD-02 não selecionado pelo usuário no Step 06 — "isso não é dívida técnica, é uma feature que nunca foi implementada, Dante confundiu ausência de feature com débito."
**Regra proposta:** Descartado — usuário considerou caso isolado, já existe critério equivalente ("Sempre distinguir 'dívida técnica' de 'mudança de feature' no relatório") em anti-patterns.md; o problema foi uma falha pontual de aplicação, não uma lacuna de regra.
**Decisão do usuário:** Descartado.

## Alterações Aplicadas
- `pipeline/data/anti-patterns.md`, seção "Breno Backend (backend-architect)", bullet "Nunca" adicionado: "Nunca extrair claims de identidade em um controller — sempre passar pelo middleware de identidade, mesmo em endpoints novos criados rapidamente para uma task de segurança."
```

## Notes

- Nunca escrever em `anti-patterns.md` ou `quality-criteria.md` sem aprovação explícita do usuário para aquele candidato específico — mesmo que o padrão pareça óbvio.
- Nunca remover ou reescrever uma regra existente que não seja o próprio candidato em ajuste.
- Este checkpoint não bloqueia a execução seguinte do squad — é sempre o último passo, informativo mesmo quando há alterações aplicadas.
