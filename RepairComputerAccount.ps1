# Repair Computer Account in Active Directory
# Verifies and repairs the secure channel between computer and domain controller

$Domain = Read-Host "Enter Netbios domain name"
$admin = Read-Host "Enter Administrator User name"
$PasswordText = Read-Host "Enter the administrator Password"
$password = ConvertTo-SecureString $PasswordText -AsPlainText -Force
$DomainController = Read-Host "Enter the Name of the Domain Controller"

$credential = New-Object System.Management.Automation.PSCredential ("$domain\$admin", $password)
Test-ComputerSecureChannel -Repair -Server $DomainController -Credential $credential
