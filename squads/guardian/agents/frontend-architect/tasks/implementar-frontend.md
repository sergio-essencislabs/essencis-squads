---
task: "Implementar Frontend"
order: 1
input: |
  - achado: achado de frontend roteado pelo Jarvis (id, camada, descrição, severidade, arquivo:linha)
  - plano_roteamento: squads/guardian/output/roteamento.md (contexto de ordem/dependência entre achados)
output: |
  - implementacao: squads/guardian/output/implementacao-frontend.md (branch, diff resumido, PR aberto)
---

# Implementar Frontend

Implementa a correção de frontend roteada pelo Jarvis para um achado aprovado (duplicação de componente, drift de contrato de API, tratamento de erro ausente), em branch dedicada, sobre Angular 19 com o design system Velzon, e abre PR — nunca push direto em main/master.

> `duplicate-detector` = metodologia em `C:\Software\ClaudeCode\squads\guardian\reference\{geocloud|elims}\skills\duplicate-detector\SKILL.md` (caminho absoluto, conforme produto do achado) — ler e aplicar diretamente, sem depender de `.claude`/`.cursor` do produto.


## Onde a task vive — o par `contraparte`

Desde 2026-09-09 (TASK-060 no GeoCloudAI), toda `GT-NNNN` gerada para um repositório de produto
que tenha `.agents/` versionado ganha um **par de mesmo número** lá, e o front-matter dos dois
aponta um para o outro em `contraparte:`.

Os dois têm papéis diferentes, e **não são cópia**:

| Arquivo | Responde | Quem escreve |
|---|---|---|
| `squads/guardian/tasks/…/GT-NNNN.md` (hub) | *por que isto entrou na fila* — achado, evidência, severidade, `run_origem` | Tomás, no Step 07 |
| `<repo-de-produto>/.agents/tasks/…/GT-NNNN.md` | *como será feito e como foi feito* — RN, CA, plano, **Registro de execução**, **Validação** | quem implementa e quem revisa |

**Regra operacional:** se a task tem `contraparte`, o Registro de execução, a Validação e o
fechamento acontecem **no par do repositório de produto** — é ele que viaja na branch e é revisado
no mesmo PR do código. O GT do hub não recebe registro de execução; ele guarda o porquê.

Se a task **não** tem `contraparte` (trabalho sobre o próprio squad, ou repositório de produto sem
`.agents/` versionado — hoje o E-LIMS), tudo acontece no hub, como antes.

Autoridade: `squads/guardian/agents/task-curator/tasks/gerar-tasks.md`, passo 5.

## Process

1. Rodar duplicate-detector em `shared/`, `shared-modules/` e `ui/` antes de criar qualquer componente novo; se existir componente equivalente ou próximo, consolidar em vez de duplicar.
2. Confirmar o contrato de API real com o Backend Architect (shape do DTO, campos obrigatórios/opcionais) — nunca assumir o contrato a partir de suposição ou de código legado.
3. Implementar o componente como standalone, com rota lazy via `loadComponent`, guard apropriado para a rota, e um service de API dedicado — nenhuma chamada HTTP direta do componente.
4. Respeitar a decisão de state management já feita para o produto (`@ngrx/signals`); não introduzir um mecanismo de estado paralelo.
5. Se o componente ler dados via getter de template, aplicar cache por chave com guarda de in-flight para evitar refetch repetido a cada ciclo de renderização.
6. Tratar erro de resposta de API cobrindo tanto JSON estruturado quanto texto plano, exibindo mensagem apropriada ao usuário em ambos os casos.
7. Atualizar os pontos de uso existentes quando a mudança consolidar ou substituir um componente duplicado; acionar QA e Marta Documentation quando o fluxo alterado for documentado.
8. Abrir Pull Request: nunca fazer push direto em main/master. Criar branch dedicada, comitar a implementação, e abrir PR descrevendo achado, correção e pontos de uso atualizados. Parar aqui e aguardar o checkpoint de revisão (Otávio Review) e a aprovação humana antes de qualquer merge.

## Output Format

```yaml
branch_name: string          # ex.: fix/consolidate-address-modal
files_changed:
  - path: string
    change_summary: string
pr_title: string
pr_description: string       # inclui achado de origem, componente consolidado/criado, contrato de API confirmado
pr_url: string                 # placeholder até a criação real via gh CLI
tests_added:
  - name: string
    covers: string
```

## Output Example

```yaml
branch_name: fix/consolidate-address-modal
files_changed:
  - path: shared/components/address-modal/address-modal.component.ts
    change_summary: "Novo componente standalone consolidando as 2 implementações duplicadas de modal de endereço"
  - path: features/geocloud/wells/well-detail.component.ts
    change_summary: "Atualizado para usar shared/components/address-modal"
  - path: features/elims/samples/sample-detail.component.ts
    change_summary: "Atualizado para usar shared/components/address-modal"
  - path: shared/components/address-modal/address-modal.component.spec.ts
    change_summary: "Testes de abertura/fechamento e submissão do modal consolidado"
pr_title: "refactor: consolidar modal de endereço duplicado (TD-03)"
pr_description: >
  Corrige achado TD-03 (Dante Debit): remove 2 implementações duplicadas
  de modal de endereço, consolida em shared/components/address-modal,
  atualiza os 2 pontos de uso. Contrato de API confirmado com Breno
  Backend antes da implementação — nenhuma mudança de shape de DTO.
  Componente standalone, sem chamada HTTP direta (usa AddressApiService).
pr_url: "PENDING"
tests_added:
  - name: AddressModalComponent should open and close correctly
    covers: "Ciclo de abertura/fechamento do modal consolidado"
  - name: AddressModalComponent should submit valid payload
    covers: "Submissão do formulário respeitando o contrato de API confirmado"
```

## Quality Criteria

- Nenhum componente novo duplica um componente shared existente.
- Nenhuma chamada HTTP direta de componente sem passar por um service dedicado.
- Contrato de API confirmado com o Backend Architect antes da implementação.
- PR aberto, nunca push direto em main/master.

## Veto Conditions

Reject and redo if ANY are true:
- Qualquer push direto em main/master (sem branch dedicada + PR) — reject automático, sem exceção.
- Componente novo criado sem antes rodar duplicate-detector em `shared/`/`shared-modules/`/`ui/`.
- Chamada HTTP feita diretamente de um componente, sem service de API dedicado.
- Contrato de DTO assumido sem confirmação explícita do Backend Architect.
- Uso da classe `.modal` pura do Bootstrap em um modal customizado, em vez do padrão de componente Velzon.
