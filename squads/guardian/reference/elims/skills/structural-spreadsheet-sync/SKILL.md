---
name: structural-spreadsheet-sync
description: Mantém a planilha estrutural canônica (Atributos, Metodos_Back, Permissões) do ELIMS sincronizada com o código da branch main, sempre que uma classe/endpoint for criado, removido ou alterado. Use junto com documentation-sync sempre que a mudança afetar entidade, DTO, controller ou permissão.
---

# Structural Spreadsheet Sync

## Objetivo

A planilha canônica deste produto cobre **somente a branch `main`**, no mesmo padrão do GeoCloud:

`Documentation/Main/Planilha_ELIMS_main.xlsx`

(`Documentation/Main/Planilha_ELIMS_main.xlsx`)

Não gravar `Planilha_ELIMS_*.xlsx` na raiz de Miscelaneous nem em `docs/estrutura/`. Não criar pasta/planilha para outras branches. Abas: `Base`, `Atributos`, `Metodos_Back`, `Permissões`. Não criar aba nova.

A coluna OBSERVAÇÃO só registra divergência ainda verdadeira no código da `main`.

## Entradas

- Classe/entidade criada, removida ou alterada (nome, produto).
- Endpoint(s) de Controller adicionados/removidos/alterados (rota, permission key).
- Campo(s) de model/DTO/front adicionados/removidos/renomeados.

## Saídas

- Linhas atualizadas nas abas `Atributos`, `Metodos_Back`, `Permissões` da planilha da `main`.

## Formato canônico (não inventar um novo)

### Aba `Atributos`

Cabeçalho por classe:
`<Classe>,,,DATABASE,,PK,FK,AI,NN,UQ,,BACK MODEL,,,BACK DTO,,REQ,MIN,MAX,,FRONT,,,NOTAS`

Uma linha por atributo. FK sempre em **2 linhas** (coluna física + propriedade de navegação):
```
,,,accountid,int,,Account,,X,,,AccountId,int,,AccountId,int,X,,,,accountId?,number
account,Account,,,,,,,,,,Account,Account?,,Account,AccountDto?,,,,,account?,Account
```
`PK`/`AI`/`NN`/`UQ` = `X` quando aplicável. `FK` = nome da classe referenciada. `*`/`?` no tipo =
opcional/nullable. Célula de nota (última coluna) é livre — usar para qualquer divergência
código×banco×front observada (ex.: "no modelo/DTO; NÃO no banco vivo").

**Espaçamento:** exatamente **duas linhas em branco** entre cada tabela. Título de seção
(`CORE / AUTENTICACAO / ADMINISTRACAO`, etc.) **sem preenchimento**, com **uma linha em branco
sem cor** imediatamente abaixo; a primeira tabela da seção vem depois. Cabeçalho da tabela:
fundo `#FFC000`, negrito, altura 18,75 — **colunas-espaçador** (C, K, N, T, W em `Atributos`)
ficam sem preenchimento, como divisória entre os blocos lado a lado.

### Aba `Metodos_Back`

Por classe: nome da classe em uma linha, depois cabeçalho fixo
`CONTROLLER,Chave,,,SERVICE,,REPOSITORY,Filtro,Ordem`, depois uma linha por método público do
Controller com a assinatura do Controller, a permission key (ou `AllowAnonymous`), e as assinaturas
correspondentes de Service/Repository.

### Aba `Permissões`

Por classe: nome da classe + cabeçalho `Rota (Back),Chave de Permissão,Observação`, depois uma linha
por endpoint com a rota HTTP e a permission key exigida.

## Fluxo

1. Abrir `Documentation/Main/Planilha_ELIMS_main.xlsx`.
2. Identificar a classe afetada nas 3 abas (buscar pelo nome exato da classe).
3. Aplicar a mudança seguindo exatamente o formato acima — não improvisar uma coluna nova sem atualizar o cabeçalho de todas as classes.
4. Salvar só nessa pasta. Não gravar em Miscelaneous nem em `docs/estrutura/`.
5. O agente/playbook invocador também roda `documentation-sync` (as duas skills não se chamam entre si — orquestração é do agente/playbook, ver `MASTER_PROMPT.md` §6).

## Limitações

- Não infere schema do banco vivo (sem acesso à conexão real) — os dados de `DATABASE`/`PK`/`FK`/etc.
  vêm da leitura do código-fonte (migrations/scripts SQL, entidades). Se houver divergência conhecida
  entre código e banco vivo, registrar na coluna de nota, não silenciar.

## Quando usar

Toda vez que uma classe, DTO, endpoint, permissão ou campo de model for criado, removido ou alterado no ELIMS (`main`).

## Quando não usar

Mudanças que não alteram estrutura pública (banco, contrato de API, model/DTO) — ex.: refactor interno sem mudança de assinatura.
