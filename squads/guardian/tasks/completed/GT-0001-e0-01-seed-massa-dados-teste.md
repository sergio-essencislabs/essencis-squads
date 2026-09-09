---
id: GT-0001
title: "Seed: popular ambiente com furos, caixas e marcações representativas"
status: active
type: feature
reaberta_qa: "2026-09-03"
achado_origem: "N/A — pedido direto de implementação (projeto Visualizadores/Navegação/Layout)"
auditor_origem: "Jarvis — planejamento (planejar-implementacao.md)"
severidade: "N/A — feature, bloqueante de E3/E4"
produto: GeoCloudAI
camada: backend
run_origem: "adhoc-chief-architect-104840 (planejamento) + PR #342 (criação das issues)"
issue_url: "https://github.com/Essencis-Labs/GeoCloudAI/issues/316"
grupo_execucao: "Onda 1"
owner: ""
created_at: 2026-09-02
updated_at: 2026-09-02
affected_modules: [seed, drillhole, drillbox, drillcore]
related_adrs: []
---

# GT-0001 — Seed: popular ambiente com furos, caixas e marcações representativas

## Contexto
Hoje não é possível validar Single View e MultiView de forma realista — falta volume de dados. Bugs de escala (régua, empilhamento vertical, performance de N caixas) só apareceriam em produção sem isso. Bloqueia todo o E3 e E4.

## Achado original
Pedido direto de implementação — corpo completo em https://github.com/Essencis-Labs/GeoCloudAI/issues/316.
- Seed/script com no mínimo 10 DrillHoles com ≥ 200 m de profundidade cada, com DrillBoxes/DrillCores completos e imagens.
- Popular hierarquia completa Region → Deposit → Mine → MineArea → DrillHole.
- Incluir marcações (litologias, fraturas, veios) e ao menos 1 resumo de IA gerado.
- Documentar como rodar/resetar o seed.
- **Refinamento pedido pelo usuário (2026-09-02, ver `_memory/memories.md`)**: o seed deve rodar automaticamente no boot (`dotnet run`/`dotnet test`), não como script manual separado — decidir entre migration de dados (FluentMigrator) ou seeder idempotente estilo `PermissionSeeder.cs`, com guarda de ambiente (só dev) obrigatória.

## Objetivo
Ambiente de dev/homologação sobe já populado com dado realista, sem passo manual, sem risco de rodar em produção.

## Fora de escopo
Estimativa/planejamento de lavra, treino do modelo de rede neural (fora do escopo do produto).

## Comportamento atual
Sem massa de dados representativa — impossível validar bugs de escala.

## Comportamento esperado
10+ furos, hierarquia completa, marcações e resumos de IA populados automaticamente no boot em ambiente de dev.

## Regras de negócio
- RN-01: N/A — task técnica de infraestrutura de teste, sem regra de negócio nova.

## Critérios de aceitação
- [x] CA-01: Ambiente de dev/homologação sobe com os 10 furos populados por um único comando (ou automaticamente no boot, conforme refinamento).
- [x] CA-02: Ao menos 1 furo com > 200 m e caixas com imagens reais (ou representativas/duplicadas do diretório Resources).
- [x] CA-03: Hierarquia navegável do Region até o DrillHole sem nós órfãos.
- [x] CA-04: Ao menos 1 caixa com resumo de IA e 1 caixa sem, para testar o indicador visual (GT-0009/E2-05).
- [x] CA-05 (refinamento): seed roda automaticamente no boot, idempotente, com guarda de ambiente (nunca roda fora de dev/homologação).

## Impacto técnico
### Backend
Migration de dados ou seeder idempotente no `Startup.cs` — decisão a confirmar com Rui/Breno (ver GADR não aberto para isso, é decisão de implementação, não arquitetural).
### Frontend
N/A.
### Banco de dados
Usa schema existente, sem nova tabela/coluna esperada.
### Integrações
N/A.
### Segurança
Guarda de ambiente obrigatória — nunca seedar fora de dev/homologação.

