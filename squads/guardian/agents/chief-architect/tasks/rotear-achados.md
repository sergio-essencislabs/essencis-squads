---
task: "Rotear Achados"
order: 2
input: |
  - tasks_aprovadas: GT-NNNN aprovadas pelo usuário no Gate de Promoção (squads/guardian/output/gate-promocao.md), cada uma com o texto completo em squads/guardian/tasks/backlog/ (achado/pedido, componente/endpoint, camada sugerida, produto e severidade)
output: |
  - plano_roteamento: tabela de roteamento com camada, grupo de execução (paralelo/sequencial), ordem e observações de dependência/núcleo compartilhado (squads/guardian/output/roteamento.md)
  - gadr: quando aplicável, decisão registrada em squads/guardian/decisions/GADR-NNNN.md
---

# Rotear Achados

Classifica cada task aprovada por camada dominante (backend/frontend/database/segurança) e monta o plano de execução — incluindo grupos de execução paralela/sequencial — que os especialistas de implementação vão consumir, incluindo ordem de dependência e sinalização de tasks que tocam o núcleo compartilhado de Conta/Identidade.

## Process

1. Ler todas as `GT-NNNN` aprovadas em `gate-promocao.md`, o texto completo de cada uma em `tasks/backlog/` — nenhuma task aprovada pode ficar fora do plano.
2. Classificar cada task por camada dominante (backend, frontend, database) e por severidade, usando o conteúdo da própria task como ponto de partida. Preencher o campo `camada` no frontmatter da task.
3. Verificar se a task toca o núcleo compartilhado de Conta/Identidade (Account, Entity, Profile, Functionality, User). Se sim, sinalizar tratamento especial: a avaliação de impacto nos dois produtos (GeoCloudAI e E-LIMS) precede o roteamento a qualquer especialista único, e um `GADR` é redigido (`redigir-gadr.md`), preenchendo `related_adrs` na task.
4. Montar **grupos de execução**: um grupo é um conjunto de tasks que podem rodar concorrentemente sem violar nenhuma regra de veto (mesmo arquivo/endpoint nunca no mesmo grupo; núcleo compartilhado nunca isolado a um produto só; segurança crítica antes de dívida técnica no mesmo componente). Tasks com dependência declarada (schema → backend → frontend) ficam em grupos sequenciais distintos. Preencher `grupo_execucao` no frontmatter de cada task.
5. Nunca paralelizar tasks que tocam o mesmo arquivo/endpoint — declarar a ordem sequencial nesse caso.
6. Priorizar explicitamente tasks de segurança crítica antes de dívida técnica quando ambas tocam o mesmo componente.
7. Registrar o plano de roteamento completo, com os grupos de execução e a ordem de merge sugerida, como artefato de saída para os especialistas de Backend, Frontend e Database consumirem no próximo estágio.

## Output Format

```yaml
plano_roteamento:
  - task_id: "GT-0001"
    componente: "POST /Address/add"
    camada: "backend"
    severidade: "critica"
    especialista: "backend-architect"
    grupo_execucao: "A"
    ordem: 1
    nucleo_compartilhado: false
    dependencias: []
    observacao: "Bloqueante — trata antes da task de dívida técnica no mesmo controller"
  - task_id: "GT-0002"
    componente: "AddressController"
    camada: "backend"
    severidade: "media"
    especialista: "backend-architect"
    grupo_execucao: "A"
    ordem: 2
    nucleo_compartilhado: false
    dependencias: ["GT-0001"]
    observacao: "Depende da correção de segurança acima estar mesclada primeiro"
  - task_id: "GT-0003"
    componente: "Tela de endereço (Angular)"
    camada: "frontend"
    severidade: "baixa"
    especialista: "frontend-architect"
    grupo_execucao: "B"
    ordem: 1
    nucleo_compartilhado: false
    dependencias: []
    observacao: "Independente do backend — grupo B pode rodar em paralelo com o grupo A"
```

## Output Example

### Cenário: task de segurança crítica + task de dívida técnica no mesmo endpoint, mais uma task frontend independente

## Plano de Roteamento

| Task | Camada | Grupo | Ordem | Observação |
|---|---|---|---|---|
| GT-0001 — AllowAnonymous sem justificativa em POST /Address/add | Backend | A | 1 | Bloqueante — trata antes da task de dívida no mesmo controller |
| GT-0002 — Duplicação de lógica de endereço em 2 controllers | Backend | A | 2 | Depende da correção de segurança acima estar mesclada primeiro |
| GT-0003 — Ajuste de tela de endereço | Frontend | B | 1 | Independente — grupo B roda em paralelo com o grupo A |

Notas do roteamento: nenhuma task nesta rodada toca o núcleo compartilhado de Conta/Identidade, então não há GADR nem avaliação de impacto cross-produto pendente. GT-0001 e GT-0002 tocam o mesmo controller (`AddressController`), por isso foram sequenciadas dentro do grupo A em vez de paralelizadas — rodar em paralelo geraria conflito de merge previsível. GT-0003 é independente das duas (camada diferente, sem dependência declarada, nenhum arquivo em comum), por isso está em um grupo separado (B) que pode ser disparado em paralelo com o grupo A.

## Quality Criteria

- Toda task aprovada aparece no plano de roteamento, nenhuma é esquecida.
- Tasks de núcleo compartilhado estão explicitamente marcadas, com GADR quando aplicável.
- Dependências entre tasks do mesmo componente estão declaradas.
- Todo grupo marcado como paralelo respeita as regras de veto.

## Veto Conditions

Reject e refaça se QUALQUER uma for verdadeira:
- Uma task de núcleo compartilhado foi roteada para um único produto sem avaliação de impacto no produto irmão registrada no plano e sem GADR associado.
- Duas tasks que tocam o mesmo arquivo/endpoint foram colocadas no mesmo grupo de execução paralela.
- Uma task de segurança crítica foi roteada com ordem posterior a uma task de dívida técnica no mesmo componente.
