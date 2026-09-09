---
task: "Curar Issues"
order: 1
input: |
  - achados_selecionados: lista de achados aprovados no checkpoint "Revisão dos Achados", com evidência arquivo:linha e severidade original
output: |
  - issues_criadas: lista de issues novas criadas ou comentários adicionados a issues existentes, com labels e vínculo ao Project #7
---

# Curar Issues

> **Escopo: só modo ad-hoc.** Desde a introdução do hub de tasks
> (`squads/guardian/tasks/`), o pipeline completo não chama mais esta task —
> ele usa `gerar-tasks.md` (Step 07, gera `GT-NNNN.md` sem `gh`) seguido de
> `criar-issues-de-tasks.md` (Step 10, cria a issue a partir da task já
> promovida pelo Gate). Esta task continua existindo só para o caso ad-hoc
> estreito descrito em `~/.claude/skills/guardian/SKILL.md` (1 achado, sem
> roteamento, fornecido diretamente pelo usuário fora de qualquer pipeline) —
> `gh issue create`/comentário/board só depois da confirmação consolidada do
> `runner.agent.md`, nunca antes.

Busca duplicata no board Essencis-Labs (322 itens) para o achado fornecido e, a partir do resultado, cria uma issue nova ou comenta na existente. Nunca decide se o achado avança — isso já foi decidido pelo usuário — apenas transcreve o achado em backlog rastreável, sem perder severidade nem evidência.

## Process

1. Para cada achado aprovado, buscar no repositório correspondente (Essencis-Labs/GeoCloudAI ou Essencis-Labs/ELIMS, via gh CLI) por issue já aberta cobrindo o mesmo componente/endpoint/tabela.
2. Se encontrar equivalente aberta: não duplicar — comentar na issue existente com o novo achado como evidência adicional, e atualizar severidade/labels se o novo achado for mais grave que o registrado.
3. Se não houver equivalente: redigir a issue nova com estrutura fixa (Contexto → Achado com evidência arquivo:linha → Severidade → Critério de aceite → Camada/produto responsável), com título seguindo a convenção "GeoCloud - <título>" ou "ELIMS - <título>".
4. Vincular a issue (nova ou comentada) ao known-issue correspondente na knowledge base, se existir.
5. Etiquetar com produto, camada (backend/frontend/database/segurança/docs) e origem do achado (qual auditor gerou), e adicionar ao Project #7 (Essencis-Labs) preenchendo Status/Priority/Stack.

## Output Format

```yaml
issues_criadas:
  - achado_origem: "SEC-01"
    tipo: "nova"                 # nova | comentario
    repo: "Essencis-Labs/GeoCloudAI"
    numero: 231
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
```

## Output Example

> Use como referência de qualidade, não como template rígido.

**Issue nova a partir do achado SEC-01:**
**Título:** GeoCloud - Corrigir AllowAnonymous sem justificativa em POST /Address/add
**Corpo:**
### Contexto
Achado pela auditoria de segurança (Selma Security) do squad guardian.
### Achado
`[AllowAnonymous]` presente em `Controllers/AddressController.cs:47`, sem justificativa escrita, permitindo criação de endereço por chamador não autenticado.
### Severidade
Crítica (BOLA)
### Critério de aceite
Endpoint exige `[Authorize]` + `[RequiredPermission("address.create")]`; key confirmada no seed; teste de permissão cobrindo caso negado.
### Camada
Backend
**Labels:** `security`, `backend`, `geocloud`
**Projeto:** adicionada ao Project #7, Status "Backlog", Priority "Alta", Stack "Backend".

**Duplicata encontrada — comentário em vez de issue nova (achado relacionado):** comentário adicionado à issue #208 ("Geocloud - Bloqueio e tentativas de acesso (login)"): "Achado adicional da auditoria automática (2026-08-21): endpoint relacionado `POST /Address/add` também carece de controle de acesso — mesma família de problema de autorização. Evidência: `AddressController.cs:47`."

## Quality Criteria

- [ ] Nenhuma issue criada sem busca de duplicata comprovada — resultado da busca citado explicitamente.
- [ ] Toda issue tem evidência concreta (arquivo:linha) e critério de aceite claro.
- [ ] Toda issue/comentário tem severidade, camada e produto etiquetados corretamente, e está vinculado ao Project #7.

## Veto Conditions

Reject and redo if ANY are true:
1. Uma issue foi aberta sem busca de duplicata citada no resultado.
2. Uma issue foi criada vaga, sem achado concreto e evidência de arquivo:linha.
3. A severidade original do achado foi rebaixada na transcrição para a issue ou comentário.
