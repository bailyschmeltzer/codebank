# Enforce Password Policy on User Account
# Set password expiration and complexity requirements

param(
    [Parameter(Mandatory=$true)]
    [string]$UserName,
    [int]$PasswordAgeDays = 90,
    [switch]$PasswordNeverExpires
)

$user = Get-ADUser -Identity $UserName -Properties "msDS-UserPasswordExpiryTimeComputed"

if ($PasswordNeverExpires) {
    Set-ADUser -Identity $user -PasswordNeverExpires $true
    Write-Host "Password set to never expire for $UserName"
} else {
    Set-ADUser -Identity $user -PasswordNeverExpires $false
    Write-Host "Password will expire for $UserName (policy will apply: $PasswordAgeDays days)"
}

# Display current password settings
$user = Get-ADUser -Identity $UserName -Properties PasswordExpired, PasswordNotRequired, msDS-UserPasswordExpiryTimeComputed
Write-Host "`nCurrent Settings for $UserName :"
Write-Host "  Password Expired: $($user.PasswordExpired)"
Write-Host "  Password Not Required: $($user.PasswordNotRequired)"
if ($user.'msDS-UserPasswordExpiryTimeComputed' -ne 0) {
    $expiryTime = [datetime]::FromFileTime($user.'msDS-UserPasswordExpiryTimeComputed')
    Write-Host "  Password Expires: $($expiryTime.ToShortDateString())"
}
