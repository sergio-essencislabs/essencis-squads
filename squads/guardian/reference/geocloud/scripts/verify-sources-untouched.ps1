<#
.SYNOPSIS
  Garante que uma pasta de código-fonte original (ex.: GeoCloudAI,
  GeoCloudAI) não foi alterada durante uma tarefa. Captura um inventário
  de hash/tamanho/data de cada arquivo (+ git status/diff se for um repo
  git) em modo Baseline, e recompara tudo em modo Verify.

.PARAMETER Mode
  "Baseline" para capturar o estado atual, "Verify" para comparar contra
  um manifesto já capturado.

.PARAMETER SourcePath
  Caminho absoluto da pasta a proteger (ex.: C:\...\GeoCloud\GeoCloudAI).

.PARAMETER ManifestPath
  Caminho do arquivo JSON de manifesto. Deve ficar FORA de SourcePath —
  gravar dentro violaria a própria garantia de "nada foi alterado".

.EXAMPLE
  powershell -File verify-sources-untouched.ps1 -Mode Baseline -SourcePath "C:\...\GeoCloudAI" -ManifestPath "C:\...\_verification\geocloud.json"
  powershell -File verify-sources-untouched.ps1 -Mode Verify   -SourcePath "C:\...\GeoCloudAI" -ManifestPath "C:\...\_verification\geocloud.json"
#>
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Baseline", "Verify")]
    [string]$Mode,

    [Parameter(Mandatory = $true)]
    [string]$SourcePath,

    [Parameter(Mandatory = $true)]
    [string]$ManifestPath
)

$ErrorActionPreference = "Stop"

$ExcludedDirNames = @("node_modules", "bin", "obj", ".git", ".angular", "dist", "TestResults", "v7-results", ".vs")

