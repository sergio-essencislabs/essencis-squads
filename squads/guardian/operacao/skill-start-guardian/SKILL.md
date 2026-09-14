---
name: start-guardian
description: Garante que as 11 sessões do squad Guardian estejam de pé nesta máquina — em segundo plano, sem janela — e, se pedirem para ver, abre abas do Windows Terminal anexando às sessões que já rodam. Use quando pedirem para iniciar, subir, levantar ou abrir o squad, o Guardian, os agentes ou as janelas dos agentes, inclusive de longe pelo celular. Não use para subir o device: o device é mantido pela tarefa agendada.
---

# Subir o squad Guardian

O squad são **11**: Vision, Jarvis, Breno, Otavio, Tomas, Rui, Dante, Selma,
Livia, Flavia, Marta. Todas rodam em **sessões de fundo**, sem janela:

```
claude --bg --resume <sessionId>
```

**sem mais nada** — retomando por identidade, não por data. O nome, o `--add-dir`
e o modelo voltam sozinhos, das opções salvas da própria sessão.

**Só a Vision aparece no celular**, e está certo assim: decisão do Sergio em
14/09/2026, depois de as três alternativas terem sido tentadas e medidas. As
aprovações estão centralizadas na Vision.

Três scripts, e a diferença importa:

| | |
|---|---|
| `C:\Software\GeoCloud\subir-squad.ps1` | **sobe** as sessões em fundo. É o padrão |
| `C:\Software\GeoCloud\abrir-squad.ps1` | **abre abas** anexando às que já rodam. Só quando pedirem para *ver* |
| `C:\Software\GeoCloud\estado-squad.ps1` | **só lê** — quem está vivo/dormente, tokens, model/effort/autocompact, RAM, tarefa agendada. Rode antes de relatar estado, em vez de juntar 3-4 comandos à mão |

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

Ele **confere sozinho no fim** e diz `conferido: as 11 estao de pe` ou
`NAO subiram: <nomes>`. Relate o que ele disser, literalmente.

**Não precisa de guarda contra duplicata**: o script checa cada persona pela
linha de comando antes de subir, e pula as que já estão de pé.

## A regra mais importante deste arquivo: acordar faz parte do despacho

**Sessão aposentada é normal e aceitável.** O daemon recolhe sessão de fundo
ociosa, e com a memória apertada isso leva **1 a 2 minutos**, não 60:

```
bg retire 67bdda6a: settled, idle 2m [low memory]
```

Medido em 14/09 com 10% de RAM livre. Conferir a lista antes de uma rodada de
despachos **não basta** — entre conferir e mandar a mensagem a persona já pode
ter caído.

Então, antes de **cada** despacho:

```powershell
cd <diretorio da persona>; claude --bg --resume <sessionId>
```

A saída certa é `woke session <id> with its saved options`. Só então
`SendMessage`. Acordar quem já está de pé é inofensivo — devolve a mesma linha.
**Na dúvida, acorde.**

Numa rodada de vários despachos, acorde **cada uma imediatamente antes da sua
mensagem**, nunca todas no começo: com recolhimento em 1-2 min, as últimas da
fila caem antes de receber.

Recolher não é destrutivo: id, diretório e conversa sobrevivem. O que se perde
é o despacho, e ele se perde **em silêncio**.

## A outra regra que não se quebra: `--resume` sem flag

Uma sessão de fundo guarda as **próprias** opções (`-n`, `--add-dir`,
`--model`). Passar qualquer flag no resume não as sobrescreve — **forka uma
cópia** com id novo, e cópia que não é achada morre em segundos.

A saída certa é `woke session <id> with its saved options`. Se aparecer
`started a copy as <novo>`, **pare**: o id está errado ou a sessão está aberta
noutro processo. Relate, e **não adote a cópia** — pare a cópia com
`claude stop <novo>`.

## Se pedirem para ver as janelas

```powershell
powershell -ExecutionPolicy Bypass -NoProfile -File C:\Software\GeoCloud\abrir-squad.ps1 -Sim
```

Ele abre abas com `claude attach <id>` — **anexa às sessões que já rodam, não
cria novas**, e **fechar a aba não derruba a sessão**. Medido no ciclo completo
em 14/09: 2 processos antes, 3 com a aba aberta (só o cliente do attach), 2
depois de fechar a janela.

Bônus: sessão com algo anexado **nunca** é recolhida (`attachers.size > 0` no
binário). Uma janela aberta é a única forma conhecida de isentar do
recolhimento.

**Se algum dia uma persona estiver em Remote Control, não use `attach` nela** —
ali o attach sobe uma **segunda sessão viva** sobre a mesma conversa (medido na
Marta: três processos no mesmo id). O `abrir-squad` detecta esse caso e trata
sozinho.

## Como conferir, e com qual instrumento

