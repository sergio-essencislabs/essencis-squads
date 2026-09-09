---
execution: inline
agent: writer
inputFile: squads/reporter/output/planilha-concorrentes.md
outputFile: squads/reporter/output/resumo-executivo.md
outputFileHtml: squads/reporter/output/resumo-executivo.html
---

# Step 05: Resumo Executivo

## Context Loading

Load these files before executing:
- `squads/reporter/output/planilha-concorrentes.md` — achados
  estruturados desta semana, com concorrente/tema, novidade, data, fonte,
  categoria, confiança e relevância competitiva por linha
- `squads/reporter/output/research-brief.md` — research brief
  original de Rita Radar, para contexto adicional sobre lacunas e ângulos que
  não couberam na planilha
- `squads/reporter/agents/writer.agent.md` — persona de
  Beatriz Briefing, tom direto e orientado a dados da Essencis, sem
  embelezamento

## Instructions

### Process

1. Ler a planilha estruturada por completo e o research brief original, para
   ter tanto o dado consolidado quanto o contexto que não entrou na tabela.
2. Identificar os 3-5 achados de maior relevância competitiva real —
   priorizar por confiança e por impacto direto em uma capacidade real do
   GeoCloudAI/E-LIMS (nunca listar todos os achados da planilha).
3. Escrever um parágrafo de abertura com o panorama quantitativo da semana:
   quantos concorrentes foram monitorados, quantos achados no total, quantos
   de alta confiança, e se há algum padrão emergente entre eles.
4. Para cada achado priorizado, escrever 1-2 frases: o que aconteceu + por
   que importa para GeoCloudAI/E-LIMS, remetendo à linha específica da
   planilha. Nunca usar qualificador vago ("acompanhar de perto") sem ligar a
   uma implicação concreta.
5. Se algum achado priorizado tiver confiança baixa ou média, marcar isso
   explicitamente no texto — nunca apresentar com o mesmo peso de um achado
   de alta confiança.
6. Fechar com uma seção de lacunas: o que não foi possível confirmar esta
   semana (achados descartados por fonte única, rumores não confirmados,
   etc.), puxando do research brief quando a planilha não cobrir isso.
7. Salvar a versão em Markdown em `resumo-executivo.md`, seguindo exatamente
   o Output Format abaixo.
8. Gerar `resumo-executivo.html` com o MESMO conteúdo do Markdown — mesmo
   texto, mesma priorização, mesma seção de lacunas, nunca resumido mais ou
   menos entre as duas versões — como um documento HTML autocontido: CSS
   inline em um único `<style>` no `<head>`, sem CDN/fonte externa/link
   externo, usando fontes de sistema (`system-ui`, `-apple-system`,
   `sans-serif`), com esquema de cores que funcione tanto em modo claro
   quanto escuro via `@media (prefers-color-scheme: dark)`. O arquivo deve
   abrir direto no navegador ou ser anexado/encaminhado por e-mail/Slack sem
   nenhuma dependência de rede.

## Output Format

The Markdown version MUST follow this exact structure:
```markdown
# Resumo Executivo — Monitoramento de Concorrentes (semana de {data início} a {data fim})

{parágrafo de abertura com panorama quantitativo da semana}

## Principais achados
1. **{Concorrente/tema} — {título curto}** ({nível de confiança}): {o que
   aconteceu + por que importa para GeoCloudAI/E-LIMS}.
{repetir para cada achado priorizado, máximo 5}

## Lacunas desta semana
{o que não foi possível confirmar, com motivo}
```

The HTML version must mirror this exact structure and content — mesmo
título, mesmo parágrafo de abertura, mesma lista numerada de achados na
mesma ordem, mesma seção de lacunas — envolvido em um documento HTML mínimo
autocontido (`<!DOCTYPE html>`, `<head>` com um único bloco `<style>` inline,
`<body>` com o conteúdo). Nenhum `<link>`, `<script src>` ou `@import`
externo é permitido.

## Output Example

```markdown
# Resumo Executivo — Monitoramento de Concorrentes (semana de 2026-08-17 a 2026-08-23)

14 concorrentes monitorados, 6 achados relevantes identificados (4 de alta
confiança, 2 sinais fracos). Destaque da semana: Seequent lançou modelagem
implícita com IA — primeiro concorrente direto a aplicar IA generativa na
etapa de modelagem geológica, área onde o GeoMind hoje atua só em consulta e
análise, não em geração de modelo.

## Principais achados
1. **Seequent — IA em modelagem implícita** (alta confiança): lançou módulo
   de modelagem implícita com IA generativa (comunicado oficial de
   2026-08-15, corroborado por Mining Technology). GeoCloudAI já tem
   modelagem geológica explícita/implícita (módulo 17), mas sem componente
   de IA nessa etapa específica — ponto de atenção competitivo para o
   roadmap do GeoMind.
2. **KoBold Metals — nova rodada de investimento** (alta confiança): sem
   comparação direta de capacidade de produto, mas sinaliza capital
   disponível para concorrência de IA-first em exploração mineral.
3. **Micromine — possível integração XRF portátil** (confiança baixa, sinal
   fraco): mencionado em fórum de usuários, sem confirmação oficial da
   Micromine até o fechamento desta semana.

## Lacunas desta semana
Não foi possível confirmar oficialmente o rumor de integração XRF da
Micromine (fonte única, baixa confiança). Nenhuma novidade verificada de
Datarock ou CorePlan nesta janela — seguem no radar para a próxima execução.
```

## Veto Conditions

Reject and redo if ANY of these are true:
1. A versão HTML tem conteúdo diferente da versão Markdown (mesmo texto é
   obrigatório nas duas — nunca dois resumos diferentes).
2. O HTML depende de recurso externo (CDN, fonte web, link, script externo)
   em vez de ser totalmente autocontido.
3. O resumo lista mais de 5 achados ou lista a planilha inteira sem
   priorização.
4. Algum achado de confiança baixa/média aparece sem marcação explícita,
   com o mesmo peso de um achado de alta confiança.
5. A seção de lacunas está ausente ou vazia sem justificativa.
6. Alguma afirmação de relevância não remete a uma linha específica da
   planilha estruturada.

## Quality Criteria

- [ ] Resumo executivo tem no máximo 5 achados priorizados, nunca a lista completa.
- [ ] Toda afirmação de relevância remete a uma linha específica da planilha.
- [ ] Seção de lacunas está presente e não vazia.
- [ ] Abertura traz o panorama quantitativo da semana (concorrentes monitorados, total de achados, achados de alta confiança).
- [ ] Versão HTML tem conteúdo idêntico à versão Markdown.
- [ ] Versão HTML é autocontida (CSS inline, sem CDN/fonte/link externo) e legível em claro e escuro.
