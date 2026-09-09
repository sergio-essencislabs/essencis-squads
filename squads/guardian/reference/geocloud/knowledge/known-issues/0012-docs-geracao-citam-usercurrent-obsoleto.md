---
id: KI-0012
title: "4 documentos gerados do código nunca foram regerados após renames (UserCurrent e UploadImage corrigidos 2026-09-01; imgType* ainda pendente)"
severidade: média
status: parcialmente resolvida
produto: GeoCloud
---

## Descrição

`docs/system/README.md` (corrigido nesta rodada, 2026-08-31) citava um
controller `UserCurrent` com endpoint `refresh` — confirmado que não existe
em nenhum lugar de `api/src` (zero ocorrências). O controller real é
`UserLoginController`, com só `login`/`logout`; não há refresh token nem
detecção de reuso — o JWT é stateless, expira em 12h fixas
(`UserLoginService.TokenLifetimeHours`).

A mesma citação a `UserCurrent` também aparece nos 4 documentos descritos
como "gerados a partir do código real" (`api/docs/system/`):
`permission-rules.md`, `business-requirements.md`, `endpoint-usage.md`,
`attribute-mapping.md`. Isso sugere que os 4 foram gerados **antes** do
rename `UserCurrent`→`UserLogin` e nunca foram regerados desde então —
divergência estrutural, não um erro de digitação isolado.

**Extensão (2026-09-01, fechamento pós-merge do PR #298)**: a mesma classe de
problema foi achada de novo, por um caminho diferente — a reconciliação
completa de `GeoCloud.xlsx` (Atributos/Metodos_Back/Permissões) contra o
código real encontrou dois renames que a planilha não refletia
(`imgType*`→`ImgLogo`/`ImgBanner`, migration `004-upload-imagem-imglogo-imgbanner.sql`;
e a rota/nome real do endpoint de upload de imagem, `UploadImagem(int id[, bool logo])`,
que a planilha documentava como `UploadImage(string archiveName)`). **Correção
(2026-09-01, fechamento da auditoria de documentação)**: a caracterização
original — "cópia indevida do único caso onde esse nome é real,
`RoleController`" — estava imprecisa. `UploadImage(string archiveName)` é real
em **6 classes**, não só `Role`: `Role`, `DrillCore`, `DrillCoreAnnotation`,
`DrillCoreFracture`, `DrillCoreLithology` e `Lithology` (confirmado pelo
`[Route(...)]` real de cada controller). As ~19 outras classes citadas nos
documentos com essa assinatura usam de fato `UploadImagem(int id, bool logo)`
na rota `uploadImagem`.

**Resolução parcial (2026-09-01)**: os renames `UserCurrent`→`UserLogin`/
`AccountRegistration` e `UploadImage`→`UploadImagem` foram corrigidos nos 4
documentos (`permission-rules.md`, `business-requirements.md`,
`endpoint-usage.md`, `attribute-mapping.md`) — seção por seção, cada mudança
confirmada contra o controller/service real antes de escrever, sem
find-replace às cegas (ver PR do fechamento da auditoria de documentação,
branch `docs/full-documentation-sync-2026-09-01`). **O rename
`imgType*`→`ImgLogo`/`ImgBanner` continua sem corrigir** nos 4 documentos —
fora do escopo aprovado desta rodada; `attribute-mapping.md` ainda cita
`ImgTypeProfile`/`ImgTypeCover` (14 ocorrências, zero `ImgLogo`/`ImgBanner`).
Confirma a hipótese original: os 4 documentos foram gerados uma vez e nunca
regerados desde então, acumulando múltiplos renames não refletidos.

**Por que não corrigido nesta rodada**: esses 4 arquivos somam mais de
400 KB e são descritos como saída de um processo de geração (não edição
manual linha a linha, ao contrário de `docs/system/README.md`). Um
find-replace mecânico de `UserCurrent`→`UserLogin` resolveria a citação de
nome, mas não teria como confirmar se os ENDPOINTS/campos associados
(ex.: uma linha de `refresh` inteira em `permission-rules.md`) também
precisam ser removidos, sem o gerador real ou uma varredura completa
equivalente à que Selma/Breno fariam. Mesmo princípio já aplicado em
`_reconcile_structural_spreadsheet.py`: escrever uma correção adivinhada
num artefato curado é pior que registrar o gap.

## Evidência

```bash
grep -rl "UserCurrent" api/docs/
# api/docs/system/permission-rules.md
# api/docs/system/business-requirements.md
# api/docs/system/endpoint-usage.md
# api/docs/system/attribute-mapping.md
# api/docs/implementations/34-*, 36-*, 37-*, 39-* (relatórios históricos — não corrigir, são snapshot datado)

grep -rl "UserCurrent" api/src/
# (nenhum resultado)

# Extensão 2026-09-01
grep -c "imgTypeProfile\|imgTypeCover\|ImgTypeProfile" api/docs/system/attribute-mapping.md
# 14
grep -c "ImgLogo\|ImgBanner" api/docs/system/attribute-mapping.md
# 0
grep -n "uploadImage" api/docs/system/permission-rules.md | wc -l
# dezenas de linhas (ex.: linha 20, 55, 118, 463, 481, 516, 544, 562, 594, 659, 692, 729, 765, 785, 934, 951, 970, 1069, 1230, 1249, ...)
grep -n "UploadImage" api/docs/system/endpoint-usage.md | wc -l
# dezenas de linhas (Account, Company, CompanyType, CoreShed, Deposit, DepositType, DrillBox, DrillBoxStatus, DrillCore, DrillCoreAnnotation, DrillCoreFracture, DrillCoreLithology, DrillingType, Employee, EmployeeRole, Lithology, Mine, MineArea, MineAreaType, MineStatus, ...)
```

## Ação recomendada

**Restante do escopo**: aplicar o mesmo tratamento (reconciliação manual,
linha a linha, nunca find-replace às cegas) ao rename `imgType*`→
`ImgLogo`/`ImgBanner` nos 4 documentos — mesmo padrão já usado para
`UserCurrent` e `UploadImage`/`UploadImagem` nesta rodada. Não localizado (em
nenhuma das três rodadas até agora) o processo de geração original desses 4
documentos (citado em `Library/Products/GeoCloudAI/S - GeoCloudAI - Reference
Tables Map` como "gerados a partir do código real"); enquanto isso, tratar
como reconciliação manual continua sendo a única via confiável. Como a lista
de renames não-refletidos já passou por 3 rodadas de achados, uma auditoria
dedicada e completa desses 4 arquivos (nos mesmos moldes dos 15 agentes
usados para o `GeoCloud.xlsx` em 2026-09-01) provavelmente encontraria mais
drift do que só esses 3 renames — decisão de priorização cabe ao usuário, não
assumir urgência.

## Resolução

**Parcial (2026-09-01)**: `UserCurrent`→`UserLogin`/`AccountRegistration` e
`UploadImage`→`UploadImagem` corrigidos nos 4 documentos, branch
`docs/full-documentation-sync-2026-09-01`. `imgType*`→`ImgLogo`/`ImgBanner`
continua **pendente** — reabrir/rastrear separadamente se ninguém pegar no
próximo ciclo de auditoria.

## Dono

Documentation Architect (Marta) + Backend Architect (Breno, para confirmar o gerador ou a extração manual).
