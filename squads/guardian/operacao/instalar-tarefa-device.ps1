<#
.SINOPSE
  Registra no Agendador de Tarefas a tarefa que mantem o device e o squad
  de pe. Tres gatilhos -- no logon, ao retornar da suspensao, e a cada 30
  minutos. Rodar uma vez por maquina. E idempotente: reexecutar substitui.

.COMO USAR
  powershell -ExecutionPolicy Bypass -NoProfile -File .\instalar-tarefa-device.ps1
  -Conferir    mostra o que faria, sem registrar
  -Remover     remove a tarefa
  -Script <p>  o garantir-device.ps1 a chamar
  -Minutos <N> intervalo da repeticao (padrao 30)

.DUAS DECISOES QUE ESTAO NO CODIGO E NAO SAO NEGOCIAVEIS DE LEVE

  1. `-LogonType Interactive` -- a tarefa roda NA SESSAO DO USUARIO.
     Como servico (Sessao 0) o device subiria, mas as janelas que ele abrisse
     seriam invisiveis: pareceria funcionar e nao funcionaria.
     Consequencia aceita: apos um reinicio, o device so sobe depois do login.

  2. `-MultipleInstances IgnoreNew` -- cinto, nao suspensorio.
     Quem impede device duplicado e a CHECAGEM dentro do garantir-device.ps1,
     que olha a linha de comando dos processos. Esta politica so evita duas
     execucoes da tarefa se uma demorar; nao sabe nada sobre o device.
#>

[CmdletBinding(PositionalBinding = $false)]
param(
  [string] $Nome        = 'Guardian - manter de pe',
  [string] $Script      = 'C:\Software\GeoCloud\garantir-device.ps1',
  [string] $ScriptSquad = 'C:\Software\GeoCloud\subir-squad.ps1',
  [string] $NomeAntigo  = 'Guardian - garantir device',
  [switch] $SemSquad,
  [int]    $Minutos     = 30,
  [switch] $Remover,
  [switch] $Conferir
)

$ErrorActionPreference = 'Stop'

$existente = Get-ScheduledTask -TaskName $Nome -ErrorAction SilentlyContinue

if ($Remover) {
  if ($existente) {
    if ($Conferir) { Write-Host "-Conferir: removeria a tarefa '$Nome'."; return }
    Unregister-ScheduledTask -TaskName $Nome -Confirm:$false
    Write-Host "removida: $Nome"
  } else {
    Write-Host "nada a remover: '$Nome' nao existe."
  }
  return
}

if (-not (Test-Path -LiteralPath $Script)) {
  throw "Script nao existe: $Script  (copie o garantir-device.ps1 para la antes)"
}
$Script = (Resolve-Path -LiteralPath $Script).Path

$exe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$arg = "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File `"$Script`""

$acoes = @(New-ScheduledTaskAction -Execute $exe -Argument $arg -WorkingDirectory (Split-Path -Parent $Script))

# Segunda acao: subir as 12 sessoes de fundo. O Agendador executa as acoes em
# ORDEM, entao o device sobe primeiro -- as personas nascem com ele de pe e ja
# ficam alcancaveis do celular.
if (-not $SemSquad) {
  if (Test-Path -LiteralPath $ScriptSquad) {
    $argSquad = "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File `"$ScriptSquad`""
    $acoes += New-ScheduledTaskAction -Execute $exe -Argument $argSquad -WorkingDirectory (Split-Path -Parent $ScriptSquad)
  } else {
    Write-Warning "subir-squad.ps1 nao existe em $ScriptSquad -- a tarefa vai so manter o device."
  }
}

# Gatilho 1: no logon deste usuario.
$g1 = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"

