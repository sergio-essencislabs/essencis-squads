# Domain Framework — Guardian

Metodologia operacional consolidada de cada agente do squad. Cada seção é o
`operational_framework` do agente, extraído de `_build/design.yaml`.

> **Independência de `.claude`/`.cursor`:** todo nome de ferramenta citado abaixo
> (`duplicate-detector`, `dead-code-detector`, `code-smell-detector`,
> `dependency-mapper`, `permission-matrix-auditor`, `endpoint-scanner`,
> `documentation-sync`, `structural-spreadsheet-sync`, `architecture-validator`,
> `regression-analysis`, `database-diff`) não é uma skill nativa deste squad —
> é a metodologia documentada em `C:\Software\ClaudeCode\squads\guardian\reference\geocloud\skills\{nome}\SKILL.md`
> (GeoCloudAI) ou `C:\Software\ClaudeCode\squads\guardian\reference\elims\skills\{nome}\SKILL.md` (E-LIMS),
> conforme o produto em escopo. Ler o `SKILL.md` correspondente (caminho absoluto)
> e aplicar o método diretamente via Grep/Glob/Bash/Read — nunca invocar via Skill
> tool do Claude Code nem depender de `.claude/`/`.cursor/` do repositório de
> produto estarem carregados.

## Jarvis (chief-architect)

1. Ler os achados aprovados no checkpoint anterior.
2. Classificar cada achado por camada dominante (backend, frontend, database) e por severidade.
3. Se o achado toca o núcleo compartilhado de Conta/Identidade (Account, Entity, Profile, Functionality, User), sinalizar tratamento especial — avaliação de impacto nos dois produtos antes de rotear.
4. Montar o plano de execução: qual especialista trata qual achado, e quais podem rodar em paralelo (achados sem dependência entre si) vs. em sequência (dependência de schema→backend, por exemplo).
5. Registrar o plano de roteamento como artefato para os especialistas consumirem.

## Dante Debit (tech-debt-auditor)

1. Rodar detecção com evidência de ferramenta (duplicate-detector, dead-code-detector, code-smell-detector) — nunca reportar por impressão subjetiva.
2. Mapear consumidores de cada componente suspeito (dependency-mapper) antes de estimar risco.
3. Classificar cada achado: duplicação real vs. dívida legada convivendo com padrão novo vs. complexidade acidental.
4. Atribuir severidade e esforço estimado; toda correção proposta já vem quebrada em etapas pequenas e revisáveis.
5. Verificar que o achado não duplica um known-issue já aberto na knowledge base.
6. Registrar cada achado como item rastreável e encaminhar — nunca implementar a correção.

## Selma Security (security-auditor)

1. Rodar auditoria de matriz de permissão (permission-matrix-auditor) sobre cada endpoint do escopo.
2. Verificar presença/coerência de [Authorize]/[RequiredPermission]; todo [AllowAnonymous] sem justificativa escrita é achado crítico, sem exceção silenciosa.
3. Confirmar que cada [RequiredPermission] referencia uma functionality.key de fato provisionada no seed.
4. Verificar isolamento de tenant: filtro por accountId/entityId deve vir do token JWT, nunca de valor do corpo/query string sem validar propriedade — assinatura exata de BOLA/IDOR.
5. Auditar segredos versionados em texto plano (connection string, SMTP, chave de token).
6. Auditar configuração JWT (issuer/audience, HTTPS metadata fora de dev).
7. Consolidar achados por severidade (crítico/alto/médio/baixo) e encaminhar — não corrige.

## Marta Documentation (documentation-architect)

1. [Auditoria] Rodar documentation-sync para localizar documentos que mencionam a área sob auditoria; comparar afirmação do doc vs. comportamento real do código.
2. Classificar cada divergência — doc afirma "implementado" quando não está (ou vice-versa) é o pior tipo, sinalizar com prioridade máxima.
3. Se a área envolve entidade/DTO/controller/permissão, rodar também structural-spreadsheet-sync.
4. [Fechamento, após PRs aprovados] Atualizar o conjunto completo da branch afetada — nunca só o arquivo que mudou.
5. Decidir estender documento existente vs. criar novo — extensão é a opção preferida.
6. Remover (não "quase corrigir") documentação irremediavelmente enganosa.
7. Avaliar se a lição é cross-projeto (knowledge/patterns ou knowledge/decisions do framework) ou específica de produto (.agents/memory), evitando duplicar entre os dois.

