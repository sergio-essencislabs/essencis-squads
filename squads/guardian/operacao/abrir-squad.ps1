<#
.SINOPSE
  Reabre o squad inteiro depois de um reinicio: as janelas do Claude Code em
  abas de uma unica janela do Windows Terminal.

  A aba do device (Remote Control) so e aberta se NAO houver device de pe.
  Quem mantem o device e a tarefa agendada "Guardian - manter de pe"; este
  script so cobre o caso de ela nao ter rodado ainda.

.COMO USAR
  powershell -ExecutionPolicy Bypass -File .\abrir-squad.ps1

  -Conferir           so imprime o que faria, sem abrir nada
  -Apenas vision,rui  abre so as janelas nomeadas -- SEPARADAS POR VIRGULA,
                      sem espaco: com -File, "vision rui" nao passa as duas
  -SemDevice          nao abre a aba do Remote Control
  -SomenteDevice      abre SO a aba do device, nenhuma janela de persona.
                      E o caso de "so o device caiu" -- contradiz -SemDevice
                      e -Apenas, e o script recusa as duas combinacoes
  -Sim                pula a confirmacao do aviso de sessoes ja vivas.
                      Use so quando voce ja sabe que ha sessoes vivas e quer
                      abrir assim mesmo -- ou para testar o script sem teclado
  -Base <caminho>     raiz das worktrees (padrao: C:\Software\GeoCloud)
  -DeviceDir <cam>    diretorio de onde o servidor de Remote Control sobe.
                      Com --spawn worktree, as sessoes sob demanda ganham
                      worktrees isoladas, mas o servidor mora neste diretorio
  -DeviceNome <nome>  nome da sessao do device. Padrao VAZIO, e de proposito:
                      medido que o nome automatico ja e estavel por maquina
                      (<hostname>-<duas-palavras> igual a cada subida), entao
                      fixar nao acrescenta nada e so faz a subida viva e as
                      mortas terem rotulos identicos na lista do celular
  -DeviceSpawn        same-dir | worktree | session  (padrao: worktree)
  -DeviceCapacidade   maximo de sessoes simultaneas  (padrao: 11)
  -DevicePermissao    modo de permissao das sessoes criadas sob demanda

.COMO CADA JANELA VOLTA
  `claude --continue` retoma a conversa MAIS RECENTE do diretorio. Nao ha id
  fixo: quem decide e a data de modificacao do .jsonl em
  %USERPROFILE%\.claude\projects\<slug-do-diretorio>\

  Consequencia que morde: se um diretorio tiver mais de uma sessao e a errada
  for a mais nova, aquela janela volta na conversa errada e ninguem e avisado.
  Por isso o script imprime a data de cada uma antes de abrir, e marca as que
  tem mais de uma. Rode com -Conferir e leia essa lista.

.O QUE ESTE SCRIPT NAO GARANTE
  - Nao verifica que a sessao retomada e a "certa", so mostra a data.
  - Nao ordena a subida: as abas sobem juntas.
  - O aviso de duplicata conta processos claude.exe na maquina inteira; ele
    detecta que HA sessoes vivas, nao QUAIS.
#>

# PositionalBinding=$false de proposito: sem isso, "-Apenas vision rui" liga o
# "rui" ao -Base por posicao e o script vai procurar em "rui\_wt_vision".
# Argumento solto tem de dar erro, nao virar raiz de diretorio.
[CmdletBinding(PositionalBinding = $false)]
param(
  [switch]   $SemDevice,
  [switch]   $SomenteDevice,
  [string[]] $Apenas,
  [switch]   $Conferir,
  [switch]   $Sim,
  [string]   $Base       = 'C:\Software\GeoCloud',
  [string]   $DeviceDir        = 'C:\Software\GeoCloud\_device',
  [string]   $DeviceNome       = '',
  [string]   $DeviceSpawn      = 'worktree',
  [int]      $DeviceCapacidade = 11,
  [string]   $DevicePermissao  = 'acceptEdits'
)

$ErrorActionPreference = 'Stop'

if ($SomenteDevice -and $SemDevice) {
  throw "-SomenteDevice e -SemDevice se contradizem: um manda abrir so o device, o outro manda nao abrir o device."
}
if ($SomenteDevice -and $Apenas) {
  throw "-SomenteDevice e -Apenas se contradizem: -SomenteDevice nao abre janela de persona nenhuma."
}

