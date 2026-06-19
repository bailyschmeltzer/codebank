# Purpose: Export enabled AD users to CSV for mailbox audit.
$ExportPath = ‘c:\adusers_list.csv’

# Export core identity fields for follow-on mailbox review.
Get-ADUser -Filter 'enabled -eq $true' | Select-object DistinguishedName,Name,UserPrincipalName | Export-Csv -NoType $ExportPath