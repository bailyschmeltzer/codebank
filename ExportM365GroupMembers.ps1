# Export M365 Group Members
# Get all Microsoft 365 groups and their members

Connect-AzureAD -ErrorAction Stop

$groups = Get-AzureADGroup -Filter "mailEnabled eq true"
$groupMembers = @()

ForEach ($group in $groups) {
    $members = Get-AzureADGroupMember -ObjectId $group.ObjectId
    
    ForEach ($member in $members) {
        $groupMembers += [PSCustomObject]@{
            GroupName = $group.DisplayName
            GroupEmail = $group.Mail
            MemberName = $member.DisplayName
            MemberEmail = $member.Mail
            MemberType = $member.ObjectType
        }
    }
}

$groupMembers | Format-Table -AutoSize

# Export to CSV
$exportPath = "C:\Reports\M365GroupMembers_$(Get-Date -Format 'yyyyMMdd').csv"
$groupMembers | Export-Csv -Path $exportPath -NoTypeInformation
Write-Host "Exported to: $exportPath"
