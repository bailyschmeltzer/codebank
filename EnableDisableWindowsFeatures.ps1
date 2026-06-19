# Enable/Disable Windows Features
# Quickly enable or disable Windows optional features

param(
    [Parameter(Mandatory=$true)]
    [string]$FeatureName,
    [ValidateSet('Enable', 'Disable')]
    [string]$Action = 'Enable'
)

Write-Host "Windows Feature: $FeatureName" -ForegroundColor Green
Write-Host "Action: $Action" -ForegroundColor Cyan

try {
    if ($Action -eq 'Enable') {
        Enable-WindowsOptionalFeature -FeatureName $FeatureName -Online -NoRestart
        Write-Host "Feature enabled successfully" -ForegroundColor Green
    } else {
        Disable-WindowsOptionalFeature -FeatureName $FeatureName -Online -NoRestart
        Write-Host "Feature disabled successfully" -ForegroundColor Green
    }
} catch {
    Write-Error "Failed to $($Action.ToLower()) feature: $_"
}

# List available features
Write-Host "`nCommon Windows Features:" -ForegroundColor Cyan
Get-WindowsOptionalFeature -Online | Where-Object {$_.FeatureName -match 'IIS|Hyper|RDS|Telnet'} | Format-Table FeatureName, State
