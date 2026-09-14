<#
.SINOPSE
  Sobe o squad em SESSOES DE FUNDO -- sem janela, sem Windows Terminal.
  Cada persona volta pelo `claude --bg --resume <sessionId>`, SEM MAIS NADA.

  Para VER uma delas depois: `claude attach <id>` (ou o /start-guardian).

.POR QUE NENHUMA FLAG -- a regra mais importante deste arquivo
  Uma sessao de fundo guarda as PROPRIAS opcoes (-n, --add-dir, --model).
  Passar qualquer flag no resume nao as sobrescreve: FORKA uma copia. O claude
  avisa, e o aviso e literal:

    "background session <id> keeps its own saved options, so the flags you
     passed started a copy as <novo>. Without flags, the same command
     continues <id> itself."

  Enquanto este script passava `-n <Nome>`, toda subida gerava um id novo. Como
  ele entao "corrigia" o mapa com o id da copia, o sessoes.json foi perdendo os
  ids reais ate apontar so para copias -- e copia de sessao inexistente morre em
  segundos. Foi essa a falha do logon, nao o diretorio.

  Sem flag, a saida e "woke session <id> with its saved options". Mesmo id,
  mesmo nome, mesma historia.

.POR QUE --resume <id> E NAO --continue
  `--continue` retoma a conversa MAIS RECENTE do diretorio -- escolhe pela
  DATA. Se a pasta tiver mais de uma sessao e a errada for a mais nova, a
  persona volta na conversa errada e nada avisa. Ja aconteceu aqui.

  `--resume <id>` retoma POR IDENTIDADE. O risco desaparece -- em troca de
  manter os ids num arquivo, que e o que o sessoes.json faz.

.COMO USAR
  powershell -ExecutionPolicy Bypass -NoProfile -File .\subir-squad.ps1

  -Conferir          diz o que faria, sem subir nada
  -Apenas rui,marta  so as nomeadas (VIRGULA, nao espaco)
  -Sessoes <arq>     o mapa persona -> sessionId
                     (padrao: C:\Software\GeoCloud\sessoes.json)

.COMO ELE SABE QUE UMA JA ESTA DE PE
  Pela LINHA DE COMANDO dos processos, por DOIS criterios:

    1. `-n <Nome>`      -- toda sessao subida por este script leva o nome
    2. o `sessionId`    -- aparece como `--session-id <id>` mesmo SEM o `-n`

  O segundo nao e luxo. Uma sessao iniciada por outro caminho -- ou por uma
  versao antiga deste script -- nao tem `-n`, e so o primeiro criterio a deixa
  passar. Foi exatamente assim que a Vision passou despercebida e o script
  FORKOU a conversa viva numa copia.

  Nao serve contar processos: o device cria sessoes proprias.

.ONDE OLHAR QUANDO UMA NAO SOBE
  `~/.claude/daemon.log`. Ele diz o motivo com todas as letras:

    bg settled <id> (crashed): source session <id-origem> not found

  Isso quer dizer que o `--resume` foi chamado de um diretorio cujo
  ~/.claude/projects/<dir-codificado>/ nao contem <id-origem>.jsonl. Por isso
  este script faz Push-Location para o diretorio da persona antes de chamar.

.O QUE ESTE SCRIPT NAO RESOLVE
  Sessao de fundo nao tem quem responda a um pedido de permissao. Ela fica
  parada em silencio ate alguem atender -- do celular, ou dando attach. E o
  risco operacional deste desenho, e nao ha conserto dentro do script.

  O DIRETORIO DE TRABALHO tambem nao. Ele vem do `dispatch.cwd` gravado no
  roster quando a sessao nasceu, e acordar so repete o gravado. As doze nasceram
  em _wt_vision e continuam la. Consertar exige recriar cada sessao no diretorio
  certo -- o que troca o id. O script ACUSA (DIRETORIO ERRADO) e nao esconde.
#>

[CmdletBinding(PositionalBinding = $false)]
param(
  [switch]   $Conferir,
  [string[]] $Apenas,
  [string]   $Sessoes   = 'C:\Software\GeoCloud\sessoes.json',
  [string]   $ClaudeExe = '',
  [string]   $LogDir    = 'C:\Software\GeoCloud\_device-log'
)

$ErrorActionPreference = 'Stop'

