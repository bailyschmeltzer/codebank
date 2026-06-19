# Purpose: Export local Administrators group membership.
# PrincipalSource helps distinguish local, domain, and Microsoft account entries.
Get-LocalGroupMember -Group "Administrators" |
Select-Object Name, ObjectClass, PrincipalSource |
Export-Csv ".\LocalAdmins.csv" -NoTypeInformation

Write-Host "Exported to LocalAdmins.csv"