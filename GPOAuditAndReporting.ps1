# GPO Audit and Reporting
# List all Group Policies and their settings

param(
    [string]$Domain = $env:USERDOMAIN
)

Write-Host "Scanning Group Policies in domain: $Domain" -ForegroundColor Green

try {
    # Get all GPOs
    $gpos = Get-GPO -All -Domain $Domain
    
    $gpoInfo = ForEach ($gpo in $gpos) {
        [PSCustomObject]@{
            DisplayName = $gpo.DisplayName
            ID = $gpo.Id
            Owner = $gpo.Owner
            CreationTime = $gpo.CreationTime
            ModificationTime = $gpo.ModificationTime
            Status = 'Present'
        }
    }
    
    Write-Host "Found $($gpoInfo.Count) Group Policies" -ForegroundColor Cyan
    $gpoInfo | Format-Table -AutoSize
    
    # Export to CSV
    # $gpoInfo | Export-Csv -Path "C:\Reports\GPOAudit_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation
    
} catch {
    Write-Error "Failed to retrieve GPO information: $_"
}