function Get-SourceInventory {
    param([string]$Path)
    $normalized = (Resolve-Path $Path).Path
    Get-ChildItem -Path $normalized -Recurse -Force -File | Where-Object {
        $relDir = $_.DirectoryName.Substring($normalized.Length)
        $segments = $relDir -split '[\\/]'
        -not ($segments | Where-Object { $ExcludedDirNames -contains $_ })
    } | ForEach-Object {
        [PSCustomObject]@{
            RelPath          = $_.FullName.Substring($normalized.Length).TrimStart('\', '/')
            Length           = $_.Length
            LastWriteTimeUtc = $_.LastWriteTimeUtc.ToString("o")
            Hash             = (Get-FileHash -Path $_.FullName -Algorithm SHA256).Hash
        }
    }
}

function Get-ExcludedDirsSummary {
    param([string]$Path)
    $normalized = (Resolve-Path $Path).Path
    Get-ChildItem -Path $normalized -Recurse -Force -Directory | Where-Object {
        $ExcludedDirNames -contains $_.Name
    } | ForEach-Object {
        $relPath = $_.FullName.Substring($normalized.Length).TrimStart('\', '/')
        $stats = Get-ChildItem -Path $_.FullName -Recurse -Force -File -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum
        [PSCustomObject]@{
            RelPath   = $relPath
            FileCount = $stats.Count
            TotalSize = $stats.Sum
        }
    }
}

function Get-GitState {
    param([string]$Path)
    $result = [PSCustomObject]@{ IsGitRepo = $false; Status = ""; DiffStat = "" }
    if (Test-Path (Join-Path $Path ".git")) {
        $result.IsGitRepo = $true
        Push-Location $Path
        try {
            $result.Status = ((git status --porcelain) -join "`n")
            $result.DiffStat = ((git diff --stat) -join "`n")
        } finally {
            Pop-Location
        }
    }
    return $result
}

if ($Mode -eq "Baseline") {
    $inventory = Get-SourceInventory -Path $SourcePath
    $gitState = Get-GitState -Path $SourcePath

    $excludedSummary = Get-ExcludedDirsSummary -Path $SourcePath

    $manifest = [PSCustomObject]@{
        SourcePath      = (Resolve-Path $SourcePath).Path
        CapturedAt      = (Get-Date).ToString("o")
        IsGitRepo       = $gitState.IsGitRepo
        GitStatus       = $gitState.Status
        GitDiff         = $gitState.DiffStat
        ExcludedDirNames = $ExcludedDirNames
        ExcludedSummary = $excludedSummary
        FileCount       = $inventory.Count
        Files           = $inventory
    }

    $manifestDir = Split-Path -Parent $ManifestPath
    if (-not (Test-Path $manifestDir)) { New-Item -ItemType Directory -Force -Path $manifestDir | Out-Null }
    $manifest | ConvertTo-Json -Depth 6 | Set-Content -Path $ManifestPath -Encoding UTF8

    Write-Host "== Baseline capturado ==" -ForegroundColor Cyan
    Write-Host "Origem: $($manifest.SourcePath)"
    Write-Host "Arquivos: $($manifest.FileCount)"
    Write-Host "Git repo: $($manifest.IsGitRepo)"
    Write-Host "Manifesto salvo em: $ManifestPath" -ForegroundColor Green
}
elseif ($Mode -eq "Verify") {
    if (-not (Test-Path $ManifestPath)) { throw "Manifesto não encontrado: $ManifestPath — rode -Mode Baseline primeiro." }
    $baseline = Get-Content -Path $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json

    $currentInventory = Get-SourceInventory -Path $SourcePath
    $gitState = Get-GitState -Path $SourcePath
    $currentExcludedSummary = Get-ExcludedDirsSummary -Path $SourcePath

    $baselineMap = @{}
    foreach ($f in $baseline.Files) { $baselineMap[$f.RelPath] = $f }
    $currentMap = @{}
    foreach ($f in $currentInventory) { $currentMap[$f.RelPath] = $f }

    $added = @()
    $removed = @()
    $modified = @()

    foreach ($key in $currentMap.Keys) {
        if (-not $baselineMap.ContainsKey($key)) {
            $added += $key
        } elseif ($baselineMap[$key].Hash -ne $currentMap[$key].Hash) {
            $modified += $key
        }
    }
    foreach ($key in $baselineMap.Keys) {
        if (-not $currentMap.ContainsKey($key)) { $removed += $key }
    }

    $gitStatusChanged = ($baseline.GitStatus -ne $gitState.Status)
    $gitDiffChanged = ($baseline.GitDiff -ne $gitState.DiffStat)

    $excludedBaselineMap = @{}
    foreach ($e in $baseline.ExcludedSummary) { $excludedBaselineMap[$e.RelPath] = $e }
    $excludedChanges = @()
    foreach ($e in $currentExcludedSummary) {
        $b = $excludedBaselineMap[$e.RelPath]
        if ($null -eq $b) {
            $excludedChanges += "$($e.RelPath) [novo]"
        } elseif ($b.FileCount -ne $e.FileCount -or $b.TotalSize -ne $e.TotalSize) {
            $excludedChanges += "$($e.RelPath) (antes: $($b.FileCount) arquivos/$($b.TotalSize) bytes -> agora: $($e.FileCount) arquivos/$($e.TotalSize) bytes)"
        }
    }

    Write-Host "== Verificação de integridade ==" -ForegroundColor Cyan
    Write-Host "Origem: $($baseline.SourcePath)"
    Write-Host "Baseline: $($baseline.FileCount) arquivos capturados em $($baseline.CapturedAt) (excluindo $($ExcludedDirNames -join ', '))"
    Write-Host "Atual:    $($currentInventory.Count) arquivos"

    $clean = ($added.Count -eq 0) -and ($removed.Count -eq 0) -and ($modified.Count -eq 0) -and (-not $gitStatusChanged) -and (-not $gitDiffChanged) -and ($excludedChanges.Count -eq 0)

    if ($clean) {
        Write-Host "`nNENHUMA DIFERENÇA — fonte intacta." -ForegroundColor Green
        exit 0
    } else {
        Write-Host "`nDIFERENÇAS ENCONTRADAS:" -ForegroundColor Red
        if ($added.Count -gt 0)    { Write-Host "  Arquivos adicionados ($($added.Count)): $($added -join ', ')" -ForegroundColor Red }
        if ($removed.Count -gt 0) { Write-Host "  Arquivos removidos ($($removed.Count)): $($removed -join ', ')" -ForegroundColor Red }
        if ($modified.Count -gt 0){ Write-Host "  Arquivos modificados ($($modified.Count)): $($modified -join ', ')" -ForegroundColor Red }
        if ($gitStatusChanged)    { Write-Host "  git status mudou. Antes:`n$($baseline.GitStatus)`nAgora:`n$($gitState.Status)" -ForegroundColor Red }
        if ($gitDiffChanged)      { Write-Host "  git diff --stat mudou. Antes:`n$($baseline.GitDiff)`nAgora:`n$($gitState.DiffStat)" -ForegroundColor Red }
        if ($excludedChanges.Count -gt 0) { Write-Host "  Pastas excluídas (node_modules/bin/obj/etc.) com contagem/tamanho diferente: $($excludedChanges -join '; ')" -ForegroundColor Red }
        exit 1
    }
}
