---
description: Princípios de qualidade de código (SOLID, DRY, KISS, YAGNI) aplicados a ELIMS
globs:
alwaysApply: false
---

# Qualidade

- **DRY**: antes de criar qualquer classe/componente/endpoint, procure equivalente (`duplicate-detector`). O núcleo de Conta/Identidade já existe nos dois produtos — nunca recrie.
- **KISS/YAGNI**: não generalize antecipadamente. Otimização/abstração sem evidência concreta de necessidade é rejeitada (ver Performance Architect — só atua com evidência).
- **SOLID**: um service por responsabilidade; injeção de dependência via interface (`I{Nome}Service`/`I{Nome}Repository`), nunca instanciação direta dentro de outro service.
- **Separation of Concerns**: controller não tem lógica de negócio; service não tem SQL; repository não tem regra de negócio.
- Toda regra de negócio nova (especialmente transição de status) precisa de teste cobrindo caso válido, inválido e idempotente — ver o padrão já estabelecido em `StatusTransitionServiceTests`.

Refatoração e feature nunca acontecem na mesma tarefa (ver `playbooks/refatoracao.md`).
