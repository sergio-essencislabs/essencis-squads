<#
.SINOPSE
  Sobe o squad em SESSOES DE FUNDO -- sem janela, sem Windows Terminal.
  Cada persona volta pelo `claude --bg --resume <sessionId> -n <Nome>`.

  Para VER uma delas depois: `claude attach <id>` (ou o /start-guardian).

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

.O QUE ESTE SCRIPT NAO RESOLVE
  Sessao de fundo nao tem quem responda a um pedido de permissao. Ela fica
  parada em silencio ate alguem atender -- do celular, ou dando attach. E o
  risco operacional deste desenho, e nao ha conserto dentro do script.
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
# A original esta viva NESTE momento, no processo local? E a unica fonte que
# sabe a verdade depois de um reinicio -- o servico pode achar que sim e estar
# olhando registro obsoleto.
# ATENCAO ao criterio: procurar o id em QUALQUER posicao da linha e circular.
# A COPIA carrega `--resume <id-da-original>` na propria linha de comando, entao
# "achei o id" acha a copia e conclui que a original esta viva. Foi assim que o
# primeiro conserto apagou a copia e deixou a persona fora.
#
# A marca de uma sessao VIVA e `--session-id <id>`: o id que ela E, nao o que
# ela retomou.
function ProcessoVivo([string]$sid) {
  if (-not $sid) { return $false }
  $agora = @(Get-CimInstance Win32_Process -Filter "Name='claude.exe'" -ErrorAction SilentlyContinue |
             ForEach-Object { $_.CommandLine } | Where-Object { $_ })
  foreach ($l in $agora) {
    if ($l -match ("--session-id\s+" + [regex]::Escape($sid) + "(\s|$)")) { return $true }
  }
  return $false
}

$mapaMudou = $false
foreach ($p in $subir) {
  $antes = $ErrorActionPreference

  # PASSO 1 -- limpar registro obsoleto ANTES de tentar retomar.
  # Depois de um reinicio os processos morrem, mas o servico ainda pode
  # considerar a sessao "rodando". Nesse estado o --resume nao retoma: cria uma
  # COPIA. Foi o que derrubou o teste de logon -- as doze viraram copia, e o
  # conserto anterior apagava a copia deixando de pe uma "original" inexistente.
  # `claude stop` sobre sessao ja parada e inofensivo.
  $ErrorActionPreference = 'Continue'
  & $ClaudeExe stop $p.sessionId.Substring(0,8) 2>&1 | Out-Null

  # PASSO 2 -- retomar.
  try {
    $saida = & $ClaudeExe --bg --resume $p.sessionId -n $p.nome --add-dir $p.dir 2>&1
  } finally {
    $ErrorActionPreference = $antes
  }
  $limpo = ($saida | Out-String) -replace ([regex]::Escape($ESC) + '\[[0-9;]*[a-zA-Z]'), ''

  # PASSO 3 -- se AINDA assim veio copia, decidir MEDINDO, nao acreditando.
  if ($limpo -match 'started a copy as\s+([0-9a-f]{6,})') {
    $copia = $matches[1]
    Start-Sleep -Seconds 2
    if (ProcessoVivo $p.sessionId) {
      # A original existe de verdade: a copia e que sobra.
      $ErrorActionPreference = 'Continue'
      & $ClaudeExe stop $copia 2>&1 | Out-Null
      & $ClaudeExe rm   $copia 2>&1 | Out-Null
      $ErrorActionPreference = $antes
      Registrar ("  {0,-13} ja estava viva de verdade; copia {1} removida" -f $p.nome, $copia)
    } else {
      # "Ja esta rodando" era afirmacao do servico sobre um processo que nao
      # existe. A copia E a sessao desta persona agora -- ela fica, e o mapa
      # passa a apontar para ela. Apagar a copia aqui deixaria a persona FORA.
      $p.sessionId = $copia
      $mapaMudou = $true
      Registrar ("  {0,-13} registro obsoleto: a original nao existe. A copia {1} FICA e vira a sessao desta persona" -f $p.nome, $copia)
    }
    continue
  }

  if ($limpo -match 'backgrounded') {
    $curto = if ($limpo -match '([0-9a-f]{8})') { $matches[1] } else { $p.sessionId.Substring(0,8) }
    Registrar ("  {0,-13} subiu  id={1}" -f $p.nome, $curto)
  } else {
    Registrar ("  {0,-13} FALHOU: {1}" -f $p.nome, (($limpo -split "`n")[0]).Trim())
  }
}

