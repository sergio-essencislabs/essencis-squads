# Operação: recuperar o squad depois de um reinício

O squad roda como **N janelas do Claude Code**, uma por worktree, mais uma sessão
de **Remote Control** que é o que faz a máquina aparecer como device no celular.
Um reinício derruba todas. Este diretório existe para que a recuperação seja um
duplo clique em vez de uma reconstrução de memória.

| arquivo | o que faz |
|---|---|
| `abrir-squad.ps1` | abre as janelas em abas de uma única janela do Windows Terminal, mais a aba do device |
| `criar-atalho.ps1` | cria o atalho na área de trabalho que chama o de cima. Rodar uma vez por máquina |
| `garantir-device.ps1` | checa se o device está de pé; sobe só se não estiver. Feito para o Agendador |
| `instalar-tarefa-device.ps1` | registra a tarefa que chama o de cima no logon e a cada 30 min. Rodar uma vez por máquina |
| `skill-start-guardian/SKILL.md` | a skill `/start-guardian` — abre o squad numa frase, inclusive do celular |

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

**Há duas coisas com nome parecido e elas não são a mesma.** Confundi-las custou
uma rodada inteira deste PR:

| | o que é |
|---|---|
| `claude remote-control` **(subcomando)** | **o device.** Servidor persistente que faz a máquina aparecer no celular e em `claude.ai/code`, criando sessões sob demanda |
| `claude --remote-control <nome>` **(flag)** | uma sessão interativa comum, controlável remotamente. **Não é o device**, e **nem aparece** no `/agents` |

A aba do device roda o **subcomando**:

```
claude remote-control --spawn worktree --capacity 11 --permission-mode acceptEdits --name <nome>
```

### O nome do device

Sem `--name`, o nome é gerado como `<hostname>-<duas-palavras>` — por exemplo
`essencis002-snazzy-rocket` — e **muda a cada subida**. Por isso o padrão aqui é
**fixo**: fixar mantém o mesmo rótulo no celular entre reinícios, em vez de
acumular devices com nomes diferentes.

### O device morre com as abas

Medido: o processo do device é **filho de uma aba** do Windows Terminal. Fechar
todas as abas o derruba junto — não é um serviço que sobrevive à janela.

### `-SomenteDevice`

Abre só a aba do device, nenhuma janela de persona. É o caso de "só o device
caiu".

### O device fora do terminal — a tarefa agendada

Enquanto o device for filho de uma aba, fechar as abas o derruba, e **não há
ninguém do outro lado para o celular chamar**. A tarefa resolve isso:

```powershell
powershell -ExecutionPolicy Bypass -NoProfile -File .\instalar-tarefa-device.ps1
```

Registra `Guardian - garantir device` com **dois gatilhos** — no logon e a cada
30 minutos — chamando `garantir-device.ps1`, que **checa antes de agir**: se o
device já estiver de pé, não faz nada.

**Nunca como serviço.** Serviço roda na Sessão 0, isolada da área de trabalho:
o device subiria, mas as janelas que ele abrisse seriam **invisíveis**. Pareceria
funcionar e não funcionaria. Por isso `LogonType Interactive`.

**A consequência aceita:** depois de um reinício, o device só sobe **após o
login**. Não há como contornar sem cair na Sessão 0. Uma vez logado, bloquear a
tela não derruba nada.

**Por que checagem explícita e não a política do Agendador.** O `IgnoreNew`
impede duas execuções *da tarefa*, não dois devices — e a tarefa termina
deixando o processo vivo, então a política não diz nada sobre ele. Quem impede
device duplicado é o `garantir-device.ps1`, olhando a **linha de comando** dos
processos: há muitos `claude.exe` na máquina e só um é o device.

**O log não é opcional.** Sem terminal, a saída do device some — e é no caso
extremo que se precisa dela. O script grava em `C:\Software\GeoCloud\_device-log\`:

```
2026-09-13 11:12:30  device ausente -- subindo
2026-09-13 11:12:39  subiu: PID 13908 | saida: ...\device-20260913-111230.out.log
```

**Testado de ponta a ponta:** device morto → `Start-ScheduledTask` → device de
volta com PID novo, tarefa em `Ready` (não presa em `Running`), `LastTaskResult`
= 0, e as duas linhas no log.

### O que o `/agents` mostra sobre o device: nada

Uma entrada `Remote Control · offline` no `/agents` **não é o device** — é
resíduo de uma sessão interativa antiga que foi morta sem se desregistrar. O
device em funcionamento **não aparece nessa lista**. Para saber se ele está de
pé, procure o processo:

```powershell
Get-CimInstance Win32_Process -Filter "Name='claude.exe'" |
  Where-Object { $_.CommandLine -match 'remote-control' }
```

## Como conferir que deu certo

Não conte abas: **aba aberta não é sessão viva**. Abra `/agents` numa das janelas
e confira que os pares aparecem e que o device aparece como `Remote Control`, não
como `offline`.

## Abrir o squad de longe: a skill `/start-guardian`

Com o device mantido pela tarefa, o celular sempre encontra alguém nesta
máquina. Uma sessão nova no device, a frase `/start-guardian`, e as janelas
abrem aqui.

Instalar (uma vez por máquina):

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude\skills\start-guardian" | Out-Null
Copy-Item .\skill-start-guardian\SKILL.md "$env:USERPROFILE\.claude\skills\start-guardian\SKILL.md" -Force
```

Fica no **nível de usuário** de propósito: as sessões que o device cria nascem
em worktrees novas, e uma skill presa a um repositório não estaria lá.

### O que a skill faz antes de abrir, e por quê

Ela **confere se já não está aberto** antes de qualquer coisa. Não é
formalidade: de longe não há ninguém para responder a um prompt, então o script
vai com `-Sim`, que **pula a confirmação**. Com `-Sim` e as janelas já abertas,
ele duplicaria tudo — e duas janelas na mesma worktree fazem trabalho ser
atribuído a quem não o fez.

Se achar sessões vivas, ela **para e relata**, em vez de abrir.

### O que ela relata sempre

A lista das datas inteira, qualquer linha marcada `(de N sessoes)` ou
`SEM SESSAO`, e a contagem final por `claude agents --json` — **não por contar
abas nem processos**.

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
| **a aba do device** | **não testada.** O que eu testei foi a flag `--remote-control`, que **não é o device** — o comando certo é o subcomando, e ele só será exercitado no primeiro reinício de verdade |
| `-SomenteDevice` com `-SemDevice` e com `-Apenas` | testados: o script recusa as duas combinações nomeando a contradição |
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

**4. A aba do device rodava o comando errado, e o teste "passou".** O script
chamava `claude --remote-control VaultS` — a **flag**, que abre uma sessão
interativa controlável. O device é o **subcomando** `claude remote-control`.

O que fez isso atravessar: eu **verifiquei o resultado errado**. Vi surgir
`VaultS · Remote Control · idle` no `/agents` e declarei o device no ar. Mas o
device de verdade **nunca aparece nessa lista** — e estava de pé o tempo todo,
noutro processo, com outro nome. Também declarei que ele tinha caído quando
fecharam as abas de teste; não tinha.

Quem percebeu foi o Sergio, por um caminho que nenhum teste meu tinha: **o nome
não batia.** O device dele chama-se `essencis002-snazzy-rocket`; o que eu subi
chamava-se `VaultS`.

Os quatro produziam **comportamento plausível a partir de entrada errada**, que
é a forma que não se detecta lendo o código. E o quarto acrescenta uma variante
pior: **o teste confirmava, porque media a coisa errada.**
