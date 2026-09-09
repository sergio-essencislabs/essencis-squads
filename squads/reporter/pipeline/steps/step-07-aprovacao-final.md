---
type: checkpoint
outputFile: squads/reporter/output/aprovacao.md
---

# Step 07: Aprovação Final

## Context Loading

Load these files before presenting this checkpoint:
- `squads/reporter/output/revisao.md` — veredito de Vitor
  Veredito sobre a planilha e o resumo executivo
- `squads/reporter/output/resumo-executivo.md` — resumo
  executivo final (versão Markdown)
- `squads/reporter/output/atualizacao-produto.md` — relatório
  de Paulo Produto sobre se algum `product-capabilities.md` foi atualizado
  nesta execução (GeoCloudAI e/ou E-LIMS)

## Purpose

Este é o checkpoint final da execução. Apresenta o veredito do revisor e o
conteúdo do resumo executivo para aprovação humana e, se Paulo Produto
atualizou algum `product-capabilities.md` nesta execução, decide junto com o
usuário se essa atualização deve ser commitada (e opcionalmente enviada com
push) agora. Nenhum commit ou push é feito automaticamente pelo pipeline —
essa decisão é sempre do usuário, seguindo a mesma política de segurança do
squad Guardian.

## Instructions

Apresentar ao usuário:

1. O veredito de Vitor Veredito (`revisao.md`) por completo, incluindo a
   tabela de critérios pontuados e qualquer ressalva não bloqueante.
2. O conteúdo do resumo executivo (`resumo-executivo.md`), na íntegra.
3. Mencionar explicitamente o caminho do arquivo `resumo-executivo.html`,
   pronto para abrir no navegador ou encaminhar por e-mail/Slack.
4. Se `atualizacao-produto.md` indicar que algum `product-capabilities.md`
   foi de fato atualizado nesta execução (não apenas confirmado como já
   válido), resumir o que mudou (produto, capacidades adicionadas/alteradas/
   removidas) e perguntar explicitamente ao usuário se deseja commitar essa
   atualização agora. **Nunca commitar ou dar push automaticamente** — se o
   usuário não especificar, o padrão é NÃO commitar.

Perguntar ao usuário, numerando as opções:

1. Aprovar tudo e commitar as atualizações de produto (o pipeline então
   commita — e, se o usuário confirmar explicitamente, também dá push — as
   mudanças em `product-capabilities.md` no(s) repositório(s) de produto
   correspondente(s)).
2. Aprovar o relatório mas não commitar nada agora (as atualizações de
   `product-capabilities.md` ficam registradas apenas localmente, para uma
   decisão futura).
3. Pedir ajustes (especificar o quê) — volta a um dos steps anteriores
   conforme o ajuste pedido.

Se não houve nenhuma atualização de `product-capabilities.md` nesta
execução, omitir a menção a commit e perguntar apenas se o resumo executivo
está aprovado ou se precisa de ajuste.

## Output Format

The output MUST follow this exact structure:
```markdown
# Aprovação Final — {data}

## Veredito do Revisor
{veredito completo de revisao.md, incluindo tabela de critérios}

## Resumo Executivo
{conteúdo completo de resumo-executivo.md}

Versão HTML disponível em: `squads/reporter/output/resumo-executivo.html`

## Atualização de Produto Nesta Execução
{resumo do que Paulo Produto atualizou, ou "Nenhuma atualização de product-capabilities.md nesta execução — commit não se aplica"}

## Decisão do Usuário
{1, 2 ou 3, conforme escolhido, com detalhe de ajuste se opção 3}

## Ação de Commit/Push
{"Commit realizado em {repositório}, arquivo product-capabilities.md" / "Push também realizado, a pedido explícito do usuário" / "Nenhum commit realizado — atualização permanece apenas local" / "N/A — sem atualização de produto nesta execução"}
```

## Output Example

```markdown
# Aprovação Final — 2026-08-23

## Veredito do Revisor
==============================
 VEREDITO: APROVAR COM RESSALVAS
==============================
| Critério | Nota | Motivo |
|---|---|---|
| Consistência planilha x resumo | 9/10 | Todos os achados citados no resumo batem com a planilha |
| Consistência Markdown x HTML | 10/10 | Conteúdo idêntico, HTML autocontido |
| Rigor de confiança | 8/10 | Achado #3 corretamente marcado como sinal fraco |
| Base real de relevância | 10/10 | Toda comparação remete a product-capabilities.md |
| Política de git (Paulo Produto) | 10/10 | Nenhuma operação git executada, apenas leitura via worktree |
**Geral: 9.25/10**

## Resumo Executivo
# Resumo Executivo — Monitoramento de Concorrentes (semana de 2026-08-17 a 2026-08-23)
14 concorrentes monitorados, 6 achados relevantes identificados (4 de alta confiança, 2 sinais fracos)...
[conteúdo completo]

Versão HTML disponível em: `squads/reporter/output/resumo-executivo.html`

## Atualização de Produto Nesta Execução
E-LIMS: main avançou de `ad10947` para `f3a9c21`. Nova seção "Ingestão de
Telemetria de Equipamento" adicionada ao product-capabilities.md, com
evidência do controller `EquipmentTelemetryController.cs`. Nenhuma operação
git foi executada por Paulo Produto — commit não realizado, aguardando esta
decisão.

## Decisão do Usuário
2. Aprovar o relatório mas não commitar nada agora — usuário quer revisar a
   redação da nova seção antes de tornar a mudança permanente.

## Ação de Commit/Push
Nenhum commit realizado — atualização permanece apenas local em
product-capabilities.md do repositório E-LIMS.
```

## Notes

- Nunca commitar ou dar push automaticamente, em nenhuma circunstância — a
  decisão é sempre explícita do usuário, mesmo quando o veredito do revisor
  é APROVAR sem ressalvas.
- Se o usuário escolher a opção 1 mas não mencionar push, tratar como
  "commit local apenas" e perguntar separadamente se deve também dar push —
  nunca assumir push por padrão.
- Se o usuário pedir ajustes (opção 3), identificar se o ajuste é no resumo
  executivo (volta ao Step 5), na estruturação dos achados (volta ao Step 4)
  ou na atualização de produto (volta ao Step 2), e registrar isso
  claramente no output antes de reencaminhar o pipeline.
