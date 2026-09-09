# Ao portar código de referência, verificar o registro real de DI — não copiar o tipo injetado

**Data:** 2026-08-31
**Origem:** implementação de `UserPasswordReset` no GeoCloudAI.

## Lição

O arquivo de referência (padrão do D'Amore) injetava a classe concreta
`EmailService` no construtor do service. O port copiou isso literalmente.
Compilou sem erro — mas quebraria em runtime na primeira requisição: o
container de DI do GeoCloudAI só registra esse serviço pela interface
(`services.AddHttpClient<IEmailService, EmailService>()`, em `Startup.cs`),
nunca pela classe concreta. Pedir `EmailService` diretamente no construtor
teria estourado `InvalidOperationException: Unable to resolve service for
type 'EmailService'` só quando o endpoint fosse chamado de verdade — nenhum
teste de compilação pega isso.

O erro só foi encontrado porque, antes do merge, a suíte de testes unitários
nova para o service (`UserPasswordResetServiceTests.cs`) tentou usar
`NSubstitute` para mockar a dependência — e `EmailService` é `sealed`, então
nem dava para mockar a classe concreta. Isso forçou a correção para
`IEmailService`, que é também o tipo certo pelo registro real de DI.

## Como aplicar

- Ao portar um arquivo de referência (de qualquer origem — outro produto,
  outro sistema, código do D'Amore), **nunca copiar o tipo de uma
  dependência injetada sem confirmar como ela está registrada no
  `Startup.cs`/`Program.cs` real do projeto de destino** — `grep` rápido
  (`services.Add.*NomeDaClasse`) resolve isso em segundos.
- Escrever pelo menos um teste unitário do service novo, mesmo que simples,
  antes de considerar a task fechada — mockar as dependências via
  `NSubstitute`/interface é o jeito mais barato de descobrir esse tipo de
  divergência antes do runtime, porque uma classe concreta `sealed` recusa
  ser mockada e força a pergunta certa.
- Vale tanto para GeoCloudAI quanto para E-LIMS (mesmo padrão de DI via
  `AddScoped`/`AddHttpClient` com interface, nunca a classe concreta
  diretamente).
