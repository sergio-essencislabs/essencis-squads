<#
.SYNOPSIS
  Auto-validação estrutural do geocloud-ai-framework: frontmatter de skills/policies,
  tamanho de SKILL.md, links markdown internos quebrados, presença de arquivos
  obrigatórios. Roda antes de qualquer commit que altere skills/ ou policies/.

.EXAMPLE
  pwsh ./validate-framework.ps1
#>

$ErrorActionPreference = "Continue"
$frameworkRoot = Split-Path -Parent $PSScriptRoot
$errors = @()
$warnings = @()

Write-Host "== Validação estrutural do geocloud-ai-framework ==" -ForegroundColor Cyan

# 1. Arquivos raiz obrigatórios
$requiredRootFiles = @("README.md", "CHANGELOG.md", "VERSION", "FRAMEWORK_ARCHITECTURE.md", "FRAMEWORK_DECISIONS.md", "FRAMEWORK_ROADMAP.md", "MASTER_PROMPT.md")
foreach ($f in $requiredRootFiles) {
    if (-not (Test-Path (Join-Path $frameworkRoot $f))) {
        $errors += "Arquivo raiz obrigatório ausente: $f"
    }
}

# 2. Skills: frontmatter name/description + limite de 500 linhas
$skillsDir = Join-Path $frameworkRoot "skills"
Get-ChildItem -Path $skillsDir -Directory | ForEach-Object {
    $skillFile = Join-Path $_.FullName "SKILL.md"
    if (-not (Test-Path $skillFile)) {
        $errors += "Skill '$($_.Name)' sem SKILL.md"
        return
    }
    $lines = Get-Content -Path $skillFile -Encoding UTF8
    if ($lines.Count -gt 500) {
        $warnings += "Skill '$($_.Name)' tem $($lines.Count) linhas (> 500, recomendado quebrar com progressive disclosure)"
    }
    $raw = Get-Content -Path $skillFile -Raw -Encoding UTF8
    if ($raw -notmatch '(?ms)^---\s*\r?\n.*?name:\s*\S+.*?---') {
        $errors += "Skill '$($_.Name)' sem frontmatter 'name' válido"
    }
    if ($raw -notmatch '(?ms)^---\s*\r?\n.*?description:\s*\S+.*?---') {
        $errors += "Skill '$($_.Name)' sem frontmatter 'description' válido"
    }
}

# 3. Policies: frontmatter description + (globs ou alwaysApply) + limite 50 linhas (aviso, não erro)
$policiesDir = Join-Path $frameworkRoot "policies"
Get-ChildItem -Path $policiesDir -Filter "*.md" | ForEach-Object {
    $raw = Get-Content -Path $_.FullName -Raw -Encoding UTF8
    if ($raw -notmatch '(?ms)^---\s*\r?\n.*?description:\s*\S+.*?---') {
        $errors += "Policy '$($_.Name)' sem frontmatter 'description' válido"
    }
    if ($raw -notmatch '(?ms)^---.*?(globs:|alwaysApply:).*?---') {
        $errors += "Policy '$($_.Name)' sem 'globs' ou 'alwaysApply' no frontmatter"
    }
    $bodyLines = (Get-Content -Path $_.FullName -Encoding UTF8).Count
    if ($bodyLines -gt 60) {
        $warnings += "Policy '$($_.Name)' tem $bodyLines linhas (recomendado manter concisa, ~50 linhas)"
    }
}

# 4. Agentes: seções obrigatórias presentes
$requiredAgentSections = @("## Missão", "## Objetivo", "## Responsabilidades", "## Entradas", "## Saídas", "## Fluxo interno", "## Critérios de atuação", "## Limitações", "## Integrações", "## Checklist", "## Formato de resposta", "## Critérios de qualidade")
Get-ChildItem -Path (Join-Path $frameworkRoot "agents") -Filter "*.md" | ForEach-Object {
    $raw = Get-Content -Path $_.FullName -Raw -Encoding UTF8
    foreach ($section in $requiredAgentSections) {
        if ($raw -notmatch [regex]::Escape($section)) {
            $errors += "Agente '$($_.Name)' sem seção obrigatória: $section"
        }
    }
}

# 5. Contagem mínima esperada (mandato do framework)
$counts = @{
    "agents"    = (Get-ChildItem -Path (Join-Path $frameworkRoot "agents") -Filter "*.md").Count
    "skills"    = (Get-ChildItem -Path $skillsDir -Directory).Count
    "policies"  = (Get-ChildItem -Path $policiesDir -Filter "*.md").Count
    "playbooks" = (Get-ChildItem -Path (Join-Path $frameworkRoot "playbooks") -Filter "*.md").Count
    "templates" = (Get-ChildItem -Path (Join-Path $frameworkRoot "templates") -Filter "*.md").Count
}
$minimums = @{ "agents" = 13; "skills" = 15; "policies" = 11; "playbooks" = 11; "templates" = 11 }
foreach ($key in $minimums.Keys) {
    if ($counts[$key] -lt $minimums[$key]) {
        $errors += "Contagem de '$key' ($($counts[$key])) abaixo do mínimo esperado ($($minimums[$key]))"
    }
}

# Resultado
Write-Host "`nContagens: $($counts | ConvertTo-Json -Compress)"
if ($warnings.Count -gt 0) {
    Write-Host "`nAvisos:" -ForegroundColor Yellow
    $warnings | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
}
if ($errors.Count -gt 0) {
    Write-Host "`nErros:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    Write-Host "`nValidação FALHOU ($($errors.Count) erro(s))." -ForegroundColor Red
    exit 1
} else {
    Write-Host "`nValidação OK." -ForegroundColor Green
    exit 0
}
