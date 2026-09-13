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
  [string]   $ClaudeExe = ''
)

$ErrorActionPreference = 'Stop'

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
    if ($sid -and $l -like ("*" + $sid + "*"))                   { return $true }
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
Write-Host ("a subir: " + $subir.Count + " de " + $mapa.Count)

if ($Conferir) { Write-Host "-Conferir: nada foi subido."; return }
if ($subir.Count -eq 0) { Write-Host "nada a fazer."; return }

Write-Host ""
foreach ($p in $subir) {
  $saida = & $ClaudeExe --bg --resume $p.sessionId -n $p.nome --add-dir $p.dir 2>&1
  $id = ($saida | Out-String) -replace "`e\[[0-9;]*[a-zA-Z]", ''
  if ($id -match 'backgrounded[^\w]*([0-9a-f]{6,})') {
    Write-Host ("  {0,-13} subiu  id={1}" -f $p.nome, $matches[1]) -ForegroundColor Green
  } else {
    Write-Host ("  {0,-13} FALHOU: {1}" -f $p.nome, (($id -split "`n")[0]).Trim()) -ForegroundColor Red
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
  Write-Host ("conferido: as " + $mapa.Count + " estao de pe.") -ForegroundColor Green
} else {
  Write-Host ("NAO subiram: " + ($naoSubiu -join ', ')) -ForegroundColor Red
}
Write-Host "Para ver uma delas: claude attach <id>   |   lista: claude agents"
