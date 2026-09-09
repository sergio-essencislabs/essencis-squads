---
playbook: Nova Tela (Frontend)
gatilho: necessidade de uma tela/fluxo novo no Angular
---

# Playbook — Nova Tela

1. **Duplicate Detector** — verificar componentes `shared`/`shared-modules`/`ui` reaproveitáveis antes de criar novo.
2. **Frontend Architect** — confirmar o contrato de API com o Backend Architect (não assumir formato de DTO).
3. Implementar componente standalone + rota lazy (`loadComponent`) + guard apropriado (`AuthGuard`/`AdminGuard`).
4. Service de API dedicado (`*.service.ts`) — nunca HTTP direto no componente.
5. Se houver getter de template com fetch, aplicar cache + guarda de in-flight (`policies/boas-praticas-frontend.md`).
6. **QA Architect** — spec de teste se a lógica do componente não for trivial.
7. **Documentation Architect** — atualizar documentação de fluxo/tela do produto (ex.: `manual-fluxo-e-lims.md`).

## Não fazer

- Criar uma variação de componente `shared` para uma diferença pequena — parametrizar o existente.
- Assumir o contrato de API sem confirmar com o Backend Architect.

---

## Consumir endpoint protegido (absorvido da SOP `consume-protected-endpoint`)

O fluxo de autenticação já está montado; a tela nova não deve reinventá-lo.

- **Não anexe token à mão.** `JwtInterceptor` injeta o `Authorization` em toda saída e
  `ErrorInterceptor` trata 401/403 centralmente. Serviço que monta header próprio
  duplica responsabilidade e escapa do tratamento de erro.
- **Base da URL sempre por `GlobalComponent.baseUrl`** — nunca string literal.
- **Listagem lê o header `Pagination`**, não um envelope no corpo: o backend devolve o
  array puro e a paginação vai no header, montada por `Response.AddPagination(...)`.
  No cliente use `{ observe: 'response' }` e leia `response.headers.get('Pagination')`.
- **Estado de sessão vive em `sessionStorage`** (`token`, `user`, `accountId`, `userId`,
  `entityId`), escrito por `currentUser.service.ts`. Leia de lá, não duplique.
- `.pipe(take(1))` nas chamadas pontuais, para não deixar subscription pendurada.
- Item novo no menu lateral entra em `makeMenu()` do `currentUser.service.ts` — a rota
  sozinha não faz a tela aparecer na navegação.
