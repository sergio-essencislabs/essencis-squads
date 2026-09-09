<#
.SYNOPSIS
  Sincroniza elims-ai-framework/policies e elims-ai-framework/skills (fonte versionada) para
  o .cursor/rules e .cursor/skills de cada repositório de produto consumidor
  (deploy ativo do Cursor). Também gera wrappers curtos para os agentes em
  .cursor/skills/agent-<nome>/SKILL.md.

  O produto é aberto em sua própria janela do
  Cursor, como repositório independente — por isso o .cursor/ é gerado dentro
  de CADA UM deles (e não mais só em ELIMS/ELIMS/.cursor), para que o Cursor
  encontre as rules/skills mesmo sem o framework estar aberto como workspace.

  Ver ADR-0001 (knowledge/decisions/0001-skills-e-rules-nativas-do-cursor.md):
  .cursor/ nunca é editado manualmente — sempre gerado por este script.

.PARAMETER DeployTarget
  Sobrescreve $deployTargets com um ou mais caminhos. Serve para sincronizar um
  checkout que foi movido/renomeado sem precisar editar este script.

  Nao chamar este parametro de $Target: o loop no fim do script usa $target, e
  variavel em PowerShell e case-insensitive -- o loop sobrescreveria o
  parametro, e o tipo [string[]] reconverteria o valor em array, quebrando a
  chamada de Sync-CursorTarget.

.EXAMPLE
  pwsh ./sync-cursor.ps1

.EXAMPLE
  pwsh ./sync-cursor.ps1 -DeployTarget "C:\Software\ELIMS\ELIMS"
#>
param(
    [string[]]$DeployTarget
)

$ErrorActionPreference = "Stop"

$frameworkRoot = Split-Path -Parent $PSScriptRoot
# Raiz que contem o framework e as pastas de produto lado a lado (hoje
# C:\Software). Derivada, nao hardcodada: o conjunto ja saiu de Documents\ uma
# vez, e um caminho fixo aqui falha em silencio -- o Test-Path dentro de
# Sync-CursorTarget apenas avisa e faz return, entao o script termina dizendo
# "Sync completo" sem ter copiado nada.
$reposRoot = Split-Path -Parent $frameworkRoot

# Repositórios de produto que consomem o framework, cada um aberto em sua
# própria janela do Cursor. Adicionar aqui qualquer novo produto que passe a
# consumir o elims-ai-framework.
#
# A pasta e ELIMS\ELIMS -- sem o sufixo "_Replit" que este script usava antes.
# O repo e github.com/Essencis-Labs/ELIMS e o checkout local perdeu o sufixo na
# mudanca para C:\Software; o alvo antigo apontava para pasta inexistente.
$deployTargets = @(
    (Join-Path $reposRoot "ELIMS\ELIMS")
)

if ($DeployTarget) { $deployTargets = $DeployTarget }

foreach ($t in $deployTargets) {
    if (-not (Test-Path $t)) {
        Write-Warning "Destino inexistente: $t"
        Write-Warning "Se a pasta do produto foi renomeada/movida, corrija `$deployTargets antes de confiar neste sync."
    }
}

