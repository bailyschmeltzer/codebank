# Start or stop an application based on business-hours schedule.
# Replace values in the configuration section as needed.

$now = Get-Date
$day = $now.DayOfWeek
$hour = $now.Hour

# Configuration
$processName = "YourProcessName"        # Example: SGNConnect
$appLaunchPath = "C:\Path\To\YourApp.lnk"
$officeDays = @("Monday", "Wednesday", "Friday")
$startHour = 8
$endHour = 17

$isOfficeDay = $officeDays -contains [string]$day
$isOfficeTime = ($hour -ge $startHour -and $hour -lt $endHour)

if ($isOfficeDay -and $isOfficeTime) {
    Get-Process -ErrorAction SilentlyContinue |
        Where-Object { $_.ProcessName -like "*$processName*" } |
        Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "Stopped process pattern: $processName"
}
else {
    if (-not (Get-Process -Name $processName -ErrorAction SilentlyContinue)) {
        Start-Process $appLaunchPath
        Write-Host "Started application: $appLaunchPath"
    }
    else {
        Write-Host "$processName is already running."
    }
}
