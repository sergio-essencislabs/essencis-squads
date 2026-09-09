---
name: structural-spreadsheet-sync
description: Mantém a planilha estrutural canônica (Base, Atributos, Metodos_Back, Permissões) de GeoCloud sincronizada com o código real da branch `main`, sempre que uma classe/endpoint for criado, removido ou alterado. Use junto com documentation-sync sempre que a mudança afetar entidade, DTO, controller ou permissão.
---

# Structural Spreadsheet Sync

## Objetivo

Existe **uma única planilha canônica** para este produto, sempre refletindo a branch `main`:

`Documentation/Main/GeoCloud.xlsx`

Toda branch nova nasce da `main` — manter uma cópia de planilha por branch de trabalho é redundante
(decisão de 2026-08-25). As pastas `Documentation/FixModelsDto/` e `Documentation/Hallucination/` e
suas planilhas antigas (`Planilha_GEOCLOUD_*.xlsx`) foram **removidas** em 2026-08-25 — não recriar.

Não gravar `GeoCloud.xlsx` na raiz de Miscelaneous nem em `.cursor/skills/Documentation/`. Abas:
`Base`, `Atributos`, `Metodos_Back`, `Permissões`. Não criar aba nova.

**A aba `Base` é congelada por design — nunca editá-la, nem por script nem manualmente.** Foi enviada
por Luiz D'Amore para estabelecer o padrão de mapeamento originalmente; existe só para revisita/
referência histórica. Quem mapeia as classes reais do sistema é a aba `Atributos` (a `Base` cobre só
13 classes legadas em português e não é mantida).

## Entradas

- Classe/entidade criada, removida ou alterada.
- Endpoint(s) de Controller adicionados/removidos/alterados (rota, permission key).
- Campo(s) de model/DTO/front adicionados/removidos/renomeados.

## Saídas

- Linhas atualizadas em `Atributos`/`Metodos_Back`/`Permissões` de `GeoCloud.xlsx` (nunca em `Base`).
- Quando a divergência não é uma linha faltando simples (ex.: campo do banco sem mapeamento coerente
  no model/DTO/front), **não escrever nota na planilha** — abrir um achado (issue no GitHub Project,
  já que é sempre a `main`) em vez disso. A antiga coluna OBSERVAÇÃO de `Atributos` foi removida em
  2026-08-25 por esse motivo; ver `Documentation/Main/backlog-observacao-migrado.md` para o backlog
  que existia até a remoção.

## Formato canônico (não inventar um novo)

### Aba `Atributos`

Cabeçalho por classe (fundo `#FFC000`, negrito): `DATABASE|PK|FK|AI|NN|UQ|BACK MODEL|BACK DTO|REQ|MIN|MAX|FRONT`
— 23 colunas (A–W), sem coluna de nota. Uma linha por atributo. FK sempre em **2 linhas** (coluna
física + propriedade de navegação). `PK`/`AI`/`NN`/`UQ` = `X` quando aplicável. `FK` = nome da classe
referenciada. Um asterisco (`*`) no tipo marca campo **nullable/opcional** — não confundir com not-null
(isso é a coluna `NN`).

**Espaçamento:** exatamente **duas linhas em branco** entre cada tabela. Título de seção
(`CORE / AUTENTICACAO / ADMINISTRACAO`, etc.) **sem preenchimento**, com **uma linha em branco
sem cor** imediatamente abaixo; a primeira tabela da seção vem depois. Colunas-espaçador (C, K, N, T,
W em `Atributos`) ficam sem preenchimento, como divisória entre os blocos lado a lado. Script:
`Documentation/_apply_table_spacing.py` (nunca toca `Base`).

### Aba `Metodos_Back`

Por classe: nome da classe em uma linha (fundo `#FFC000`, negrito), depois cabeçalho fixo
`CONTROLLER|Chave|(vazio)|(vazio)|SERVICE|(vazio)|REPOSITORY|Filtro|Ordem`, depois uma linha por
método público do Controller com a assinatura do Controller, a permission key (múltiplas chaves na
mesma célula combinam com `+`, ex. `account.add+account.update`), e as assinaturas correspondentes de
Service/Repository. Uma coluna extra (C) referencia o id da regra de escopo em `Permissões` (ex. `p1`)
quando o endpoint tem condição extra além do `[RequiredPermission]`.

### Aba `Permissões`

Por classe: nome da classe, depois uma linha por regra de escopo (`p1 - <descrição>`, o verbo do
controller a que se aplica, e o trecho de código C# real da guarda de autorização).

## Fluxo

1. **Editar `GeoCloud.xlsx` diretamente via `openpyxl`**, não existe `.csv` intermediário para este
   produto (documentação anterior desta skill afirmava o contrário — corrigido em 2026-08-25; os
   scripts sempre operaram no `.xlsx` direto). Usar os 2 scripts versionados como base, não reescrever
   a lógica de formatação/detecção do zero:
   - `Documentation/_reconcile_structural_spreadsheet.py` — detecta chaves de permissão do Controller
     ausentes em `Metodos_Back` e classes com guarda de autorização sem seção em `Permissões`. Escreve
     um relatório em `Documentation/Main/reconciliation-report.md`; **não escreve linhas novas** —
     assinatura de Service/Repository e o trecho de código da guarda exigem conhecimento de backend
     (Breno Backend/Rui Register), não são inferíveis com segurança só a partir do Controller.
   - `Documentation/_apply_table_spacing.py` — normaliza espaçamento/formatação depois de qualquer
     edição manual das 3 abas editáveis.
2. Identificar a classe afetada nas abas do produto (buscar pelo nome exato da classe — cada bloco
   começa com o cabeçalho de classe, fundo `#FFC000`).
3. Aplicar a mudança seguindo exatamente o formato acima (posição das colunas, padrão de 2 linhas para
   FK, etc.) — não improvisar coluna nova sem atualizar o cabeçalho de todas as classes.
4. Rodar `_apply_table_spacing.py` depois de qualquer edição manual, para reconfirmar espaçamento e
   estilo de cabeçalho.
5. O agente/playbook invocador também roda `documentation-sync` para verificar se a mudança afeta outra
   documentação viva além da planilha (as duas skills não se chamam entre si — orquestração é do
   agente/playbook, ver `MASTER_PROMPT.md` §6).

## Limitações

- Não infere schema do banco vivo (sem acesso à conexão real) — os dados de `DATABASE`/`PK`/`FK`/etc.
  vêm da leitura do código-fonte (migrations/entidades). Divergência real entre código e banco vivo
  vira achado/issue, nunca nota silenciosa na planilha.
- Cobre apenas este produto (GeoCloud) e só a branch `main`. Não recria a convenção para outros
  projetos ou branches sem necessidade equivalente.

## Quando usar

Toda vez que uma classe, DTO, endpoint, permissão ou campo de model for criado, removido ou alterado
na `main` do GeoCloud.

## Quando não usar

Mudanças que não alteram estrutura pública (banco, contrato de API, model/DTO) — ex.: refactor interno
sem mudança de assinatura. Mudanças em branch de trabalho que ainda não foi mesclada na `main`.
