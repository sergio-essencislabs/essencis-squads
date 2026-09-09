---
description: Boas práticas Angular 19 / Velzon para GeoCloud
globs: **/*.ts
alwaysApply: false
---

# Boas Práticas Frontend

- Componentes **standalone**, rotas com `loadComponent` (lazy). Não reintroduzir NgModules para features novas.
- State management: respeitar a escolha já feita por produto — GeoCloud usa `@ngrx/signals` (SignalStore). Trocar exige ADR do Chief Architect.
- Nunca chamar HTTP direto de um componente — sempre via `*.service.ts` dedicado.
- Getter de template que busca dados do backend precisa de cache por chave + guarda de requisição em andamento (`_inflight`), senão gera storm de change detection (lição já catalogada).
- Tratamento de erro HTTP cobre tanto JSON estruturado quanto `BadRequest(string)` como texto plano (`err.error.text`) antes de usar um fallback genérico.
- Campo que referencia outra entidade (método, equipamento, usuário) é `<select>` de dados reais — nunca texto livre.
- Modal customizado não usa a classe `.modal` pura do Bootstrap (colisão com `display:none` do Bootstrap) — usar classe própria com display definido no SCSS escopado.

```ts
// ❌ EVITAR — getter dispara fetch sem guarda
get statusLabel() { return this.api.getStatus(this.id); }

// ✅ BOM — cache + guarda de in-flight
get statusLabel() {
  if (this.cache.has(this.id)) return this.cache.get(this.id);
  if (!this.inflight.has(this.id)) { this.inflight.add(this.id); this.api.getStatus(this.id).subscribe(...); }
  return this.loadingLabel;
}
```
