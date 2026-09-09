---
execution: subagent
agent: security-auditor
inputFile: squads/guardian/output/audit-scope.md
outputFile: squads/guardian/output/audit-seguranca.md
model_tier: powerful
---

# Step 04: Auditoria de Segurança

## Context Loading

Load these files before executing:
- `squads/guardian/output/audit-scope.md` — modo desta execução, produto(s),
  frentes priorizadas e profundidade decididos pelo usuário no Step 01;
  determina se este step deve rodar de fato (modo auditoria-nova, com
  "Segurança" priorizada) ou virar stub.
- `squads/guardian/agents/security-auditor.agent.md` — persona de
  Selma Security: audita tenant isolation, BOLA/IDOR, matriz de permissões e
  segredos versionados; sem eufemismo em achado crítico, nunca implementa a
  correção.
- `squads/guardian/agents/security-auditor/tasks/auditar-seguranca.md`
  — processo operacional a seguir: quais verificações rodar em qual ordem
  sobre endpoints, permissões e configuração.
- `C:\Software\GeoCloud\GeoCloudAI` (GeoCloudAI — backend em `api/src/Back.*`, frontend em `web/`) e
  `C:\Software\ELIMS\ELIMS` (E-LIMS — backend em `backend/src/Back.*`, frontend em
  `frontend/`) — os codebases de produto reais sob auditoria. Mesma stack
  (.NET 9 + Dapper, Angular 19), layout de pastas diferente: nunca assumir o
  layout de um produto ao varrer o outro. Inclui o seed de
  permissões (`functionality.key`) e a configuração JWT de cada produto.
- `C:/Software/ClaudeCode/squads/guardian/reference/geocloud` e `C:/Software/ClaudeCode/squads/guardian/reference/elims` — o
  material de referência interno do squad, por produto; contém as
  policies/playbooks de qualidade e a knowledge base de known-issues já
  registrados. Não é o codebase auditado.

## Instructions

> **Independência de `.claude`/`.cursor`:** `permission-matrix-auditor` e `endpoint-scanner` não são skills nativas deste squad — são as metodologias em `C:/Software/ClaudeCode/squads/guardian/reference/{geocloud|elims}/skills/{nome}/SKILL.md` (caminho absoluto, conforme codebase em escopo). Ler o `SKILL.md` correspondente e aplicar o método diretamente via Grep/Glob/Bash/Read, sem depender do Skill tool nem de `.claude/`/`.cursor/` do repositório de produto.

### Process

1. Ler `audit-scope.md`. Se o **modo** não for "auditoria-nova" (ou seja, for
   "retomar-promocao" ou "implementacao-direta"), gravar o output só com a
   nota "N/A — modo {modo}, ver audit-scope.md" e encerrar imediatamente, sem
   nenhuma varredura. Se o modo for "auditoria-nova" mas "Segurança" não
   estiver entre as frentes priorizadas, registrar o output apenas com a nota
   "Fora do escopo definido no checkpoint" e encerrar — não auditar mesmo
   assim. Se a seção "Conhecimento Prévio (VaultS)" citar achados relevantes a
   esta frente, tratá-los como ponto de partida já verificado: focar a
   varredura em confirmar se ainda são verdade e em cobrir o que essa seção
   não cobre, em vez de rederivar do zero o que ela já documenta — nunca
   aceitar sem checagem quando o achado do VaultS parecer desatualizado
   frente ao código atual.
2. Rodar `permission-matrix-auditor` (`endpoint-scanner`) sobre cada endpoint
   do(s) codebase(s) no escopo, verificando presença/coerência de
   `[Authorize]`/`[RequiredPermission]`. Todo `[AllowAnonymous]` sem
   justificativa escrita no código é achado crítico, sem exceção silenciosa.
3. Para cada `[RequiredPermission]` encontrado, confirmar que a
   `functionality.key` referenciada existe de fato no seed provisionado do
   produto correspondente.
