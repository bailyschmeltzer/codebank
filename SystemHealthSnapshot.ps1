# Purpose: Output a quick system health and performance snapshot.
$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor
$drives = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"

$uptime = (Get-Date) - $os.LastBootUpTime
$memTotalGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
$memFreeGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)

Write-Host "Computer: $env:COMPUTERNAME"
Write-Host "OS: $($os.Caption) $($os.Version)"
Write-Host "Uptime: $($uptime.Days) days $($uptime.Hours) hours"
Write-Host "CPU: $($cpu.Name)"
Write-Host "Memory: $memFreeGB GB free / $memTotalGB GB total"
Write-Host ""
Write-Host "Disk Free Space:"
# Summarize fixed-disk capacity and free space in GB.
$drives | Select-Object DeviceID,
    @{Name="SizeGB";Expression={[math]::Round($_.Size/1GB,2)}},
    @{Name="FreeGB";Expression={[math]::Round($_.FreeSpace/1GB,2)}} |
    Format-Table -AutoSize

Write-Host ""
Write-Host "Top 10 Processes by CPU:"
# Surface currently expensive processes for quick triage.
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, Id, CPU, WS |
    Format-Table -AutoSize