# A lista de janelas vem do `sessoes.json`, que e o mapa que o subir-squad usa.
# Ela ERA fixa aqui dentro, e isso custou caro em 14/09: o mapa perdeu a entrada
# `GeoCloudAI` (que nunca foi persona -- e o nome do DEVICE), mas a lista fixa
# continuou com ela. Sem sessionId, a aba caiu em `claude --continue -n
# GeoCloudAI`, que escolhe a conversa pela DATA e CRIA sessao: nasceu uma sessao
# solta sobre uma janela velha do Jarvis, exatamente o que estes scripts existem
# para nao fazer.
#
# Duas listas para a mesma verdade sempre divergem. Agora ha uma so, e o
# diretorio tambem vem do mapa -- a lista fixa dizia `_wt_vision` para a Vision,
# que na verdade trabalha em `C:\Software\GeoCloud`.
$mapaSessoes = 'C:\Software\GeoCloud\sessoes.json'
if (-not (Test-Path -LiteralPath $mapaSessoes)) {
  throw "sessoes.json nao encontrado em $mapaSessoes -- sem ele nao da para saber quais janelas abrir nem em que conversa. Nao invento a lista."
}
$cru = Get-Content -LiteralPath $mapaSessoes -Raw -Encoding UTF8 | ConvertFrom-Json
$janelas = @($cru | ForEach-Object {
  [pscustomobject]@{
    Nome      = $_.nome
    Dir       = ($_.dir -replace '/', [string][char]92)
    SessionId = $_.sessionId
  }
})
if ($janelas.Count -eq 0) { throw "sessoes.json esta vazio." }

if ($SomenteDevice) { $janelas = @() }

if ($Apenas) {
  # Invocado com -File, o PowerShell NAO separa "vision,rui" em dois: chega um
  # elemento so. E -File e como o atalho chama. Por isso separamos aqui.
  # Use virgula, nao espaco: "-Apenas vision rui" nao passa os dois.
  $filtro = @(($Apenas -join ',') -split ',' |
              ForEach-Object { $_.Trim().ToLowerInvariant() } |
              Where-Object { $_ })
  $janelas = @($janelas | Where-Object { $filtro -contains $_.Nome.ToLowerInvariant() })
  if ($janelas.Count -eq 0) {
    throw "Nenhuma janela casa com -Apenas: $($Apenas -join ', ')"
  }
}

# ---- conferencias antes de abrir --------------------------------------------

$faltando = @($janelas | Where-Object { -not (Test-Path -LiteralPath $_.Dir) })
if ($faltando.Count -gt 0) {
  throw "Diretorio inexistente: " + (($faltando | ForEach-Object { $_.Dir }) -join ', ')
}

# ---- quem esta em Remote Control ---------------------------------------------
#
# Desde 14/09 as personas vivem em Remote Control (`--remote-control <Nome>
# --resume <id>`), em processo oculto, e e isso que as poe na tela do celular.
#
# Para essas, `claude attach <id>` NAO serve. Medido em 14/09 no Dante: o attach
# responde "Waking session ..." e sobe uma SEGUNDA sessao viva sobre a MESMA
# conversa -- ficaram tres processos no mesmo id (o de remote control, um
# pty-host e um `--resume`). E exatamente a duplicata que este script existe
# para nao criar.
#
# O que se faz entao: derrubar o processo OCULTO e reabrir o MESMO comando numa
# aba visivel. A sessao e a mesma, o id e o mesmo, a conversa segue no celular,
# e agora ela tem janela. Uma sessao viva por conversa, que e a regra.
$emRC = @{}
try {
  Get-CimInstance Win32_Process -Filter "Name='claude.exe'" -ErrorAction Stop |
    ForEach-Object {
      $cl = $_.CommandLine
      if ($cl -and $cl -match '--remote-control[= ](\S+)') { $emRC[$matches[1]] = $_.ProcessId }
    }
} catch {}

# O aviso de duplicata so vale para as janelas que NAO tem sessionId no mapa --
# essas caem em `--continue`, que CRIA sessao e pode escolher a conversa errada
# pela data. Quem tem id abre com `claude attach`, que ANEXA a sessao ja viva:
# nao cria nada, e fechar a aba nao derruba a sessao.
#
# A versao anterior avisava sempre, contando processos claude.exe. Com 27
# processos no ar (device, pty-hosts e as 12 sessoes) ela gritava duplicata
# num caminho onde duplicata nao existe -- e um aviso que assusta a toa e um
# aviso que se aprende a ignorar.
$semId = @($janelas | Where-Object { -not $_.SessionId })
if ($semId.Count -gt 0) {
  Write-Warning ("Sem sessionId no mapa: " + (($semId | ForEach-Object { $_.Nome }) -join ', '))
  Write-Warning "Essas vao abrir com --continue, que escolhe a conversa pela DATA e CRIA sessao."
  Write-Warning "As demais usam 'claude attach' e sao seguras."
  if (-not $Conferir -and -not $Sim) {
    $r = Read-Host "Continuar mesmo assim? (s/N)"
    if ($r -ne 's') { Write-Host "Cancelado."; return }
  } elseif ($Sim) {
    Write-Warning "-Sim: seguindo sem perguntar."
  }
}