# O log nao e enfeite: este script roda pelo Agendador, com -WindowStyle Hidden.
# Sem registro, uma falha no logon nao deixa rastro nenhum -- e foi exatamente
# isso que aconteceu: a acao que falhou era a unica sem log.
function Registrar([string]$texto) {
  $linha = '{0:yyyy-MM-dd HH:mm:ss}  {1}' -f (Get-Date), $texto
  Write-Host $linha
  try {
    if (-not (Test-Path -LiteralPath $LogDir)) { New-Item -ItemType Directory -Force -Path $LogDir | Out-Null }
    Add-Content -LiteralPath (Join-Path $LogDir 'subir-squad.log') -Value $linha -Encoding UTF8
  } catch { Write-Warning ("nao consegui escrever o log: " + $_.Exception.Message) }
}

# Qualquer erro nao tratado tem de virar linha no log antes de derrubar o script.
trap {
  Registrar ("ERRO NAO TRATADO: " + $_.Exception.Message + " | em: " + $_.InvocationInfo.Line.Trim())
  exit 1
}

Registrar ("inicio (Conferir=" + [bool]$Conferir + ")")

if (-not (Test-Path -LiteralPath $Sessoes)) {
  throw "Mapa de sessoes nao existe: $Sessoes  (veja o README: ele e gerado do acervo de conversas)"
}

# Achatar de proposito: no PowerShell 5.1 o ConvertFrom-Json devolve o array
# do JSON como UM objeto, e `@(...)` em volta produz um array de um elemento.
# O sintoma e "12 de 1" e campos aparecendo como System.Object[].
$cru = Get-Content -LiteralPath $Sessoes -Raw -Encoding UTF8 | ConvertFrom-Json
$mapa = @()
foreach ($x in $cru) { $mapa += $x }
if ($mapa.Count -eq 0) { throw "Mapa de sessoes vazio: $Sessoes" }
if (-not $mapa[0].nome -or -not $mapa[0].sessionId) {
  throw "Mapa de sessoes sem os campos 'nome' e 'sessionId': $Sessoes"
}

if (-not $ClaudeExe) {
  $c = Get-Command claude -ErrorAction SilentlyContinue
  if ($c) { $ClaudeExe = $c.Source }
  else {
    $padrao = Join-Path $env:USERPROFILE '.local\bin\claude.exe'
    if (Test-Path -LiteralPath $padrao) { $ClaudeExe = $padrao }
  }
}
if (-not $ClaudeExe -or -not (Test-Path -LiteralPath $ClaudeExe)) {
  throw "Nao achei o claude.exe. Use -ClaudeExe."
}

if ($Apenas) {
  # Com -File o PowerShell nao separa a virgula: chega um elemento so.
  $filtro = @(($Apenas -join ',') -split ',' |
              ForEach-Object { $_.Trim().ToLowerInvariant() } | Where-Object { $_ })
  $mapa = @($mapa | Where-Object { $filtro -contains $_.nome.ToLowerInvariant() })
  if ($mapa.Count -eq 0) { throw "Nenhuma persona casa com -Apenas: $($Apenas -join ', ')" }
}

$faltando = @($mapa | Where-Object { -not (Test-Path -LiteralPath $_.dir) })
if ($faltando.Count -gt 0) {
  throw "Diretorio inexistente: " + (($faltando | ForEach-Object { $_.dir }) -join ', ')
}

# Quem ja esta de pe -- pela linha de comando, nao pela contagem.
$linhas = @(Get-CimInstance Win32_Process -Filter "Name='claude.exe'" -ErrorAction SilentlyContinue |
            ForEach-Object { $_.CommandLine } | Where-Object { $_ })

