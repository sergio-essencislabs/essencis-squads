---
id: ADR-0005
title: Chief Architect e Documentation Architect sempre ativos via policy alwaysApply, não como agentes model-invoked
status: aceito
date: 2026-07-31
deciders: usuário (dono do framework)
---

## Contexto

Os 13 agentes (`agents/*.md`) foram deliberadamente configurados com `disable-model-invocation: true`
(ADR-0003) — nenhum é acionado automaticamente pelo Cursor; todos exigem invocação nomeada explícita
("aja como Backend Architect..."). Isso preserva economia de contexto (`MASTER_PROMPT.md` §7/§11), mas
o usuário identificou uma expectativa legítima: **Chief Architect** (roteamento para o agente de camada
correto, arbitragem cross-cutting) e **Documentation Architect** (garantir documentação/planilha
estrutural sincronizada) deveriam estar ativos em *toda* tarefa, sem precisar nomeá-los a cada vez —
diferente dos outros 11 agentes de camada/especializados, que continuam corretamente sob demanda.

A alternativa óbvia — remover `disable-model-invocation` só desses dois — foi descartada: isso tornaria
a ativação *probabilística* (o modelo decide, por mensagem, se acha a descrição relevante), não
*determinística*. O único mecanismo do framework que garante execução em toda mensagem, sem depender de
julgamento do modelo, é uma policy com `alwaysApply: true` (mesmo mecanismo de `policies/seguranca.md`,
`policies/documentacao.md`, etc.).

## Decisão

Criar `policies/orquestracao.md` (`alwaysApply: true`) que codifica, de forma **leve** (não a
especificação completa dos dois agentes), duas obrigações em toda tarefa:

1. **Início:** um raciocínio curto de Chief Architect — identificar camada/agente responsável, checar
   precedente (ADR/pattern), e só carregar `agents/chief-architect.md` na íntegra se a tarefa for de
   fato cross-cutting/arquitetural.
2. **Fim:** um checklist curto de Documentation Architect — docs vivos e planilha estrutural
   atualizados (ou explicitamente marcados como "não aplicável"), só carregando
   `agents/documentation-architect.md` completo quando há atualização real e não-trivial a fazer.

Os outros 11 agentes continuam exatamente como definidos no ADR-0003: `disable-model-invocation: true`,
assumidos apenas quando o passo 1 acima (ou o usuário) indicar.

## Consequências

- Toda tarefa neste framework passa a ter, garantidamente (não probabilisticamente), uma etapa de
  roteamento inicial e uma etapa de verificação documental final — sem o usuário precisar nomear os dois
  agentes em cada pedido.
- Custo de contexto controlado: a policy é curta (checklist, não a especificação completa de ~80 linhas
  de cada agente) — os arquivos completos só são lidos quando o próprio raciocínio leve concluir que a
  tarefa justifica (mesmo padrão de progressive disclosure já usado em skills/SKILL.md).
- Não há mudança na mecânica de invocação dos agentes em si (`agents/chief-architect.md` e
  `agents/documentation-architect.md` continuam existindo e podem seguir sendo invocados nomeadamente,
  como qualquer outro agente, quando alguém quiser a especificação completa desde o início).
- `MASTER_PROMPT.md` §5 atualizado para refletir que estes dois agentes são "sempre ativos (via
  `policies/orquestracao.md`)", diferenciando-os explicitamente dos demais ("sob demanda").

## Alternativas consideradas

- **Remover `disable-model-invocation` só de Chief/Documentation Architect:** rejeitada — ativação
  probabilística, não garante "sempre".
- **Remover `disable-model-invocation` dos 13 agentes:** rejeitada — ambiguidade entre agentes de camada
  que se sobrepõem (Backend/Security/Database podem todos parecer relevantes ao mesmo pedido) e custo de
  contexto alto (13 especificações completas candidatas a carregar em toda mensagem).
- **Tornar `agents/chief-architect.md`/`documentation-architect.md` eles mesmos `alwaysApply` na
  íntegra:** rejeitada — cada um tem ~80 linhas; carregar os dois por completo em toda mensagem (mesmo um
  typo trivial) é desperdício de contexto que o próprio framework existe para evitar.
