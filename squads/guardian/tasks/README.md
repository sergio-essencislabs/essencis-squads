# Tasks do Guardian

Cada arquivo aqui é uma unidade de trabalho gerada pelo squad — a partir de um
achado de auditoria aprovado (Steps 03-06) ou de um pedido direto de
implementação ("Guardian, preciso fazer X", Step 02). O formato é adaptado do
`bootstrap-agent-architecture` (plugin `victor-bootstrap`), que já usa esse
mesmo padrão em `.agents/tasks/` dos repositórios de produto — mas este hub é
**próprio e centralizado do Guardian**, nunca escrito em `.agents/` do
repositório alvo, para não colidir com o ciclo de vida/numeração daquela
arquitetura (IDs diferentes: `GT-NNNN` aqui, `TASK-NNNN` lá).

## Estado = pasta

O estado de uma task é comunicado por onde o arquivo está, nunca por um campo
isolado no frontmatter:

```
backlog/   → gerada pelo Step 07 (Geração de Tasks), aguardando o Gate (Step 08)
active/    → promovida: issue criada (Step 10), implementação em andamento/roteada
completed/ → Step 17 (Revisão dos PRs) confirmou as 3 evidências (código, docs, testes)
```

Mover o arquivo de pasta **é** a transição de estado. O campo `status:` no
frontmatter só espelha a pasta atual, nunca diverge dela.

## Numeração

IDs `GT-NNNN`, sequenciais, escaneados nas três pastas (nunca reaproveitar um
número já usado, mesmo de uma task movida ou arquivada). Nome do arquivo:
`GT-NNNN-{achado-id-lower}-{slug}.md` (ex.: `GT-0001-sec-01-allowanonymous-address-add.md`)
ou, para tasks originadas de um pedido de implementação direta,
`GT-NNNN-feature-{slug}.md`.

## Quem escreve aqui

- **Tomás Ticket (task-curator)** — gera as tasks em `backlog/` (Step 07) e as
  move para `active/` ao criar a issue correspondente (Step 10). Nunca decide
  mérito arquitetural, só transcreve com fidelidade.
- **Jarvis (chief-architect)** — preenche `camada`/`grupo_execucao` no
  roteamento (Step 09) e atualiza `related_adrs` quando redige um `GADR`
  (`squads/guardian/decisions/`).
- **Breno / Flávia / Rui** — atualizam "Registro de execução" e "Validação"
  da própria task durante a implementação (Steps 11/13/15).
- **Otávio (reviewer)** — move `active/ → completed/` no Step 17, só depois de
  confirmar as 3 evidências reais (código, documentação, testes) — nunca em
  silêncio; se faltar algo, a task fica em `active/` com a pendência registrada.
