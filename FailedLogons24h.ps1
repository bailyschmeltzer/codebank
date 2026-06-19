# Purpose: Export failed logon events from the last 24 hours.
$since = (Get-Date).AddHours(-24)
# Event ID 4625 captures failed sign-in attempts from the Security log.
Get-WinEvent -FilterHashtable @{
    LogName = "Security"
    Id = 4625
    StartTime = $since
} -ErrorAction SilentlyContinue |
Select-Object TimeCreated,
    @{Name="User";Expression={$_.Properties[5].Value}},
    @{Name="Workstation";Expression={$_.Properties[13].Value}},
    @{Name="SourceIP";Expression={$_.Properties[19].Value}},
    @{Name="Status";Expression={$_.Properties[7].Value}} |
Export-Csv ".\FailedLogons_Last24h.csv" -NoTypeInformation

Write-Host "Exported to FailedLogons_Last24h.csv"