# Essencis Squads

Squads Opensquad de produção da Essencis Labs.

| Squad | O que faz |
|---|---|
| **[guardian](squads/guardian/)** | Auditoria de dívida técnica, documentação e segurança do GeoCloudAI e do E-LIMS; cria o backlog no board Essencis-Labs e executa correções via PR. Nove personas. |
| **[reporter](squads/reporter/)** | Pesquisa semanal de concorrentes e mercado, e atualização do documento de capacidades de cada produto. |

## Por que este repositório existe, e por que é privado

Até 2026-09-09 os dois squads viviam em `C:\Software\ClaudeCode\squads\`, onde a regra
`squads/*/` do `.gitignore` os deixava **fora de qualquer controle de versão** — sem
branch, sem revisão, sem backup. Perder a máquina era perder os dois squads inteiros.
As `GT-0037` e `GT-0038` registraram o problema três vezes antes de ele ser resolvido.

A primeira tentativa de correção foi abrir exceção no `.gitignore` do próprio
[opensquad](https://github.com/sergio-essencislabs/opensquad). Foi abortada ao
descobrir que **aquele repositório é público**, e o conteúdo dos squads não é:

- achados de segurança abertos do GeoCloudAI (`GT-0028` e o histórico de IDOR
  cross-tenant, `AllowAnonymous` sem justificativa, path traversal);
- 2,9 MB de documentação interna dos dois produtos em `reference/`;
- baselines de verificação com caminhos e estado da máquina de desenvolvimento;
- uma credencial de teste em texto puro, redigida ao criar este repositório.

Daí este repositório, privado. O `opensquad` continua público com o framework; o que é
trabalho de cliente vive aqui.

## Como isto se conecta à máquina

Os caminhos que o Claude Code usa **não mudaram**. Três junções de diretório apontam
para cá, então tudo que referencia `C:\Software\ClaudeCode\squads\...` continua válido:

```powershell
cmd /c mklink /J "C:\Software\ClaudeCode\squads\guardian"  "C:\Software\EssencisSquads\squads\guardian"
cmd /c mklink /J "C:\Software\ClaudeCode\squads\reporter"  "C:\Software\EssencisSquads\squads\reporter"
cmd /c mklink /J "%USERPROFILE%\.claude\skills\guardian"   "C:\Software\EssencisSquads\skills\guardian"
cmd /c mklink /J "%USERPROFILE%\.claude\skills\reporter"   "C:\Software\EssencisSquads\skills\reporter"
```

Junção não precisa de administrador e não vem no clone — é detalhe do sistema de
arquivos local. **Numa máquina nova, rode os quatro comandos uma vez** depois do clone.

Existe **um** arquivo de cada coisa, não duas cópias: editar aqui é editar o squad, e a
edição fica versionada.

## Onde ficam as tasks

Duas, e não são cópia uma da outra:

- **`GT-NNNN`** em `squads/guardian/tasks/` — responde *por que isto entrou na fila*
  (achado, evidência, severidade, run de origem), e vive junto do histórico de auditoria
  que lhe dá sentido. É versionada **aqui**.
- **`TASK-NNN`** em `<repo-de-produto>/.agents/tasks/` — responde *como será feito*, e
  vive ao lado do código, revisada no mesmo PR. É versionada **lá**.

Referência cruzada obrigatória nos dois sentidos. Numerações independentes: `GT-0041` e
`TASK-0041` não são o mesmo documento. Ver `squads/guardian/agents/task-curator/tasks/gerar-tasks.md`,
passo 5, e a `TASK-060` no GeoCloudAI.
