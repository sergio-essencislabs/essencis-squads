<#
.SINOPSE
  Registra no Agendador de Tarefas a tarefa que mantem o device de pe:
  dois gatilhos -- no logon e a cada 30 minutos -- chamando garantir-device.ps1.
  Rodar uma vez por maquina. E idempotente: reexecutar substitui a tarefa.

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
  [string] $Nome     = 'Guardian - garantir device',
  [string] $Script   = 'C:\Software\GeoCloud\garantir-device.ps1',
  [int]    $Minutos  = 30,
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

$acao = New-ScheduledTaskAction -Execute $exe -Argument $arg -WorkingDirectory (Split-Path -Parent $Script)

# Gatilho 1: no logon deste usuario.
$g1 = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"

# Gatilho 2: a cada N minutos, indefinidamente. Comeca 1 min depois do registro
# para a primeira repeticao nao coincidir com a instalacao.
# Sem -RepetitionDuration de proposito: `[TimeSpan]::MaxValue` estoura o XML
# ("Duration:P99999999DT23H59M59S ... fora do intervalo"). Duracao ausente e
# como o Agendador expressa "indefinidamente".
$g2 = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) `
        -RepetitionInterval (New-TimeSpan -Minutes $Minutos)

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
  Write-Host "  sessao    : Interactive (NUNCA servico -- Sessao 0 quebra as janelas)"
  Write-Host "  instancias: IgnoreNew"
  Write-Host "  ja existe : $([bool]$existente)"
  return
}

if ($existente) { Unregister-ScheduledTask -TaskName $Nome -Confirm:$false }

Register-ScheduledTask -TaskName $Nome -Action $acao -Trigger @($g1, $g2) `
                       -Principal $principal -Settings $cfg `
                       -Description 'Mantem o device (claude remote-control) de pe: checa no logon e a cada 30 min; se ja estiver rodando, nao faz nada.' | Out-Null

# Conferir lendo de volta, nao confiar no Register.
$v = Get-ScheduledTask -TaskName $Nome -ErrorAction SilentlyContinue
if (-not $v) { throw "Register-ScheduledTask nao levantou erro, mas a tarefa nao esta la." }

Write-Host ""
Write-Host "registrada: $Nome"
Write-Host "  estado   : $($v.State)"
Write-Host "  gatilhos : $($v.Triggers.Count)"
Write-Host "  executa  : $($v.Actions[0].Execute)"
Write-Host "  argumento: $($v.Actions[0].Arguments)"
Write-Host "  logon    : $($v.Principal.LogonType)"
Write-Host ""
Write-Host "Para testar agora:  Start-ScheduledTask -TaskName '$Nome'"
