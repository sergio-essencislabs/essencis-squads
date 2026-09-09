---
playbook: Integração Externa
gatilho: necessidade de integrar com serviço externo (e-mail, IA, futuro MCP, API de terceiro)
---

# Playbook — Integração Externa

1. **Integration Architect** verifica se já existe cliente para o mesmo tipo de integração no produto ou no produto irmão (ex.: cliente SMTP já existe — reaproveitar, não recriar).
2. Definir contrato do cliente de integração (interface, timeout, retry, comportamento em falha).
3. **Security Architect** define onde a credencial será armazenada (nunca texto plano versionado).
4. Implementar com tratamento de falha explícito — nunca "best effort" silencioso quando a falha afeta o usuário (ex.: convite não enviado deve ser comunicado, não apenas logado).
5. **QA Architect** — teste com a integração mockada (não testar contra o serviço externo real em CI/local).
6. **Documentation Architect** — documentar propósito, configuração necessária e comportamento em falha em `docs/system/`.
7. Se a integração for cross-projeto (ex.: mesmo provedor de e-mail para os dois produtos), avaliar se o cliente deveria ser compartilhado — escalar ao Chief Architect.

## Não fazer

- Integrar sem tratamento de falha (o caso já identificado de `UserInviteService` logando link no console em vez de enviar e-mail é um gap a resolver, não um padrão a repetir).
- Colocar credencial de API/SMTP/IA em `appsettings.json` versionado.
