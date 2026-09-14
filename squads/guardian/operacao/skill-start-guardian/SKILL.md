---
name: start-guardian
description: Garante que as 11 sessões do squad Guardian estejam de pé nesta máquina — em Remote Control, visíveis no celular, sem janela no notebook — e, se pedirem para ver, reabre as mesmas sessões em abas do Windows Terminal. Use quando pedirem para iniciar, subir, levantar ou abrir o squad, o Guardian, os agentes ou as janelas dos agentes, inclusive de longe pelo celular. Não use para subir o device: o device é mantido pela tarefa agendada.
---

# Subir o squad Guardian

Desde **14/09/2026** as dez rodam em **Remote Control**, em processo oculto:

```
claude --remote-control <Nome> --resume <sessionId>
```

É esse comando que cria a conversa do lado do servidor — e é por isso que **as
onze aparecem na lista de sessões do celular**. Mesma sessão, mesmo id, mesma
história. A Vision é a única exceção de forma: ela é de fundo e já nasceu no
app, então já tinha ponte.

Dois scripts, e a diferença importa:

| | |
|---|---|
| `C:\Software\GeoCloud\subir-squad.ps1` | **sobe** as sessões ocultas. É o padrão |
| `C:\Software\GeoCloud\abrir-squad.ps1` | **abre abas** reerguendo as mesmas sessões. Só quando pedirem para *ver* |

## O padrão: subir oculto

```powershell
powershell -ExecutionPolicy Bypass -NoProfile -File C:\Software\GeoCloud\subir-squad.ps1 -Conferir
```

Isso não sobe nada. Ele lista cada persona com o `sessionId` e diz
`ja de pe` ou `SUBIR`. **Leia e relate essa lista.**

Depois, se houver alguma a subir:

```powershell
powershell -ExecutionPolicy Bypass -NoProfile -File C:\Software\GeoCloud\subir-squad.ps1
```

Ele **confere sozinho no fim** e diz `conferido: as 11 estao de pe` ou
`NAO subiram: <nomes>`. Relate o que ele disser, literalmente.

**Não precisa de guarda contra duplicata**: antes de subir, o script checa cada
persona pelas linhas de comando dos processos vivos — tanto `-n <Nome>` (fundo)
quanto `--remote-control <Nome>` (celular) — e pula as que já estão de pé.

## A regra que não se quebra: nada de redirecionar a saída

`--remote-control ... --resume <id>` **só funciona se o processo nascer com
terminal**. Redirecionar stdout ou stderr tira o terminal, e o claude cai no
caminho headless (`--print`), que exige prompt. O sintoma é esta mensagem:

```
Error: No deferred tool marker found in the resumed session. Either the session
was not deferred, the marker is stale (tool already ran), or it exceeds the
tail-scan window. Provide a prompt to continue the conversation.
```

**A mensagem engana.** Ela fala de marcador e de janela de varredura, e faz
perder horas conferindo transcript. A causa não está no arquivo — está em como
o processo nasceu. No binário ela vive entre as mensagens de `--print` sobre
stdin e prompt; foi assim que o diagnóstico fechou, em 14/09.

Duas consequências práticas:

- `Start-Process ... -RedirectStandardError <arquivo>` **quebra** a subida.
  Confira o desfecho pelo processo (`$proc.HasExited`) e pela conferência final,
  que lê as linhas de comando.
- Dar prompt posicional **não resolve**: o claude roda uma volta só, imprime a
  resposta e sai. A conversa chega a aparecer no celular e morre em seguida.

## A outra regra: `--resume` sem flag no fundo

Sessão de fundo guarda as **próprias** opções (`-n`, `--add-dir`, `--model`).
Passar qualquer flag no resume não as sobrescreve — **forka uma cópia** com id
novo. A saída certa é `woke session <id> with its saved options`. Se aparecer
`started a copy as <novo>`, o id do mapa está errado — **relate, não adote a
cópia**.

## Se pedirem para ver as janelas

```powershell
powershell -ExecutionPolicy Bypass -NoProfile -File C:\Software\GeoCloud\abrir-squad.ps1 -Sim
```

