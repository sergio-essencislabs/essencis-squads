---
id: GT-0016
title: "Spike: levantar parâmetros e camadas de dados usados pelo IMAGO"
status: active
type: feature
achado_origem: "N/A — pedido direto de implementação"
auditor_origem: "Jarvis — planejamento"
severidade: "N/A — spike, bloqueante de GT-0017"
produto: GeoCloudAI
camada: frontend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/322"
grupo_execucao: "Onda 1"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-02
affected_modules: [single-view]
related_adrs: []
contraparte: "N/A — anterior à TASK-060; .agents/tasks/ não existia quando esta GT nasceu"
---

# GT-0016 — Spike: parâmetros/camadas do IMAGO

## Par no repositório de produto

**Não há par, e ele não foi perdido.** Esta GT é de 2026-09-02; o diretório `.agents/tasks/` do
GeoCloudAI só passou a existir em 2026-09-09, no commit `8e10d774` (TASK-060). O mecanismo de
par não existia quando ela nasceu — o `contraparte:` não é ponteiro quebrado, é ausência
decidida.

**A ausência é decisão, não buraco — e não é por falta de informação.** A rastreabilidade do
lado-produto continua alcançável pelo que este arquivo já cita: issue, PR ou commit. Há por
onde chegar ao que foi feito; o que não há é um registro do lado de lá, porque não havia onde
escrevê-lo.

Um par criado hoje acrescentaria um ponteiro a uma rota que já funciona, e pagaria por isso
afirmando, pela própria existência, que o mecanismo de par cobria esta GT. Seria **registro
com proveniência falsa** — a mesma inversão de "planejado documentado como implementado",
com outra roupa. Por isso não foi criado.

Apurado na GT-0146 (issue #634), CA-07, em 12/09/2026. A busca forense e o controle positivo
ficam no registro daquela task e não são copiados aqui.

## Contexto
Levantar e documentar quais parâmetros o IMAGO expõe, para decidir o que entra em GT-0017 (E3-05). Ponto de partida: cores, geoquímica, mineralogia quantitativa, mapa hiperespectral, caixa molhada.

## Achado original
Corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/322. Entregável: documento comparativo (IMAGO × GeoCloudAI) listando cada parâmetro, origem do dado, e se é viável real ou mock nesta fase.

## Objetivo
Lista fechada de camadas a implementar em GT-0017, priorizada, com fonte do dado definida.

## Fora de escopo
Implementação das camadas (GT-0017).

## Comportamento atual
Sem levantamento formal.

## Comportamento esperado
Documento comparativo completo, GT-0017 refinada a partir do resultado.

## Regras de negócio
- RN-01: N/A.

## Critérios de aceitação
- [x] CA-01: Lista fechada de camadas a implementar, priorizada.
- [x] CA-02: Para cada camada: fonte do dado definida (real ou mock).
- [x] CA-03: GT-0017 (E3-05) refinada a partir deste resultado.

## Impacto técnico
### Frontend
Levantamento, sem implementação.
### Backend
Pode revelar necessidade de endpoint novo para geoquímica/mineralogia (confirmar com Breno).
### Banco de dados / Integrações / Segurança
N/A.

## Plano de implementação
- [ ] Levantar parâmetros do IMAGO.
- [ ] Documentar comparativo com GeoCloudAI.
- [ ] Definir fonte de dado por camada (real/mock).

## Estratégia de testes
- [ ] N/A — spike, sem código de produto.

## Riscos e rollback
Nenhum.

## Registro de execução
### Alterações realizadas
Investigação de código (sem acesso ao IMAGO em si) em `api/src/Back.Domain/Classes`, `api/src/Back.API/Controllers` e no single-view atual (`web/src/app/pages/geodata/drill-holes/drill-hole-view-unic/`). Para cada parâmetro do achado original (cores, geoquímica, mineralogia quantitativa, mapa hiperespectral, caixa molhada) mais camadas correlatas do mesmo domínio (mineralização tipo/gênese, textura, estrutura, alteração), confirmado se o dado é real (com onde está modelado) ou precisa ser mock. Documento comparativo completo publicado como comentário na issue #322 (não como arquivo em `docs/` — ver Decisões). Resumo com a lista priorizada também publicado como comentário na issue #338 (GT-0017), já refinando o escopo dela.

### Arquivos principais
Nenhum arquivo de produto alterado (spike). Nenhum arquivo novo no repositório GeoCloudAI — decisão de registrar via comentário nas issues (ver Decisões).

### Decisões
- Publicado como **comentário nas issues #322 e #338**, não como arquivo em `docs/`: os subdiretórios de `docs/` no repositório (`docs/modules`, `docs/domain`, etc.) têm convenção própria de documentação técnica estável por módulo/domínio (frontmatter `estado/fonte/ultima-revisao`, "não duplicar fonte primária") que não se encaixa bem num spike pontual; a issue já é o registro rastreável e linkável ao GT-0017.
- Confirmado que **nenhum endpoint novo é necessário** para as camadas reais levantadas (geoquímica e mineralogia incluídas) — a hipótese registrada no "Impacto técnico" original de GT-0016/GT-0017 (endpoint novo) não se confirmou; todos os controllers/services já existem.
- Ampliado o escopo do spike além dos 5 parâmetros originais do achado para incluir mineralização (tipo/gênese), textura, estrutura e alteração — são dados reais do mesmo domínio (testemunho de sondagem), já com `ImgRect` e services no frontend, mas ainda não expostos como camadas no seletor do single-view. Baixo custo de implementação dado que seguem exatamente o padrão já usado por Fracture/Lithology.
- "Cores" no IMAGO provavelmente significa colorimetria instrumentada (medição óptica contínua); o que existe hoje é `Color` (nome + hexadecimal) como cadastro de referência vinculado a `Lithology`, já usado no overlay de litologia — tratado como real parcial, não como camada nova.

### Divergências
Nenhuma divergência do achado original — apenas ampliação do escopo do levantamento (ver Decisões).

### Pendências
Nenhuma. GT-0017 já foi atualizada com a lista priorizada (ver arquivo GT-0017).

## Validação
- CA-01: lista priorizada de 9 camadas (mineralogia quantitativa, mineralização, textura, estrutura, alteração, geoquímica, cores, caixa molhada, mapa hiperespectral) publicada em https://github.com/Essencis-Labs/GeoCloudAI/issues/322#issuecomment-5514028049.
- CA-02: cada camada da lista tem fonte de dado real (classe de domínio + controller) ou mock explicitamente identificada na mesma tabela.
- CA-03: GT-0017 (arquivo local e issue #338) atualizada com a lista priorizada e a constatação de que não há endpoint novo necessário — https://github.com/Essencis-Labs/GeoCloudAI/issues/338#issuecomment-5514032501.

## Handoff
Bloqueia GT-0017 — desbloqueada. GT-0017 (arquivo e issue #338) atualizada com a lista priorizada resultante deste spike.
