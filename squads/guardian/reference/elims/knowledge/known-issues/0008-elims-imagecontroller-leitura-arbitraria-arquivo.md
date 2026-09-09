---
id: KI-0008
title: "ELIMS: `ImageController.get` permite leitura arbitrária de arquivo local sem autenticação, vazando `appsettings.Development.json` (TokenKey JWT + DB + SMTP)"
severidade: crítica
status: aberta
produto: ELIMS
---

## Descrição

`Back.API/Controllers/ImageController.cs` não herda `ControllerBaseMiddleware`, não tem `[Authorize]` nem `[RequiredPermission]` na classe, e o método `GetImage(string pathName)` monta o caminho do arquivo lido do disco direto de `Path.Combine(_hostEnvironment.ContentRootPath, pathName)`, sem qualquer sanitização de `pathName` nem checagem de identidade. Confirmado por execução HTTP real (não só leitura de código): uma chamada `GET api/Image/get?pathName=appsettings.Development.json`, **sem nenhum header `Authorization`**, devolve o conteúdo completo do arquivo de configuração da própria API, incluindo:

- `TokenKey` — segredo de assinatura JWT. Com esse valor, qualquer atacante forja um token válido para QUALQUER `userId`/`accountId`/`entityId`, inclusive `ownerAccount=true`/`entityId=1` (dono do sistema) — compromete a autenticação de TODO o sistema, não só o `ImageController`.
- `ConnectionStrings:DefaultConnection` — usuário/senha do Postgres.
- `EmailSettings` — credenciais SMTP em texto claro.

Este controller **escapou da varredura estática** feita por `TestCenter/_ferramentas/scripts/endpoint_scanner.py` porque o método usa a assinatura síncrona `IActionResult` (o scanner só reconhece `Task<IActionResult>`) — foi encontrado por revisão manual do código-fonte durante a curadoria da campanha V7 do ELIMS.

Este achado é uma exploração CONCRETA e mais grave do risco já registrado em [KI-0004](0004-segredos-em-texto-plano.md) (segredos versionados em texto plano) — aqui não é preciso acesso ao repositório/servidor para ler o segredo, um chamador HTTP anônimo qualquer já consegue.

## Evidência

- `ELIMS/ELIMS/backend/src/Back.API/Controllers/ImageController.cs` (classe sem `[Authorize]`, sem herdar `ControllerBaseMiddleware`; `GetImage` usa `Path.Combine(ContentRootPath, pathName)` sem validação).
- Teste dinâmico real: `ELIMS/ELIMS/backend/src/Back.ApiTests/Endpoints/ImageArbitraryFileReadRunner.cs` (`AnonymousCanReadAppsettingsWithSecrets`), resultado gravado em `ELIMS/ELIMS/backend/src/Back.ApiTests/v7-results/elims-image-arbitrary-file-read-fuzz.json` — HTTP 200, corpo com `TokenKey`/`ConnectionStrings`/`EmailSettings` completos, sem nenhum header `Authorization`.
- Curadoria: `TestCenter/Elims/RELATORIO_BUGS_CURADO_FINAL_V7.xlsx`, aba "Padrões Sistêmicos", linha 1.

## Ação recomendada

1. **Correção imediata (mecânica):** adicionar `[Authorize]` + `[RequiredPermission]` adequados ao `ImageController`; validar que o caminho final resolvido (`Path.GetFullPath`) permanece dentro de um diretório de imagens permitido (allowlist) antes de ler o arquivo — nunca aceitar caminho de arquivo arbitrário vindo do cliente.
2. **Rotação de segredos (urgente, coordenar com Security Architect):** como o `TokenKey` atual pode já ter sido exposto por este vetor em qualquer ambiente onde o endpoint esteja acessível, tratar como comprometido — rotacionar `TokenKey` (invalida sessões ativas) e a senha do Postgres/SMTP, junto com a resolução de KI-0004 (mover segredos para variável de ambiente/secret manager).
3. Repetir a mesma checagem (assinatura `IActionResult` síncrona escapando do scanner) no ELIMS, caso exista controller equivalente lá.

## Dono

Security Architect (correção + rotação de segredos) + QA Architect (ampliar `endpoint_scanner.py` para cobrir assinaturas síncronas).
