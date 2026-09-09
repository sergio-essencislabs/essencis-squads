# Knowledge base cross-projeto do squad Guardian

Destino das lições de engenharia **cross-projeto** (valem para GeoCloudAI *e*
E-LIMS) registradas pela Marta no fechamento de cada run (Step 13 / task
`atualizar-documentacao.md`, passo 4).

Regras (as mesmas de sempre, só o endereço mudou):

- Lição **específica de um produto** → `.agents/memory/` do produto
  (`C:\Software\GeoCloud\GeoCloudAI\.agents\memory\` ou
  `C:\Software\ELIMS\ELIMS\.agents\memory\`), nunca aqui.
- Lição **cross-projeto** → um arquivo `.md` nesta pasta, nome descritivo em
  kebab-case, seguindo o template `reference/{produto}/templates/known-issue.md`
  ou prosa curta com evidência.
- **Nunca** a mesma lição nos dois lugares.
- Known-issues por produto continuam em
  `reference/{geocloud|elims}/knowledge/known-issues/` — esta pasta é só para
  o que atravessa os dois produtos.

Histórico herdado: os `knowledge/patterns/` e `knowledge/decisions/` antigos de
cada produto estão em `reference/{geocloud|elims}/knowledge/` — consulte-os
antes de criar entrada nova para não duplicar.