function Sync-CursorTarget {
    param(
        [Parameter(Mandatory = $true)][string]$FrameworkRoot,
        [Parameter(Mandatory = $true)][string]$TargetRoot
    )

    if (-not (Test-Path $TargetRoot)) {
        Write-Warning "Destino não encontrado, pulando: $TargetRoot"
        return
    }

    Write-Host "`n== Framework Sync -> $TargetRoot ==" -ForegroundColor Cyan

    $cursorRules = Join-Path $TargetRoot ".cursor\rules"
    $cursorSkills = Join-Path $TargetRoot ".cursor\skills"
    New-Item -ItemType Directory -Force -Path $cursorRules | Out-Null
    New-Item -ItemType Directory -Force -Path $cursorSkills | Out-Null

    # 1. Policies -> Rules (.mdc)
    $policiesDir = Join-Path $FrameworkRoot "policies"
    $policyFiles = Get-ChildItem -Path $policiesDir -Filter "*.md"
    $syncedRules = @()
    foreach ($file in $policyFiles) {
        $destName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name) + ".mdc"
        $destPath = Join-Path $cursorRules $destName
        Copy-Item -Path $file.FullName -Destination $destPath -Force
        $syncedRules += $destName
        Write-Host "  rule  <- $($file.Name)"
    }

    # 2. Skills -> .cursor/skills (copy full folder, verbatim)
    $skillsDir = Join-Path $FrameworkRoot "skills"
    $syncedSkills = @()
    Get-ChildItem -Path $skillsDir -Directory | ForEach-Object {
        $skillName = $_.Name
        $destDir = Join-Path $cursorSkills $skillName
        New-Item -ItemType Directory -Force -Path $destDir | Out-Null
        Copy-Item -Path (Join-Path $_.FullName "*") -Destination $destDir -Recurse -Force
        $syncedSkills += $skillName
        Write-Host "  skill <- $skillName"
    }

    # 3. Agents -> thin wrapper skills (disable-model-invocation: true)
    $agentsDir = Join-Path $FrameworkRoot "agents"
    $syncedAgents = @()
    Get-ChildItem -Path $agentsDir -Filter "*.md" | ForEach-Object {
        $agentSlug = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
        $skillName = "agent-$agentSlug"
        $destDir = Join-Path $cursorSkills $skillName
        New-Item -ItemType Directory -Force -Path $destDir | Out-Null

        # Extrai a linha "Missão" do agente para compor a descrição do wrapper.
        $content = Get-Content -Path $_.FullName -Raw -Encoding UTF8
        $agentTitle = ($content -split "`n" | Where-Object { $_ -match '^# ' } | Select-Object -First 1) -replace '^# ', ''
        if (-not $agentTitle) { $agentTitle = $agentSlug }

        $relativePath = "elims-ai-framework/agents/$($_.Name)"
        $wrapper = @"
---
name: $skillName
description: Assume a persona "$agentTitle" do framework ELIMS. Use quando o usuário pedir explicitamente para agir como este agente, ou quando outro agente encaminhar uma tarefa para esta persona.
disable-model-invocation: true
---

# $agentTitle (wrapper)

Leia a especificação completa em ``$relativePath`` (Missão, Objetivo, Responsabilidades, Entradas, Saídas, Fluxo interno, Critérios, Limitações, Integrações, Checklist, Formato de resposta, Critérios de qualidade) antes de responder, e siga-a integralmente para esta tarefa.
"@
        Set-Content -Path (Join-Path $destDir "SKILL.md") -Value $wrapper -Encoding UTF8
        $syncedAgents += $skillName
        Write-Host "  agent <- $agentSlug (wrapper)"
    }

    # 4. Reporta arquivos em .cursor/ sem fonte correspondente (candidatos a remoção manual)
    Write-Host "-- Verificando artefatos órfãos --" -ForegroundColor DarkCyan
    Get-ChildItem -Path $cursorRules -Filter "*.mdc" -ErrorAction SilentlyContinue | ForEach-Object {
        if ($syncedRules -notcontains $_.Name) {
            Write-Warning "Rule sem fonte em policies/: $($_.Name) — revisar remoção manual."
        }
    }
    $expectedSkillDirs = $syncedSkills + $syncedAgents
    Get-ChildItem -Path $cursorSkills -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        if ($expectedSkillDirs -notcontains $_.Name) {
            Write-Warning "Skill sem fonte em skills/ ou agents/: $($_.Name) — revisar remoção manual."
        }
    }

    Write-Host "Sincronizado: $($syncedRules.Count) rules, $($syncedSkills.Count) skills, $($syncedAgents.Count) agent wrappers." -ForegroundColor Green
}

foreach ($target in $deployTargets) {
    Sync-CursorTarget -FrameworkRoot $frameworkRoot -TargetRoot $target
}

Write-Host "`n== Sync completo para $($deployTargets.Count) destino(s) ==" -ForegroundColor Green