4. Verificar isolamento de tenant em cada endpoint que filtra por
   `accountId`/`entityId`: o valor deve vir do token JWT via middleware de
   identidade, nunca do corpo/query string sem validar propriedade contra o
   token — essa é a assinatura exata de BOLA/IDOR a procurar.
5. Auditar segredos versionados em texto plano (connection string, SMTP,
   chave de token) e a configuração JWT (issuer/audience, HTTPS metadata fora
   de ambiente de dev) nos arquivos de configuração do(s) codebase(s).
6. Consolidar achados por severidade (Crítica/Alta/Média/Baixa), citando
   sempre arquivo:linha, e salvar em `audit-seguranca.md` — sem propor ou
   aplicar a correção, apenas encaminhar.

## Output Format

```markdown
# Auditoria de Segurança — Selma Security

**Data:** YYYY-MM-DD
**Escopo auditado:** [produto(s) e codebase(s) conforme audit-scope.md]

### Achado SEC-NN — Severidade: [Crítica/Alta/Média/Baixa] ([BOLA/IDOR/Segredo/JWT/outro])
**Endpoint ou componente:** `arquivo:linha`
**Evidência:** [ferramenta ou revisão de código] — [o que foi encontrado]
**Risco:** [impacto concreto se explorado]
**Correção esperada:** [o que a camada responsável deve implementar, sem implementar aqui]

[repetir por achado]

## Resumo
- Total de achados: N
- Por severidade: Crítica N / Alta N / Média N / Baixa N
```

## Output Example

```markdown
# Auditoria de Segurança — Selma Security

**Data:** 2026-08-21
**Escopo auditado:** GeoCloudAI (C:\Software\GeoCloud\GeoCloudAI)

### Achado SEC-01 — Severidade: Crítica (BOLA)
**Endpoint ou componente:** `Controllers/AddressController.cs:47`
**Evidência:** endpoint-scanner — `[AllowAnonymous]` presente, sem
justificativa escrita no código nem registro em known-issues.
**Risco:** qualquer chamador não autenticado pode criar endereço associado a
`accountId` arbitrário.
**Correção esperada:** aplicar `[Authorize]` + `[RequiredPermission("address.create")]`,
confirmar key provisionada no seed.

### Achado SEC-02 — Severidade: Crítica (IDOR)
**Endpoint ou componente:** `Controllers/DrillBoxController.cs:88`
**Evidência:** revisão de código — `accountId` usado no filtro da query vem
do corpo da requisição (`PUT /DrillBox/{id}/update`), não do token JWT.
**Risco:** sequestro cross-tenant — usuário de uma conta pode editar DrillBox
de outra conta informando `accountId` diferente no body.
**Correção esperada:** substituir por `accountId` extraído do middleware de
identidade; ignorar valor do body.

## Resumo
- Total de achados: 2
- Por severidade: Crítica 2 / Alta 0 / Média 0 / Baixa 0
```

## Veto Conditions

Reject and redo if ANY of these are true:
- Algum `[AllowAnonymous]` sem justificativa escrita foi tratado como
  aceitável em vez de achado crítico.
- Algum achado de tenant isolation não cita arquivo:linha como evidência.
- Alguma `permission key` referenciada não foi verificada contra o seed real
  do produto antes de considerar o endpoint seguro.
- Algum segredo em texto plano foi classificado como "aceitável em dev".
- O relatório contém proposta de implementação da correção em vez de apenas
  a correção esperada e a camada responsável.

## Quality Criteria

- [ ] Zero endpoint sem decisão explícita de acesso registrada (autorizado
      ou `AllowAnonymous` justificado).
- [ ] Toda `permission key` referenciada existe no seed correspondente.
- [ ] Isolamento de tenant validado e citado com arquivo:linha em cada
      achado relacionado.
- [ ] Nenhum segredo novo em texto plano versionado passou sem achado.
- [ ] Achados respeitam o escopo (produto/frentes/profundidade) definido no
      checkpoint anterior.
