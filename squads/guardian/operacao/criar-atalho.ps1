<#
.SINOPSE
  Cria um atalho na area de trabalho que dispara o abrir-squad.ps1.
  Rodar uma vez por maquina; depois disso a recuperacao e um duplo clique.

.COMO USAR
  powershell -ExecutionPolicy Bypass -File .\criar-atalho.ps1

  -Script <caminho>  o abrir-squad.ps1 a chamar
                     (padrao: o que estiver ao lado deste arquivo)
  -Nome <texto>      nome do atalho (padrao: 'Abrir squad')
  -Destino <pasta>   onde criar (padrao: a area de trabalho do usuario)

.POR QUE ELE LE O ATALHO DE VOLTA
  O Save() do WScript.Shell nao levanta erro quando grava um alvo que nao
  existe: o atalho fica la, quebrado, com cara de pronto. Entao o script
  confere o alvo NO DISCO depois de salvar, e imprime o que leu.
#>

[CmdletBinding(PositionalBinding = $false)]
param(
  [string] $Script,
  [string] $Nome    = 'Abrir squad',
  [string] $Destino
)

$ErrorActionPreference = 'Stop'

if (-not $Script) {
  $Script = Join-Path $PSScriptRoot 'abrir-squad.ps1'
}
if (-not $Destino) {
  $Destino = [Environment]::GetFolderPath('Desktop')
}

if (-not (Test-Path -LiteralPath $Script)) {
  throw "Script nao existe: $Script"
}
if (-not (Test-Path -LiteralPath $Destino)) {
  throw "Pasta de destino nao existe: $Destino"
}

$Script = (Resolve-Path -LiteralPath $Script).Path
$alvo   = Join-Path $Destino "$Nome.lnk"

$ws  = New-Object -ComObject WScript.Shell
$lnk = $ws.CreateShortcut($alvo)
$lnk.TargetPath       = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$lnk.Arguments        = "-ExecutionPolicy Bypass -NoProfile -File `"$Script`""
$lnk.WorkingDirectory = Split-Path -Parent $Script
$lnk.IconLocation     = (Join-Path $env:SystemRoot 'System32\imageres.dll') + ',76'
$lnk.Description      = 'Reabre as janelas do squad e a aba do device (Remote Control)'
$lnk.Save()

# Conferir lendo do disco: Save() nao acusa alvo inexistente.
if (-not (Test-Path -LiteralPath $alvo)) { throw "Save() nao levantou erro, mas o atalho nao esta la: $alvo" }
$v = $ws.CreateShortcut($alvo)

Write-Host ""
Write-Host "atalho    : $alvo"
Write-Host "alvo      : $($v.TargetPath)"
Write-Host "argumentos: $($v.Arguments)"
Write-Host "pasta     : $($v.WorkingDirectory)"
Write-Host ""
if (-not (Test-Path -LiteralPath $v.TargetPath)) {
  Write-Warning "O alvo do atalho NAO existe neste caminho. O atalho esta quebrado."
} else {
  Write-Host "Conferido no disco: o alvo existe." -ForegroundColor Green
}
