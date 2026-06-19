# Purpose: Export remote computer uptime and reachability.
param(
    [string]$ComputerList = ".\computers.txt"
)

$results = foreach ($c in Get-Content $ComputerList) {
    try {
        # Query remote OS data; failures are captured as unreachable rows.
        $os = Get-CimInstance Win32_OperatingSystem -ComputerName $c -ErrorAction Stop
        $uptime = (Get-Date) - $os.LastBootUpTime
        [pscustomobject]@{
            Computer = $c
            Reachable = $true
            LastBoot = $os.LastBootUpTime
            UptimeDays = [math]::Round($uptime.TotalDays,2)
        }
    } catch {
        [pscustomobject]@{
            Computer = $c
            Reachable = $false
            LastBoot = $null
            UptimeDays = $null
        }
    }
}

$results | Export-Csv ".\RemoteUptimeReport.csv" -NoTypeInformation
Write-Host "Exported to RemoteUptimeReport.csv"