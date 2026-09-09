<#
.SYNOPSIS
  Concatena os fragmentos CSV produzidos por lote (subagentes) em um único
  .csv multi-aba (marcadores "===== SHEET: X =====") e opcionalmente gera
  o .xlsx espelho via csv-to-xlsx.py.

.PARAMETER ProductName
  "ELIMS" (usado só para mensagens).

.PARAMETER FragmentsDir
  Pasta com os arquivos <Lote>.atributos.csv / .metodos.csv / .permissoes.csv.

.PARAMETER BatchOrder
  String com os prefixos de lote separados por vírgula, na ordem desejada (ex.: "G1,G2,G3,G4,G5").

.PARAMETER OutputCsvPath
  Caminho do .csv final consolidado.

.PARAMETER GenerateXlsx
  Se presente, roda csv-to-xlsx.py ao final.

.EXAMPLE
  powershell -File assemble-structural-spreadsheet.ps1 -ProductName ELIMS -FragmentsDir ..\ELIMS\docs\estrutura\_fragments -BatchOrder "G1,G2,G3,G4,G5" -OutputCsvPath ..\ELIMS\docs\estrutura\Account_GeoCloud_resumo_estrutural.csv -GenerateXlsx
#>
param(
    [Parameter(Mandatory = $true)][string]$ProductName,
    [Parameter(Mandatory = $true)][string]$FragmentsDir,
    [Parameter(Mandatory = $true)][string]$BatchOrder,
    [Parameter(Mandatory = $true)][string]$OutputCsvPath,
    [switch]$GenerateXlsx
)

$ErrorActionPreference = "Stop"

$BatchList = $BatchOrder -split "[,; ]+" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }

function Read-FragmentLines {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        Write-Warning "Fragmento ausente: $Path"
        return @()
    }
    return Get-Content -Path $Path -Encoding UTF8
}

$lines = @()

$lines += "===== SHEET: Atributos ====="
foreach ($batch in $BatchList) {
    $path = Join-Path $FragmentsDir "$batch.atributos.csv"
    $lines += Read-FragmentLines -Path $path
}

$lines += "===== SHEET: Metodos_Back ====="
$lines += """MÉTODOS (Back) — Controller → Service → Repository, por classe ($ProductName)."""
$lines += "Chave = permission key exigida no endpoint (ver aba Permissões). Filtro/Ordem: preencher manualmente (campos de busca/ordenação)."
foreach ($batch in $BatchList) {
    $path = Join-Path $FragmentsDir "$batch.metodos.csv"
    $lines += Read-FragmentLines -Path $path
}

$lines += "===== SHEET: Permissões ====="
$lines += "PERMISSÕES — $ProductName (rota, chave de permissão exigida, observação)"
foreach ($batch in $BatchList) {
    $path = Join-Path $FragmentsDir "$batch.permissoes.csv"
    $lines += Read-FragmentLines -Path $path
}

$outDir = Split-Path -Parent $OutputCsvPath
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Force -Path $outDir | Out-Null }
Set-Content -Path $OutputCsvPath -Value $lines -Encoding UTF8

Write-Host "OK: $OutputCsvPath ($($lines.Count) linhas)" -ForegroundColor Green

if ($GenerateXlsx) {
    $xlsxPath = [System.IO.Path]::ChangeExtension($OutputCsvPath, "xlsx")
    $scriptDir = $PSScriptRoot
    python (Join-Path $scriptDir "csv-to-xlsx.py") $OutputCsvPath $xlsxPath
}