# Device ja de pe? Desde que a tarefa agendada passou a mante-lo, abrir a aba
# sem checar criaria um SEGUNDO device. A checagem e a mesma do
# garantir-device.ps1 -- pela LINHA DE COMANDO, porque ha muitos claude.exe e
# so um e o device. Fica ANTES do -Conferir de proposito: a conferencia tem de
# dizer se abriria a aba ou nao.
if (-not $SemDevice) {
  $deviceVivo = @(Get-CimInstance Win32_Process -Filter "Name='claude.exe'" -ErrorAction SilentlyContinue |
                  Where-Object { $_.CommandLine -and $_.CommandLine -match '(?<!-)remote-control' })
  if ($deviceVivo.Count -gt 0) {
    Write-Host ""
    Write-Host ("device ja de pe (PID " + (($deviceVivo | ForEach-Object { $_.ProcessId }) -join ', ') +
                ") -- nao abro outra aba.") -ForegroundColor Cyan
    Write-Host "  quem o mantem e a tarefa 'Guardian - manter de pe'." -ForegroundColor Cyan
    $SemDevice = $true
    if ($SomenteDevice) {
      Write-Host "-SomenteDevice sem nada a fazer: o device ja esta de pe." -ForegroundColor Cyan
      return
    }
  }
}

# Qual conversa cada janela vai retomar, pela data do .jsonl mais recente.
Write-Host ""
if ($SomenteDevice) {
  Write-Host "-SomenteDevice: nenhuma janela de persona sera aberta." -ForegroundColor Cyan
}
if ($janelas.Count -gt 0) {
Write-Host "Janela        O que a aba vai executar" -ForegroundColor Cyan
Write-Host "------------  ------------------------------------------------" -ForegroundColor Cyan
}
# A previa mostra o COMANDO, nao um palpite sobre qual conversa a data escolhe.
# A versao anterior listava o .jsonl mais recente de cada pasta e chamava isso
# de "conversa que o --continue vai retomar" -- descrevia um caminho que o
# script ja nao usa quando ha mapa. Previa que nao descreve o que sera feito e
# pior que previa nenhuma.
foreach ($j in $janelas) {
  if ($emRC.ContainsKey([string]$j.Nome)) {
    Write-Host ("{0,-13} remote control -> aba visivel (mesmo id {1}; o processo oculto pid {2} sai)" -f $j.Nome, $j.SessionId.Substring(0,8), $emRC[[string]$j.Nome])
  } elseif ($j.SessionId) {
    Write-Host ("{0,-13} claude attach {1}   (anexa a sessao viva; fechar a aba nao a derruba)" -f $j.Nome, $j.SessionId.Substring(0,8))
  } else {
    # Sem regex de proposito: barra invertida em regex e fonte de erro silencioso.
    $slug = $j.Dir.Replace(':', '-').Replace([char]92, '-').Replace('/', '-').Replace('_', '-').Replace('.', '-')
    $proj = Join-Path $env:USERPROFILE ".claude\projects\$slug"
    $s = @(Get-ChildItem -LiteralPath $proj -Filter *.jsonl -ErrorAction SilentlyContinue |
           Sort-Object LastWriteTime -Descending)
    if ($s.Count -eq 0) {
      Write-Host ("{0,-13} claude --continue  -- SEM SESSAO, vai comecar conversa nova" -f $j.Nome) -ForegroundColor Yellow
    } else {
      $marca = if ($s.Count -gt 1) { " de $($s.Count) -- confira que a mais nova e a certa" } else { "" }
      Write-Host ("{0,-13} claude --continue  -- pela DATA: {1:yyyy-MM-dd HH:mm}{2}" -f $j.Nome, $s[0].LastWriteTime, $marca) -ForegroundColor Yellow
    }
  }
}
Write-Host ""

if ($Conferir) { Write-Host "-Conferir: nada foi aberto."; return }

