# Bulk Reset User Passwords
# Reset passwords for selected users and send temporary credentials

param(
    [string]$OutputPath = "C:\Reports\PasswordReset_$(Get-Date -Format 'yyyyMMdd').csv"
)

$users = Get-ADUser -Filter * | Out-GridView -PassThru -Title "Select users to reset passwords"

if (-not $users) {
    Write-Host "No users selected"
    exit
}

$passwordResets = @()

ForEach ($user in $users) {
    $tempPassword = [System.Web.Security.Membership]::GeneratePassword(12, 3)
    
    try {
        Set-ADAccountPassword -Identity $user.SamAccountName -NewPassword (ConvertTo-SecureString $tempPassword -AsPlainText -Force) -Reset
        Set-ADUser -Identity $user.SamAccountName -ChangePasswordAtLogon $true
        
        $passwordResets += [PSCustomObject]@{
            Username = $user.SamAccountName
            DisplayName = $user.Name
            Email = $user.EmailAddress
            TemporaryPassword = $tempPassword
            ResetTime = Get-Date
            Status = 'Success'
        }
        
        Write-Host "Reset password for $($user.SamAccountName)" -ForegroundColor Green
    } catch {
        Write-Host "Failed to reset password for $($user.SamAccountName): $_" -ForegroundColor Red
    }
}

# Export to CSV
$passwordResets | Export-Csv -Path $OutputPath -NoTypeInformation
Write-Host "Password resets exported to: $OutputPath"
