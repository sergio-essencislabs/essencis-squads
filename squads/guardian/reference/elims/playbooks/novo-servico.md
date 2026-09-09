---
playbook: Novo Serviço (Application)
gatilho: nova regra de negócio que não se encaixa em um service existente
---

# Playbook — Novo Serviço

1. **Duplicate Detector** — verificar se a regra de negócio já pertence (ou deveria pertencer) a um service existente antes de criar um novo.
2. **Backend Architect** — definir a interface (`I{Nome}Service`) antes da implementação; injetar repositórios via interface, nunca instanciar diretamente.
3. Se o serviço envolve transição de estado (status), seguir o padrão de matriz válido/inválido/idempotente (`StatusTransitionServiceTests`).
4. **Architecture Validator** (skill) — confirmar que o service não acessa SQL/MySqlConnector diretamente (deve passar por Repository).
5. **QA Architect** — teste unitário isolado (sem banco) para a regra de negócio pura.
6. **Documentation Architect** — documentar a regra de negócio em `business-requirements.md`.

## Não fazer

- Criar um service "utilitário" genérico (`Helper`, `Utils`) sem responsabilidade única clara.
- Duplicar lógica já existente em outro service em vez de extrair/reutilizar.
