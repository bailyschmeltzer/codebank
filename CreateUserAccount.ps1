# Create User Account with Settings
# Quickly create new AD user with standard configuration

param(
    [Parameter(Mandatory=$true)]
    [string]$FirstName,
    [Parameter(Mandatory=$true)]
    [string]$LastName,
    [Parameter(Mandatory=$true)]
    [string]$Department,
    [Parameter(Mandatory=$true)]
    [string]$Manager,
    [string]$OUPath = (Get-ADOrganizationalUnit -Filter {Name -eq 'Users'}).DistinguishedName
)

$displayName = "$FirstName $LastName"
$samAccountName = "$($FirstName.Substring(0,1))$($LastName)".ToLower()
$userPrincipalName = "$samAccountName@$((Get-ADDomain).DNSRoot)"
$tempPassword = [System.Web.Security.Membership]::GeneratePassword(12, 3)

try {
    # Create new user
    New-ADUser -Name $displayName `
        -GivenName $FirstName `
        -Surname $LastName `
        -SamAccountName $samAccountName `
        -UserPrincipalName $userPrincipalName `
        -Path $OUPath `
        -Department $Department `
        -Manager $Manager `
        -AccountPassword (ConvertTo-SecureString $tempPassword -AsPlainText -Force) `
        -Enabled $true `
        -ChangePasswordAtLogon $true
    
    Write-Host "User created successfully" -ForegroundColor Green
    Write-Host "  Display Name: $displayName"
    Write-Host "  SAM Account: $samAccountName"
    Write-Host "  UPN: $userPrincipalName"
    Write-Host "  Temporary Password: $tempPassword"
    Write-Host "  Department: $Department"
    Write-Host "  OU: $OUPath"
    
} catch {
    Write-Error "Failed to create user: $_"
}