# Dois criterios, e o segundo nao e luxo: uma sessao iniciada por outro caminho
# (ou por uma versao antiga deste script) NAO tem `-n`. Foi assim que a Vision
# passou despercebida e o script FORKOU a conversa viva numa copia.
# O sessionId aparece na linha como `--session-id <id>` mesmo sem `-n`.
function JaDePe([string]$nome, [string]$sid) {
  foreach ($l in $linhas) {
    if ($l -match ("-n\s+" + [regex]::Escape($nome) + "(\s|$)")) { return $true }
    # `--session-id <id>`, nao o id em qualquer posicao: a linha de uma COPIA
    # carrega `--resume <id-da-original>` e casaria por engano.
    if ($sid -and $l -match ("--session-id\s+" + [regex]::Escape($sid) + "(\s|$)")) { return $true }
    # Sessao ACORDADA nao tem `--session-id`: o daemon a relanca como
    # `--resume <...\projects\...\<id>.jsonl> -n <Nome> --add-dir ...`.
    # Casar o `.jsonl` e seguro -- e o transcript que ela E, nao o que retomou.
    if ($sid -and $l -match ([regex]::Escape($sid) + "\.jsonl")) { return $true }
    # Sessao em REMOTE CONTROL nao tem `-n` nem `--session-id`, e NAO aparece no
    # `claude agents --json` -- ela se registra do lado do servidor. A linha dela
    # e `--remote-control <Nome> --resume <id>`.
    #
    # Sem este ramo o script conclui que a persona caiu e sobe uma COPIA EM
    # FUNDO por cima da que esta viva. Aconteceu em 14/09 as 06:47: as doze
    # foram convertidas para Remote Control e a tarefa agendada ressuscitou as
    # doze em fundo 15 minutos depois -- nove Remote Control e dez de fundo
    # simultaneas, duas sessoes vivas sobre a mesma conversa.
    if ($l -match ("--remote-control[= ]" + [regex]::Escape($nome) + "(\s|$)")) { return $true }
  }
  return $false
}

Write-Host ""
Write-Host "Persona       Sessao                                estado" -ForegroundColor Cyan
Write-Host "------------  ------------------------------------  ------" -ForegroundColor Cyan
$subir = @()
foreach ($p in $mapa) {
  if (JaDePe $p.nome $p.sessionId) {
    Write-Host ("{0,-13} {1}  ja de pe" -f $p.nome, $p.sessionId)
  } else {
    Write-Host ("{0,-13} {1}  SUBIR" -f $p.nome, $p.sessionId) -ForegroundColor Yellow
    $subir += $p
  }
}
Write-Host ""
Registrar ("a subir: " + $subir.Count + " de " + $mapa.Count)

if ($Conferir) { Registrar "-Conferir: nada foi subido."; exit 0 }
if ($subir.Count -eq 0) { Registrar "nada a fazer: as $($mapa.Count) ja estao de pe."; exit 0 }

Write-Host ""
$ESC = [char]27   # `e so existe no PowerShell 6+. No 5.1 vira a letra "e", e o
                  # strip de ANSI falha em silencio -- foi o que fez este laco
                  # rotular de FALHOU onze sessoes que tinham subido.
