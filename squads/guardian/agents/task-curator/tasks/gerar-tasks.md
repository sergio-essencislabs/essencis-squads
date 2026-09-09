---
task: "Gerar Tasks"
order: 1
input: |
  - itens_aprovados: achados de auditoria (TD/SEC/DOC-NN) ou linhas da quebra por camada de plano-implementacao.md, aprovados pelo usuário no Step 06 (squads/guardian/output/achados-selecionados.md)
output: |
  - tasks_geradas: uma GT-NNNN.md por item, salva em squads/guardian/tasks/backlog/ (squads/guardian/output/tasks-geradas.md)
  - tasks_no_repo_alvo: uma GT-NNNN.md por item — MESMO número do GT do hub — salva em <repo-de-produto>/.agents/tasks/backlog/, com referência cruzada ao par
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
   gerado, escrever também um `GT-NNNN-{slug}.md` em
   `<repo-de-produto>/.agents/tasks/backlog/`, usando o `_template.md` **daquele
   repositório**, não o do Guardian.

   **O prefixo é `GT`, e não `TASK`, e isso não é cosmético.** Aquela pasta é
   compartilhada com o orquestrador `bootstrap-*`, que cria `TASK-NNN` e mantém
   a própria sequência. Duas fontes numerando na mesma sequência colidem no dia
   em que as duas criam na mesma janela — as duas nascem válidas e só brigam no
   merge. Prefixos distintos tornam a colisão **impossível**, em vez de
   improvável. O Guardian nunca cria `TASK-NNN`; o orquestrador nunca cria `GT`.

   **O número é o MESMO do GT do hub.** Um item de trabalho, um número. O que
   muda é o papel de cada arquivo:

   - o `GT` do **hub** responde *por que isto entrou na fila* — achado,
     evidência, severidade, run de origem — e vive junto do histórico de
     auditoria que lhe dá sentido;
   - o `GT` do **repo de produto** responde *como será feito e como foi feito* —
     regras de negócio, critérios de aceitação, plano, e depois o Registro de
     Execução — e vive ao lado do código, versionado, revisado no mesmo PR.

   Não são cópia um do outro, e nenhum dos dois é resumo do outro. O
   front-matter de cada um aponta para o outro em `contraparte:`, com caminho
   completo. **Sem a referência cruzada nos dois sentidos**, dois arquivos com o
   mesmo nome em repositórios diferentes divergem na primeira alteração e
   ninguém sabe qual vale.

   Numeração: a sequência `GT` é **global ao Guardian**, e não por repositório.
   Ao escolher o próximo número livre, varrer os três lugares — o hub
   (`squads/guardian/tasks/{backlog,active,completed}/`) e o
   `.agents/tasks/{backlog,active,completed}/` de **cada repositório de produto
   em escopo**. Um `GT-0041` no GeoCloudAI e outro no E-LIMS seriam dois
   trabalhos diferentes com o mesmo nome.

   Se o repositório de produto não tiver `.agents/` (não foi bootstrapado), não
   inventar a estrutura: gerar só o `GT` do hub e registrar a ausência em
   `tasks-geradas.md`, para o dono do produto decidir. É o caso do E-LIMS, cujo
   `.agents/` é ignorado por decisão do dono daquele repositório.

6. Registrar o resultado em `tasks-geradas.md`.

## Output Format

```yaml
tasks_geradas:
  - origem: "SEC-01"                 # ou "plano-implementacao: backend"
    task_id: "GT-0001"
    arquivo: "squads/guardian/tasks/backlog/GT-0001-sec-01-allowanonymous-address-add.md"
    titulo: "Corrigir AllowAnonymous sem justificativa em POST /Address/add"
    camada_provisoria: "backend"
    task_repo_alvo: "GeoCloudAI/.agents/tasks/backlog/GT-0001-sec-01-allowanonymous-address-add.md"
```

## Quality Criteria

- Toda task gerada preenche as seções obrigatórias do template — "N/A" explícito quando não aplicável, nunca omitido em silêncio.
- Toda task tem evidência concreta e critério de aceitação claro.
- Todo item aprovado foi processado — nenhum ficou de fora.
- Todo `GT` do hub tem o `GT` de mesmo número no repo de produto, e os dois se citam em `contraparte:` — ou a ausência de `.agents/` está registrada explicitamente.

## Veto Conditions

Reject e refaça se QUALQUER uma for verdadeira:
1. Uma task foi gerada com severidade rebaixada em relação à origem.
2. Um item aprovado não aparece no output (nenhuma `GT-NNNN` correspondente).
3. Uma `GT-NNNN` reaproveitou um número já usado por outra task existente.
4. Um `GT` do hub foi gerado sem o par no repo de produto, num repositório que **tem** `.agents/` — ou o par foi gerado sem referência cruzada nos dois sentidos.
5. O par no repo de produto recebeu número diferente do `GT` do hub, ou foi nomeado `TASK-NNN` — `TASK` é a sequência do orquestrador `bootstrap-*` e o Guardian não escreve nela.
6. A varredura de numeração ignorou o `.agents/tasks/` de algum repositório de produto em escopo, podendo repetir um `GT` já usado lá.
4. Qualquer chamada `gh` foi feita nesta task.
