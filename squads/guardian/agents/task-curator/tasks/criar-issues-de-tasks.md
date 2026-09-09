---
task: "Criar Issues de Tasks"
order: 2
input: |
  - gt_ids_aprovadas: GT-IDs aprovadas no Gate de Promoção (squads/guardian/output/gate-promocao.md), já roteadas por Jarvis (squads/guardian/output/roteamento.md)
output: |
  - issues_criadas: lista de issues novas criadas ou comentários adicionados a issues existentes, com labels e vínculo ao Project #7; cada GT-NNNN.md movida para tasks/active/ com issue_url preenchido
---

# Criar Issues de Tasks

Busca duplicata no board Essencis-Labs para cada `GT-ID` promovida pelo Gate
e, a partir do resultado, cria uma issue nova ou comenta na existente — a
issue é redigida a partir do conteúdo da task já existente (nunca do zero),
já sabendo camada e GADR relacionado do roteamento de Jarvis. Move a task de
`backlog/` para `active/` como parte da promoção.

## Process

1. Para cada `GT-ID` aprovada, ler a task completa em `tasks/backlog/` e a
   linha correspondente em `roteamento.md` (camada, grupo, GADR).
2. Buscar no repositório correspondente (Essencis-Labs/GeoCloudAI ou
   Essencis-Labs/ELIMS, via `gh` CLI) por issue já aberta cobrindo o mesmo
   componente/endpoint/tabela.
3. Se encontrar equivalente aberta: não duplicar — comentar na issue
   existente com a task como evidência adicional, atualizar severidade/
   labels se a task for mais grave que o registrado. Preencher `issue_url`
   apontando para a issue existente de qualquer forma.
4. Se não houver equivalente: redigir a issue a partir do conteúdo da task
   (Contexto → Achado com evidência arquivo:linha → Severidade → Critério de
   aceitação → Camada/produto, citando o GADR relacionado quando houver),
   título "GeoCloud - <título>" ou "ELIMS - <título>". Criar com
   `gh issue create`, etiquetar, adicionar ao Project #7 (Status/Priority/
   Stack).
5. Preencher `issue_url` no frontmatter da task e mover o arquivo de
   `tasks/backlog/` para `tasks/active/`.
6. Vincular ao known-issue correspondente na knowledge base, se existir.
7. Registrar o resultado em `issues-criadas.md`.

## Output Format

```yaml
issues_criadas:
  - task_id: "GT-0001"
    tipo: "nova"                 # nova | comentario
    repo: "Essencis-Labs/GeoCloudAI"
    numero: 341
    titulo: "GeoCloud - Corrigir AllowAnonymous sem justificativa em POST /Address/add"
    severidade: "Critica"
    labels: ["security", "backend", "geocloud"]
    projeto:
      board: "Essencis-Labs/projects/7"
      status: "Backlog"
      priority: "Alta"
      stack: "Backend"
    duplicate_check:
      buscado: true
      resultado: "nenhuma equivalente encontrada"
    known_issue_vinculado: null
    task_movida_para: "squads/guardian/tasks/active/GT-0001-sec-01-allowanonymous-address-add.md"
```

## Quality Criteria

- Nenhuma issue criada sem busca de duplicata comprovada — resultado citado explicitamente.
- Toda issue/comentário tem evidência concreta e critério de aceitação claro, e está vinculado ao Project #7.
- Toda `GT-ID` processada foi movida para `tasks/active/` com `issue_url` preenchido.

## Veto Conditions

Reject e refaça se QUALQUER uma for verdadeira:
1. Uma issue foi aberta sem busca de duplicata citada no resultado.
2. A severidade original da task foi rebaixada na transcrição para a issue ou comentário.
3. Uma `GT-ID` aprovada não foi movida para `tasks/active/`, ou ficou sem `issue_url` preenchido.
