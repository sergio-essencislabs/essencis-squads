---
name: start-guardian
description: Abre as janelas do squad Guardian nesta máquina — as 12 sessões em abas do Windows Terminal, cada uma retomando a própria conversa. Use quando pedirem para iniciar, abrir, subir ou levantar o squad, o Guardian, os agentes ou as janelas dos agentes — inclusive de longe, pelo celular, através do device (Remote Control). Não use para abrir uma janela só, nem para subir o device: o device é mantido pela tarefa agendada "Guardian - garantir device".
---

# Iniciar o squad Guardian

Abre as janelas das personas em abas de uma única janela do Windows Terminal.
Cada aba roda `claude --continue -n <Nome>` no diretório da persona, retomando a
conversa daquele diretório.

O script é `C:\Software\GeoCloud\abrir-squad.ps1`. A fonte versionada dele está
em `squads/guardian/operacao/` no repositório `essencis-squads`.

## Antes de abrir: conferir se já não está aberto

**Isto não é formalidade.** O script aceita `-Sim`, que pula a confirmação — e
de longe não há ninguém para responder a um prompt. Com `-Sim` e as janelas já
abertas, ele **duplica tudo**. Duas janelas na mesma worktree fazem trabalho ser
atribuído a quem não o fez, e isso já aconteceu aqui.

Então, primeiro:

```powershell
claude agents --json
```

Conte as sessões `interactive`. Depois:

```powershell
powershell -ExecutionPolicy Bypass -NoProfile -File C:\Software\GeoCloud\abrir-squad.ps1 -Conferir
```

Isso não abre nada. Ele imprime, para cada janela, **a data da conversa que o
`--continue` vai retomar**, e marca as pastas com mais de uma sessão.

**Se já houver sessões de persona vivas, pare e relate.** Diga quantas e quais,
e pergunte se é para abrir assim mesmo. Não abra por conta própria.

## Abrir

Só quando não houver sessões de persona vivas:

```powershell
powershell -ExecutionPolicy Bypass -NoProfile -File C:\Software\GeoCloud\abrir-squad.ps1 -Sim
```

`-Sim` é necessário de longe: sem ele o script para num `Read-Host` que ninguém
vai responder.

**Não passe `-SemDevice`.** O script checa sozinho se o device está de pé e não
abre uma segunda aba — quem mantém o device é a tarefa agendada.

## Depois: conferir pelo estado, não pelo que o script disse

```powershell
claude agents --json
```

Devem aparecer as 12 sessões `interactive`. **Relate o número.**

- **Contar abas não serve** — aba aberta não é sessão viva.
- **Contar processos `claude.exe` não serve** — o device cria sessões próprias,
  então o total é maior que 12 e isso é normal.

## O que relatar sempre

1. **A lista das datas** que o script imprimiu, inteira. É o que permite ver se
   alguma janela voltou na conversa errada.
2. **Qualquer linha marcada `(de N sessoes)`** — significa que aquela pasta tem
   mais de uma conversa e o `--continue` escolheu **pela data**, não por
   identidade. Se a mais nova não for a certa, a janela volta errada e **nada
   avisa**.
3. **Qualquer linha `SEM SESSAO`** — aquela janela vai começar uma conversa
   nova, não retomar.
4. **A contagem final** do `claude agents --json`.

## Se falhar

- **`Diretorio inexistente`** — uma worktree sumiu. Diga qual; não invente
  caminho nem abra as outras por metade.
- **`Nenhuma janela casa com -Apenas`** — nome errado; os nomes estão no
  `param()` do script.
- **Nada abriu e nenhum erro** — confira `claude agents --json` antes de
  concluir. Silêncio não é sucesso.

## O que este skill não faz

- **Não sobe o device.** Isso é da tarefa `Guardian - garantir device`, que
  checa no logon e a cada 30 minutos. Se o device estiver fora, é essa tarefa
  que falhou, e o log está em `C:\Software\GeoCloud\_device-log\`.
- **Não fecha nada.** Não mata sessões para "limpar" antes de abrir.
- **Não abre uma janela só.** Para isso, `-Apenas <nome>` direto no script.
