# Monitor Disk Space and Alert when Low
# Checks all fixed drives and reports usage percentage

$drives = Get-Volume | Where-Object {$_.DriveType -eq 'Fixed'}
$threshold = 85  # Alert if usage exceeds 85%

$driveInfo = ForEach ($drive in $drives) {
    $usagePercent = ($drive.SizeRemaining / $drive.Size) * 100
    [PSCustomObject]@{
        DriveLetter = $drive.DriveLetter
        Size_GB = [math]::Round($drive.Size / 1GB, 2)
        Used_GB = [math]::Round(($drive.Size - $drive.SizeRemaining) / 1GB, 2)
        Free_GB = [math]::Round($drive.SizeRemaining / 1GB, 2)
        UsagePercent = [math]::Round((100 - $usagePercent), 2)
        Status = if ((100 - $usagePercent) -gt $threshold) { 'CRITICAL' } else { 'OK' }
    }
}

$driveInfo | Format-Table

# Alert on critical drives
$criticalDrives = $driveInfo | Where-Object {$_.Status -eq 'CRITICAL'}
if ($criticalDrives) {
    Write-Warning "Critical disk space on: $($criticalDrives.DriveLetter -join ', ')"
}
