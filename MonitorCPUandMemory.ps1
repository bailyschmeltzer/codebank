# Monitor CPU and Memory Usage on Remote Servers
# Get real-time performance metrics from multiple computers

param(
    [Parameter(Mandatory=$true)]
    [string[]]$ComputerNames,
    [int]$Threshold = 80  # Alert if usage exceeds threshold
)

$performanceData = @()

ForEach ($computer in $ComputerNames) {
    try {
        $cpuUsage = Get-WmiObject Win32_Processor -ComputerName $computer | 
            Measure-Object -Property LoadPercentage -Average | 
            Select-Object -ExpandProperty Average
        
        $memory = Get-WmiObject Win32_LogicalMemoryConfiguration -ComputerName $computer
        $totalMemory = $memory.TotalPhysicalMemory / 1MB
        
        $usedMemory = (Get-WmiObject Win32_OperatingSystem -ComputerName $computer | 
            Select-Object -ExpandProperty TotalVisibleMemorySize) - (Get-WmiObject Win32_OperatingSystem -ComputerName $computer | 
            Select-Object -ExpandProperty FreePhysicalMemory)
        
        $memoryPercent = ($usedMemory / $totalMemory) * 100
        
        $performanceData += [PSCustomObject]@{
            ComputerName = $computer
            CPUPercent = [math]::Round($cpuUsage, 2)
            MemoryPercent = [math]::Round($memoryPercent, 2)
            CPUStatus = if ($cpuUsage -gt $Threshold) { 'HIGH' } else { 'OK' }
            MemoryStatus = if ($memoryPercent -gt $Threshold) { 'HIGH' } else { 'OK' }
        }
    } catch {
        Write-Warning "Failed to connect to $computer : $_"
    }
}

$performanceData | Format-Table -AutoSize
