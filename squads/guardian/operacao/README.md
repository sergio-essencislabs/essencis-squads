# Operação: recuperar o squad depois de um reinício

O squad roda como **N janelas do Claude Code**, uma por worktree, mais uma sessão
de **Remote Control** que é o que faz a máquina aparecer como device no celular.
Um reinício derruba todas. Este diretório existe para que a recuperação seja um
duplo clique em vez de uma reconstrução de memória.

| arquivo | o que faz |
|---|---|
| `abrir-squad.ps1` | abre as janelas em abas de uma única janela do Windows Terminal, mais a aba do device |
| `criar-atalho.ps1` | cria o atalho na área de trabalho que chama o de cima. Rodar uma vez por máquina |

## Uso

```powershell
powershell -ExecutionPolicy Bypass -File .\abrir-squad.ps1            # abre tudo
powershell -ExecutionPolicy Bypass -File .\abrir-squad.ps1 -Conferir  # não abre nada, só lista
powershell -ExecutionPolicy Bypass -File .\abrir-squad.ps1 -Apenas vision,rui
```

`-Apenas` **separa por vírgula, não por espaço**. Com `-File` — que é como o
atalho chama —, `-Apenas vision rui` não passa as duas.

## O que decide em qual conversa cada janela volta

`claude --continue` retoma a conversa **mais recente do diretório**. Não há id
fixo: quem decide é a data de modificação do `.jsonl` em
`%USERPROFILE%\.claude\projects\<slug-do-diretório>\`.

**Isso morde quando um diretório tem mais de uma sessão.** Se a errada for a mais
nova, aquela janela volta na conversa errada e nada avisa. Por isso o script
imprime a data de cada uma **antes** de abrir e marca as que têm mais de uma:

```
Vision        2026-09-13 09:30  (de 3 sessoes -- confira que a mais nova e a certa)
Breno         2026-09-13 08:29  (de 2 sessoes -- confira que a mais nova e a certa)
Jarvis        2026-09-13 05:28
```

Rode com `-Conferir` e leia essa lista antes de abrir de verdade.

## Por que ele avisa sobre `claude.exe` já rodando

Duas janelas na mesma worktree fazem trabalho ser atribuído a quem não o fez —
já aconteceu: uma sessão duplicada ficou viva e o despacho foi para a janela
errada. O script conta os processos e pede confirmação.

**O aviso detecta que HÁ sessões vivas, não QUAIS.** Para saber quais, use
`/agents` numa janela aberta.

## O device (Remote Control)

A última aba roda `claude --remote-control <nome>`. O nome mantém a identidade
que já aparece no celular — **trocá-lo cria um device novo na lista em vez de
reconectar o mesmo**. Os padrões estão no `param()` do script; passe `-DeviceDir`
e `-DeviceNome` se mudarem.

## Como conferir que deu certo

Não conte abas: **aba aberta não é sessão viva**. Abra `/agents` numa das janelas
e confira que os pares aparecem e que o device aparece como `Remote Control`, não
como `offline`.

## A cópia local e esta aqui

O atalho aponta para uma cópia fora do repositório (por padrão
`C:\Software\GeoCloud\abrir-squad.ps1`), para não depender de qual branch um
clone está no momento do reinício. **Esta versão é a fonte.** Depois de alterar
aqui, atualize a cópia:

```powershell
Copy-Item .\abrir-squad.ps1 C:\Software\GeoCloud\abrir-squad.ps1 -Force
```

Duas cópias podem divergir, e o risco é conhecido. A alternativa — o atalho
apontar para dentro de um clone — falharia silenciosamente sempre que o clone
estivesse noutra branch, que é pior: quebraria exatamente no reinício, que é
quando ninguém quer diagnosticar.

## O que foi testado e o que não foi

| | |
|---|---|
| caminhos das janelas, e a sessão que cada `--continue` pega | conferido contra as sessões vivas |
| **o disparo real das 12 abas** | **testado**: `-Base` apontado para diretórios descartáveis, `-SemDevice`. Subiram **exatamente 12** processos `claude` novos, e as **13 sessões vivas sobreviveram** — conferido por PID, antes e depois |
| o fechamento do que o teste abriu | os 12 shells mortos por três critérios simultâneos (filho do Windows Terminal + idade < 5 min + linha de comando exata). Nenhum processo original morreu |
| `-w new` cria janela nova | **verificado** enumerando janelas da classe `CASCADIA_HOSTING_WINDOW_CLASS`: 2 → 3 → 2 |
| `-Apenas`, nome inexistente, `-Base` inexistente, `-SemDevice`, `-Sim` | testados, incluindo os ramos de erro |
| o atalho | criado e **lido de volta do disco** — `Save()` não acusa alvo inexistente |
| **a aba do device** | **não testada** — subir o Remote Control agora mudaria o estado do device de verdade |
| **o disparo com as 12 sessões vivas no mesmo diretório** | **não testado, de propósito** — duas janelas `--continue` no mesmo diretório retomam o mesmo arquivo de conversa, e já houve um caso em que isso fez trabalho ser atribuído a quem não o fez |

## Dois defeitos que só apareceram porque os ramos de erro foram exercidados

Registrados porque a forma se repete, não pela anedota.

**1. `-Apenas vision,rui` não funcionava via `-File`.** O PowerShell não separa a
vírgula quando invocado com `-File`: chega um elemento só, e o filtro não casava
nada. Funcionava quando chamado de dentro do PowerShell — ou seja, funcionava no
teste e falharia no uso, porque o atalho usa `-File`.

**2. `-Apenas vision rui` ligava `rui` ao `-Base` por posição.** O script ia
procurar em `rui\_wt_vision` e a mensagem de erro falava de um diretório que
ninguém escreveu. Corrigido com `PositionalBinding = $false`: argumento solto
agora dá erro nomeando o argumento, em vez de virar raiz de diretório.

**3. Contar processos do Windows Terminal não conta janelas.** No teste do
disparo, o número de processos `WindowsTerminal.exe` não mudou, e eu concluí que
`-w new` não tinha criado janela nova — que as 12 abas tinham entrado na janela
viva. **Errado nas duas metades:** o Windows Terminal hospeda **várias janelas
num processo só**, então o instrumento não media o objeto. Enumerando janelas da
classe `CASCADIA_HOSTING_WINDOW_CLASS`, o `-w new` cria janela nova: 2 → 3 → 2.

Antes disso, uma sonda de 1,5 s medida aos 3 s deu o mesmo resultado pelo motivo
oposto: **a janela já tinha fechado quando eu contei.** Duas medições erradas
concordaram, e a concordância pareceu confirmação.

Os três produziam **comportamento plausível a partir de entrada errada**, que é
a forma que não se detecta lendo o código.
