$ExportPath = ‘c:\adusers_list.csv’

Get-ADUser -Filter 'enabled -eq $true' | Select-object DistinguishedName,Name,UserPrincipalName | Export-Csv -NoType $ExportPath