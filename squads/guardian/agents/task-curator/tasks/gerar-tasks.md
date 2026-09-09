---
task: "Gerar Tasks"
order: 1
input: |
  - itens_aprovados: achados de auditoria (TD/SEC/DOC-NN) ou linhas da quebra por camada de plano-implementacao.md, aprovados pelo usuário no Step 06 (squads/guardian/output/achados-selecionados.md)
output: |
  - tasks_geradas: uma GT-NNNN.md por item, salva em squads/guardian/tasks/backlog/ (squads/guardian/output/tasks-geradas.md)
  - tasks_no_repo_alvo: uma TASK-NNN.md por item, salva em <repo-de-produto>/.agents/tasks/backlog/, referenciando o GT correspondente
---

# Gerar Tasks

Transcreve cada achado/linha de plano aprovado em uma task estruturada
(`GT-NNNN.md`), no formato do template do Guardian. **Nunca chama `gh`** —
essa é a diferença central em relação a `curar-issues.md`: aqui a task fica
pronta em `tasks/backlog/`, aguardando o Gate de Promoção antes de qualquer
issue existir. Nunca decide se um item avança — isso já foi decidido pelo
usuário no Step 06 — apenas transcreve com fidelidade e rastreabilidade.

## Process

1. Para cada item aprovado, localizar o texto completo de origem: achado no
   relatório do auditor correspondente (modo auditoria-nova) ou linha da
   quebra por camada em `plano-implementacao.md` (modo implementacao-direta).
2. Determinar o próximo `GT-NNNN` livre escaneando
   `squads/guardian/tasks/{backlog,active,completed}/*.md`.
3. Preencher o template (`squads/guardian/tasks/_template.md`) com fidelidade
   total: nunca rebaixar severidade, nunca resumir a evidência a ponto de
   perdê-la, nunca inventar critério de aceitação que a origem não sustenta.
4. Salvar em `squads/guardian/tasks/backlog/GT-NNNN-{slug}.md`, com
   `status: backlog` e `run_origem` preenchido.
5. **Emitir a task de execução no repositório de produto** (decisão do dono do
   produto, 2026-09-09 — ver TASK-060 no GeoCloudAI). Para cada `GT-NNNN`
   gerado, escrever também um `TASK-NNN.md` em
   `<repo-de-produto>/.agents/tasks/backlog/`, usando o `_template.md` **daquele
   repositório**, não o do Guardian.

   Os dois arquivos não são cópia um do outro, e é por isso que existem dois:

   - o `GT` responde **por que isto entrou na fila** — o achado, a evidência, a
     severidade, a run de origem — e vive no hub do squad, junto do histórico de
     auditoria que dá sentido a ele;
   - o `TASK` responde **como será feito** — regras de negócio, critérios de
     aceitação, plano, e depois o Registro de Execução — e vive ao lado do
     código que descreve, versionado, para ser revisado no mesmo PR.

   **A referência cruzada é obrigatória nos dois sentidos**: o `GT` cita o
   caminho do `TASK`, e o front-matter do `TASK` cita o `GT` em
   `origem_guardian`. Sem isso, dois registros do mesmo trabalho divergem na
   primeira alteração e ninguém sabe qual vale.

   Numeração: o `TASK-NNN` continua a sequência **do repositório de produto**
   (varrer `.agents/tasks/{backlog,active,completed}/`), nunca a do Guardian —
   são duas sequências independentes, e alinhá-las daria a falsa impressão de
   que `GT-0041` e `TASK-0041` são o mesmo documento.

   Se o repositório de produto não tiver `.agents/` (não foi bootstrapado), não
   inventar a estrutura: gerar só o `GT` e registrar a ausência em
   `tasks-geradas.md`, para o dono do produto decidir.
6. Registrar o resultado em `tasks-geradas.md`.

## Output Format

```yaml
tasks_geradas:
  - origem: "SEC-01"                 # ou "plano-implementacao: backend"
    task_id: "GT-0001"
    arquivo: "squads/guardian/tasks/backlog/GT-0001-sec-01-allowanonymous-address-add.md"
    titulo: "Corrigir AllowAnonymous sem justificativa em POST /Address/add"
    camada_provisoria: "backend"
    task_repo_alvo: "GeoCloudAI/.agents/tasks/backlog/TASK-061-allowanonymous-address-add.md"
```

## Quality Criteria

- Toda task gerada preenche as seções obrigatórias do template — "N/A" explícito quando não aplicável, nunca omitido em silêncio.
- Toda task tem evidência concreta e critério de aceitação claro.
- Todo item aprovado foi processado — nenhum ficou de fora.
- Todo `GT` gerado tem o `TASK` correspondente no repo de produto, e os dois se citam — ou a ausência de `.agents/` está registrada explicitamente.

## Veto Conditions

Reject e refaça se QUALQUER uma for verdadeira:
1. Uma task foi gerada com severidade rebaixada em relação à origem.
2. Um item aprovado não aparece no output (nenhuma `GT-NNNN` correspondente).
3. Uma `GT-NNNN` reaproveitou um número já usado por outra task existente.
4. Um `GT` foi gerado sem o `TASK` correspondente no repo de produto, num repositório que **tem** `.agents/` — ou o par foi gerado sem referência cruzada nos dois sentidos.
5. Um `TASK-NNN` reaproveitou um número já usado no repositório de produto, ou copiou a numeração do Guardian em vez de seguir a sequência local.
4. Qualquer chamada `gh` foi feita nesta task.