## Plano de implementação
- [ ] Decidir mecanismo (migration de dados vs. seeder) com guarda de ambiente.
- [ ] Popular hierarquia + furos + caixas + cores + imagens.
- [ ] Popular marcações e resumos de IA (com e sem, para GT-0009).
- [ ] Documentar como rodar/resetar.

## Estratégia de testes
- [ ] Manual — subir ambiente do zero e confirmar navegação completa.
- [ ] Integração — confirmar idempotência (rodar 2x não duplica dado).

## Riscos e rollback
Seed rodando fora de dev por falta de guarda de ambiente populariam dado sintético em staging/produção — mitigado pela guarda de ambiente do CA-05.

## Registro de execução
### Alterações realizadas
- Criado um seeder idempotente (`IDevDataSeederService`/`DevDataSeederService`) que, no boot da API em Development, popula sob a Account 1 ("Essencis", tenant system-owner presente em todo ambiente criado a partir da baseline): 1 Region → 1 Deposit → 1 Mine → 2 MineArea → 10 DrillHole (200m a 320m) → 12 DrillBox/furo (120 no total, cada uma com foto sintética 900x280 + miniatura, seguindo a mesma convenção de nome `{id}-{guid}.jpg`/`{id}-{guid}_.jpg` do upload real) → 3 DrillCore/caixa (360 no total), com marcação de litologia em 100% dos testemunhos (360), fratura em ~1/3 (120) e veio/mineralização em ~1/4 (120).
- Simulado exatamente 1 "resumo de IA" (via `chat_conversation`/`chat_message`, deixando explícito no texto que é dado de seed e não uma chamada real ao LLM) na primeira caixa seedada; as outras 119 caixas ficam sem resumo — cobre os dois casos exigidos pelo CA-04.
- Guarda de ambiente extraída para uma função pura e testável (`DevDataSeedGuard.ShouldRun`), chamada de `Back.API/Extensions/DevDataSeedExtensions.cs`, que só permite o seed quando `IWebHostEnvironment.EnvironmentName == "Development"` — sem nenhuma chave de configuração capaz de religar isso fora de Development.
- `Program.cs` passou a chamar `host.Services.SeedDevelopmentDataAsync(...)` logo depois de `ApplyPendingMigrations` e antes de `host.RunAsync()`; falha do seed é logada como erro mas não derruba o boot.
- Documentado em `api/docs/system/dev-data-seed.md` (linkado em `api/docs/system/README.md`): como rodar, hierarquia gerada, convenção do resumo de IA simulado, guarda de ambiente, SQL de reset manual e todas as decisões/divergências abaixo.
- Adicionado teste de regressão dedicado para a guarda de ambiente (CA-05) em `api/tests/Back.UnitTests/Seed/DevDataSeedGuardTests.cs`.

### Arquivos principais
- `api/src/Back.Application/Contracts/IDevDataSeederService.cs` (novo)
- `api/src/Back.Application/Services/DevDataSeederService.cs` (novo) — orquestra os repositórios existentes (Region/Deposit/Mine/MineArea/DrillHole/DrillBox/DrillCore/Rect/DrillCoreLithology/DrillCoreFracture/DrillCoreMineralization/Chat), sem SQL próprio (Dapper fica só em `Back.Persistence/Repositories`, como manda a arquitetura).
- `api/src/Back.Application/Services/DevDataSeedGuard.cs` (novo) — decisão pura de ambiente, sem dependência de ASP.NET Core hosting, para ser testável a partir de `Back.UnitTests`.
- `api/src/Back.API/Extensions/DevDataSeedExtensions.cs` (novo) — resolve o guard + o serviço num scope do DI e chama `SeedAsync()`.
- `api/src/Back.API/Program.cs` (editado) — `Main` virou `async Task`; chama o seed guardado logo após as migrations.
- `api/src/Back.API/Startup.cs` (editado) — registra `IDevDataSeederService`.
- `api/docs/system/dev-data-seed.md` (novo) — documentação de uso/reset/decisões.
- `api/docs/system/README.md` (editado) — link para o doc acima.
- `api/tests/Back.UnitTests/Seed/DevDataSeedGuardTests.cs` (novo).