foreach ($p in $subir) {
  $antes = $ErrorActionPreference

  # PASSO 1 -- limpar registro obsoleto ANTES de acordar.
  # O roster (~/.claude/daemon/roster.json) sobrevive ao reinicio; os processos
  # nao. Nesse estado o daemon pode tentar reatar a um worker morto.
  # `claude stop` sobre sessao ja parada e inofensivo, e so chega aqui quem o
  # JaDePe nao viu na lista de processos.
  $ErrorActionPreference = 'Continue'
  & $ClaudeExe stop $p.sessionId.Substring(0,8) 2>&1 | Out-Null

  # PASSO 2 -- ACORDAR a sessao. SEM NENHUMA FLAG, e este e o ponto inteiro.
  #
  # O proprio claude explica, quando se passa flag:
  #   "background session <id> keeps its own saved options, so the flags you
  #    passed started a copy as <novo>. Without flags, the same command
  #    continues <id> itself."
  #
  # Ou seja: `-n <Nome>` NAO era inofensivo. Era ele que forkava. Cada subida
  # gerava um id novo, o mapa envelhecia a cada boot, e a copia nascia sem
  # historia. Sem flag a saida vira "woke session <id> with its saved options
  # (-n, --add-dir, --model)" -- o nome, o diretorio concedido e o modelo voltam
  # de onde ja estavam gravados. Nao ha o que repassar.
  #
  # Push-Location continua importando por outro motivo: depois de um reinicio o
  # daemon nao lembra de nada, e o `--resume <id>` so acha o transcript na pasta
  # de projeto que corresponde ao diretorio de onde se chamou. Chamar do lugar
  # errado da `bg settled <id> (crashed): source session ... not found` -- foi
  # exatamente isso que derrubou as doze no teste de logon, e o motivo estava
  # escrito no ~/.claude/daemon.log o tempo todo.
  # MODO REMOTE CONTROL, por decisao do Sergio em 14/09.
  #
  # `--bg` sobe a sessao mas ela NAO aparece no celular: a ponte com o app e o
  # identificador da conversa na nuvem, e sessao criada por script aqui nao tem
  # nenhuma. Medido em 14/09: das doze, so a Vision tinha `bridgeSessionId`, e
  # ele e identico ao endereco desta conversa no app -- ela aparece porque
  # NASCEU la, nao porque e de fundo.
  #
  # `--remote-control <Nome> --resume <id>` cria a conversa do lado do servidor:
  # mesma sessao, mesmo id, mesma historia, e a persona aparece no celular.
  # Testado na Selma em 13/09 (ida e volta completa) e nas nove em 14/09.
  #
  # `-WindowStyle Hidden` de proposito: em Remote Control a sessao vive presa ao
  # processo, nao ao terminal. Oculto ela sobrevive sem janela -- medido.
  #
  # NAO redirecionar stdout nem stderr aqui. Redirecionar tira o terminal do
  # processo, e sem terminal o claude entra no caminho headless (`--print`) --
  # que exige prompt. O resultado e esta saida, medida em 14/09 nas duas que
  # faltavam, e que custou a manha inteira:
  #
  #   Error: No deferred tool marker found in the resumed session. Either the
  #   session was not deferred, the marker is stale (tool already ran), or it
  #   exceeds the tail-scan window. Provide a prompt to continue the conversation.
  #
  # A mensagem induz ao erro: ela fala de marcador e de janela de varredura,
  # mas a causa nao esta no transcript -- esta em como o processo nasceu. No
  # binario ela vive entre as mensagens de `--print` sobre stdin e prompt, e e
  # ai que o diagnostico se fecha. Sem redirecionamento, o mesmo comando com o
  # mesmo id subiu na hora.
  #
  # Dar prompt posicional tambem NAO serve: o claude roda uma volta so, imprime
  # a resposta e sai -- a conversa aparece no celular e morre em seguida.
  #
  # Como se confere o desfecho, entao, sem ter a saida em arquivo: pelo proprio
  # processo. Se ele continua vivo depois da espera, a sessao subiu; se saiu, o
  # codigo de saida e o que se tem. A conferencia de verdade e a do fim, que le
  # as linhas de comando dos processos vivos.
  $proc = Start-Process -FilePath $ClaudeExe `
            -ArgumentList "--remote-control $($p.nome) --resume $($p.sessionId)" `
            -WorkingDirectory $p.dir -WindowStyle Hidden -PassThru
  Start-Sleep -Seconds 14
  $ErrorActionPreference = $antes
  if ($proc.HasExited) {
    $limpo = "FALHOU: processo saiu com codigo $($proc.ExitCode)"
  } else {
    $limpo = "woke session $($p.sessionId) em remote control"
  }

  # PASSO 3 -- ler a resposta. Sao tres desfechos, e so um e o certo.
  if ($limpo -match 'woke session') {
    Registrar ("  {0,-13} acordou  {1}" -f $p.nome, $p.sessionId.Substring(0,8))
  }
  elseif ($limpo -match 'started a copy as\s+([0-9a-f]{6,})') {
    # Copia sem flag nenhuma quer dizer que o id do mapa nao e um id de sessao
    # de fundo conhecida -- id curto, ou id de uma copia que ja morreu. A copia
    # nasce e o daemon a mata em segundos com "source session ... not found".
    # NAO adotar a copia no mapa: foi assim que os ids de verdade se perderam e
    # o mapa passou a apontar so para fantasmas.
    $copia = $matches[1]
    Registrar ("  {0,-13} COPIOU {1} em vez de acordar -- o id do mapa nao e o id real desta sessao" -f $p.nome, $copia)
  }
  elseif ($limpo -match 'backgrounded') {
    Registrar ("  {0,-13} subiu  {1}" -f $p.nome, $p.sessionId.Substring(0,8))
  }
  else {
    Registrar ("  {0,-13} FALHOU: {1}" -f $p.nome, (($limpo -split "`n")[0]).Trim())
  }
}

# O mapa NAO e mais reescrito por este script, e isso e de proposito.
# Acordar sem flag preserva o id, entao o mapa nao envelhece. Enquanto o script
# passava `-n <Nome>`, cada subida forkava um id novo e o script "consertava" o
# mapa gravando o id da copia -- ate o mapa inteiro apontar so para copias
# mortas e nenhum id real sobrar. O mapa e fonte, nao rascunho: se um id estiver
# errado, o -Conferir acusa e a correcao e manual.

