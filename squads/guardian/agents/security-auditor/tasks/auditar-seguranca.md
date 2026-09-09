---
task: "Auditar Segurança"
order: 1
input: |
  - escopo_auditoria: endpoints, permissões e configuração de segurança em escopo definidos no checkpoint "Escopo da Auditoria" (squads/guardian/output/audit-scope.md)
output: |
  - achados_seguranca: lista de achados com endpoint, evidência, risco, severidade e correção esperada (squads/guardian/output/audit-seguranca.md)
---

# Auditar Segurança

Varre endpoints, matriz de permissões e configuração de segurança no escopo definido (`C:\Software\GeoCloud\GeoCloudAI` e/ou `C:\Software\ELIMS\ELIMS`), buscando falhas de autorização, tenant isolation e segredos versionados. Consolida achados por severidade e encaminha — nunca corrige.

> `permission-matrix-auditor` e `endpoint-scanner` = metodologias em `C:\Software\ClaudeCode\squads\guardian\reference\{geocloud|elims}\skills\{nome}\SKILL.md` (caminho absoluto, conforme produto em `audit-scope.md`) — ler e aplicar diretamente, sem depender de `.claude`/`.cursor` do produto.

## Process

1. Rodar `permission-matrix-auditor` sobre cada endpoint do escopo para obter evidência estruturada de cobertura de autorização.
2. Verificar presença e coerência de `[Authorize]`/`[RequiredPermission]` em cada endpoint via `endpoint-scanner`; todo `[AllowAnonymous]` sem justificativa escrita no código é achado crítico, sem exceção silenciosa.
3. Para cada `[RequiredPermission]` encontrado, confirmar que a `functionality.key` referenciada está de fato provisionada no seed correspondente — permissão apontando para key inexistente é achado, não detalhe.
4. Verificar isolamento de tenant em cada endpoint que filtra por dado sensível: o filtro por `accountId`/`entityId` deve vir do token JWT; se vier do corpo ou da query string sem validar propriedade contra o token, é a assinatura exata de BOLA/IDOR.
5. Auditar segredos versionados em texto plano (connection string, SMTP, chave de token) em todo o escopo, sem exceção por ambiente.
6. Auditar a configuração JWT (issuer/audience, HTTPS metadata) fora de ambiente de desenvolvimento.
7. Consolidar todos os achados por severidade (crítico/alto/médio/baixo) e encaminhar ao relatório final — a auditoria não corrige o próprio achado.

## Output Format

```yaml
achados_seguranca:
  - achado_id: "SEC-01"
    endpoint: "POST /Address/add"
    tipo: "BOLA"
    evidencia:
      ferramenta: "endpoint-scanner"
      saida: "[AllowAnonymous] presente, sem justificativa escrita no código nem registro em known-issues"
    risco: "qualquer chamador não autenticado pode criar endereço associado a accountId arbitrário"
    severidade: "critica"
    correcao_esperada: "aplicar [Authorize] + [RequiredPermission(\"address.create\")], confirmar key provisionada no seed"
    produto: "GeoCloudAI"
```

## Output Example

### Achado SEC-01 — Severidade: Crítica (BOLA)
**Endpoint:** `POST /Address/add`
**Evidência:** endpoint-scanner — `[AllowAnonymous]` presente, sem justificativa escrita no código nem registro em known-issues.
**Risco:** qualquer chamador não autenticado pode criar endereço associado a `accountId` arbitrário.
**Correção esperada:** aplicar `[Authorize]` + `[RequiredPermission("address.create")]`, confirmar key provisionada no seed.

### Achado SEC-02 — Severidade: Crítica (IDOR)
**Endpoint:** `PUT /DrillBox/{id}/update`
**Evidência:** revisão de código — `accountId` usado no filtro da query vem do corpo da requisição, não do token JWT.
**Risco:** sequestro cross-tenant — usuário de uma conta pode editar DrillBox de outra conta informando `accountId` diferente.
**Correção esperada:** substituir por `accountId` extraído do middleware de identidade; ignorar valor do body.

## Quality Criteria

- Zero endpoint sem decisão explícita de acesso (autorizado ou AllowAnonymous justificado).
- Toda permission key referenciada existe no seed correspondente.
- Isolamento de tenant validado e citado com arquivo:linha em cada achado.
- Nenhum segredo novo em texto plano versionado.

## Veto Conditions

Reject e refaça se QUALQUER uma for verdadeira:
- Um `[AllowAnonymous]` sem justificativa escrita foi tratado como aceitável em vez de achado crítico.
- Um `accountId`/`entityId` vindo do corpo da requisição foi aceito sem validação contra o token JWT.
- Um segredo em texto plano foi classificado como "aceitável em dev" em vez de achado.
- O relatório inclui uma correção já implementada pela própria auditora, em vez de apenas reportada.