# Gatilho 2: a cada N minutos, indefinidamente. Comeca 1 min depois do registro
# para a primeira repeticao nao coincidir com a instalacao.
# Sem -RepetitionDuration de proposito: `[TimeSpan]::MaxValue` estoura o XML
# ("Duration:P99999999DT23H59M59S ... fora do intervalo"). Duracao ausente e
# como o Agendador expressa "indefinidamente".
$g2 = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) `
        -RepetitionInterval (New-TimeSpan -Minutes $Minutos)

# Gatilho 3: ao RETORNAR DA SUSPENSAO.
#
# Suspender derruba o daemon inteiro, e com ele TODAS as sessoes de fundo de
# uma vez -- nao e uma persona que cai, e o conjunto. O log nao deixa duvida:
#   [supervisor] --- daemon start --- origin=transient
#   [bg] bg adopt: adopted=0 respawned=0 dead=12
# Aconteceu em 13/09 as 13:58: suspendeu, voltou 2s depois, e as 12 morreram.
# So a repeticao de 30 min trouxe de volta -- por sorte ela caiu 1 min depois.
# Sem este gatilho, uma suspensao logo apos uma execucao deixa o squad fora por
# quase meia hora, em silencio.
#
# `New-ScheduledTaskTrigger` nao sabe fazer gatilho por evento; e preciso
# montar o MSFT_TaskEventTrigger a mao. O evento e o mesmo que aparece no
# Visualizador: Power-Troubleshooter, id 1, "O sistema continuou apos retornar
# do modo de suspensao".
#
# O Delay nao e enfeite: no instante do evento a rede e o perfil ainda estao
# voltando, e subir 12 sessoes ali da erro intermitente e dificil de explicar.
$classeEvt = Get-CimClass -ClassName MSFT_TaskEventTrigger `
                          -Namespace Root/Microsoft/Windows/TaskScheduler
$g3 = New-CimInstance -CimClass $classeEvt -ClientOnly
$g3.Enabled      = $true
$g3.Delay        = 'PT20S'
$g3.Subscription = @'
<QueryList><Query Id="0" Path="System"><Select Path="System">*[System[Provider[@Name='Microsoft-Windows-Power-Troubleshooter'] and EventID=1]]</Select></Query></QueryList>
'@

$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" `
                                        -LogonType Interactive -RunLevel Limited

$cfg = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries `
                                    -DontStopIfGoingOnBatteries `
                                    -StartWhenAvailable `
                                    -MultipleInstances IgnoreNew `
                                    -ExecutionTimeLimit (New-TimeSpan -Minutes 10)

if ($Conferir) {
  Write-Host "-Conferir: registraria a tarefa abaixo, sem executar nada."
  Write-Host ""
  Write-Host "  nome      : $Nome"
  Write-Host "  executa   : $exe"
  Write-Host "  argumentos: $arg"
  Write-Host "  gatilho 1 : no logon de $env:USERDOMAIN\$env:USERNAME"
  Write-Host "  gatilho 2 : a cada $Minutos min, indefinidamente"
  Write-Host "  gatilho 3 : ao retornar da suspensao (Power-Troubleshooter id 1, +20s)"
  Write-Host "  sessao    : Interactive (NUNCA servico -- Sessao 0 quebra as janelas)"
  Write-Host "  instancias: IgnoreNew"
  $oQue = if ($SemSquad) { 'so o device' } else { 'device, depois squad' }
  Write-Host "  acoes     : $($acoes.Count)  ($oQue)"
  Write-Host "  ja existe : $([bool]$existente)"
  return
}

if ($existente) { Unregister-ScheduledTask -TaskName $Nome -Confirm:$false }
# A tarefa mudou de nome ao passar a cobrir o squad; remover a antiga evita
# duas tarefas fazendo a mesma coisa em horarios deslocados.
$velha = Get-ScheduledTask -TaskName $NomeAntigo -ErrorAction SilentlyContinue
if ($velha) { Unregister-ScheduledTask -TaskName $NomeAntigo -Confirm:$false; Write-Host "removida a tarefa antiga: $NomeAntigo" }

Register-ScheduledTask -TaskName $Nome -Action $acoes -Trigger @($g1, $g2, $g3) `
                       -Principal $principal -Settings $cfg `
                       -Description 'Mantem o device e as 12 sessoes do squad de pe: checa no logon, ao voltar da suspensao e a cada 30 min; o que ja estiver rodando e ignorado.' | Out-Null

# Conferir lendo de volta, nao confiar no Register.
$v = Get-ScheduledTask -TaskName $Nome -ErrorAction SilentlyContinue
if (-not $v) { throw "Register-ScheduledTask nao levantou erro, mas a tarefa nao esta la." }

Write-Host ""
Write-Host "registrada: $Nome"
Write-Host "  estado   : $($v.State)"
Write-Host "  gatilhos : $($v.Triggers.Count)"
Write-Host "  acoes    : $($v.Actions.Count)"
Write-Host "  executa  : $($v.Actions[0].Execute)"
Write-Host "  argumento: $($v.Actions[0].Arguments)"
Write-Host "  logon    : $($v.Principal.LogonType)"
Write-Host ""
Write-Host "Para testar agora:  Start-ScheduledTask -TaskName '$Nome'"
