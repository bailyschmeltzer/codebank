# Backup Active Directory to CSV
# Full backup of all AD users and computers

param(
    [string]$BackupPath = "C:\AD_Backups",
    [string]$SearchBase = (Get-ADDomain).DistinguishedName
)

if (-not (Test-Path $BackupPath)) {
    New-Item -ItemType Directory -Path $BackupPath -Force
}

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'

# Backup All Users
Write-Host "Backing up Active Directory users..."
$users = Get-ADUser -Filter * -SearchBase $SearchBase -Properties *
$users | Select-Object Name, SamAccountName, UserPrincipalName, EmailAddress, Department, Title, Manager, Enabled |
    Export-Csv -Path "$BackupPath\AD_Users_$timestamp.csv" -NoTypeInformation

# Backup All Computers
Write-Host "Backing up Active Directory computers..."
$computers = Get-ADComputer -Filter * -SearchBase $SearchBase -Properties *
$computers | Select-Object Name, SamAccountName, OperatingSystem, LastLogonDate, Enabled |
    Export-Csv -Path "$BackupPath\AD_Computers_$timestamp.csv" -NoTypeInformation

# Backup All Groups
Write-Host "Backing up Active Directory groups..."
$groups = Get-ADGroup -Filter * -SearchBase $SearchBase -Properties *
$groups | Select-Object Name, SamAccountName, GroupCategory, GroupScope, Description |
    Export-Csv -Path "$BackupPath\AD_Groups_$timestamp.csv" -NoTypeInformation

Write-Host "Backup complete:"
Write-Host "  Users: $($users.Count)"
Write-Host "  Computers: $($computers.Count)"
Write-Host "  Groups: $($groups.Count)"
Write-Host "  Location: $BackupPath"
