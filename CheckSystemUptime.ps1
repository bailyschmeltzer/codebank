# Check System Uptime
# Reports uptime for local and remote computers

param(
    [string[]]$ComputerNames = @($env:COMPUTERNAME)
)

$uptimeInfo = @()

ForEach ($computer in $ComputerNames) {
    try {
        $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computer -ErrorAction Stop
        $lastBootTime = [Management.ManagementDateTimeConverter]::ToDateTime($os.LastBootUpTime)
        $uptime = (Get-Date) - $lastBootTime
        
        $uptimeInfo += [PSCustomObject]@{
            ComputerName = $computer
            LastBootTime = $lastBootTime
            UptimeDays = [math]::Round($uptime.TotalDays, 2)
            UptimeHours = [math]::Round($uptime.TotalHours, 2)
            OperatingSystem = $os.Caption
        }
    } catch {
        Write-Warning "Failed to get uptime from $computer : $_"
    }
}

$uptimeInfo | Format-Table -AutoSize
