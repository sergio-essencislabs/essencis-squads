---
name: start-guardian
description: Garante que as 12 sessões do squad Guardian estejam de pé nesta máquina — em segundo plano, sem janela — e, se pedirem para ver, abre abas do Windows Terminal anexando às sessões que já rodam. Use quando pedirem para iniciar, subir, levantar ou abrir o squad, o Guardian, os agentes ou as janelas dos agentes, inclusive de longe pelo celular. Não use para subir o device: o device é mantido pela tarefa agendada.
---

# Subir o squad Guardian

O squad roda em **sessões de fundo** — sem janela. Cada persona volta pelo
`claude --bg --resume <sessionId>`, **sem mais nada**, retomando **por
identidade** e não por data. O nome, o `--add-dir` e o modelo voltam sozinhos,
das opções salvas da própria sessão — ver *"A regra que não se quebra"* abaixo,
que é a instrução mais importante deste arquivo.

Dois scripts, e a diferença importa:

| | |
|---|---|
| `C:\Software\GeoCloud\subir-squad.ps1` | **sobe** as sessões em fundo. É o padrão |
| `C:\Software\GeoCloud\abrir-squad.ps1` | **abre abas** anexando às que já rodam. Só quando pedirem para *ver* |

## O padrão: subir em fundo

```powershell
powershell -ExecutionPolicy Bypass -NoProfile -File C:\Software\GeoCloud\subir-squad.ps1 -Conferir
```

Isso não sobe nada. Ele lista cada persona com o `sessionId` e diz
`ja de pe` ou `SUBIR`. **Leia e relate essa lista.**

Depois, se houver alguma a subir:

```powershell
powershell -ExecutionPolicy Bypass -NoProfile -File C:\Software\GeoCloud\subir-squad.ps1
```

Ele **confere sozinho no fim** e diz `conferido: as 12 estao de pe` ou
`NAO subiram: <nomes>`. Relate o que ele disser, literalmente.

**Não precisa de guarda contra duplicata**: o script checa cada persona pela
linha de comando (`-n <Nome>`) antes de subir, e pula as que já estão de pé.

## Se pedirem para ver as janelas

```powershell
powershell -ExecutionPolicy Bypass -NoProfile -File C:\Software\GeoCloud\abrir-squad.ps1 -Sim
```

Ele abre abas com `claude attach <id>` — **anexa às sessões que já rodam, não
cria novas**. Por isso `-Sim` aqui é seguro.

## Como conferir, e com qual instrumento

**`claude agents --json` lista só as sessões locais de fundo.** No desenho atual
as doze são de fundo, então ele devolve as doze e é um instrumento honesto.

A ressalva é para quem estiver em **Remote Control**: essa sessão sai da lista.
Medido em 13/09 — a Selma em Remote Control sumiu do `agents --json` e o total
caiu para 11, continuando viva e alcançável por nome no `/agents`.

> Correção de um diagnóstico antigo deste arquivo: ele dizia que
> *"já aconteceu de devolver `1` com 11 de pé"* por causa do Remote Control.
> **Não era isso.** Naquele episódio as onze estavam de fato mortas — eram
> cópias que o daemon matou por não achar a sessão de origem. O `agents --json`
> estava certo; a leitura é que estava errada.

Confira pelos dois:

1. **`/agents`** — a lista de pares, que mostra as `Remote Control`.
2. **A linha de comando dos processos**, que é o que o próprio script usa:

```powershell
Get-CimInstance Win32_Process -Filter "Name='claude.exe'" |
  ForEach-Object { if ($_.CommandLine -match '-n\s+(\S+)') { $matches[1] } } |
  Sort-Object -Unique
```

O `-Unique` **não é enfeite**. Cada persona aparece em *duas* linhas de comando:
o processo da sessão e o anfitrião de pty que o daemon põe na frente
(`--bg-pty-host ... -- claude --session-id ...`), que carrega a linha interna
inteira. Sem `-Unique` a lista vem com 24 entradas para 12 personas — e a versão
anterior deste trecho tinha exatamente esse defeito.

**Nunca conte processos `claude.exe`** para concluir: além do pty-host dobrando
cada uma, o device tem processo próprio. O total ser maior que 12 é normal.

## O que relatar sempre

1. A lista do `-Conferir`, inteira, com quem estava `ja de pe` e quem foi subir.
2. A conferência final do script, literal.
3. A contagem pelo `/agents`.
4. **Qualquer persona que não subiu**, nomeada. Não diga "quase todas".

## A regra que não se quebra: `--resume` sem flag

Uma sessão de fundo guarda as **próprias** opções (`-n`, `--add-dir`,
`--model`). Passar qualquer flag no resume não as sobrescreve — **forka uma
cópia** com id novo, e cópia de sessão que não é achada morre em ~10s.

Nunca acrescente flags ao comando do script. A saída certa é
`woke session <id> with its saved options`. Se aparecer
`started a copy as <novo>`, o id do mapa está errado — **relate, não adote a
cópia**.

Quando uma não sobe, o motivo está escrito em `~/.claude/daemon.log`:

```
bg settled <id> (crashed): source session <origem> not found
```

Isso significa que o `--resume` foi chamado de um diretório cuja pasta
`~/.claude/projects/<dir-codificado>/` não contém `<origem>.jsonl`.

## Duas coisas que este desenho não resolve

**Sessão de fundo não tem quem responda a pedido de permissão.** Ela fica parada
em silêncio até alguém atender — do celular, ou dando `claude attach`. Se uma
persona parecer travada, é a primeira hipótese.

**O `sessoes.json` precisa estar atualizado.** É o mapa persona → `sessionId`.
Se ele sumir, o `abrir-squad` cai para `--continue`, que escolhe **pela data** —
e aí uma janela pode voltar na conversa errada sem avisar. O script avisa quando
isso acontece; **não ignore esse aviso**.

## Decidido: as personas não aparecem no celular, e está certo assim

Só a **Vision** tem ponte com o app. As outras onze rodam em segundo plano e
**não** aparecem na lista de sessões do celular. Isso é decisão de 13/09/2026,
não defeito: as aprovações estão centralizadas na Vision, e o usuário recusou
a alternativa por causa da poluição na lista.

**Não troque o `claude attach <id>` do `abrir-squad.ps1`.** Já foi proposto e
recusado. Para o registro, com o que foi medido:

- `attach` é local — **não** cria ponte.
- `claude remote-control --session-id <id-de-fundo>` não serve: aquele id é de
  sessão de Remote Control.
- O que funcionaria: `claude --remote-control <Nome> --resume <id>`. Testado na
  Selma, ida e volta completa, id preservado, sem device extra. O custo é que
  a sessão passa a viver presa ao terminal — fechar a janela encerra — e sai do
  `claude agents --json` (mas segue alcançável por nome, como `Remote Control`).

## O que este skill não faz

- **Não sobe o device.** Isso é da tarefa agendada `Guardian - manter de pe`.
  Se o device estiver fora, é essa tarefa que falhou, e o log está em
  `C:\Software\GeoCloud\_device-log\`.
- **Não fecha nem mata nada** para "limpar" antes de subir.
- **Não regenera o `sessoes.json`.** Se ele estiver errado, relate — não
  reescreva por conta própria: um id errado faz a persona voltar noutra conversa.
