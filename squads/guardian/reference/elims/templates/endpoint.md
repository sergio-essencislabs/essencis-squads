---
tipo: Documentação de Endpoint
produto: ELIMS | ELIMS
---

# `<MÉTODO> /<rota>`

**Controller/Action:** `<Nome>Controller.<Método>`
**Permission key:** `<recurso.acao>` (ou `AllowAnonymous` + justificativa)
**Isolamento de tenant:** <como accountId/entityId são aplicados>

## Request

```json
{}
```

## Response

```json
{}
```

## Erros possíveis

| Status | Motivo |
|---|---|
| 401 | Token ausente/inválido |
| 403 | Permission key ausente |
| ... | |
