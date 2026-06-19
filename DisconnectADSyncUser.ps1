# Disconnect AD Sync User from Azure AD
# After removing user from sync group, run this to prevent reconnection
# CRITICAL: Use quotes around "$NULL" or [string]::Empty

$userprincipalName = Read-Host "Enter User Principal Name (e.g., user@domain.com)"
get-msoluser -UserPrincipalName $userprincipalName | Set-MsolUser -ImmutableId "$Null"

Write-Host "User $userprincipalName disconnected from Azure AD sync"
