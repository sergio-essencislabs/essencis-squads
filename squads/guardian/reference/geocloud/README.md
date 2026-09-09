# geocloud-ai-framework

Framework de Engenharia Assistida por IA do **GeoCloud**.

Este repositório é um **projeto de software independente**: modular, evolutivo, documentado e versionado (ver [VERSION](VERSION) e [CHANGELOG.md](CHANGELOG.md)). Ele não contém código de produto — contém o conhecimento, os processos e os agentes/skills que guiam o desenvolvimento assistido por IA do GeoCloud.

> Derivado do `ai-framework` 0.8.0, que servia GeoCloud e GeoLims na mesma base. A partir da 1.0.0 são dois frameworks independentes, um por produto — ver [CHANGELOG.md](CHANGELOG.md). O equivalente do outro produto é o `elims-ai-framework`.

## Por que este framework existe

O GeoCloud é .NET 9 em Clean Architecture + Angular 19/Velzon + **MySQL 8 via Dapper**, com um núcleo de Conta/Identidade de 16 classes. O histórico do projeto acumulou drift de schema, permissões inertes em runtime e documentação que descrevia um sistema diferente do que roda — ver [knowledge/known-issues/](knowledge/known-issues/) e [ADR-0006](knowledge/decisions/0006-geocloud-usa-mysql.md), que corrige justamente uma dessas divergências.

Este framework existe para que qualquer agente de IA (ou humano) que trabalhe no produto:

1. Encontre rapidamente o contexto certo, sem reler o codebase inteiro (economia de tokens/contexto).
2. Siga os mesmos padrões arquiteturais, de segurança e de nomenclatura em todo o produto.
3. Nunca duplique um componente que já existe (busca de reutilização é obrigatória — ver [MASTER_PROMPT.md](MASTER_PROMPT.md)).
4. Mantenha a documentação e a knowledge base sempre sincronizadas com o código.
5. Registre decisões arquiteturais de forma rastreável (ADRs em [knowledge/decisions/](knowledge/decisions/)).

## Estrutura

```
geocloud-ai-framework/
├── MASTER_PROMPT.md # coordenação global — nunca contém lógica de um agente específico
├── FRAMEWORK_ARCHITECTURE.md # arquitetura detalhada deste framework
├── FRAMEWORK_DECISIONS.md # índice de ADRs (decisões arquiteturais do framework)
├── FRAMEWORK_ROADMAP.md # roadmap de evolução do framework
├── CHANGELOG.md
├── VERSION
├── agents/ # 13 personas especializadas (Chief Architect, Backend Architect, ...)
├── skills/ # 19 skills nativas do Cursor (SKILL.md) — executam, não decidem
├── policies/ # 12 políticas permanentes (fonte para .cursor/rules/*.mdc)
├── playbooks/ # 13 processos recorrentes ponta-a-ponta
├── templates/ # 11 modelos reutilizáveis (ADR, feature, bug, etc.)
├── knowledge/ # knowledge base federada (índice + síntese cross-projeto)
├── scripts/ # automação do próprio framework (sync, scaffolds, validação)
└── tests/ # auto-validação estrutural do framework
```

## Como isso chega ao Cursor

`policies/` e `skills/` são a **fonte versionada**. `scripts/sync-cursor.ps1` gera/copia o conteúdo ativo para `.cursor/rules/` e `.cursor/skills/` do repositório do produto (`C:/Software/GeoCloud/GeoCloudAI` — ver `$deployTargets` no script), que é o que o Cursor efetivamente carrega ao abrir aquela janela. **Nunca edite `.cursor/` diretamente** — edite a fonte aqui e rode o sync. Ver [ADR-0001](knowledge/decisions/0001-skills-e-rules-nativas-do-cursor.md).

Os 13 agentes são personas de prompt (não existe "tipo de subagente" customizável no Cursor); cada agente tem um wrapper curto em `.cursor/skills/agent-<nome>/SKILL.md` (`disable-model-invocation: true`) que aponta para a especificação completa em `agents/<nome>.md`. Invoque nomeando o agente ("aja como o Backend Architect...") ou peça explicitamente a skill. **Exceção:** Chief Architect e Documentation Architect não precisam ser nomeados — `policies/orquestracao.md` (`alwaysApply: true`) garante que toda tarefa passe por um roteamento leve dos dois; ver [ADR-0005](knowledge/decisions/0005-chief-e-documentation-architect-sempre-ativos.md).

## Como evoluir o framework

Ver a seção "Estratégia de Evolução" em [FRAMEWORK_ARCHITECTURE.md](FRAMEWORK_ARCHITECTURE.md#estratégia-de-evolução) e o [FRAMEWORK_ROADMAP.md](FRAMEWORK_ROADMAP.md). Resumo:

1. Toda mudança relevante de arquitetura → registrar um ADR novo (`scripts/new-adr.ps1`).
2. Toda lição aprendida nova → registrar em `knowledge/patterns/` (`scripts/new-memory.ps1`), no mesmo formato atômico já usado em `GeoCloudAI/.agents/memory/`.
3. Nunca duplicar: antes de criar agente/skill/policy/playbook novo, procurar exaustivamente por equivalente existente (obrigatório pelo `MASTER_PROMPT.md`).
4. Compatibilidade retroativa: mudanças que quebram um agente/skill existente exigem SemVer major + entrada no `CHANGELOG.md`.
5. Após qualquer alteração em `policies/` ou `skills/`, rodar `scripts/sync-cursor.ps1` e `scripts/validate-framework.ps1`.

## Produto que este framework serve

| Projeto | Caminho local do código |
|---|---|
| GeoCloud | `C:/Software/GeoCloud/GeoCloudAI` |

O framework vive em `Documents/geocloud-ai-framework` e **não embute** o código do produto.
`scripts/sync-cursor.ps1` gera `.cursor/` dentro do repositório listado em `$deployTargets`.

## Repositório remoto (GitHub)

Este fork ainda **não tem remote configurado**. Para publicá-lo:

```bash
gh repo create sergio-essencislabs/geocloud-ai-framework --private --source=. --remote=origin
git push -u origin master
```

O produto (`GeoCloudAI`) mantém seu próprio remote/git, independente deste
framework.