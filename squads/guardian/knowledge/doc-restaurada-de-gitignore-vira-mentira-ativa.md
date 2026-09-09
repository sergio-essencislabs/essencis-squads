# Doc restaurada de `.gitignore` para versionada precisa de reconciliação imediata — enquanto ignorada, um erro nela é inofensivo; assim que volta a ser citada como fonte, é o pior tipo de divergência

**Data:** 2026-09-01
**Origem:** reconciliação completa de `.specify/memory/**` no GeoCloudAI (branch
`docs/full-documentation-sync-2026-09-01`), depois que um commit anterior
(`020cbc9`) restaurou esses 9 arquivos como exceção versionada a um
`.gitignore` mais amplo.

## Lição

Um documento gitignored que afirma algo errado (`architecture.md` dizendo
PostgreSQL num sistema que já era MySQL, ou descrevendo um soft delete que
nunca existiu no schema) não tem custo prático **enquanto** ninguém o lê como
fonte de verdade — é só texto morto no disco de quem o criou. O erro é real,
mas inerte.

O momento em que isso muda não é quando o erro é introduzido — é quando o
arquivo **volta a ser versionado e citado como "fonte primária"** por outros
documentos vivos (neste caso, 6 arquivos diferentes, incluindo `AGENTS.md` e
`.agents/context/CONTEXT.md`, passaram a apontar para
`.specify/memory/architecture/architecture.md` como referência oficial de
arquitetura assim que ele foi restaurado). Nesse instante, uma afirmação
errada deixa de ser "documentação desatualizada que ninguém lê" e vira
exatamente o pior tipo de divergência pelos princípios do próprio squad
("doc afirma implementado quando não está" / vice-versa, com prioridade
máxima) — só que **retroativa**: ela estava errada havia meses, mas só passa
a enganar alguém a partir do commit de restauração.

Achado concreto nesta rodada: a mentira mais grave não era a mais óbvia
(PostgreSQL vs. MySQL, fácil de pegar num grep). Era uma seção inteira de
"soft delete universal" (`deleted_at`/`deleted_by`, `ISoftDeletableEntity`,
filtro obrigatório em todo SELECT/UPDATE/join) que **nunca existiu** no
schema real — confirmado por: zero colunas `deletedAt`/`deletedBy` em
qualquer `CREATE TABLE` do dump real, `ISoftDeletableEntity` ausente de
`Back.Domain` (nem pasta `Abstractions/` existe), e 90 dos 96 repositórios
usando `DELETE FROM` físico. Essa narrativa fictícia estava espalhada por
**5 arquivos diferentes** do mesmo Spec Kit (`architecture.md`, `database.md`,
`backend.md`, `domain.md`, e os dois diagramas grandes) — porque cada um
citava o outro como já correto, o erro nunca foi contestado internamente.

## Como aplicar

- Ao restaurar (ou "des-gitignorar") qualquer documento que descreve
  comportamento de sistema — não só Spec Kit, qualquer doc técnico que saia
  do estado "ninguém lê isso" para "fonte primária citada por outros
  documentos" — trate a restauração como gatilho automático para uma
  reconciliação completa contra o código real, não como um simples "restaurar
  e seguir em frente". A restauração do arquivo e a auditoria do seu conteúdo
  são a mesma tarefa, não duas tarefas separadas que podem ser adiadas.
- Não confiar na aparência de detalhe/precisão de uma seção como sinal de que
  ela é correta. A seção de soft delete deste caso era longa, específica,
  com exemplos de código e uma justificativa de negócio coerente ("dados de
  sondagem são caros, exclusão precisa ser reversível") — e era inteiramente
  fictícia. Densidade de detalhe não é evidência de veracidade.
- Quando uma alegação aparece repetida em múltiplos documentos do mesmo
  conjunto (ex.: "soft delete universal" em 5 arquivos), isso não é
  corroboração — é sinal de que os documentos foram escritos citando uns aos
  outros, não o código. Verificar a alegação uma vez contra o código real e
  aplicar a correção em todos os arquivos que a repetem, em vez de tratar
  cada repetição como confirmação independente.
- Vale tanto para GeoCloudAI quanto para E-LIMS: qualquer projeto que
  mantenha documentação técnica gitignored "para uso local" corre o mesmo
  risco assim que alguém decide versioná-la de novo.