# Se algum id mudou, o mapa em disco ficou velho. Gravar agora: deixar para
# depois faz o proximo boot repetir o mesmo caminho de copia.
if ($mapaMudou) {
  try {
    # RELER o arquivo e alterar so as personas tocadas. Escrever $mapa direto
    # APAGA as demais quando se usou -Apenas -- ja aconteceu: uma execucao com
    # `-Apenas rui,dante` deixou o mapa com 2 entradas em vez de 12.
    $atualCru = Get-Content -LiteralPath $Sessoes -Raw -Encoding UTF8 | ConvertFrom-Json
    $todas = @(); foreach ($x in $atualCru) { $todas += $x }

    # Guardar o id COMPLETO, nao o curto que a nota do claude imprime: o mapa e
    # a entrada do --resume, e id curto ali nao e o mesmo identificador.
    $vivas = @{}
    $ErrorActionPreference = 'Continue'
    $ag = (& $ClaudeExe agents --json 2>$null | Out-String)
    $ErrorActionPreference = 'Stop'
    try {
      foreach ($a in ($ag | ConvertFrom-Json)) { if ($a.name) { $vivas[[string]$a.name] = [string]$a.sessionId } }
    } catch {
      Registrar "ATENCAO: nao consegui ler os ids completos por 'claude agents --json'."
    }

    $tocadas = @($subir | ForEach-Object { $_.nome })
    $n = 0
    foreach ($t in $todas) {
      if ($tocadas -notcontains $t.nome) { continue }
      $completo = $vivas[[string]$t.nome]
      if ($completo -and $completo -ne $t.sessionId) {
        Registrar ("  mapa: {0,-13} {1} -> {2}" -f $t.nome, $t.sessionId.Substring(0,8), $completo.Substring(0,8))
        $t.sessionId = $completo
        $t.ultima_atividade = (Get-Date -Format 'yyyy-MM-dd HH:mm')
        $n++
      }
    }
    if ($n -gt 0) {
      ($todas | ConvertTo-Json -Depth 5) | Set-Content -LiteralPath $Sessoes -Encoding UTF8
      Registrar ("mapa atualizado: $n de $($todas.Count) entradas; as outras preservadas")
    } else {
      Registrar "mapa nao precisou mudar (ids completos ja conferem)"
    }
  } catch {
    Registrar ("ATENCAO: ids mudaram e NAO consegui gravar o mapa: " + $_.Exception.Message)
  }
}

# Conferir pelo estado, nao pelo que o laco imprimiu.
Start-Sleep -Seconds 6
$linhas2 = @(Get-CimInstance Win32_Process -Filter "Name='claude.exe'" -ErrorAction SilentlyContinue |
             ForEach-Object { $_.CommandLine } | Where-Object { $_ })
$naoSubiu = @()
foreach ($p in $mapa) {
  $achou = $false
  foreach ($l in $linhas2) {
    if ($l -match ("-n\s+" + [regex]::Escape($p.nome) + "(\s|$)")) { $achou = $true; break }
    if ($p.sessionId -and $l -like ("*" + $p.sessionId + "*"))      { $achou = $true; break }
  }
  if (-not $achou) { $naoSubiu += $p.nome }
}
Write-Host ""
if ($naoSubiu.Count -eq 0) {
  Registrar ("conferido: as " + $mapa.Count + " estao de pe.")
  Write-Host "Para ver uma delas: claude attach <id>   |   lista: claude agents"
  exit 0
} else {
  Registrar ("NAO subiram: " + ($naoSubiu -join ', '))
  exit 1
}