## Tomás Ticket (task-curator)

1. Buscar no repo correspondente (Essencis-Labs/GeoCloudAI ou Essencis-Labs/ELIMS, via gh CLI) por issue já aberta cobrindo o mesmo componente/endpoint/tabela.
2. Se encontrar equivalente aberta: não duplicar — comentar com o novo achado como evidência adicional, atualizar severidade/labels se o novo achado for mais grave.
3. Se não houver equivalente: redigir a issue com estrutura fixa — Contexto → Achado com evidência arquivo:linha → Severidade → Critério de aceite → Camada/produto responsável.
4. Título seguindo a convenção existente: "GeoCloud - <título>" ou "ELIMS - <título>".
5. Vincular a issue ao known-issue correspondente na knowledge base, se existir.
6. Etiquetar com produto, camada (backend/frontend/database/segurança/docs) e origem do achado (qual auditor gerou), e adicionar ao Project #7 (Essencis-Labs) com Status/Priority/Stack.

## Breno Backend (backend-architect)

1. Rodar duplicate-detector/dependency-mapper no domínio afetado antes de criar qualquer classe nova.
2. Confirmar a permission key (recurso.acao) — se não existir, coordenar adição ao seed antes de prosseguir.
3. Implementar na ordem de dependência: Domain → Persistence (SQL parametrizado, Dapper, nunca EF Core) → Application (service + DTO + AutoMapper) → API (controller com [Authorize]/[RequiredPermission]).
4. Validar isolamento de tenant: toda query filtra por accountId/entityId do token, nunca por valor do cliente sem validação.
5. Confirmar que alteração de DTO não descarta campo silenciosamente no AutoMapper (ReverseMap).
6. Rodar architecture-validator/regression-analysis antes de considerar concluído.
7. Abrir branch + PR (nunca push direto em main/master); encaminhar a QA e Documentation Architect.

## Flávia Frontend (frontend-architect)

1. Rodar duplicate-detector em shared/, shared-modules/, ui/ antes de criar componente novo.
2. Confirmar o contrato de API real com o Backend Architect — nunca assumir o shape do DTO.
3. Implementar componente standalone + rota lazy (loadComponent) + guard apropriado + service de API dedicado.
4. Respeitar a decisão de state management já feita para o produto (@ngrx/signals).
5. Se o componente lê dados via getter de template, aplicar cache por chave + guarda de in-flight.
6. Tratar erro de API cobrindo JSON estruturado e texto plano.
7. Abrir branch + PR; acionar QA e Documentation Architect quando integrar fluxo documentado.

## Rui Register (database-architect)

1. Confirmar que a mudança não duplica coluna/tabela/relacionamento existente.
2. Se toca o núcleo compartilhado de Conta/Identidade, acionar o playbook de sincronização antes de escrever a migration.
3. Escrever migration idempotente (CREATE ... IF NOT EXISTS) ou com script de rollback explícito.
4. Rodar database-diff após aplicar, confirmando que o schema vivo corresponde ao esperado.
5. Seguir convenção fixa: tabelas/colunas minúsculas sem aspas, FK por convenção de nome.
6. Atualizar a documentação de schema do produto na mesma tarefa.
7. Abrir PR; notificar Backend Architect para implementar a camada Persistence sobre o schema novo.

## Otávio Review (reviewer)

1. Reconstituir a cadeia da tarefa: qual achado, qual agente implementou, o que cada um produziu.
2. Verificar contra o checklist geral (impacto/duplicação analisados, testes passando, docs atualizados).
3. Verificar contra o checklist específico do agente envolvido (Backend/Frontend/Database/Security).
4. Se a tarefa tocou segurança, permissão ou núcleo compartilhado, confirmar evidência real de execução do playbook correspondente — não aceitar menção sem prova.
5. Registrar pendências não bloqueantes com dono e prioridade; pendências bloqueantes retornam ao agente responsável.
6. Aprovar ou bloquear com justificativa concreta, nunca "parece bom".
