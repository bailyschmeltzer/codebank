# Get Windows Update History
# Reports installed updates and pending updates

param(
    [string]$ComputerName = $env:COMPUTERNAME,
    [int]$LastDays = 30
)

Write-Host "=== Windows Update History for $ComputerName ===" -ForegroundColor Green

try {
    # Get Installed Updates
    $installed = Get-HotFix -ComputerName $ComputerName | 
        Where-Object {$_.InstalledOn -gt (Get-Date).AddDays(-$LastDays)} |
        Sort-Object -Property InstalledOn -Descending
    
    Write-Host "`nRecent Updates (last $LastDays days): $($installed.Count)" -ForegroundColor Cyan
    $installed | Format-Table HotFixId, Description, @{Name='InstalledOn'; Expression={$_.InstalledOn.ToShortDateString()}} -AutoSize
    
} catch {
    Write-Warning "Could not retrieve update history from $ComputerName : $_"
}

# Check for Pending Updates (Windows Update Agent)
try {
    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()
    $pendingUpdates = $updateSearcher.Search("IsInstalled=0")
    
    Write-Host "`nPending Updates: $($pendingUpdates.Updates.Count)" -ForegroundColor Cyan
    if ($pendingUpdates.Updates.Count -gt 0) {
        $pendingUpdates.Updates | Select-Object @{Name='Title'; Expression={$_.Title}} | Format-Table
    }
    
} catch {
    Write-Warning "Could not check for pending updates: $_"
}