### Decisões
- **Migration de dados vs. seeder idempotente → seeder idempotente.** Não existe hoje um `PermissionSeeder.cs` no código real (busquei em todo `api/src` e não encontrei — o nome citado no refinamento parece vir de uma expectativa/outro projeto irmão, não deste repositório). Segui o espírito do padrão mesmo assim: uma classe de serviço idempotente, chamada explicitamente no boot (não dentro de uma migration FluentMigrator), com sua própria guarda de ambiente testável. Não usei migration porque FluentMigrator não tem um conceito nativo de "ambiente" (só tags, que exigiriam uma camada de configuração condicional nova só para replicar o que `IWebHostEnvironment.IsDevelopment()` já garante de forma direta) e porque dado sintético de teste não é "schema" — não é papel de uma migration.
- **Conta-alvo do seed: Account 1 (fixo).** É o tenant "system owner" (`EntityId=1`, `UserId=1`/`test@test`) presente em qualquer ambiente criado a partir de `M202605050001_MySqlBaselineV2` (ver `api/docs/system/README.md` §2) — confirmado lendo `mysql_baseline_v2.sql` e validado contra uma cópia real do banco de dev (`geocloudai`). Login de dev já conhecido enxerga a massa de dados sem credencial nova. Se a Account 1 não existir ou não tiver `UserId`/`Guid`, o seed loga aviso e sai sem quebrar o boot.
- **Imagens sintéticas, não descoberta/duplicação de fotos reais do `Resources/`.** O diretório `Resources/` não é versionado (`.gitignore`) e não existe garantidamente em toda máquina/CI. Gerar uma imagem sintética determinística (bandas coloridas por testemunho, mesma convenção de nome do upload real) mantém o seed 100% reprodutível em qualquer ambiente, ao custo de não ser uma foto real de testemunho — CA-02 explicitamente permite "representativas/duplicadas".
- **Resumo de IA simulado via `chat_conversation`/`chat_message`, não uma tabela nova.** Não existe hoje nenhuma coluna/tabela "resumo de IA por caixa" (chat é uma conversa avulsa, sem FK para `DrillBox`). Criar essa tabela seria decisão de schema do GT-0009 (consumidor deste seed), não deste seed. Usei o mecanismo de chat já existente com uma convenção de `metadata` JSON (`{"drillBoxId":...,"kind":"drillbox_ai_summary_seed"}`) documentada como não-definitiva.
- **Volume: 12 caixas/furo × 3 testemunhos/caixa** (120 caixas, 360 testemunhos) — suficiente para expor bugs de escala em Multi View sem tornar o primeiro boot lento (seed completo em poucos segundos localmente).

### Divergências
- O refinamento da task cita `PermissionSeeder.cs` como referência de padrão já existente — não encontrado neste repositório (`api/src`). Não bloqueou a implementação (ver "Decisões" acima), mas registro para quem revisar não estranhar a ausência dessa referência.
- Durante a validação, descobri um bug pré-existente e não relacionado a este seed: bootstrapping a partir de um banco **vazio** (schema=nenhum) falha na migration `M20260828175631_WidenCommentsTo1000` com `Duplicate entry '20260828175631' for key 'versioninfo.UC_Version'`, porque a migration de baseline (`M202605050001_MySqlBaselineV2`) já insere esse `VersionInfo` como dado histórico do dump, mas o `VersionLoader` do FluentMigrator não reconsulta essa linha antes de tentar reaplicar a migration compilada do mesmo número. Isso **não** afeta bancos de dev já existentes (incrementalmente migrados, como o `geocloudai` real) nem foi introduzido por mim — só aparece ao fazer `dotnet run` contra um banco MySQL completamente vazio. Não tentei corrigir (fora do escopo do GT-0001 e mexe em migrations já aplicadas); sinalizando para o `database-schema-guardian`/dono das migrations avaliar.
- Não há um comando de reset automatizado (ex.: `dotnet run -- --reset-seed`) — documentei o SQL de reset manual em `api/docs/system/dev-data-seed.md`. Registrando como decisão consciente de escopo (a task pede "documentar como resetar", não necessariamente automatizar o reset).

