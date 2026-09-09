# Changelog

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/). Este projeto segue [SemVer](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Alterado

- Pasta canônica da documentação estrutural: `ELIMS/Documentation/Main/` (somente a branch `main`, mesmo padrão do GeoCloud). Policies `documentacao`/`orquestracao`, skills `documentation-sync`/`structural-spreadsheet-sync`/`uml-generator` e o Documentation Architect apontam para `Planilha_ELIMS_main.xlsx` nesse caminho — não mais `docs/estrutura/`, a raiz de Miscelaneous, nem pastas por outras branches.

## [1.2.0] - 2026-08-15

Derivação do `geocloud-ai-framework` 1.1.0 para o **ELIMS**. Herda os playbooks já
enriquecidos e o pattern de premissa desatualizada; devolve o conhecimento próprio do
ELIMS que havia sido retirado no fork anterior.

### Adicionado

- Known-issues específicos do ELIMS restaurados: KI-0007 a KI-0012, com as linhas
  correspondentes no índice.
- `ADR-0006` do ELIMS (adoção do MySQL) de volta no lugar do ADR equivalente do GeoCloud.
- `_verification/baseline-elims.json`.

### Alterado

- Caminhos ajustados para a estrutura real do ELIMS: `backend/src/Back.*` e `frontend/`,
  em vez de `api/src/` e `web/` do GeoCloud.
- `scripts/sync-cursor.ps1` com alvo único `ELIMS/ELIMS`.
- Números do pattern de premissa desatualizada **reverificados no código do ELIMS**:
  52 dos 57 repositórios fazem `DELETE FROM`, 1 menciona `deleted_at`.

### Pendente

- `playbooks/nova-entidade.md` está sem referência canônica. A do framework de origem é a
  feature `Color`, **que é do GeoCloud** — deixá-la ali seria propagar fato de um produto
  para o outro, exatamente o defeito que o pattern herdado descreve. Falta eleger a
  vertical mais limpa do ELIMS e preencher a tabela.
- `scripts/bootstrap-new-base.ps1` com 29 erros de sintaxe, herdados da 0.8.0.

## [1.1.0] - 2026-08-15

### Adicionado

- Conteúdo concreto absorvido dos agents/skills que existiam soltos em
  `Miscelaneous/Claude_Config_GeoCloud` (gerados em julho para o Claude Code).
  Na taxonomia deste framework eles eram **playbooks**, não skills — as 19 skills daqui
  são de análise, não de construção — então o conteúdo foi enxertado em
  `playbooks/nova-entidade.md`, `playbooks/nova-tela.md` e `playbooks/migration.md`.
- `playbooks/nova-entidade.md`: vertical completa com a `Color` como referência canônica,
  incluindo a etapa de cadastro das permission keys, que sem ela faz o endpoint responder
  403 mesmo com o código correto.
- `knowledge/patterns/documentacao-descreve-codigo-que-nao-existe-mais.md`: registro das
  três premissas erradas encontradas na absorção.

### Corrigido

- **A SOP absorvida estava errada em dois pontos, e foi corrigida em vez de copiada:**
  mandava usar `INSERT ... RETURNING id` (PostgreSQL) e soft-delete por `deleted_at` com
  `ISoftDeletableEntity`. Verificação no código de 2026-08-15: 94 repositórios fazem
  `DELETE FROM` direto, nenhum usa `deleted_at`, a interface não existe mais e o schema
  não tem a coluna. A divergência ficou registrada dentro do próprio playbook.

### Descartado

- `devops-postgres-agent`: obsoleto por inteiro após o [ADR-0006](knowledge/decisions/0006-elims-migra-para-mysql.md).
- `dotnet-dapper-agent` e `angular-signals-agent`: eram especialistas por stack, eixo
  diferente das 13 personas por papel deste framework. O conteúdo útil foi para os
  playbooks; os arquivos não sobreviveram.

## [1.0.0] - 2026-08-15

Fork do `ai-framework` (0.8.0) em dois frameworks de produto único. Este passa a ser o
**`elims-ai-framework`**, exclusivo do ELIMS. O escopo cross-produto foi removido,
o que caracteriza quebra de compatibilidade e justifica o major.

### Alterado

- **Premissa de banco corrigida: PostgreSQL → MySQL 8.** A documentação afirmava que o
  ELIMS rodava sobre PostgreSQL/Npgsql. A verificação no código do produto mostrou
  `MySqlConnector`, `SELECT LAST_INSERT_ID()` e dump `MySQL 8.0.46` — a migração havia
  acontecido sem que a documentação acompanhasse. Ver [ADR-0006](knowledge/decisions/0006-elims-migra-para-mysql.md).
- `policies/banco-de-dados.md` reescrita para MySQL 8, incluindo as duas armadilhas do
  motor: ordem de eixo do SRID 4326 (latitude primeiro) e `ST_Intersection` devolvendo
  `GEOMETRYCOLLECTION` em SRS geográfico.
- `scripts/sync-cursor.ps1`: alvo único, `ELIMS/ELIMS`.
- Referências internas de `ai-framework` para `elims-ai-framework` (45 ocorrências).

### Removido

- Todo o conteúdo específico do ELIMS/GeoLims: KI-0007 a KI-0012, ADR-0006 original
  ("ELIMS migra para MySQL"), a skill `parity-diff`, o playbook
  `sincronizacao-nucleo-compartilhado`, o pattern `permission-fuzz-testing-cross-produto`
  e o baseline `_verification/baseline-elims.json`.
- Menções cross-produto em agentes, policies, playbooks, skills, templates e knowledge.

### Preservado deliberadamente

- O histórico deste CHANGELOG abaixo de 1.0.0, que registra decisões tomadas quando o
  framework servia os dois produtos. Reescrevê-lo apagaria a proveniência das decisões
  que continuam valendo.
- Citações do arquivo-fonte `ELIMS_GeoCloud_Visao_Tecnica.md` e da branch
  `elims-geocloud-padronization`: são nomes reais de artefatos que existiram, não
  conteúdo de produto irmão.

### Conhecido

- `scripts/bootstrap-new-base.ps1` tem 29 erros de sintaxe de PowerShell. **Defeito
  preexistente**, herdado da 0.8.0 — não introduzido neste fork. Precisa de correção.

## [0.8.0] - 2026-08-13

### Removido

- Bases experimentais `NewGeoCloud` e `NewELIMS` (pastas locais em `GeoLims/` e repositórios GitHub
  `sergio-essencislabs/NewGeoCloud` e `sergio-essencislabs/NewELIMS`).
- Referências operacionais a essas bases em README, arquitetura, playbooks, policies, skills, scripts
  e knowledge — o framework passa a apontar diretamente para os produtos
  `ELIMS/ELIMS` e `ELIMS/ELIMS`.

### Modificado

- `scripts/sync-cursor.ps1`: `$deployTargets` agora aponta para
  `Documents/ELIMS/ELIMS` e `Documents/ELIMS/ELIMS`.
- `playbooks/onboarding-nova-base.md` e `scripts/bootstrap-new-base.ps1`: exemplos generalizados
  (sandbox genérico), sem nomes `New*`.

## [0.7.0] - 2026-08-04

### Adicionado

- `ADR-0006` (removido na 1.0.0): `ELIMS` adota **MySQL** como motor
  de banco de dados oficial (driver `MySqlConnector`), divergindo intencionalmente do ELIMS
  (PostgreSQL) — decisão de produto da equipe do ELIMS (Thiago e Victor), analisada e formalizada nesta
  versão. `policies/banco-de-dados.md` recebe a seção "ELIMS usa MySQL".
- Porta completa da branch `elims-geocloud-padronization` (`ELIMS/ELIMS`, fonte read-only) para
  `ELIMS`: 211 arquivos alterados, incluindo reforço de tenant isolation
  (`TenantAuthorizationFilter` global, `TenantController`, `TenantAuthorizationRepository`), hierarquia
  de identidade (`IdentityHierarchyRepository`), e reintrodução dos campos `company`/`formType`/
  `employees` em `Account` (existiam no schema mas não eram expostos em Model/DTO/Front).
  Migration `011_functionality_permission_keys.sql` (colunas de suporte a `[RequiredPermission]` em
  `functionality` — extensão exclusiva deste framework) validada com sucesso contra MySQL local via
  teste xUnit temporário com `MySqlConnector`. `Back.Tests` confirmado em 66/66 após a porta.
- `KI-0012` (removido na 1.0.0): o
  `TenantAuthorizationFilter` trazido pela porta acima pode já mitigar KI-0002/KI-0009/KI-0010, mas
  precisa de reteste real (`NoAuthSystemicRunner`/`AuditTrailIntegrityRunner`) antes de fechá-los.
- `knowledge/pendencias.md`/`knowledge/domain/equipe.md`: pendência "replicar trabalho de Thiago e
  Victor" (aberta desde 2026-07-31) encerrada como resolvida.

### Corrigido

- `ELIMS/ELIMS/docs/Classe-entitydetail-proposta-de-normalizacao.md`: comparado com o estado real de
  `Entity.cs`/`EntityDetail.cs` (idêntico entre `ELIMS` e a branch fonte) — documento marcado como
  parcialmente superado; a normalização real ("TASK-11") extraiu o bloco comercial/CRM em uma tabela
  filha 1:1 (`entity_detail`) em vez de distribuir campo a campo para `Address`/`Entity`/`EntityNature`
  como a proposta original sugeria. Único item implementado exatamente como proposto: `Status` foi para
  `Entity.Status`.

### Pendente

- Build do frontend `ELIMS` (`npm run build`) teve erros de compilação corrigidos nesta versão
  (`Account.ts`, `settings.component.html` desalinhados após a porta), mas não pôde ser re-verificado
  de ponta a ponta por indisponibilidade do terminal na sessão em que a correção foi feita — pendência
  registrada em `knowledge/pendencias.md`.
- `.xlsx` de `ELIMS/ELIMS/docs/estrutura/Account_ELIMS_resumo_estrutural.xlsx` não regenerado a partir do
  `.csv` atualizado (script `csv-to-xlsx.py` precisa de terminal, indisponível nesta sessão).
- Commit/push de `ELIMS` e `ai-framework`, remoção do remote `elims-source`, e execução de
  `scripts/validate-framework.ps1` — todos dependem de terminal, indisponível nesta sessão; arquivos já
  estão prontos em disco para quando o terminal voltar a responder.

## [0.6.0] - 2026-08-03

### Modificado

- **Modelo de publicação revogado:** o repositório de "publicação consolidada" (`sergio-essencislabs/TESTS`,
  via `git subtree`) foi abandonado. `ai-framework/`, `ELIMS/` e `ELIMS/` agora têm cada um seu
  próprio repositório remoto privado e dedicado no GitHub (`sergio-essencislabs/ai-framework`,
  `sergio-essencislabs/ELIMS`, `sergio-essencislabs/ELIMS`), para uso com cada projeto aberto em
  janela própria do Cursor.
- `scripts/sync-cursor.ps1`: reescrito para gerar `.cursor/rules` e `.cursor/skills` em **múltiplos
  destinos** (um por repositório de produto, listados em `$deployTargets`), em vez de um único
  `GeoLims/.cursor/` compartilhado. Lógica de sync por policy/skill/agent extraída para a função
  `Sync-CursorTarget`, reutilizada por destino.
- `README.md` e `FRAMEWORK_ARCHITECTURE.md`: seção "Publicação consolidada" substituída por "Repositórios
  remotos (GitHub)"; diagrama de fluxo de contexto atualizado para múltiplos destinos de deploy.

### Pendente

- `../TESTS-monorepo/` (clone de staging local usado para montar a publicação consolidada) ficou órfão
  com a revogação do modelo acima e ainda não foi removido — não faz parte da fonte versionada do
  framework nem de nenhum dos 3 produtos; remoção pendente de confirmação do responsável.

## [0.5.0] - 2026-07-31

### Adicionado

- Campanha de testes de permissão/segurança V7 para o ELIMS (`TestCenter/Elims/`), replicando e
  ampliando a metodologia já usada no ELIMS (`TestCenter/GeoCLoud/`, arquivos originalmente em
  `ELIMS/Miscelaneous/` centralizados e renomeados para o padrão `_V7` no final do nome). Ferramenta
  reutilizável (scripts + template xUnit) centralizada em `TestCenter/_ferramentas/` para os próximos
  ciclos (`_V8` em diante). Ver `TestCenter/README.md`.
- `knowledge/patterns/permission-fuzz-testing-cross-produto.md`: primeiro registro em
  `knowledge/patterns/` — metodologia reutilizável de fuzzing de permissão (dinâmico via xUnit + estático
  via scanner de endpoints) validada nos dois produtos.
- 4 Known Issues novos, todos no ELIMS, encontrados pela campanha V7:
  - **KI-0008 (crítica):** `ImageController.get` permite leitura arbitrária de arquivo local sem
    autenticação — confirmado vazando `appsettings.Development.json` (TokenKey JWT, senha do Postgres,
    credenciais SMTP) via chamada HTTP anônima real.
  - **KI-0009 (crítica):** 36 dos 58 controllers de negócio do ELIMS sem `[Authorize]` na classe —
    acesso anônimo confirmado via HTTP real em 30 deles.
  - **KI-0010 (alta):** `Entity.GetByUser` sem guarda de tenant (IDOR) — a correção já aplicada no
    ELIMS não foi replicada no ELIMS.
  - **KI-0011 (média):** JWT sem claim `accountId` derruba `ControllerBaseMiddleware` com
    `NullReferenceException` (500 em vez de 401) — recorrência do bug já catalogado no ELIMS.
- `ELIMS/ELIMS/backend/src/Back.ApiTests/` e `Back.IntegrationTests/`: projetos xUnit novos (fuzzing de
  permissão contra API + Postgres efêmero), sem alteração de código de produção.

## [0.4.0] - 2026-07-31

### Adicionado

- `policies/orquestracao.md` (`alwaysApply: true`, 12ª policy): garante deterministicamente que **todo**
  pedido do usuário passe por um roteamento leve de Chief Architect no início (qual camada/agente é
  responsável, existe precedente) e por um checklist leve de Documentation Architect no fim (docs vivos
  e planilha estrutural atualizados, ou explicitamente marcados "não aplicável") — sem precisar nomear
  esses dois agentes a cada pedido. Os outros 11 agentes continuam `disable-model-invocation: true`,
  acionados só sob demanda/roteamento.
- `knowledge/decisions/0005-chief-e-documentation-architect-sempre-ativos.md`: ADR justificando por que
  esse mecanismo é uma policy `alwaysApply` leve (determinístico, baixo custo de contexto) em vez de
  remover `disable-model-invocation` dos dois agentes (ativação probabilística) ou torná-los
  `alwaysApply` por completo (custo de contexto alto em toda mensagem).

### Modificado

- `MASTER_PROMPT.md` §5 (Integração entre agentes): reescrito para declarar explicitamente que Chief
  Architect e Documentation Architect são "sempre ativos" (via `policies/orquestracao.md`), diferenciando
  esse par dos demais 11 agentes ("sob demanda").
- `FRAMEWORK_ARCHITECTURE.md`: novo objetivo arquitetural (#6) e nota na "Estratégia para economia de
  contexto" descrevendo o mecanismo leve de roteamento/checklist.
- `README.md`: contagem de policies atualizada (11 → 12) e nota sobre a exceção de invocação de Chief
  Architect/Documentation Architect.
- `FRAMEWORK_DECISIONS.md`: índice atualizado com ADR-0005.

## [0.3.1] - 2026-07-31

### Adicionado

- `ELIMS/ELIMS/db/geocloudai.sql` (+ `db/README.md`): cópia de trabalho do dump `pg_dump` (texto,
  schema+dados) do banco do ELIMS, capturado de `ELIMS/GeoCloudDB/geocloudai.sql` — hash SHA-256
  verificado idêntico à origem.
- `ELIMS/ELIMS/db/elims.sql` (+ `db/README.md`): cópia de trabalho do dump `pg_dump` formato custom
  (`PGDMP`) do banco do ELIMS, capturado de `ELIMS/ELIMS DB/elims.sql` — hash SHA-256 verificado
  idêntico à origem. `.gitattributes` do `ELIMS` marca o arquivo como binário (`-text -diff`) para
  impedir corrupção por conversão de fim de linha (`core.autocrlf=true`); blob no git confirmado
  byte-a-byte idêntico via `git hash-object`.
- Convenção documentada nos dois `db/README.md`: a partir de agora, `ELIMS`/`ELIMS` trabalham
  com estas cópias locais, não com as pastas originais (`GeoCloudDB`/`ELIMS DB`), que permanecem
  intocadas como fonte histórica — mesma regra já aplicada ao código-fonte (`ELIMS`/`ELIMS`).

## [0.3.0] - 2026-07-30

### Fase 6 — Revisão de redundâncias (via subagente de exploração)

Correções decorrentes da revisão sistemática de agentes/skills/policies/playbooks/templates:

#### Adicionado

- `templates/known-issue.md`: template canônico para `knowledge/known-issues/` (frontmatter
  `id`/`title`/`severidade`/`status`/`produto`), substituindo a referência incorreta a
  `templates/checklist.md`/`bug-report.md`.
- Tabela de inventário das 19 skills em `FRAMEWORK_ARCHITECTURE.md`.

#### Corrigido

- `knowledge/roadmap/README.md` e `knowledge/melhorias.md`: item "adotar ferramenta real de migration"
  contradizia o ADR-0004 (decisão já tomada de não usar); marcado como decidido/encerrado.
- `knowledge/known-issues/0005-*.md`: seção "Ação recomendada" reescrita para não parecer aberta (a
  decisão já foi tomada — ver "Resolução").
- `MASTER_PROMPT.md`: `version` do frontmatter alinhada à `VERSION` do framework; path quebrado
  `skills/permission-matrix-auditor.md` corrigido para `skills/permission-matrix-auditor/SKILL.md`;
  fluxo (§3) e gerenciamento documental (§8) passam a citar `structural-spreadsheet-sync`.
- `FRAMEWORK_ARCHITECTURE.md`: referência inválida "`MASTER_PROMPT.md` §4.3" corrigida para "regra 3 da
  seção 4".
- `agents/documentation-architect.md`: numeração duplicada no fluxo interno (dois passos "4.") corrigida.
- `agents/knowledge-manager.md` e `knowledge/known-issues/README.md`: referência de template para
  known-issue corrigida para `templates/known-issue.md`.
- `playbooks/atualizacao-documental.md`, `playbooks/nova-entidade.md`, `playbooks/novo-endpoint.md`:
  passo explícito para rodar `structural-spreadsheet-sync` quando a mudança afeta
  entidade/DTO/controller/permissão (estava só na arquitetura, não nos playbooks).
- `policies/documentacao.md`: nova regra exigindo a planilha estrutural atualizada.
- Linguagem "skill aciona skill" (contradizia `MASTER_PROMPT.md` §6) corrigida em
  `skills/documentation-sync/SKILL.md` e `skills/structural-spreadsheet-sync/SKILL.md` — agora explícito
  que a orquestração é do agente/playbook, não de uma skill chamando outra.
- Overlap `endpoint-scanner` ↔ `permission-matrix-auditor`: checagem de seed/severidade removida do
  scanner (inventário puro) e mantida só no auditor.
- Overlap `architecture-validator` ↔ `naming-validator`: verificação de nomenclatura removida do
  validador de arquitetura (fica só no `naming-validator`).
- `skills/impact-analysis/SKILL.md` e `skills/regression-analysis/SKILL.md`: limites explícitos entre as
  duas (triagem de contrato/schema/núcleo vs. mapeamento tático pré-implementação).

## [0.2.1] - 2026-07-30

### Corrigido

- `ELIMS/ELIMS/frontend/angular.json`: orçamento `anyComponentStyle` alinhado ao de `ELIMS/web`
  (`maximumWarning: 80kb`/`maximumError: 100kb`, antes `8kb`/`64kb`), que fazia `ng build --configuration
  production` falhar em `xrf-titan.component.scss` (78kb). Ver `KI-0007`.

### Validado (Fase 5)

- `dotnet build` de `ELIMS/ELIMS/backend/Back.sln` e `ELIMS/ELIMS/backend/src/Back.sln`: sucesso, 0 erros (apenas
  avisos pré-existentes de NuGet — `MailKit`/`MimeKit`/`AutoMapper` — e nullability).
- `npm run build` (`ng build`, produção) de `ELIMS/web` e `ELIMS/frontend`: sucesso, 0 erros, após
  a correção acima.
- Planilhas estruturais consolidadas via `scripts/assemble-structural-spreadsheet.ps1` a partir dos
  fragmentos por lote: `Account_GeoCloud_resumo_estrutural.csv` (100 classes) e
  `Account_ELIMS_resumo_estrutural.csv` (58 classes) — 158 classes no total, confirmando a cobertura
  completa exigida.

## [0.2.0] - 2026-07-30

### Adicionado

- Skill `structural-spreadsheet-sync` (19ª skill) para manter as planilhas estruturais canônicas de
  ELIMS/ELIMS sincronizadas com o código.
- ADR-0004: decisão formal de não usar framework/ferramenta de migration (scripts SQL manuais
  versionados), por exigência do gerente do projeto.
- KI-0006: relatório `implementations/29-migrations-soft-delete-auditoria.md` descrevia sistema de
  auditoria/migration que não existe no código real (só soft-delete parcial existe de fato).
- `scripts/verify-sources-untouched.ps1`: baseline + verificação de hash/tamanho/data para garantir
  que `ELIMS/ELIMS` e `ELIMS/ELIMS` permanecem intocados durante qualquer tarefa.
- `scripts/csv-to-xlsx.py`: converte o `.csv` multi-aba (marcadores `===== SHEET: X =====`) das
  planilhas estruturais em `.xlsx` espelho.
- `ELIMS/ELIMS/docs/estrutura/Account_GeoCloud_resumo_estrutural.csv`/`.xlsx` e
  `ELIMS/ELIMS/docs/estrutura/Account_ELIMS_resumo_estrutural.csv`/`.xlsx`: planilhas estruturais
  completas (todas as classes/endpoints) dos dois produtos, extraídas manualmente do código-fonte.
- `ELIMS/ELIMS/backend/docs/migrations.md`: documento de processo de schema criado desde o início
  (evita a mesma divergência doc×código encontrada no ELIMS).

### Corrigido

- `ELIMS/ELIMS/backend/docs/migrations.md`: reescrito para refletir a realidade do código (sem runner
  FluentMigrator) em vez do sistema aspiracional documentado anteriormente.
- `implementations/29-migrations-soft-delete-auditoria.md`: nota de correção adicionada apontando
  `KI-0006`.
- `policies/banco-de-dados.md` e `playbooks/migration.md`: desambiguação de que "migration" sempre
  significa script SQL manual, nunca uma ferramenta/lib.

### Removido

- `ELIMS/Miscelaneous/Account_ELIMS_resumo_estrutural.csv`/planilha antiga — substituída pela versão
  canônica completa em `ELIMS/ELIMS/docs/estrutura/`.

## [0.1.0] - 2026-07-30

### Adicionado

- Estrutura inicial completa do framework: `MASTER_PROMPT.md`, `FRAMEWORK_ARCHITECTURE.md`, `FRAMEWORK_DECISIONS.md`, `FRAMEWORK_ROADMAP.md`.
- 13 agentes especializados em `agents/`.
- 18 skills nativas do Cursor em `skills/`.
- 11 policies em `policies/` (fonte de `.cursor/rules/*.mdc`).
- 13 playbooks em `playbooks/`.
- 11 templates em `templates/`.
- Knowledge base federada inicial em `knowledge/` (arquitetura, domínio, decisões, padrões, known-issues, roadmap).
- Scripts de automação do framework (`sync-cursor.ps1`, `new-adr.ps1`, `new-memory.ps1`, `validate-framework.ps1`, `bootstrap-new-base.ps1`).
- Testes de auto-validação estrutural em `tests/`.
- Scaffold inicial de `ELIMS/ELIMS` (baseline de `ELIMS/ELIMS`) e `ELIMS/ELIMS` (baseline de `ELIMS/ELIMS`).
- ADR-0001, ADR-0002, ADR-0003 registrando as decisões fundacionais do framework.

### Baseado em

Descoberta completa de `ELIMS`, `ELIMS`, `GeoLims` e do documento `ELIMS_GeoCloud_Visao_Tecnica.md` (28/07/2026), incluindo mapeamento de arquitetura, dívida técnica conhecida e ativos de documentação/knowledge já existentes.
