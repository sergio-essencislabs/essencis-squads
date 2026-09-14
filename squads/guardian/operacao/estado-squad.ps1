<#
Consolida numa tela só o que hoje eu (Vision) checava com 3-4 comandos
separados a cada vez -- e era exatamente nessa repetição que eu errava
medição. Só leitura: não sobe, não derruba, não edita nada.

Cobre:
  - cada persona do sessoes.json: viva? tokens? model/effort/autocompact?
    ultima atividade?
  - device (Remote Control)
  - ultima execucao da tarefa agendada "Guardian - manter de pe"
  - RAM livre
  - inconsistencias entre sessoes.json e os processos/jobs reais

Uso:
  powershell -ExecutionPolicy Bypass -NoProfile -File C:\Software\GeoCloud\estado-squad.ps1
#>

[CmdletBinding(PositionalBinding = $false)]
param(
  [string] $Sessoes = 'C:\Software\GeoCloud\sessoes.json',
  [string] $JobsDir = "$env:USERPROFILE\.claude\jobs"
)

$ErrorActionPreference = 'Continue'

function Ler-Json($caminho) {
  if (-not (Test-Path -LiteralPath $caminho)) { return $null }
  try { return Get-Content -LiteralPath $caminho -Raw -Encoding UTF8 | ConvertFrom-Json }
  catch { return $null }
}

# --- linhas de comando dos processos vivos, uma vez so -----------------------
$linhas = @(Get-CimInstance Win32_Process -Filter "Name='claude.exe'" -ErrorAction SilentlyContinue |
            ForEach-Object { $_.CommandLine } | Where-Object { $_ })

function Vivo([string]$nome) {
  foreach ($l in $linhas) {
    if ($l -match ("-n\s+" + [regex]::Escape($nome) + "(\s|$)")) { return 'fundo' }
    if ($l -match ("--remote-control[= ]" + [regex]::Escape($nome) + "(\s|$)")) { return 'remote control' }
  }
  return $null
}

$deviceVivo = @($linhas | Where-Object { $_ -match '(?<!-)remote-control' }).Count -gt 0

# --- cabecalho ----------------------------------------------------------------
Write-Host ""
Write-Host ("=" * 78) -ForegroundColor DarkGray
Write-Host ("  ESTADO DO SQUAD GUARDIAN -- " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) -ForegroundColor Cyan
Write-Host ("=" * 78) -ForegroundColor DarkGray

# --- RAM ------------------------------------------------------------------
$os = Get-CimInstance Win32_OperatingSystem
$totGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
$livGB = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
$pct = [math]::Round(100 * $livGB / $totGB)
$corRam = if ($pct -lt 15) { 'Red' } elseif ($pct -lt 30) { 'Yellow' } else { 'Green' }
Write-Host ("RAM livre: {0} GB de {1} GB ({2}%)" -f $livGB, $totGB, $pct) -ForegroundColor $corRam

# --- device -----------------------------------------------------------------
$corDevice = if ($deviceVivo) { 'Green' } else { 'Red' }
Write-Host ("Device (Remote Control server): " + $(if ($deviceVivo) { 'de pe' } else { 'FORA' })) -ForegroundColor $corDevice

