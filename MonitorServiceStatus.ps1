# Monitor Windows Service Status on Multiple Servers
# Checks if critical services are running

param(
    [Parameter(Mandatory=$true)]
    [string[]]$ComputerNames,
    [string[]]$ServiceNames = @('WinRM', 'BITS', 'EventLog', 'spooler')
)

$serviceStatus = @()

ForEach ($computer in $ComputerNames) {
    try {
        ForEach ($service in $ServiceNames) {
            $svc = Get-Service -Name $service -ComputerName $computer -ErrorAction SilentlyContinue
            
            if ($svc) {
                $serviceStatus += [PSCustomObject]@{
                    ComputerName = $computer
                    ServiceName = $service
                    Status = $svc.Status
                    StartType = $svc.StartType
                    Healthy = $svc.Status -eq 'Running' -and $svc.StartType -eq 'Automatic'
                }
            } else {
                Write-Warning "Service $service not found on $computer"
            }
        }
    } catch {
        Write-Warning "Failed to connect to $computer : $_"
    }
}

$serviceStatus | Format-Table -AutoSize

# Alert on unhealthy services
$unhealthy = $serviceStatus | Where-Object {-not $_.Healthy}
if ($unhealthy) {
    Write-Warning "Unhealthy services detected:`n$($unhealthy | Format-Table -AutoSize | Out-String)"
}
