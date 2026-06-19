# Export Exchange distribution group membership to CSV.

# Optional: specify admin UPN when needed
# Connect-ExchangeOnline -UserPrincipalName admin@contoso.onmicrosoft.com
Connect-ExchangeOnline

$groups = Get-DistributionGroup -ResultSize Unlimited
$results = @()

foreach ($group in $groups) {
    Write-Host "Processing group: $($group.DisplayName)" -ForegroundColor Cyan

    $members = Get-DistributionGroupMember -Identity $group.Identity -ResultSize Unlimited -ErrorAction SilentlyContinue

    if ($members) {
        foreach ($member in $members) {
            $results += [PSCustomObject]@{
                GroupName = $group.DisplayName
                GroupEmail = $group.PrimarySmtpAddress
                MemberName = $member.Name
                MemberEmail = $member.PrimarySmtpAddress
                MemberType = $member.RecipientType
            }
        }
    }
    else {
        $results += [PSCustomObject]@{
            GroupName = $group.DisplayName
            GroupEmail = $group.PrimarySmtpAddress
            MemberName = "<No Members>"
            MemberEmail = ""
            MemberType = ""
        }
    }
}

$outputPath = "$env:USERPROFILE\Documents\O365_Group_Members.csv"
$results | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8
Write-Host "Export complete: $outputPath" -ForegroundColor Green
