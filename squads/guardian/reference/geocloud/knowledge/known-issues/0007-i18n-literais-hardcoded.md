---
id: KI-0007
title: i18n via uiText/LITERALS com dicionários incompletos por idioma
severidade: média
status: aberta
produto: GeoCloud
---

## Descrição

O frontend do GeoCloud usa dois mecanismos de i18n em paralelo:

1. Chaves estruturadas `KEY | translate` (ngx-translate) em
   `web/src/assets/i18n/{en,es,pt}.json`. Após a etapa de i18n `es` do
   PR [#265](https://github.com/Essencis-Labs/GeoCloudAI/pull/265), o `es.json`
   espelha o `en.json` (3341 chaves, 0 faltando).
2. `uiText` / `LITERALS` — texto-fonte-como-chave (estilo gettext). O template
   passa a string literal para o pipe `uiText`
   (`web/src/app/pipes/ui-text.pipe.ts`), que procura em `LITERALS[<texto>]` do
   idioma ativo e cai no próprio texto quando não acha.

Medição em 21/08/2026 (branch `cursor/hallucination-full-61b7`):

- **5287** bindings `uiText` em 231 templates.
- Namespace `LITERALS` com **1920** entradas; no `es.json`, ~891 ainda iguais ao
  inglês. O `pt.json` deixa ~886 sem traduzir — dívida de **todos** os locais.
- Parte é UI legítima (`Add <Entidade>`, `Enter name`); parte é português
  hardcoded em componentes novos (finance, rede neural, viewer 3D); parte é
  ruído de extração (`alt="Header Avatar"`).

Não é bug de binding: o padrão fonte-como-chave funciona. O que falta é dado
completo no dicionário. A etapa de alta visibilidade do PR #265 já traduziu
títulos "Agregar …", breadcrumbs e nomes de entidade; o grosso permanece.

**Canônico no produto** (não duplicar o texto longo aqui — ADR-0002):
`GeoCloudAI/Documentation/Hallucination/known-issues/0001-i18n-literais-hardcoded.md`
(lá o ID local é **KI-0001** da pasta Hallucination; neste framework o número
livre é **KI-0007**, porque [KI-0001](0001-permissoes-inertes-em-runtime.md) já
é "permissões inertes em runtime").

## Ação recomendada

Tarefa dedicada, faseada, no frontend:

1. Higienizar `LITERALS`: remover ruído (fragmentos com `"`, `<`, `=`, `(`).
2. Completar traduções legítimas de `LITERALS` para `es` **e** `pt` (reusar
   chaves estruturadas quando o texto coincide). É tarefa de dados, não
   reescrita de código.
3. **Não** migrar os 5287 bindings `uiText` para `KEY | translate` — alto
   risco/custo sem benefício proporcional.
4. Prevenção: lint/CI que liste `uiText` sem entrada traduzida; política de
   não hardcodar português em componente (texto-fonte em inglês + `LITERALS.pt`).

## Dono

Frontend Architect + Documentation Architect.
