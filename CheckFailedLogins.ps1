# Check and Report Failed Logins
# Reports failed login attempts in the past 24 hours

param(
    [int]$HoursBack = 24,
    [int]$Threshold = 5  # Alert if failed attempts exceed this
)

$startTime = (Get-Date).AddHours(-$HoursBack)

try {
    $failedLogins = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        ID = 4625  # Failed login event
        StartTime = $startTime
    } -ErrorAction SilentlyContinue
    
    $loginStats = $failedLogins | 
        Select-Object @{Name='Username'; Expression={$_.Properties[5].Value}} |
        Group-Object -Property Username |
        Select-Object @(
            'Name'
            @{Name='Count'; Expression={$_.Count}}
            @{Name='Status'; Expression={if($_.Count -gt $Threshold) { 'ALERT' } else { 'OK' }}}
        )
    
    Write-Host "Failed Login Attempts (last $HoursBack hours):"
    $loginStats | Format-Table -AutoSize
    
    $alertAccounts = $loginStats | Where-Object {$_.Status -eq 'ALERT'}
    if ($alertAccounts) {
        Write-Warning "Accounts with multiple failed attempts: $($alertAccounts.Name -join ', ')"
    }
    
} catch {
    Write-Error "Error retrieving security events: $_"
}
