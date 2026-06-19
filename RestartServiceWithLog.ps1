# Purpose: Restart a service and log before/after status.
param(
    [Parameter(Mandatory=$true)]
    [string]$ServiceName
)

$log = ".\ServiceRestart.log"
$before = Get-Service -Name $ServiceName -ErrorAction Stop
Add-Content $log "$(Get-Date) BEFORE: $ServiceName is $($before.Status)"

Restart-Service -Name $ServiceName -Force -ErrorAction Stop
# Brief delay lets SCM update service state before re-checking.
Start-Sleep -Seconds 2

$after = Get-Service -Name $ServiceName
Add-Content $log "$(Get-Date) AFTER: $ServiceName is $($after.Status)"
Write-Host "Logged to ServiceRestart.log"