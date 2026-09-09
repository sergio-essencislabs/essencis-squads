---
id: GADR-0001
title: Matriz de disponibilidade das guias por entidade (Images/Single View/MultiView/KoreGeo3)
status: accepted
date: 2026-09-02
deciders: [Sergio Mendes]
related_tasks: [GT-0004]
produtos_afetados: [GeoCloudAI]
---

# GADR-0001 — Matriz de disponibilidade das guias por entidade

## Contexto
As guias Images, Single View, MultiView e KoreGeo3 precisam aparecer em níveis diferentes da hierarquia (Region → Deposit → Mine → MineArea → DrillHole → DrillBox). Definir a regra num só componente/config evita implementação divergente entre as 4 guias — 4 issues dependem diretamente desta decisão (GT-0011/#328, GT-0019/#332, GT-0022/#340, GT-0026/#336).

## Decisão
**Alternativa C aceita (2026-09-02)**: Single View e KoreGeo3 exigem seleção obrigatória de furo ao abrir a partir de um nível agregador (reaproveitando a tela/endpoint `getByRegion` já existente); MultiView abre automaticamente com os N primeiros furos (`pageSize=10`, `direct=false`) e permite adicionar mais pelo seletor de GT-0020. Estratégia de carga: `pageSize=10`, `direct=false` por padrão, com recomendação de reativar um teto de `pageSize` no backend (`PageParams.MaxPageSize`, hoje comentado).

## Alternativas consideradas

**Achado que embasa as opções abaixo (2026-09-02)**: já existe infraestrutura pronta e reutilizada em todo o produto para listar entidades a partir de Region — `DrillHole/getByRegion` (`DrillHoleController.cs:197-226`, `DrillHoleRepository.cs:325+`), com paginação server-side real (`PageParams`, sem `maxPageSize` aplicado hoje) e um flag `direct` (furos ligados diretamente à Region vs. árvore inteira Region→Deposit→Mine→MineArea→DrillHole). O mesmo padrão está replicado para Deposit/Mine/MineArea/DrillBox/Sample/Commodity. A tela `region-view-drill-holes` já usa isso com `pageSize=10` e paginação via `ngx-bootstrap/pagination` — não é virtual scroll nem carga total.

### Alternativa A — Seleção obrigatória em todas as guias, reaproveitando a tela de listagem já existente
Abrir Single View/MultiView/KoreGeo3 a partir de Region primeiro mostra a lista paginada de furos (reuso direto do padrão `region-view-drill-holes` + `getByRegion`), usuário escolhe antes de qualquer guia carregar.
- Vantagens: reaproveita 100% de infra já existente e testada; nunca há risco de travar a tela, porque nada pesado carrega antes da escolha; consistente com o padrão que o resto do produto já usa.
- Desvantagens: 1 clique a mais antes de ver o furo, mesmo para quem só quer olhar o mais recente.

### Alternativa B — Agregação automática (top-N via a mesma paginação)
Guia abre já carregando os N primeiros furos (`pageSize` padrão, ex. 10) automaticamente via `getByRegion`, com paginação para ver mais.
- Vantagens: menos cliques.
- Desvantagens: não faz sentido para Single View/KoreGeo3, que são visualizadores de **1 furo por vez** — "qual dos 10 é o furo ativo por padrão" é arbitrário e confuso. Funciona melhor só para MultiView, que já é uma comparação multi-furo por natureza.

### Alternativa C — Híbrido por guia (recomendada)
Single View e KoreGeo3 (visualizadores de 1 furo) usam a Alternativa A (seleção obrigatória); MultiView (já uma comparação multi-furo, GT-0020) usa a Alternativa B — abre com os N primeiros furos via `getByRegion(direct: false, pageSize: 10)` e permite adicionar mais pelo seletor que GT-0020 já está construindo.
- Vantagens: cada guia usa o padrão que faz sentido para a própria natureza (1 furo vs. comparação); reaproveita a mesma infra de paginação nos dois casos.
- Desvantagens: regra não é "uma só para as 4 guias" — precisa documentar a exceção claramente na matriz (CA-05 de GT-0004, ordem/padrão por entidade).

**Recomendação do Jarvis**: Alternativa C. Uma regra única (A ou B puro) força uma experiência ruim em pelo menos um grupo de guias; o híbrido usa a mesma infraestrutura de paginação nos dois casos, só muda o gatilho (seleção vs. auto-carga).

**Estratégia de carga — recomendação complementar**: usar `pageSize=10` (mesmo padrão já em uso), `direct=false` por padrão (árvore completa, não só furos ligados diretamente à Region — é o que um geólogo esperaria ver). Como o backend não aplica `maxPageSize` hoje (comentado em `PageParams.cs`), recomendo reativar um teto server-side como parte desta decisão — nada impede hoje um front pedir `pageSize=100000` (já visto em outra tela do sistema) e travar a resposta numa Region com centenas de furos.

## Consequências
### Positivas
Fonte única de verdade para "que guia aparece onde" evita 4 implementações divergentes.
### Negativas
### Riscos
Decisão errada sobre comportamento em nível agregador (Region agregando furos vs. exigindo seleção) se propaga para as 4 guias.

## Plano de adoção
GT-0004 (E1-03) implementa a matriz + config compartilhada; só depois GT-0011, GT-0019, GT-0022, GT-0026 podem consumi-la.

## Validação
As 4 issues dependentes conseguem usar a mesma config sem reimplementar a regra.

## Revisão
Revisar se a matriz "tudo ✅ abaixo de Region" (proposta no `.md` original) sobrevive à decisão de estratégia de carga — Region com centenas de furos pode exigir uma exceção à matriz simples. Revisar também se o teto de `pageSize` recomendado foi de fato aplicado no backend (risco pré-existente, não introduzido por este projeto, mas relevante para ele).

**2026-09-02 (Sergio Mendes)**: matriz confirmada como sobrevivente (ver GT-0004, "Divergências") — a estratégia de carga por paginação já resolve o volume sem restringir a matriz. Teto de `pageSize` ainda não aplicado — auditoria completa dos ~79 call sites concluída (96 confirmados em 36 arquivos, ver GT-0004 "Pendências"); plano de migração e bug funcional separado registrados em [#350](https://github.com/Essencis-Labs/GeoCloudAI/issues/350) e [#349](https://github.com/Essencis-Labs/GeoCloudAI/issues/349), respectivamente. Não urgente — segue como dívida técnica planejada, não bloqueante para GT-0011/GT-0019/GT-0022/GT-0026.

**2026-09-03 (Sergio Mendes) — revisão pós-QA, reverte parcialmente a confirmação acima**: depois de testar a branch com Matheus, decidido que **KoreGeo3 deve estar disponível só a partir de DrillHole (e DrillBox)**, não nos 6 níveis — diferente do Single View e do MultiView, que continuam "tudo ✅ abaixo de Region" como confirmado em 2026-09-02. Motivo: KoreGeo3 é um visualizador de furo único (testemunho), diferente de Single View (também 1 furo, mas faz sentido escolher a partir de um nível agregador) — na prática, KoreGeo3 nunca precisava da seleção agregadora que GT-0026 implementou. `entity-guide.model.ts`: `koreGeo3.levels` passa de `ALL_LEVELS` para `['drillHole', 'drillBox']` (mesmo padrão de `images`). Isso desfaz o trabalho de GT-0026 (#369, já mesclado) — ver GT-0023/GT-0026 para o registro da reversão.
