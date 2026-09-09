---
id: GADR-0002
title: Adoção do KoreGeo3 como visualizador padrão (descontinuação do KoreGeo2)
status: accepted
date: 2026-09-02
deciders: [Sergio Mendes]
related_tasks: [GT-0023, GT-0024, GT-0025]
produtos_afetados: [GeoCloudAI]
---

# GADR-0002 — Adoção do KoreGeo3

## Contexto
KoreGeo2 e KoreGeo3 coexistem hoje; a issue #323 partiu de 2 gaps conhecidos (faixas de litologia, barra lateral de marcação/profundidade) e pedia confirmar se havia mais. A própria issue #323 (E5-01) já pede um ADR formal como critério de aceitação.

**Achado que muda o escopo desta decisão (investigação de código, 2026-09-02)**: os 2 gaps conhecidos **não são funcionalidades ausentes** — são causadas por um único trecho de código comentado. Em `drill-hole-view-koregeo3.component.ts`, `loadDrillCores()` (linhas 196-219) tem o laço que carregaria anotações/overlays para todos os testemunhos **comentado**, e `ngOnInit()` (linhas 172-178) tem `getColors()`/`loadDepthMarkers()` também comentados. Isso desliga, de uma vez, o carregamento automático de litologia, fratura, alteração, mineralização, textura, estrutura e marcadores de profundidade salvos — não é ausência de feature, é feature presente e desligada. O HTML da barra lateral já é idêntico entre KoreGeo2 e KoreGeo3.

Além disso, a investigação achou **3 gaps reais adicionais**, não mapeados na issue original:
1. Botão de anotação por testemunho individual — no KoreGeo2, cada imagem tem seu próprio botão; no KoreGeo3 há um único botão global que só afeta o testemunho de índice 0.
2. Destaque visual (highlight) do testemunho ativo por hover/clique — existe no KoreGeo2, não tem equivalente no KoreGeo3.
3. Fallback de imagem quebrada (`onImageError`, tenta uma URL alternativa) — existe no KoreGeo2, não tem equivalente no KoreGeo3.

(Um 4º item, o rótulo de divisor de caixa, é uma melhoria do KoreGeo3 sobre o KoreGeo2, não um gap.)

## Decisão
**Alternativa A aceita (2026-09-02)**: reativar o carregamento comentado em `drill-hole-view-koregeo3.component.ts` (`loadDrillCores()`, `getColors()`, `loadDepthMarkers()`) e portar os 3 gaps reais (botão de anotação por core, highlight do core ativo, fallback de imagem quebrada) antes de definir data de corte do KoreGeo2. Ver GT-0024/GT-0025 com escopo expandido para cobrir os 3 gaps novos.

**Escopo extra confirmado pelo usuário (2026-09-02)**: depois da implementação concluída na branch, remover (comentar com `//`, não apagar) todas as guias de visualização que não são Images, Single View, MultiView ou KoreGeo3. Investigação de código (`drill-hole-view.component.html`) identificou as guias afetadas: **KoreGeo** (v1, sem número, `ngbNavItem="7"`), **KoreGeo 2** (`ngbNavItem="8"`), e **Images 2** (`ngbNavItem="4"`, componente `app-drill-hole-view-images2`) — esta última não estava mapeada em nenhuma issue original, achada só agora; confirmar com o usuário antes de comentá-la (ver GT-0027). `drillHoleViewUnic`/Single View, `drillHoleViewMult`/MultiView e o tab "Images" (`app-drill-hole-view-images`) permanecem.

## Alternativas consideradas

### Alternativa A — Reativar o carregamento + portar os 3 gaps reais, depois definir corte (recomendada)
Descomentar o carregamento automático em `loadDrillCores()`/`ngOnInit()` (baixíssimo esforço, resolve os 2 gaps originais), depois portar os 3 gaps novos (botão de anotação por core, highlight, fallback de imagem) — esforço moderado, isolado por item. Só define data de corte do KoreGeo2 depois dos 3 portados e validados.
- Vantagens: escopo real é muito menor do que a issue original presumia para os 2 gaps "conhecidos"; os 3 novos são bem delimitados (um método/comportamento cada).
- Desvantagens: ainda depende de portar 3 itens antes do corte — não é "ligar uma chave e pronto".

**Achado novo do GT-0013 (2026-09-02), relevante para GT-0024/GT-0025**: o bug de desalinhamento corrigido no Single View (`drill-hole-view-unic`) tinha como causa raiz um descompasso de referencial de coordenadas do OpenSeadragon em cenário multi-imagem — e o código já suprimia o próprio aviso do OpenSeadragon sobre isso (`silenceMultiImageWarnings = true`) em vez de corrigir. `drill-hole-view-koregeo3.component.ts` tem exatamente essa mesma flag de supressão e não foi verificado — **checar se o KoreGeo3 sofre do mesmo bug de referencial antes de considerar a paridade completa** (isso não estava nem nos 2 gaps originais nem nos 3 novos já mapeados — é uma quarta categoria de risco, ainda não confirmada).

### Alternativa B — Rodar em paralelo (feature flag) até paridade total confirmada
Manter os dois visualizadores acessíveis, usuário escolhe, corte só quando os 5 gaps (2 originais + 3 novos) estiverem fechados e passar um período de uso real sem reclamação.
- Vantagens: risco zero de regressão percebida pelo usuário final durante a transição.
- Desvantagens: mantém 2 implementações vivas por mais tempo, custo de manutenção duplo enquanto isso.

### Alternativa C — Cutover imediato aceitando os 3 gaps novos como known-issue
Reativar o carregamento (resolve os 2 gaps originais) e cortar o KoreGeo2 imediatamente, documentando os 3 gaps novos como regressão aceita/known-issue a portar depois.
- Vantagens: mais rápido — remove a manutenção dupla logo.
- Desvantagens: usuário que dependia do botão de anotação por core individual, do highlight ou do fallback de imagem perde a função sem aviso até alguém notar e abrir issue.

**Recomendação do Jarvis**: Alternativa A. O achado de que os 2 gaps "grandes" são só código comentado muda o cálculo de esforço/risco — vale a pena portar os 3 itens reais antes de cortar, porque o custo total (reativar + 3 portes pequenos) é bem menor do que o time provavelmente estimou ao abrir a issue original.

## Consequências
### Positivas
### Negativas
Descontinuar o KoreGeo2 sem paridade completa quebra fluxo de quem depende das 2 funcionalidades ausentes.
### Riscos
Os 3 gaps novos (botão de anotação por core, highlight, fallback de imagem) não estavam mapeados na issue original — GT-0024/GT-0025 precisam ser atualizadas para cobri-los, não só os 2 gaps originais.

## Plano de adoção
GT-0023 (E5-01, decisão) bloqueia GT-0024 (E5-02, faixas de litologia — na prática, reativar o carregamento comentado) e GT-0025 (E5-03, barra lateral — idem). Os 3 gaps novos (anotação por core, highlight, fallback de imagem) precisam de uma task adicional ou de escopo ampliado em GT-0024/GT-0025 — a definir quando a Alternativa A for confirmada.

## Validação
Lista de paridade fechada e nenhuma funcionalidade do KoreGeo2 "esquecida" no corte.

## Revisão
Revisar a data de corte definida contra o progresso real de GT-0024/GT-0025.
