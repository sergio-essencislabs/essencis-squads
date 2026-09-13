---
name: start-guardian
description: Garante que as 12 sessões do squad Guardian estejam de pé nesta máquina — em segundo plano, sem janela — e, se pedirem para ver, abre abas do Windows Terminal anexando às sessões que já rodam. Use quando pedirem para iniciar, subir, levantar ou abrir o squad, o Guardian, os agentes ou as janelas dos agentes, inclusive de longe pelo celular. Não use para subir o device: o device é mantido pela tarefa agendada.
---

# Subir o squad Guardian

O squad roda em **sessões de fundo** — sem janela. Cada persona volta pelo
`claude --bg --resume <sessionId> -n <Nome>`, retomando **por identidade**, não
por data.

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

**`claude agents --json` não basta.** Ele lista só as sessões locais de fundo.
Com o device de pé, sessões aparecem como `Remote Control` e **não entram nessa
lista** — já aconteceu de ele devolver `1` com 11 de pé.

Confira pelos dois:

1. **`/agents`** — a lista de pares, que mostra as `Remote Control`.
2. **A linha de comando dos processos**, que é o que o próprio script usa:

```powershell
Get-CimInstance Win32_Process -Filter "Name='claude.exe'" |
  Where-Object { $_.CommandLine -match '-n ' } |
  ForEach-Object { ($_.CommandLine -replace '.*-n ', '') }
```

**Nunca conte processos `claude.exe`** para concluir: o device cria sessões
próprias e o total é maior que 12 — isso é normal, não é duplicata.

## O que relatar sempre

1. A lista do `-Conferir`, inteira, com quem estava `ja de pe` e quem foi subir.
2. A conferência final do script, literal.
3. A contagem pelo `/agents`.
4. **Qualquer persona que não subiu**, nomeada. Não diga "quase todas".

## Duas coisas que este desenho não resolve

**Sessão de fundo não tem quem responda a pedido de permissão.** Ela fica parada
em silêncio até alguém atender — do celular, ou dando `claude attach`. Se uma
persona parecer travada, é a primeira hipótese.

**O `sessoes.json` precisa estar atualizado.** É o mapa persona → `sessionId`.
Se ele sumir, o `abrir-squad` cai para `--continue`, que escolhe **pela data** —
e aí uma janela pode voltar na conversa errada sem avisar. O script avisa quando
isso acontece; **não ignore esse aviso**.

## O que este skill não faz

- **Não sobe o device.** Isso é da tarefa agendada `Guardian - manter de pe`.
  Se o device estiver fora, é essa tarefa que falhou, e o log está em
  `C:\Software\GeoCloud\_device-log\`.
- **Não fecha nem mata nada** para "limpar" antes de subir.
- **Não regenera o `sessoes.json`.** Se ele estiver errado, relate — não
  reescreva por conta própria: um id errado faz a persona voltar noutra conversa.
