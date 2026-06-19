# Find and List Stale User Accounts
# Identify user accounts that haven't been used in a specified number of days

param(
    [int]$Days = 60,
    [string]$SearchBase = (Get-ADDomain).DistinguishedName
)

$staleDate = (Get-Date).AddDays(-$Days)
$staleUsers = Get-ADUser -Filter {LastLogonDate -lt $staleDate} `
    -SearchBase $SearchBase `
    -Properties LastLogonDate, PasswordLastSet, DistinguishedName |
    Sort-Object -Property LastLogonDate

$staleUsers | Format-Table @(
    'Name'
    'SamAccountName'
    @{Name='LastLogonDate'; Expression={$_.LastLogonDate.ToShortDateString()}}
    @{Name='PasswordLastSet'; Expression={$_.PasswordLastSet.ToShortDateString()}}
) -AutoSize

Write-Host "Found $($staleUsers.Count) stale user accounts (not logged in for $Days days)"

# Optional: Export to CSV
# $staleUsers | Select-Object Name, SamAccountName, LastLogonDate | Export-Csv -Path "C:\Reports\StaleUsers.csv" -NoTypeInformation
