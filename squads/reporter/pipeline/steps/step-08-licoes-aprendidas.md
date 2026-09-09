---
type: checkpoint
outputFile: squads/reporter/output/licoes-aprendidas.md
---

# Step 08: Lições Aprendidas

## Context Loading

Load these files before presenting this checkpoint:
- `squads/reporter/output/revisao.md` — veredito completo de Vitor Veredito, com tabela de critérios pontuados e justificativas
- `squads/reporter/output/aprovacao.md` — decisão do usuário no Step 07, incluindo qualquer pedido de ajuste e o motivo dado
- `squads/reporter/pipeline/data/anti-patterns.md` — regras "Nunca/Sempre" atuais de cada persona
- `squads/reporter/pipeline/data/quality-criteria.md` — critérios de qualidade atuais de cada persona

## Purpose

Este squad já registra preferências explícitas do usuário em `_memory/memories.md` ao final de cada execução (mecanismo automático do pipeline runner). Este checkpoint é diferente e complementar: em vez de preferências, ele busca lacunas na régua de qualidade dos próprios agentes — quando uma nota baixa, uma ressalva, um REJEITAR (com retorno ao Step 4) ou um pedido de ajuste do usuário revela um padrão de erro que `anti-patterns.md`/`quality-criteria.md` ainda não cobre, essa lacuna vira uma regra permanente para as próximas execuções, sempre com aprovação explícita do usuário antes de qualquer escrita.

## Instructions

### Process

1. Reunir toda justificativa de nota abaixo de 8 na tabela de critérios de `revisao.md`, toda ressalva não bloqueante, todo REJEITAR desta execução (mesmo já corrigido antes da aprovação final), e todo pedido de ajuste registrado em `aprovacao.md` com o motivo dado pelo usuário.
2. Para cada item reunido, verificar se o padrão de erro já está coberto por uma regra existente em `anti-patterns.md` (Nunca/Sempre da persona responsável) ou um critério em `quality-criteria.md`:
   - Se está coberto e a regra existente já cita exatamente esse padrão → não é lição nova, a régua funcionou como esperado. Descartar.
   - Se está coberto mas de forma vaga/ambígua, a ponto de não ter evitado o problema → candidato a **ajuste** da regra existente.
   - Se não está coberto por nenhuma regra → candidato a **regra nova**.
3. Deduplicar candidatos que descrevem o mesmo padrão subjacente.
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
{lista numerada, ou "Nenhum candidato identificado nesta execução — todos os problemas apontados pelo veredito já estavam cobertos pelas regras existentes."}

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
# Lições Aprendidas — 2026-08-23

## Candidatos Identificados

### Candidato 1 — Diego Dados (data-analyst)
**Arquivo alvo:** pipeline/data/anti-patterns.md
**Origem:** Vitor Veredito deu nota 6/10 em "Rigor de confiança" porque um achado de fonte única apareceu na planilha sem marcação de baixa confiança — não havia regra citável além do critério geral de "atribuir nível de confiança", que não cobre o caso específico de fonte única.
**Regra proposta:** "Nunca marcar um achado com confiança média/alta quando ele vem de uma única fonte — fonte única é sempre confiança baixa por definição, mesmo que a fonte pareça confiável."
**Decisão do usuário:** Ajustado: "Nunca marcar um achado com confiança média/alta quando ele vem de uma única fonte, salvo se a fonte for o próprio repositório do produto (código-fonte é sempre alta confiança)."

## Alterações Aplicadas
- `pipeline/data/anti-patterns.md`, seção "Diego Dados — Analista de Dados Competitivos", bullet "Nunca" adicionado: "Nunca marcar um achado com confiança média/alta quando ele vem de uma única fonte, salvo se a fonte for o próprio repositório do produto (código-fonte é sempre alta confiança)."
```

## Notes

- Nunca escrever em `anti-patterns.md` ou `quality-criteria.md` sem aprovação explícita do usuário para aquele candidato específico — mesmo que o padrão pareça óbvio.
- Nunca remover ou reescrever uma regra existente que não seja o próprio candidato em ajuste.
- Este checkpoint não bloqueia a execução seguinte do squad — é sempre o último passo, informativo mesmo quando há alterações aplicadas.