# ---- monta e dispara --------------------------------------------------------

# "-w new" de proposito: sem isso, o comportamento depende do windowingBehavior
# do Windows Terminal, e numa maquina configurada para reusar janela as abas
# entram na janela que ja esta aberta, misturadas com as sessoes vivas.
$wtArgs = New-Object System.Collections.Generic.List[string]
$wtArgs.AddRange([string[]]@('-w', 'new'))
$primeira = $true
foreach ($j in $janelas) {
  if (-not $primeira) { $wtArgs.Add(';') }
  $primeira = $false
  # `claude attach <id>` ABRE a sessao que ja esta rodando em fundo -- nao cria
  # outra. E o que elimina a duplicata que este script antes precisava vigiar.
  # O id curto e o prefixo de 8 do sessionId (conferido: "id":"f78ac08c" para
  # "sessionId":"f78ac08c-b983-...").
  #
  # O --title nao garante nada: o claude SOBRESCREVE o titulo da aba com o nome
  # da sessao. Fica so como rotulo do instante anterior ao claude subir.
  # Tres caminhos, e a ordem importa:
  #   1. em Remote Control -> derruba o oculto e reabre o MESMO comando aqui;
  #   2. de fundo com id   -> `attach`, que anexa e nao cria nada;
  #   3. sem id no mapa    -> `--continue`, que escolhe pela DATA e cria sessao.
  if ($emRC.ContainsKey([string]$j.Nome)) {
    $pidOculto = $emRC[[string]$j.Nome]
    try { Stop-Process -Id $pidOculto -Force -ErrorAction Stop } catch {}
    $cmdAba = "claude --remote-control $($j.Nome) --resume $($j.SessionId)"
  }
  elseif ($j.SessionId) { $cmdAba = "claude attach $($j.SessionId.Substring(0,8))" }
  else                  { $cmdAba = "claude --continue -n $($j.Nome)" }
  $wtArgs.AddRange([string[]]@(
    'new-tab', '--title', $j.Nome, '-d', $j.Dir,
    'powershell', '-NoExit', '-Command', $cmdAba
  ))
}

if (-not $SemDevice) {
  if (Test-Path -LiteralPath $DeviceDir) {
    # O ';' so entra se ja houver uma aba antes -- com -SomenteDevice nao ha,
    # e um ';' solto na frente faz o wt receber um comando vazio.
    if (-not $primeira) { $wtArgs.Add(';') }
    $primeira = $false
    # `claude remote-control` (SUBCOMANDO) sobe o servidor persistente que faz a
    # maquina aparecer como device. Nao confundir com `claude --remote-control`
    # (FLAG), que so abre uma sessao interativa controlavel -- ela nao e o
    # device, e nem sequer aparece no /agents.
    # --no-create-session-in-dir: sem isso o servidor pre-cria uma sessao no
    # proprio diretorio. Quando ele rodava de _wt_vision, isso punha uma SEGUNDA
    # sessao na pasta da Vision -- e no reinicio seguinte o --continue escolhe a
    # mais recente do diretorio, entao a janela podia voltar na conversa errada.
    $cmdDevice = "claude remote-control --spawn $DeviceSpawn --capacity $DeviceCapacidade --permission-mode $DevicePermissao --no-create-session-in-dir"
    # Sem --name de proposito: cada subida ganha nome proprio, para a sessao
    # viva se distinguir das mortas que ainda constam na lista do celular.
    # Fixar o nome faz a subida de agora e a de ontem terem o MESMO rotulo.
    if ($DeviceNome) { $cmdDevice += " --name $DeviceNome" }
    $wtArgs.AddRange([string[]]@(
      'new-tab', '--title', 'device', '-d', $DeviceDir,
      'powershell', '-NoExit', '-Command', $cmdDevice
    ))
  } else {
    Write-Warning "Device nao aberto: $DeviceDir nao existe. Use -DeviceDir."
  }
}

& wt @wtArgs

Write-Host ""
Write-Host "Disparado. Confira numa das janelas com /agents:" -ForegroundColor Green
if ($janelas.Count -gt 1) {
  Write-Host "  - devem aparecer $($janelas.Count - 1) pares novos;" -ForegroundColor Green
}
if (-not $SemDevice) {
  Write-Host "  - o device deve aparecer como 'Remote Control', nao 'offline'." -ForegroundColor Green
}
Write-Host "Contar as abas nao serve: aba aberta nao e sessao viva." -ForegroundColor Green
