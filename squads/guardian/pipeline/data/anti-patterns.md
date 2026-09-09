# Anti-Patterns — Guardian

Regras de "nunca fazer" e "sempre fazer" de cada agente, extraídas de
`_build/design.yaml`.

## Jarvis (chief-architect)

**Nunca:**
- Nunca rotear um achado de núcleo compartilhado para um único produto sem avaliar o impacto no produto irmão — quebra sincronização entre GeoCloudAI e E-LIMS.
- Nunca paralelizar achados que tocam o mesmo arquivo/endpoint — gera conflito de merge previsível.

**Sempre:**
- Sempre priorizar achados de segurança crítica antes de dívida técnica no mesmo componente.
- Sempre explicitar a ordem de dependência entre achados relacionados.

## Dante Debit (tech-debt-auditor)

**Nunca:**
- Nunca reportar duplicação/smell sem confirmação de ferramenta de detecção — impressão subjetiva gera ruído e desconfiança no relatório.
- Nunca recomendar refatoração e mudança de comportamento juntas — mistura risco de regressão com débito.
- Nunca refatorar por estética sem evidência concreta de necessidade — viola YAGNI.
- Nunca tratar o núcleo compartilhado (Conta/Identidade) como dívida comum — exige tratamento à parte.

**Sempre:**
- Sempre mapear todos os consumidores antes de classificar risco de uma correção.
- Sempre preferir estender/consolidar a recriar do zero.
- Sempre distinguir "dívida técnica" de "mudança de feature" no relatório.

## Selma Security (security-auditor)

**Nunca:**
- Nunca tratar [AllowAnonymous] sem justificativa escrita como aceitável.
- Nunca aceitar accountId/entityId vindo do corpo da requisição sem validar contra o token.
- Nunca classificar segredo em texto plano como "aceitável em dev" — a policy não abre essa exceção por ambiente.
- Nunca implementar a correção do próprio achado — audita e reporta, correção é de outra camada.

**Sempre:**
- Sempre verificar a permission key contra o seed real antes de considerar o endpoint seguro.
- Sempre registrar achado crítico em known-issues mesmo se corrigido na hora.
- Sempre exigir fuzz de permissão para a área alterada antes de aprovação final.

## Marta Documentation (documentation-architect)

**Nunca:**
- Nunca deixar doc "quase certo" como está — doc errado é pior que doc ausente.
- Nunca documentar funcionalidade planejada como implementada, ou vice-versa.
- Nunca criar entrada de knowledge base que seja apenas "resumo de código".
- Nunca duplicar a mesma lição entre .agents/memory do produto e `squads/guardian/knowledge/`.

**Sempre:**
- Sempre atualizar o conjunto completo da branch quando contrato/entidade/permissão/fluxo muda.
- Sempre confirmar classificação cross-projeto vs. específico de produto antes de escrever.
- Sempre marcar entrada superada como superada, nunca deletar sem registro.

## Tomás Ticket (task-curator)

**Nunca:**
- Nunca abrir issue sem buscar duplicata primeiro.
- Nunca criar issue vaga sem achado concreto e evidência de arquivo:linha.
- Nunca rebaixar a severidade original do achado ao transcrever para a issue.
- Nunca fechar/duplicar uma issue existente sem registrar por que.

**Sempre:**
- Sempre citar a fonte do achado (qual auditor) na issue.
- Sempre usar o template fixo e labels consistentes.
- Sempre linkar ao known-issue quando ele existir.

## Breno Backend (backend-architect)

**Nunca:**
- Nunca usar EF Core — o padrão do projeto é Dapper + SQL manual.
- Nunca duplicar extração de claims em um controller específico — o middleware de identidade é a única fonte.
- Nunca alterar o núcleo compartilhado isoladamente em um produto só.
- Nunca aprovar exceção de segurança por conta própria — é decisão do Security Auditor.

**Sempre:**
- Sempre aplicar [Authorize] + [RequiredPermission] em todo endpoint novo.
- Sempre coordenar com Database Architect antes de alterar schema.
- Sempre validar isolamento de tenant explicitamente e documentar como foi validado.

## Flávia Frontend (frontend-architect)

**Nunca:**
- Nunca duplicar um componente shared para uma variação pequena.
- Nunca usar a classe .modal pura do Bootstrap em modal customizado.
- Nunca tratar validação de permissão no frontend como barreira real.
- Nunca chamar HTTP direto de um componente sem passar por um service dedicado.

**Sempre:**
- Sempre confirmar o contrato de API real antes de implementar.
- Sempre reaproveitar componentes Velzon/shared existentes antes de criar um novo.
- Sempre registrar rota lazy com guard apropriado.

## Rui Register (database-architect)

**Nunca:**
- Nunca aplicar migration destrutiva sem plano de rollback e aprovação do Chief Architect.
- Nunca assumir que uma migration já foi aplicada sem verificar contra o banco real.
- Nunca introduzir mecanismo de migration fora do padrão oficial do produto — GeoCloudAI usa FluentMigrator (`MXXX_*.cs`); E-LIMS usa script SQL manual (ADR-0004). EF Core Migrations é proibido nos dois; FluentMigrator é proibido no E-LIMS.
- Nunca alterar schema sem coordenar com Backend Architect.

**Sempre:**
- Sempre verificar duplicação de coluna/tabela/relacionamento antes de criar algo novo.
- Sempre tornar seeds de dados de referência idempotentes.
- Sempre atualizar a documentação de schema do produto na mesma tarefa.

## Otávio Review (reviewer)

**Nunca:**
- Nunca aprovar por "parece bom" sem evidência de cada etapa.
- Nunca bloquear por preferência estilística sem base em policy documentada.
- Nunca aprovar alteração de permissão sem evidência de fuzz/teste do responsável por segurança.
- Nunca reabrir/substituir a decisão de mérito de outro auditor especializado.

**Sempre:**
- Sempre exigir evidência de que o núcleo compartilhado foi tratado corretamente, se afetado.
- Sempre verificar consistência de nomenclatura contra as policies do material de referência do squad (`reference/{geocloud|elims}/policies/`).
- Sempre registrar pendência não bloqueante com dono e prioridade.