### Pendências
- GT-0009 precisa confirmar (ou substituir) a convenção `chat_message.metadata` usada aqui para simular o resumo de IA por caixa antes de construir o indicador visual em cima dela.
- ~~O bug de bootstrap-a-partir-de-banco-vazio (`M20260828175631`) descrito em Divergências não foi corrigido~~ — **Resolvido em 2026-09-02**: causa raiz era `mysql_baseline_v2.sql` ainda trazer o bloco `versioninfo` do mysqldump bruto (contradizendo o próprio comentário da migration de que a tabela seria excluída). Corrigido, revisado e aprovado por `database-schema-guardian` e por Otávio Review (Guardian, ad-hoc) — PR [#348](https://github.com/Essencis-Labs/GeoCloudAI/pull/348) (retargetado para `feature/visualizadores-navegacao-layout`, mesma branch de integração dos demais PRs deste projeto).

## Validação
Build:
```
cd api && dotnet build Back.sln
```
Resultado: sucesso, 0 erros (6 avisos pré-existentes não relacionados: NU1903 do AutoMapper e 2 CS8604 em `UserService.cs`).

Testes unitários:
```
cd api && dotnet test tests/Back.UnitTests/Back.UnitTests.csproj
```
Resultado: 114 aprovados, 1 falha pré-existente e não relacionada
(`ForeignKeyRangeValidationTests.Writable_foreign_keys_follow_the_range_convention`,
sobre `DrillBoxChatSendDto.DrillBoxId` — arquivo não tocado nesta task).
Os testes novos (`DevDataSeedGuardTests`, 8 casos) e os de migration (`MigrationVersionTests`, 3 casos) passaram.

Execução manual ponta a ponta (contra uma **cópia descartável** do banco de dev real via `mysqldump`, nunca contra o `geocloudai` compartilhado):
1. `dotnet run` (`ASPNETCORE_ENVIRONMENT=Development`) — 1ª vez: seed criou region id 8 ("GT-0001 Seed - Furos de Teste"), 10 `DrillHole` (200–320m, confirmado via `SELECT length FROM drillhole WHERE name LIKE 'SEED-DH-%'`), 120 `DrillBox` (todas com `imgArquivo` preenchido e arquivo JPEG 900x280 válido gravado em `Resources/<guid>/Images/DrillBoxes/`, confirmado com `file`), 360 `DrillCore`, 360 marcações de litologia, 120 de fratura, 120 de veio, e 1 `chat_conversation` com resumo de IA simulado (exatamente 1 caixa com resumo, 119 sem — confirmado por query).
2. `dotnet run` (2ª vez, mesmo banco, mesmo ambiente) — log `Dev data seed skipped: region '...' (id 8) already exists — seed already applied.`; contagens de linhas inalteradas. Confirma idempotência (CA-05 / estratégia de testes "rodar 2x não duplica dado").
3. `dotnet run` (`ASPNETCORE_ENVIRONMENT=Production`, mesmo banco, `Seed:DevData:Enabled` não setado → default `true`) — log `Dev data seed skipped (environment='Production', Seed:DevData:Enabled=True)`; nenhuma linha nova. Confirma a guarda de ambiente (CA-05) mesmo com a seed habilitada por configuração.
Banco temporário e imagens geradas foram apagados após a validação; o `geocloudai` compartilhado não foi alterado em nenhum momento.

## Handoff
Bloqueia GT-0002 (validação), GT-0009, GT-0013, GT-0015, GT-0020 (todas dependem deste seed para validar de forma realista).

**Merge (2026-09-02)**: PR #345 mesclado (squash) em `feature/visualizadores-navegacao-layout`, commit `f78d6eaf53a8de206c89457beabcf7000a1e1b07`. Ainda não mesclado em `main` — aguardando validação manual do usuário na branch de integração.

## Achado de QA pós-implementação (2026-09-03)
Relatório de QA (Matheus, `TASKS.md`, "Observações gerais"): "as novas caixas não têm imagem de drillbox (o dado de imagem existente não foi duplicado para elas), e faltou marcar automaticamente litologia, drillcores e recorte das caixas."

**Análise (Jarvis)**: parcialmente confirmado, parcialmente não reproduzido no código.
- **Litologia/drillcore/recorte**: o código (`DevDataSeederService.cs`) confirma marcação de litologia em 100% dos 360 testemunhos, fratura em ~1/3, mineralização em ~1/4, e `Rect` (recorte) por caixa/core — não encontrei nenhuma lacuna real aqui. Recomendo confirmar com Matheus se o ambiente testado realmente tinha o seed atualizado rodado (pode ser percepção causada pelo item abaixo).
- **Imagem**: **confirmado, causa raiz identificada**. A decisão original de GT-0001 (documentada em `api/docs/system/dev-data-seed.md`, "Divergências") foi gerar imagens **sintéticas** (bandas coloridas) em vez de copiar fotos reais de `Resources/`, com a justificativa de que o worktree/ambiente de execução do agente **não tinha** `Resources/` disponível (pasta gitignored). Essa é uma decisão razoável para o ambiente sandboxed em que foi tomada, mas diverge do pedido original do usuário ("mockar OU copiar as imagens existentes em Resources") e do ambiente real de Sergio/Matheus, que **tem** um `Resources/` populado. As imagens sintéticas (bandas coloridas simples) provavelmente pareceram "sem imagem real" na avaliação de Matheus.

**Correção proposta**: o seed passa a tentar localizar imagens reais já existentes em `Resources/{accountGuid}/Images/DrillBoxes/` (ou uma pasta de referência dedicada) em tempo de execução (não em tempo de implementação) e cicla entre elas para as novas caixas; síntese permanece como fallback apenas se nenhuma imagem real for encontrada (preserva a reprodutibilidade em CI/ambientes sem `Resources/`).

Ver plano consolidado em `squads/guardian/output/qa-pos-implementacao-2026-09-03.md`.

## Correção do achado de QA — Registro de execução (2026-09-03)

### Convenção adotada (investigação do `Resources/` real)
Inspecionei o `Resources/` real do checkout principal (`C:\Software\GeoCloud\GeoCloudAI\api\src\Back.API\Resources`, gitignored, presente na máquina do usuário mas não neste worktree isolado) para confirmar a estrutura antes de implementar. Confirmado: `Resources/{accountGuid}/Images/DrillBoxes/{id}-{guid}.jpg` (foto) + `{id}-{guid}_.jpg` (miniatura), exatamente a convenção que `DrillBoxController.UploadImagem` já usa — nenhuma pasta de "referência" dedicada existe ou precisa ser inventada.

Convenção implementada em `DevDataSeederService.DiscoverReferenceImages()`:
- Varre `Resources/{qualquer accountGuid}/Images/DrillBoxes/*.jpg` (não só a conta do seed) uma única vez, no início de `SeedAsync`, antes de criar qualquer hierarquia.
- Ignora arquivos terminados em `_.jpg` (miniatura de upload, não foto principal).
- Decisão deliberada de aceitar fotos de **qualquer** conta como candidatas: `Resources/` não é isolado por tenant no nível de filesystem (o próprio `UploadImagem` nunca valida dono do path onde grava), uma foto real de testemunho é real independente de qual conta a enviou, e o seed sempre grava a cópia sob a pasta da própria Account 1 — nunca lê/expõe dado de outra conta via API.
- Se encontrar 1+ fotos, cicla entre elas (índice sequencial da caixa `% quantidade encontrada`) copiando bytes exatos (`File.Copy`) para cada nova caixa, preservando a convenção de nome `{id}-{guid}.jpg`/`{id}-{guid}_.jpg`. Miniatura é copiada junto se existir ao lado da foto principal; senão, gerada por resize (mesmo padrão de `CvService.Resize`: largura fixa, altura proporcional).
- Se não encontrar nenhuma (CI/checkout limpo), mantém o fallback sintético original inalterado.
- Cap de segurança `MaxReferenceImagesToScan = 300` para não escanear uma árvore `Resources/` anormalmente grande sem necessidade (só são precisas 120 cópias no total).
- Limitação conhecida e documentada: os `Rect` de recorte continuam calculados assumindo a dimensão sintética 900x280 (necessário para a marcação de litologia/fratura/mineralização por posição); quando a foto real tem outra dimensão, o recorte não bate pixel-a-pixel com o conteúdo real — aceitável para o propósito do seed, registrado em `dev-data-seed.md`.

### Arquivos alterados
- `api/src/Back.Application/Services/DevDataSeederService.cs` — novo método `DiscoverReferenceImages()`; `TryWriteBoxImage` agora recebe a lista de referências + índice de ciclo e prioriza cópia real sobre síntese.
- `api/docs/system/dev-data-seed.md` — nova redação da seção "Imagens", decisão registrada em "Divergências", nova subseção de validação.

### Validação
- `dotnet build Back.sln` — sucesso, 0 erros (mesmos 6 avisos pré-existentes não relacionados).
- `dotnet test tests/Back.UnitTests/Back.UnitTests.csproj` — 114 aprovados, 1 falha pré-existente e não relacionada (`ForeignKeyRangeValidationTests.Writable_foreign_keys_follow_the_range_convention`, já documentada acima).
- Execução manual ponta a ponta, contra **duas** cópias descartáveis novas do banco de dev real (`mysqldump` de `geocloudai` → dois bancos temporários; banco compartilhado nunca tocado):
  1. Sem fotos reais em `Resources/`: log `Dev data seed: no real drill box photos found under Resources/ — seeded boxes will use synthetic images (expected on a fresh checkout/CI).` — 120 caixas com imagem sintética, comportamento de fallback preservado.
  2. Com 4 fotos reais copiadas manualmente (a partir do `Resources/` real do checkout principal, nunca de dado de cliente em produção) para `Resources/{guid da Account 1}/Images/DrillBoxes/`: log `Dev data seed: found 4 real drill box photo(s) under Resources/ — reusing them (cycling) instead of synthetic images.` Confirmado por tamanho em bytes que as caixas seedadas (ex.: box 174 = 3.681.054 bytes, idêntico à foto de referência 1; box 175 = 3.965.707 bytes, idêntico à foto de referência 2) receberam cópia binária exata, ciclando corretamente entre as 4 fotos.
  3. Reexecução contra o mesmo banco do passo 2: log `Dev data seed skipped: region '...' already exists` — contagem de arquivos em `Resources/.../DrillBoxes/` inalterada (248 antes e depois), confirma que a mudança não quebrou a idempotência (CA-05).
- Bancos temporários e a pasta `Resources/` de teste (criada só neste worktree para o teste) foram apagados após a validação.

### Handoff
PR aberto: https://github.com/Essencis-Labs/GeoCloudAI/pull/374, branch `fix/gt-0001-seed-real-images` → `feature/visualizadores-navegacao-layout` (mesma branch de integração do GT-0001 original). Aguardando review/merge — depois de mesclado, sugerir a Matheus reexecutar o seed (do zero, banco limpo) com o `Resources/` real de dev populado para reconfirmar visualmente que as caixas mostram fotos reais.

## Ajuste local 2026-09-05 — thumbnails das caixas SEED
O card da lista de caixas usa a miniatura BASE (`{id}-{guid}_.jpg`). As 120 caixas SEED tinham base + miniatura ainda como placeholders cinza do seeder (só as variantes `b`/`c` haviam sido copiadas de Canaã em 2026-09-04). Substituídos 240 arquivos por fotos base reais de Canaã (rodízio de 13 fontes); placeholders guardados em `scratchpad/seed-placeholders/` da sessão. Só disco local, sem PR.