**`claude agents --json` lista as sessões de fundo** — no desenho atual, as onze.
Sessão em Remote Control sairia dessa lista, mas hoje não há nenhuma.

Confira também pela linha de comando dos processos, que é o que o script usa:

```powershell
Get-CimInstance Win32_Process -Filter "Name='claude.exe'" |
  ForEach-Object { if ($_.CommandLine -match '-n\s+(\S+)') { $matches[1] } } |
  Sort-Object -Unique
```

O `-Unique` **não é enfeite**: cada persona aparece em *duas* linhas — o
processo da sessão e o anfitrião de pty que o daemon põe na frente.

**Nunca conte processos `claude.exe`** para concluir: o device tem processo
próprio e o pty-host dobra cada sessão. Total maior que 11 é normal.

## O que relatar sempre

1. A lista do `-Conferir`, inteira, com quem estava `ja de pe` e quem foi subir.
2. A conferência final do script, literal.
3. **Qualquer persona que não subiu**, nomeada. Não diga "quase todas".

Ressalva honesta sobre a conferência final: com recolhimento em 1-2 min, ela
pode acusar `NAO subiram: <nomes>` de personas que subiram e foram recolhidas
entre a subida e a conferência. Aconteceu em 14/09 com Rui e Marta. Antes de
relatar como falha, confira no `~/.claude/daemon.log` se há `bg retire` para
elas — recolhimento não é falha de subida.

## O `sessoes.json` precisa estar certo

É o mapa persona → `sessionId` → diretório, e é a **única** fonte da lista: o
`abrir-squad` monta as janelas a partir dele. Se estiver errado, uma janela pode
voltar na conversa errada.

**Não regenere o `sessoes.json` por conta própria. Se estiver errado, relate.**

Três armadilhas medidas em 14/09:

- **O mapa tinha uma persona que não existe.** A entrada `GeoCloudAI` não era
  persona: é o rótulo do **device** no app, e o rótulo é `<repositório> ·
  <branch>` do diretório onde o servidor sobe (`_device` → GeoCloudAI, branch
  ops/device). `--name` não muda isso — nomeia sessão, não ambiente. O device já
  é o hostname, Essencis002. Entrada removida.
- **Uma persona pode ter mais de uma conversa, e só uma tem a ponte.** A certa
  tem `"type":"bridge-session"` com `lastSequenceNum` alto; fork recém-criado
  tem `0`. Resumir a errada deixou o Dante desconectado no celular.
- **Id do mapa sem transcript em disco.** Dois ids (Dante e GeoCloudAI) nunca
  foram sessões de verdade. Se `--resume` disser `No conversation found`,
  **relate** — não adote um transcript qualquer da pasta.

## Pendência conhecida

O roster grava `cwd = C:\Software\GeoCloud\_wt_vision` para a conversa do Dante
(`90977cbb`), herdado de quando ela nasceu. O `--add-dir` e o transcript estão
certos; o diretório de trabalho não. Consertar exige refazer a sessão. Deixado
como está por decisão — mexer nisso em 14/09 foi o que o desconectou do celular.

## Degradação de contexto: `--autocompact` fixado, `/clear` sob demanda

Desde 15/09/2026, todas as onze têm `--autocompact 500000` fixado em
`respawnFlags` (50% dos 1M de janela do Sonnet 5) — dispara compactação
automática por tamanho real, sem depender de boot nem de comando externo.
Detalhe técnico e o porquê das alternativas descartadas:
[[guardian-contexto-clear-vs-autocompact]].

Se o usuário quiser `/clear` numa persona específica: `abrir-squad.ps1 -Sim`
abre a aba já anexada (não cria sessão), e ele digita `/clear` lá dentro. Não
existe (e não pode existir) forma de eu disparar isso remotamente — nem por
`SendMessage`, nem por API. Depois do `/clear`, a sessão continua viva e
alcançável normalmente, sem precisar de "acordar" como se fosse aposentada.

**Identidade de cada persona sobrevive a isso** porque, desde 15/09, cada
worktree tem um `CLAUDE.md` local apontando para o `.agent.md` dela no hub
(`squads/guardian/agents/<papel>.agent.md`) — ver
[[guardian-identidade-por-arquivo]]. Antes disso, "quem a persona é" só vivia
na conversa, e um `/clear` a apagaria.

## O que este skill não faz

- **Não sobe o device nem a Vision.** Isso é da tarefa agendada `Guardian -
  manter de pe`, que desde 14/09 cuida **só** do device e da Vision, a cada 5
  minutos, no logon e ao voltar de suspensão. As outras dez ficam dormentes de
  propósito — quem as acorda é a Vision, antes de cada despacho. Se o device ou
  a Vision estiverem fora, é essa tarefa que falhou, e o log está em
  `C:\Software\GeoCloud\_device-log\`.
- **Não fecha nem mata nada** para "limpar" antes de subir.
- **Não regenera o `sessoes.json`.**
