# Get All Enabled Users in All Groups and Export to CSV
# This script gets enabled users and groups them by group membership

$enabledUsers = Get-ADUser -Filter * | Where-Object {$_.enabled -eq $true}

Get-ADGroup -Filter * | ForEach-Object {
    $group = $_
    Get-ADGroupMember -Identity $_.DistinguishedName | 
        Add-Member -NotePropertyName Group -NotePropertyValue $group.name -Force -PassThru
} | 
    Where-Object {$_.DistinguishedName -in $enabledUsers.DistinguishedName} | 
    Select-Object Group, Name | 
    Export-Csv -NoTypeInformation -Path C:\Reports\Users-Accounts.csv

Write-Host "Export complete: C:\Reports\Users-Accounts.csv"