# Conferir pelo ESTADO, e esperar o bastante.
# Uma sessao que nao acha o proprio transcript nasce e morre com atraso: no
# daemon.log o "bg settled ... (crashed)" chega de 8 a 12 segundos depois do
# "bg spawned". Conferir aos 6 segundos dava as 12 de pe e mentia.
Start-Sleep -Seconds 20

# CONFERIR PELOS DOIS INSTRUMENTOS, e o segundo nao e redundancia.
#
# `claude agents --json` ve SO as sessoes de fundo. Sessao em Remote Control se
# registra do lado do servidor e NAO entra nessa lista. Conferir so por ele,
# depois que o squad passou a subir em Remote Control, faz o script concluir que
# as doze cairam e subir doze DUPLICATAS por cima das vivas -- foi exatamente
# isso em 14/09 as 06:47: nove Remote Control e dez de fundo ao mesmo tempo,
# duas sessoes vivas sobre a mesma conversa.
$ErrorActionPreference = 'Continue'
$agJson = (& $ClaudeExe agents --json 2>$null | Out-String)
$ErrorActionPreference = 'Stop'
$vivas = @{}
try {
  foreach ($a in ($agJson | ConvertFrom-Json)) { if ($a.name) { $vivas[[string]$a.name] = $a } }
} catch {
  Registrar "ATENCAO: nao consegui ler 'claude agents --json' para conferir."
}

# Segundo instrumento: a linha de comando. E o unico que enxerga Remote Control.
$linhasFim = @(Get-CimInstance Win32_Process -Filter "Name='claude.exe'" -ErrorAction SilentlyContinue |
               ForEach-Object { $_.CommandLine } | Where-Object { $_ })
$emRC = @{}
foreach ($l in $linhasFim) {
  if ($l -match '--remote-control[= ](\S+)') { $emRC[$matches[1]] = $true }
}

$naoSubiu = @()
foreach ($p in $mapa) {
  if (-not $vivas.ContainsKey([string]$p.nome) -and -not $emRC.ContainsKey([string]$p.nome)) {
    $naoSubiu += $p.nome
  }
}
Registrar ("de pe: " + $emRC.Count + " em remote control, " + $vivas.Count + " em fundo")
Write-Host ""

# Estar viva nao basta: tem de estar viva NO DIRETORIO CERTO.
# ATENCAO ao que isto mede. O diretorio de uma sessao de fundo nao vem de onde
# o lancador rodou -- vem do `dispatch.cwd` gravado no roster quando a sessao
# NASCEU, e acordar so repete o que esta gravado. Push-Location nao muda isso.
# Consertar de verdade exige recriar a sessao (fork) no diretorio certo, o que
# troca o id. Ate la esta checagem existe para nao deixar o defeito invisivel.
$lugarErrado = @()
foreach ($p in $mapa) {
  $a = $vivas[[string]$p.nome]
  if (-not $a -or -not $a.cwd) { continue }
  $esperado = ([string]$p.dir).Replace('/','\').TrimEnd('\')
  if ($a.cwd.TrimEnd('\') -ne $esperado) {
    $lugarErrado += ("{0,-13} esta em {1}  (esperado {2})" -f $a.name, $a.cwd, $esperado)
  }
}
if ($lugarErrado.Count -gt 0) {
  Registrar ("DIRETORIO ERRADO em " + $lugarErrado.Count + " sessao(oes):")
  foreach ($e in $lugarErrado) { Registrar ("   " + $e) }
}

if ($naoSubiu.Count -eq 0) {
  Registrar ("conferido: as " + $mapa.Count + " estao de pe.")
  # NAO sugerir `claude attach` aqui: em persona de Remote Control ele sobe uma
  # SEGUNDA sessao viva sobre a mesma conversa (medido no Dante em 14/09). Quem
  # quer ver as janelas roda o abrir-squad, que derruba o processo oculto e
  # reabre o MESMO comando numa aba.
  Write-Host "Para ver as janelas: abrir-squad.ps1 -Sim   |   lista: claude agents (so as de fundo) e /agents"
  exit 0
} else {
  Registrar ("NAO subiram: " + ($naoSubiu -join ', '))
  exit 1
}
