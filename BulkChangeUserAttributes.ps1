# Bulk Change User Attributes
# Modify multiple user properties at once

param(
    [string[]]$UserNames,
    [string]$Department,
    [string]$Title,
    [string]$Office,
    [string]$Manager
)

if (-not $UserNames) {
    $UserNames = @((Get-ADUser -Filter * | Out-GridView -PassThru -Title "Select users to modify").SamAccountName)
}

if (-not $UserNames) {
    Write-Host "No users selected"
    exit
}

$updateCount = 0

ForEach ($username in $UserNames) {
    try {
        $updateParams = @{Identity = $username}
        
        if ($Department) { $updateParams['Department'] = $Department }
        if ($Title) { $updateParams['Title'] = $Title }
        if ($Office) { $updateParams['Office'] = $Office }
        if ($Manager) { $updateParams['Manager'] = $Manager }
        
        Set-ADUser @updateParams
        Write-Host "Updated: $username" -ForegroundColor Green
        $updateCount++
        
    } catch {
        Write-Warning "Failed to update $username : $_"
    }
}

Write-Host "`nTotal users updated: $updateCount" -ForegroundColor Green