Para cada persona que está em Remote Control, ele **derruba o processo oculto e
reabre o MESMO comando numa aba visível**. A sessão é a mesma, o id é o mesmo, a
conversa continua no celular — e agora tem janela.

**Nunca use `claude attach` numa persona de Remote Control.** Medido no Dante em
14/09: o attach responde `Waking session ...` e sobe uma **segunda sessão viva
sobre a mesma conversa** — ficaram três processos no mesmo id (o de remote
control, um pty-host e um `--resume`). O `attach` continua correto para sessão
de fundo; hoje só a Vision é de fundo.

## Como conferir, e com qual instrumento

**Sessão em Remote Control NÃO aparece no `claude agents --json`** — ela se
registra do lado do servidor. Com o desenho atual, esse comando devolve **1**
(a Vision) e isso é o certo, não defeito. Confira pelos dois:

1. **`/agents`** — a lista de pares, onde as dez aparecem como `Remote Control`.
2. **A linha de comando dos processos**, que é o que o próprio script usa:

```powershell
Get-CimInstance Win32_Process -Filter "Name='claude.exe'" |
  ForEach-Object { if ($_.CommandLine -match '--remote-control[= ](\S+)') { $matches[1] } } |
  Sort-Object -Unique
```

Para as de fundo o padrão é `-n\s+(\S+)`, e aí o `-Unique` **não é enfeite**:
cada uma aparece em duas linhas (a sessão e o pty-host que o daemon põe na
frente).

**Nunca conte processos `claude.exe`** para concluir: o device tem processo
próprio e o pty-host dobra as de fundo. Total maior que 11 é normal.

## O que relatar sempre

1. A lista do `-Conferir`, inteira, com quem estava `ja de pe` e quem foi subir.
2. A conferência final do script, literal.
3. **Qualquer persona que não subiu**, nomeada. Não diga "quase todas".

## O `sessoes.json` precisa estar certo

É o mapa persona → `sessionId`. Se ele sumir, o `abrir-squad` cai para
`--continue`, que escolhe **pela data** — e aí uma janela pode voltar na conversa
errada sem avisar. O script avisa; **não ignore esse aviso**.

**Não regenere o `sessoes.json` por conta própria. Se estiver errado, relate.**

Duas armadilhas medidas em 14/09:

- **O mapa tinha uma persona que não existe.** A entrada `GeoCloudAI` não era
  persona nenhuma: **`GeoCloudAI` é o nome do DEVICE** — é o que aparece em
  `·✔︎· Ready · GeoCloudAI` no log do device e no app. A conversa por trás
  daquele slot era uma janela antiga do Jarvis, que se apresentava como
  *"Jarvis, janela 2"*. Entrada removida. O squad são **11**: Vision, Jarvis,
  Breno, Otavio, Tomas, Rui, Dante, Selma, Livia, Flavia, Marta.
- **Uma persona pode ter mais de uma conversa, e só uma tem a ponte.** Resumir a
  errada põe a persona de pé numa conversa NOVA e vazia, e a que o usuário vê no
  celular fica **desconectada**. Foi o que aconteceu com o Dante: subi um fork
  (`caf11f81`, ponte com `lastSequenceNum: 0`) em vez da conversa real
  (`90977cbb`, 2143 sequências). No celular ele apareceu desconectado.

  **Como escolher**: a conversa certa é a que tem linha `"type":"bridge-session"`
  com `lastSequenceNum` alto no `.jsonl`. Fork recém-criado tem 0.

## Uma coisa que este desenho não resolve

**Sessão oculta não tem quem responda a pedido de permissão** na máquina. Ela
fica parada em silêncio até alguém atender — do celular, ou abrindo a janela
pelo `abrir-squad`. Se uma persona parecer travada, é a primeira hipótese.

## O que este skill não faz

- **Não sobe o device.** Isso é da tarefa agendada `Guardian - manter de pe`.
  Se o device estiver fora, é essa tarefa que falhou, e o log está em
  `C:\Software\GeoCloud\_device-log\`.
- **Não fecha nem mata nada** para "limpar" antes de subir.
- **Não regenera o `sessoes.json`.**