# --- tarefa agendada ---------------------------------------------------------
try {
  $tarefa = Get-ScheduledTask -TaskName 'Guardian - manter de pe' -ErrorAction Stop
  $info = Get-ScheduledTaskInfo -TaskName 'Guardian - manter de pe'
  $corTarefa = if ($info.LastTaskResult -eq 0) { 'Green' } else { 'Red' }
  Write-Host ("Tarefa agendada: ultima execucao {0}  resultado={1}  proxima={2}" -f `
    $info.LastRunTime, $info.LastTaskResult, $info.NextRunTime) -ForegroundColor $corTarefa
} catch {
  Write-Host "Tarefa agendada 'Guardian - manter de pe': NAO ENCONTRADA" -ForegroundColor Red
}

Write-Host ""
Write-Host ("{0,-10} {1,-8} {2,-14} {3,-16} {4,-9} {5,10}  {6}" -f `
  'Persona', 'Estado', 'Modelo', 'Effort/Autocmp', 'Tokens', 'Ult.ativ.', 'SessionId') -ForegroundColor Cyan
Write-Host ("-" * 100) -ForegroundColor DarkGray

# NAO envolver com @() aqui. `ConvertFrom-Json` de um array JSON emite UM
# objeto agregado pelo pipeline (nao um por item) -- e `@(...)` ao redor de um
# pipeline que emite um unico objeto ACRESCENTA um nivel de array em vez de
# proteger, aninhando as onze personas dentro de um unico elemento. Medido:
# custou uma rodada de depuracao (`$p` do loop virava as onze de uma vez).
# `[array]` e o cast idempotente certo -- se ja for array, mantem; se vier um
# unico objeto (arquivo com 1 persona so), envolve.
$mapa = [array](Get-Content -LiteralPath $Sessoes -Raw -Encoding UTF8 | ConvertFrom-Json)
$naoAchados = @()

foreach ($p in $mapa) {
  if (-not $p) { continue }
  $short = $p.sessionId.Substring(0, 8)
  $estado = Vivo $p.nome
  $jobPath = Join-Path $JobsDir "$short\state.json"
  $job = Ler-Json $jobPath

  if (-not $estado) {
    # aposentada nao e falha -- so relatamos o que o job sabe
    $estado = 'aposentada'
  }

  $modelo = '?'; $effort = '?'; $autocmp = '?'; $tokens = '?'; $ultima = '?'
  if ($job) {
    $flags = @($job.respawnFlags)
    for ($i = 0; $i -lt $flags.Count; $i++) {
      if ($flags[$i] -eq '--model' -and ($i + 1) -lt $flags.Count) { $modelo = $flags[$i + 1] }
      if ($flags[$i] -eq '--effort' -and ($i + 1) -lt $flags.Count) { $effort = $flags[$i + 1] }
      if ($flags[$i] -eq '--autocompact' -and ($i + 1) -lt $flags.Count) { $autocmp = $flags[$i + 1] }
    }
    if ($job.tokens) { $tokens = $job.tokens }
    if ($job.updatedAt) {
      try { $ultima = ([datetime]$job.updatedAt).ToString('MM-dd HH:mm') } catch { $ultima = $job.updatedAt }
    }
  } else {
    $naoAchados += $p.nome
  }

  $efAc = "$effort / $autocmp"
  $cor = switch ($estado) {
    'fundo'          { 'Green' }
    'remote control' { 'Yellow' }
    default          { 'DarkGray' }
  }
  $tokensFmt = if ($tokens -match '^\d+$') { '{0:N0}' -f [double]$tokens } else { $tokens }
  Write-Host ("{0,-10} {1,-8} {2,-14} {3,-16} {4,10}  {5,-9}  {6}" -f `
    $p.nome, $estado, $modelo, $efAc, $tokensFmt, $ultima, $short) -ForegroundColor $cor
}

Write-Host ("-" * 100) -ForegroundColor DarkGray

# --- inconsistencias ----------------------------------------------------------
$avisos = @()
if ($naoAchados.Count -gt 0) {
  $avisos += "sem job em disco (nunca rodou nesta maquina, ou id do sessoes.json esta errado): " + ($naoAchados -join ', ')
}
# processos vivos que NAO estao no sessoes.json
$nomesMapa = @($mapa | ForEach-Object { $_.nome })
$nomesVivos = @()
foreach ($l in $linhas) {
  if ($l -match '-n\s+(\S+)') { $nomesVivos += $matches[1] }
  elseif ($l -match '--remote-control[= ](\S+)') { $nomesVivos += $matches[1] }
}
$orfaos = @($nomesVivos | Sort-Object -Unique | Where-Object { $nomesMapa -notcontains $_ })
if ($orfaos.Count -gt 0) {
  $avisos += "processo vivo com nome fora do sessoes.json (orfao?): " + ($orfaos -join ', ')
}

if ($avisos.Count -gt 0) {
  Write-Host ""
  Write-Host "AVISOS:" -ForegroundColor Yellow
  foreach ($a in $avisos) { Write-Host ("  - " + $a) -ForegroundColor Yellow }
}

Write-Host ""
Write-Host "Nota sobre 'Tokens': e o contador do job (~/.claude/jobs/<id>/state.json)." -ForegroundColor DarkGray
Write-Host "Nao confirmado se e o tamanho da janela agora ou acumulado ao longo da vida" -ForegroundColor DarkGray
Write-Host "da sessao -- ver memoria guardian-contexto-clear-vs-autocompact." -ForegroundColor DarkGray
Write-Host ""
